# Display-Menu Backend Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Render every menu through native `tmux display-menu`, falling back to
the fzf picker only when a list is too tall for a menu to display at all.

**Architecture:** A new `lib/menu.sh` owns all `display-menu` argv, mirroring
how `lib/picker.sh` owns fzf's. Because `display-menu` runs a command rather
than returning a selection, every caller splits into a *list* half and an
*act* half, and both backends drive the same act half.

**Tech Stack:** bash 3.2, tmux `display-menu`, fzf, bats, shellcheck.

**Spec:** `docs/superpowers/specs/2026-09-06-display-menu-backend-design.md`

## Global Constraints

- bash 3.2 compatible. `${1+"${@}"}` for possibly-empty argv under `nounset`.
- `set -o errexit`, `set -o nounset`, `set -o pipefail` in every script.
- Package header block (`name - one line`, `Usage:`, `Arguments:`, `Example:`)
  and `help_wanted ${1+"${@}"}` before `main` in every script.
- Google Shell Style `#####` comment blocks on every function.
- `lib/picker.sh` stays the only place fzf argv is built. `lib/menu.sh`
  becomes the only place `display-menu` argv is built.
- Values crossing into a `run-shell` command are escaped twice: `printf '%q'`
  for the shell, then `menu_tmux_quote` for tmux's own parser.
- New scripts go in `SHELL_SCRIPTS` in `scripts/scripts/Makefile` in the same
  task that creates them.
- No em dashes. Plain `-`.
- `make test` and `make lint` from `scripts/scripts/` before every commit,
  judged by **exit status**, not by reading output tails.
- Redirect with `>|` — the shell has `noclobber` set and plain `>` silently
  refuses to overwrite, which has already caused stale results to be reported
  as fresh.

## Verified before planning

- Separator via an empty item name: probed against a real tmux, works.
- `-b border-lines`, `-x C -y C` (C is "centre of the terminal"), `-T` as a
  **format** (so `#[align=centre]` is valid), `-H`/`-s`/`-S` styles: all
  documented in `man tmux`.
- `display-menu` blocks while a menu is open, so probes cannot be batched in
  one script. Anything else about it gets verified against a live client, not
  asserted.

---

## File Structure

**Create:**
- `scripts/scripts/lib/menu.sh` — `display-menu` argv, fit test, backend choice
- `scripts/scripts/tests/menu_lib.bats`

**Modify:**
- `scripts/scripts/fzf-menu` — `--run` act mode, backend-aware `--popup`
- `scripts/scripts/wt-pick`, `pr-pick`, `sc-pick` — `--act`, via `menu_or_pick`
- `scripts/scripts/common.sh` — source `lib/menu.sh`
- `scripts/scripts/tests/{fzf_menu,wt_pick,pr_pick,sc_pick}.bats`
- `scripts/scripts/tests/manual/verify-menu-fit` — a `--menu` mode
- `CLAUDE.md`, `scripts/scripts/CLAUDE.md`

---

## Task 1: `lib/menu.sh` — fit test

**Files:**
- Create: `scripts/scripts/lib/menu.sh`
- Modify: `scripts/scripts/common.sh`
- Test: `scripts/scripts/tests/menu_lib.bats` (create)

**Interfaces:**
- Consumes: `lib/output.sh`
- Produces:
  - `MENU_CHROME_ROWS` — rows a menu costs beyond its items
  - `menu_client_height` — client height, or empty when unmeasurable
  - `menu_fits <count>` — 0 when a menu of that many items will display

**Context:** `man tmux`: "If the menu is too large to fit on the terminal, it
is not displayed." No scroll, no truncation, no error. So an unmeasurable
height must count as "does not fit" — falling back to fzf is always safe, a
blank menu never is.

`MENU_CHROME_ROWS` starts at 4 (border 2, title 1, one row of slack) and is
**deliberately generous**: overestimating falls back to fzf a little early,
underestimating blanks a full menu. Task 9 measures it.

- [ ] **Step 1: Write the failing tests**

Create `scripts/scripts/tests/menu_lib.bats`:

```bash
#!/usr/bin/env bats

load helper

setup() {
  setup_tmux_stub
  source "${BATS_TEST_DIRNAME}/../lib/menu.sh"
}

@test "a short list fits a tall client" {
  export TMUX_STUB_CLIENT_HEIGHT=40
  run menu_fits 6
  [ "${status}" -eq 0 ]
}

@test "a list taller than the client does not fit" {
  export TMUX_STUB_CLIENT_HEIGHT=10
  run menu_fits 60
  [ "${status}" -ne 0 ]
}

# The boundary is the whole point: one row short blanks the menu rather than
# shrinking it, so the comparison has to include the chrome.
@test "the chrome counts against the height" {
  export TMUX_STUB_CLIENT_HEIGHT=10
  run menu_fits $((10 - MENU_CHROME_ROWS))
  [ "${status}" -eq 0 ]
  run menu_fits $((10 - MENU_CHROME_ROWS + 1))
  [ "${status}" -ne 0 ]
}

# An unmeasurable height must not be treated as unlimited.
@test "an unmeasurable client height does not fit" {
  export TMUX_STUB_CLIENT_HEIGHT=""
  run menu_fits 1
  [ "${status}" -ne 0 ]
}

@test "a non-numeric client height does not fit" {
  export TMUX_STUB_CLIENT_HEIGHT="not-a-number"
  run menu_fits 1
  [ "${status}" -ne 0 ]
}

@test "menu_client_height reports what tmux says" {
  export TMUX_STUB_CLIENT_HEIGHT=33
  run menu_client_height
  [ "${output}" = "33" ]
}
```

- [ ] **Step 2: Teach the tmux stub about client_height**

`tests/stubs/tmux` keys `display-message` on the requested format. Add a
branch **above** the existing `*client_height*|*client_width*` one, because
that branch answers with a `"rows cols"` pair for a different query and would
otherwise claim this one:

```bash
      *'#{client_height}'*)
        # A lone client_height query, distinct from the "height width" pair
        # the existing branch answers. ${VAR-default}, not ${VAR:-default}:
        # an explicitly empty value is the unmeasurable case and must survive.
        printf '%s\n' "${TMUX_STUB_CLIENT_HEIGHT-40}"
        ;;
```

- [ ] **Step 3: Run the tests to verify they fail**

Run: `cd scripts/scripts && bats tests/menu_lib.bats`
Expected: FAIL on `lib/menu.sh: No such file or directory`.

- [ ] **Step 4: Write the library**

Create `scripts/scripts/lib/menu.sh`:

```bash
#!/usr/bin/env bash
#
# lib/menu.sh - native tmux display-menu rendering
#
# Owns every `display-menu` invocation's argv in this package, the way
# lib/picker.sh owns fzf's: item construction, key assignment, quoting, and
# the fit test that decides which backend a caller gets.
#
# Rows are TAB-delimited "value<TAB>label", the same shape lib/picker.sh
# consumes, so a caller can hand the same rows to either backend.
#
# Usage:
#   source "${SCRIPT_DIR}/lib/menu.sh"
#   printf 'run-me\tAlpha\n' | menu_show "Title" "$(printf '%q' "${0}") --act go"

[[ -n "${__LIB_MENU_LOADED:-}" ]] && return
readonly __LIB_MENU_LOADED=1

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/output.sh"

# Rows a menu costs on top of its items: two for the border, one for the
# title, and one of slack so a menu never lands exactly on the limit.
#
# Deliberately generous. `man tmux`: "If the menu is too large to fit on the
# terminal, it is not displayed" - no scrolling, no truncation, no error.
# Overestimating falls back to fzf slightly early; underestimating shows the
# user nothing at all and looks like a broken keybinding.
readonly MENU_CHROME_ROWS=4

#######################################
# Height of the attached client, in rows.
# Outputs:
#   The height to stdout, or nothing when it cannot be measured
#######################################
menu_client_height() {
  local height
  height="$(tmux display-message -p '#{client_height}' 2>/dev/null || true)"
  case "${height}" in
    ''|*[!0-9]*) printf '' ;;
    *)           printf '%s' "${height}" ;;
  esac
}

#######################################
# Whether a menu of this many items will actually be displayed.
#
# An unmeasurable height counts as "does not fit": the fzf fallback always
# works, a blank menu never does.
# Arguments:
#   Item count
# Returns:
#   0 if it fits, 1 otherwise
#######################################
menu_fits() {
  local count="${1}"
  local height
  height="$(menu_client_height)"
  [ -n "${height}" ] || return 1
  [ "$((count + MENU_CHROME_ROWS))" -le "${height}" ]
}
```

- [ ] **Step 5: Source it from `common.sh`**

Add to the doc comment block in `scripts/scripts/common.sh`:

```
#   source "${SCRIPT_DIR}/lib/menu.sh"     - display-menu rendering and the fit test
```

and the source line after `worktree.sh`:

```bash
source "${_COMMON_LIB_DIR}/menu.sh"
```

- [ ] **Step 6: Run the tests and lint**

Run: `cd scripts/scripts && bats tests/menu_lib.bats && make test && make lint`
Expected: all exit 0. `lib/menu.sh` is covered by the existing
`$(wildcard lib/*.sh)`, so the Makefile needs no edit.

- [ ] **Step 7: Commit**

```bash
git add scripts/scripts/lib/menu.sh scripts/scripts/common.sh \
        scripts/scripts/tests/menu_lib.bats scripts/scripts/tests/stubs/tmux
git commit -m "feat(menus): add the display-menu fit test

A menu too tall for the terminal is not displayed at all - no scroll, no
truncation, no error. So the backend choice is a measurement, and an
unmeasurable height counts as does-not-fit because falling back to fzf is
always safe."
```

---

## Task 2: `menu_show`

**Files:**
- Modify: `scripts/scripts/lib/menu.sh`
- Test: `scripts/scripts/tests/menu_lib.bats`

**Interfaces:**
- Consumes: Task 1's constants
- Produces:
  - `menu_tmux_quote <string>` — single-quote a string for tmux's parser
  - `menu_show <title> <act-prefix>` — read `value<TAB>label` rows on stdin
    and display them; each item runs `<act-prefix> <value>`

**Context:** Two quoting layers. The value must survive the **shell** inside
`run-shell` (`printf '%q'`), and the whole command must survive **tmux's own**
parser (single quotes, with embedded quotes escaped). Getting either wrong
means a path with a space silently acts on the wrong thing.

Item names are **not numbered**: tmux renders the key at the end of the line
itself, so numbering the label shows the number twice.

- [ ] **Step 1: Write the failing tests**

Append to `scripts/scripts/tests/menu_lib.bats`:

```bash
@test "the label is the item name, unnumbered" {
  printf 'v1\tFetch\nv2\tStatus\n' | menu_show "Git" "act"
  run tmux_call_args display-menu
  [[ "${output}" == *"Fetch"* ]]
  [[ "${output}" != *"1 Fetch"* ]]
}

# tmux renders the key at the end of the item line, so the key belongs in the
# key argument and not in the label.
@test "the first nine items get digit keys" {
  printf 'v1\tOne\nv2\tTwo\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  printf '%s\n' "${output}" | assert_arg_after "One" "1"
  printf '%s\n' "${output}" | assert_arg_after "Two" "2"
}

@test "items past the ninth get an empty key" {
  local i
  for i in $(seq 1 11); do printf 'v%s\tItem%s\n' "${i}" "${i}"; done \
    | menu_show "T" "act"
  run tmux_call_args display-menu
  printf '%s\n' "${output}" | assert_arg_after "Item9" "9"
  printf '%s\n' "${output}" | assert_arg_after "Item10" ""
}

@test "each item runs the act prefix with its value" {
  printf 'the-value\tOne\n' | menu_show "T" "wt-pick --act switch"
  run tmux_call_args display-menu
  [[ "${output}" == *"run-shell"* ]]
  [[ "${output}" == *"wt-pick --act switch"* ]]
  [[ "${output}" == *"the-value"* ]]
}

# A worktree path with a space in it must act on that path, not on its first
# word. This is the assertion that pins both quoting layers.
@test "a value containing spaces survives into the command" {
  printf '/tmp/two words\tOne\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  [[ "${output}" == *"two words"* ]]
}

@test "a value containing a single quote survives" {
  printf "/tmp/it's\tOne\n" | menu_show "T" "act"
  run tmux_call_args display-menu
  [[ "${output}" == *"it"* ]]
}

@test "a dash label becomes a separator with no key or command" {
  printf 'v1\tOne\nignored\t-\nv2\tTwo\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  [[ "${output}" == *"One"* ]]
  [[ "${output}" == *"Two"* ]]
}

# display-menu treats a leading hyphen as "disabled item", and its own options
# start with one too, so argv needs a -- terminator.
@test "options are terminated so a label may start with a hyphen" {
  printf 'v1\t-Not selectable\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  [[ "${output}" == *"--"* ]]
}

@test "the title goes in -T, not into an item" {
  printf 'v1\tOne\n' | menu_show "Git actions" "act"
  run tmux_call_args display-menu
  printf '%s\n' "${output}" | assert_arg_after "-T" "#[align=centre] Git actions "
}

@test "the menu is centred and given a border style" {
  printf 'v1\tOne\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  printf '%s\n' "${output}" | assert_arg_after "-x" "C"
  printf '%s\n' "${output}" | assert_arg_after "-y" "C"
  printf '%s\n' "${output}" | assert_arg_after "-b" "rounded"
}

@test "no rows means no menu" {
  run bash -c "source '${BATS_TEST_DIRNAME}/../lib/menu.sh'; printf '' | menu_show T act"
  refute_tmux_subcommand display-menu
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `cd scripts/scripts && bats tests/menu_lib.bats`
Expected: FAIL with `menu_show: command not found`.

- [ ] **Step 3: Add the quoting helper**

Append to `scripts/scripts/lib/menu.sh`:

```bash
#######################################
# Single-quote a string for tmux's command parser.
#
# The command handed to display-menu is parsed by TMUX first and by the shell
# second, so a value crosses two parsers. This covers the tmux one; the caller
# uses printf '%q' for the shell. Embedded single quotes are closed, escaped
# and reopened, which is the same idiom a POSIX shell needs.
# Arguments:
#   The string to quote
# Outputs:
#   The quoted string to stdout
#######################################
menu_tmux_quote() {
  local s="${1}"
  printf "'%s'" "$(printf '%s' "${s}" | sed "s/'/'\\\\''/g")"
}
```

- [ ] **Step 4: Add `menu_show`**

```bash
#######################################
# Display a menu of TAB-delimited rows.
#
# Item names are NOT numbered: tmux draws the key at the end of the item line
# itself, so a numbered label shows the number twice - which is exactly how
# the first attempt at this looked wrong.
#
# A label of "-" becomes a separator: display-menu takes an empty name for
# that and expects the key and command to be omitted entirely, so a separator
# contributes ONE argv element where an item contributes three.
# Arguments:
#   Menu title
#   Act prefix - a shell-quoted command that takes one value argument
# Inputs:
#   "value<TAB>label" rows on stdin
# Returns:
#   0 on success, PICKER_EMPTY when there were no rows
#######################################
menu_show() {
  local title="${1}"
  local act_prefix="${2}"

  local -a args=()
  local row value label key
  local n=0
  local items=0

  while IFS= read -r row; do
    [ -n "${row}" ] || continue
    value="${row%%$'\t'*}"
    label="${row#*$'\t'}"

    if [ "${label}" = "-" ]; then
      args+=("")
      continue
    fi

    n=$((n + 1))
    items=$((items + 1))
    if [ "${n}" -le 9 ]; then
      key="${n}"
    else
      key=""
    fi

    args+=("${label}" "${key}" \
      "run-shell -b $(menu_tmux_quote "${act_prefix} $(printf '%q' "${value}")")")
  done

  if [ "${items}" -eq 0 ]; then
    return "${PICKER_EMPTY}"
  fi

  # -- terminates the options: a label may begin with a hyphen, which is both
  # display-menu's "disabled item" marker and the shape of its own flags.
  tmux display-menu \
    -T "#[align=centre] ${title} " \
    -b rounded \
    -x C -y C \
    -- "${args[@]}"
}
```

`PICKER_EMPTY` comes from `lib/picker.sh`. Add its source at the top of
`lib/menu.sh`, after `output.sh`:

```bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/picker.sh"
```

- [ ] **Step 5: Run the tests and lint**

Run: `cd scripts/scripts && bats tests/menu_lib.bats && make test && make lint`
Expected: all exit 0.

- [ ] **Step 6: Commit**

```bash
git add scripts/scripts/lib/menu.sh scripts/scripts/tests/menu_lib.bats
git commit -m "feat(menus): render TAB rows as a native tmux menu

Labels are unnumbered because tmux draws the key at the end of the line
itself. Values cross two parsers - tmux's and the shell's - so they are
quoted for both, which is what keeps a worktree path with a space in it
from acting on its first word."
```

---

## Task 3: `menu_or_pick`

**Files:**
- Modify: `scripts/scripts/lib/menu.sh`
- Test: `scripts/scripts/tests/menu_lib.bats`

**Interfaces:**
- Consumes: `menu_fits`, `menu_show`, `pick_one`
- Produces: `menu_or_pick <title> <act-prefix> [pick_one options...]` — reads
  rows on stdin, chooses a backend, and ensures the act prefix runs either way

**Context:** This is the single decision point. On the fzf path it must invoke
the act prefix itself, so the two backends converge on one code path rather
than diverging into two.

`--empty-message` is *read* (so the menu path can report an empty list the
same way) and also *forwarded* to `pick_one`.

- [ ] **Step 1: Write the failing tests**

Append to `scripts/scripts/tests/menu_lib.bats`:

```bash
@test "a fitting list renders a menu and no fzf" {
  setup_fzf_stub
  export TMUX_STUB_CLIENT_HEIGHT=40
  printf 'v1\tOne\n' | menu_or_pick "T" "true" --empty-message "none"
  assert_tmux_subcommand display-menu
  refute_fzf_called
}

@test "a list too tall for the client uses fzf and no menu" {
  setup_fzf_stub
  export TMUX_STUB_CLIENT_HEIGHT=6
  export FZF_STUB_SELECTION=$'v3\tThree'
  local i
  for i in $(seq 1 20); do printf 'v%s\tItem%s\n' "${i}" "${i}"; done \
    | menu_or_pick "T" "true" --empty-message "none"
  refute_tmux_subcommand display-menu
  [ -s "${FZF_STUB_LOG}" ]
}

# The point of the design: both backends reach the same act half.
@test "the fzf path invokes the act prefix with the chosen value" {
  setup_fzf_stub
  setup_cmd_stubs
  stub_cmd acted
  export TMUX_STUB_CLIENT_HEIGHT=6
  export FZF_STUB_SELECTION=$'chosen-value\tThree'
  local i
  for i in $(seq 1 20); do printf 'v%s\tItem%s\n' "${i}" "${i}"; done \
    | menu_or_pick "T" "acted" --empty-message "none"
  run cmd_call_args acted
  [ "${lines[1]}" = "chosen-value" ]
}

@test "escaping the fzf path acts on nothing and closes quietly" {
  setup_fzf_stub
  setup_cmd_stubs
  stub_cmd acted
  export TMUX_STUB_CLIENT_HEIGHT=6
  export FZF_STUB_ABORT=1
  local i status=0
  for i in $(seq 1 20); do printf 'v%s\tItem%s\n' "${i}" "${i}"; done \
    | menu_or_pick "T" "acted" --empty-message "none" || status="${?}"
  [ "${status}" -eq "${PICKER_QUIET_EXIT}" ]
  refute_cmd_called acted
}

@test "an empty list reports the caller's message on either backend" {
  setup_fzf_stub
  export TMUX_STUB_CLIENT_HEIGHT=40
  local status=0
  run bash -c "source '${BATS_TEST_DIRNAME}/../lib/menu.sh'; printf '' | menu_or_pick T true --empty-message 'No open PRs.'"
  [ "${status}" -eq 3 ]
  [[ "${output}" == *"No open PRs."* ]]
  refute_tmux_subcommand display-menu
}

@test "pick_one options are forwarded on the fzf path" {
  setup_fzf_stub
  export TMUX_STUB_CLIENT_HEIGHT=6
  export FZF_STUB_SELECTION=$'v1\tOne'
  local i
  for i in $(seq 1 20); do printf 'v%s\tItem%s\n' "${i}" "${i}"; done \
    | menu_or_pick "T" "true" --prompt "Pick this> " --empty-message "none"
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--prompt" "Pick this> "
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `cd scripts/scripts && bats tests/menu_lib.bats`
Expected: FAIL with `menu_or_pick: command not found`.

- [ ] **Step 3: Add `menu_or_pick`**

Append to `scripts/scripts/lib/menu.sh`:

```bash
#######################################
# Choose a value from rows and act on it, using whichever backend can show
# them.
#
# A native menu when the rows fit, fzf when they do not. Both paths end at the
# same act prefix, which is the whole reason the fallback can be trusted: the
# backends differ in how a value is chosen and in nothing else.
# Arguments:
#   Menu title
#   Act prefix - a shell-quoted command taking one value argument
#   Remaining arguments are passed through to pick_one
# Inputs:
#   "value<TAB>label" rows on stdin
# Returns:
#   0 on success, PICKER_EMPTY on no rows, PICKER_QUIET_EXIT when the user
#   backed out of the fzf path
#######################################
menu_or_pick() {
  local title="${1}"
  local act_prefix="${2}"
  shift 2

  # Read the caller's empty-message so the menu path can report an empty list
  # in the same words pick_one would. It stays in the forwarded arguments.
  local empty_message=""
  local i=1
  while [ "${i}" -le "${#}" ]; do
    if [ "$(eval "printf '%s' \"\${${i}}\"")" = "--empty-message" ]; then
      empty_message="$(eval "printf '%s' \"\${$((i + 1))}\"")"
      break
    fi
    i=$((i + 1))
  done

  local rows
  rows="$(cat)"
  if [ -z "${rows}" ]; then
    warn "${empty_message:-nothing to pick from}"
    return "${PICKER_EMPTY}"
  fi

  local count
  count="$(printf '%s\n' "${rows}" | grep -c . || true)"
  [ -n "${count}" ] || count=0

  if menu_fits "${count}"; then
    printf '%s\n' "${rows}" | menu_show "${title}" "${act_prefix}"
    return "${?}"
  fi

  local selection status=0
  selection="$(printf '%s\n' "${rows}" | pick_one ${1+"${@}"})" || status="${?}"

  if [ "${status}" -eq "${PICKER_NO_SELECTION}" ]; then
    return "${PICKER_QUIET_EXIT}"
  fi
  if [ "${status}" -ne 0 ]; then
    return "${status}"
  fi

  local value="${selection%%$'\t'*}"
  # act_prefix is built by the caller from a %q-escaped script path plus fixed
  # flags, and the value is escaped here, so both halves are safe to evaluate.
  eval "${act_prefix} $(printf '%q' "${value}")"
}
```

- [ ] **Step 4: Run the tests and lint**

Run: `cd scripts/scripts && bats tests/menu_lib.bats && make test && make lint`
Expected: all exit 0.

- [ ] **Step 5: Commit**

```bash
git add scripts/scripts/lib/menu.sh scripts/scripts/tests/menu_lib.bats
git commit -m "feat(menus): pick a backend by whether the rows will fit

Native menu when they fit, fzf when they do not, and both paths end at the
same act prefix - the backends differ in how a value is chosen and in
nothing else."
```

---

## Task 4: `fzf-menu --run`

**Files:**
- Modify: `scripts/scripts/fzf-menu`
- Test: `scripts/scripts/tests/fzf_menu.bats`

**Interfaces:**
- Consumes: nothing new
- Produces: `fzf-menu --run <command>` — the act half for a `.menu` entry.
  Task 5's menu items invoke it.

**Context:** `run_action` today assumes it is running *inside* the fzf popup:
the bare case writes to that popup and pauses so the output can be read. A
menu item has no popup, so the bare case must open one.

`@window`, `@pane`, `@bg` and `@menu` never needed the popup and are
unchanged.

- [ ] **Step 1: Write the failing tests**

Append to `scripts/scripts/tests/fzf_menu.bats`:

```bash
# A menu item has no popup to write into, so a bare command opens its own.
@test "--run on a bare command opens a popup" {
  run "${FZF_MENU}" --run "echo hi"
  [ "${status}" -eq 0 ]
  assert_tmux_subcommand display-popup
  run tmux_call_args display-popup
  [[ "${output}" == *"echo hi"* ]]
}

# Bordered, like the other popups that show command output.
@test "--run's popup keeps its border" {
  run "${FZF_MENU}" --run "echo hi"
  run tmux_call_args display-popup
  [[ "${output}" != *"-B"* ]]
}

@test "--run's popup waits for a key so output can be read" {
  run "${FZF_MENU}" --run "echo hi"
  run tmux_call_args display-popup
  [[ "${output}" == *"Press any key"* ]]
}

@test "--run honours @window without a popup" {
  run "${FZF_MENU}" --run "@window vim"
  [ "${status}" -eq 0 ]
  assert_tmux_subcommand new-window
  refute_tmux_subcommand display-popup
}

@test "--run honours @pane without a popup" {
  run "${FZF_MENU}" --run "@pane ls -la"
  assert_tmux_subcommand send-keys
  refute_tmux_subcommand display-popup
}

@test "--run honours @bg without a popup" {
  run "${FZF_MENU}" --run "@bg true"
  [ "${status}" -eq 0 ]
  refute_tmux_subcommand display-popup
}

@test "--run rejects an unknown sigil" {
  run "${FZF_MENU}" --run "@nope echo hi"
  [ "${status}" -eq 2 ]
  [[ "${output}" == *"unknown sigil"* ]]
}

@test "--run with no command is a usage error" {
  run "${FZF_MENU}" --run
  [ "${status}" -eq 2 ]
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `cd scripts/scripts && bats tests/fzf_menu.bats`
Expected: FAIL - `--run` is not a recognised mode, so it is treated as a menu
name and exits 2 with "no such menu".

- [ ] **Step 3: Split the bare branch into a popup form**

In `scripts/scripts/fzf-menu`, add above `run_action`:

```bash
#######################################
# Run a bare command in a popup of its own and wait for a keypress.
#
# The inline bare branch in run_action assumes it is already inside the fzf
# popup. A menu item is not: display-menu runs a tmux command with nowhere to
# write, so the output needs a popup built for it. Bordered, matching the
# other popups that show command output.
# Arguments:
#   The command to run
#######################################
run_in_popup() {
  local body="${1}"
  tmux display-popup -E -w "${RUN_POPUP_WIDTH}" -h "${RUN_POPUP_HEIGHT}" \
    -d '#{pane_current_path}' \
    "${body}; printf '\\n'; read -r -n 1 -p 'Press any key to close... ' _" \
    || warn "display-popup failed"
}
```

and beside the other geometry constants:

```bash
# Geometry for a bare command's own popup, used from a menu item. Percentages
# rather than the menu's fixed width: this holds arbitrary command output, not
# a list sized to its contents.
readonly RUN_POPUP_WIDTH="80%"
readonly RUN_POPUP_HEIGHT="60%"
```

- [ ] **Step 4: Add the `--run` mode**

In the `case "${1:-}"` dispatch near the bottom, beside `--explain` and
`--popup`:

```bash
  # The act half. Invoked by a display-menu item, which runs a tmux command
  # rather than handing a selection back.
  --run)
    shift
    if [ "${#}" -lt 1 ] || [ -z "${1}" ]; then
      error "missing required argument: command"
      exit "${MENU_UNAVAILABLE}"
    fi
    run_action_from_menu "${1}"
    exit "${?}"
    ;;
```

and add the dispatcher above `run_action`:

```bash
#######################################
# Run a menu entry chosen from a native menu.
#
# Identical to run_action except for the bare case, which has no popup to
# write into and so is given one.
# Arguments:
#   The command string, sigil included
# Returns:
#   0 on success, MENU_UNAVAILABLE on an unknown sigil
#######################################
run_action_from_menu() {
  local command="${1}"
  if [ -z "$(action_sigil "${command}")" ]; then
    run_in_popup "$(action_body "${command}")"
    return 0
  fi
  run_action "${command}"
}
```

- [ ] **Step 5: Document the mode**

Add to the usage block and the header comment:

```
#        fzf-menu --run <cmd>        run one entry, as a menu item does
```

- [ ] **Step 6: Run the tests and lint**

Run: `cd scripts/scripts && bats tests/fzf_menu.bats && make test && make lint`
Expected: all exit 0.

- [ ] **Step 7: Commit**

```bash
git add scripts/scripts/fzf-menu scripts/scripts/tests/fzf_menu.bats
git commit -m "feat(menus): add --run, the act half for a menu item

display-menu runs a command rather than returning a selection, so entries
need an entry point that acts on one command. A bare command gets its own
bordered popup: the inline branch assumes it is already inside the fzf
popup, and a menu item is not."
```

---

## Task 5: `--popup` chooses a backend

**Files:**
- Modify: `scripts/scripts/fzf-menu`
- Test: `scripts/scripts/tests/fzf_menu.bats`

**Interfaces:**
- Consumes: `menu_fits`, `menu_show` (Tasks 1-2), `--run` (Task 4)
- Produces: `--popup <name>` renders natively when it fits

**Context:** `popup()` currently always opens a `display-popup` and re-runs
`fzf-menu` inside it. It becomes: render a native menu when the rows fit,
otherwise exactly what it does today.

`menu_max_rows` already accounts for one level of `@menu`, and that number is
the right one for the fit test too: a chaining menu must fit the tallest
screen it can reach.

- [ ] **Step 1: Write the failing tests**

Append to `scripts/scripts/tests/fzf_menu.bats`:

```bash
@test "--popup renders a native menu when the rows fit" {
  export TMUX_STUB_CLIENT_HEIGHT=40
  run "${FZF_MENU}" --popup demo
  [ "${status}" -eq 0 ]
  assert_tmux_subcommand display-menu
  refute_tmux_subcommand display-popup
}

@test "the native menu's items call --run" {
  export TMUX_STUB_CLIENT_HEIGHT=40
  run "${FZF_MENU}" --popup demo
  run tmux_call_args display-menu
  [[ "${output}" == *"--run"* ]]
  [[ "${output}" == *"echo fetch-ran"* ]]
}

@test "--popup falls back to fzf when the rows do not fit" {
  export TMUX_STUB_CLIENT_HEIGHT=5
  printf '# Big\n' > "${FZF_MENU_DIR}/big.menu"
  local i
  for i in $(seq 1 30); do
    printf 'Row %s\techo %s\n' "${i}" "${i}" >> "${FZF_MENU_DIR}/big.menu"
  done
  run "${FZF_MENU}" --popup big
  [ "${status}" -eq 0 ]
  assert_tmux_subcommand display-popup
  refute_tmux_subcommand display-menu
}

# A chaining menu has to fit the tallest screen it can reach, not just its own
# rows, or picking a leaf blanks it.
@test "--popup measures an @menu target for the fit test too" {
  printf '# Leaf\n' > "${FZF_MENU_DIR}/leaf.menu"
  local i
  for i in $(seq 1 30); do
    printf 'Row %s\techo %s\n' "${i}" "${i}" >> "${FZF_MENU_DIR}/leaf.menu"
  done
  printf '# Top\nLeaf\t@menu leaf\n' > "${FZF_MENU_DIR}/top.menu"
  export TMUX_STUB_CLIENT_HEIGHT=12
  run "${FZF_MENU}" --popup top
  refute_tmux_subcommand display-menu
  assert_tmux_subcommand display-popup
}

@test "--popup on a missing menu still exits 2 without rendering" {
  export TMUX_STUB_CLIENT_HEIGHT=40
  run "${FZF_MENU}" --popup nosuch
  [ "${status}" -eq 2 ]
  refute_tmux_subcommand display-menu
  refute_tmux_subcommand display-popup
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `cd scripts/scripts && bats tests/fzf_menu.bats`
Expected: the native-menu tests FAIL - `popup()` always opens a
`display-popup`, so `display-menu` is never called.

- [ ] **Step 3: Source `lib/menu.sh` in `fzf-menu`**

Beside the existing library sources:

```bash
source "${SCRIPT_DIR}/lib/menu.sh"
```

- [ ] **Step 4: Make `popup()` backend-aware**

Replace the tail of `popup()` (from `local shown=` onward) with:

```bash
  # A native menu when it will fit. menu_max_rows, not the file's own row
  # count: a chaining menu has to fit the tallest screen it can reach, or
  # picking a leaf blanks it.
  if menu_fits "${count}"; then
    menu_rows "${file}" \
      | menu_show "$(menu_header "${file}")" \
          "$(printf '%q' "${SCRIPT_DIR}/fzf-menu") --run"
    return "${?}"
  fi

  local shown="${count}"
  [ "${shown}" -gt "${POPUP_MAX_ITEMS}" ] && shown="${POPUP_MAX_ITEMS}"
  [ "${shown}" -lt 1 ] && shown=1
  local height=$((shown + POPUP_CHROME_ROWS))

  tmux display-popup -EE -w "${POPUP_WIDTH}" -h "${height}" \
    -d '#{pane_current_path}' \
    "$(printf '%q' "${SCRIPT_DIR}/fzf-menu") $(printf '%q' "${name}")"
```

`menu_rows` emits `command<TAB>N label`, which is already the
`value<TAB>label` shape `menu_show` wants — but the label carries the digit
prefix the fzf path needs and a native menu must not show. Strip it:

```bash
#######################################
# Menu rows with the digit prefix removed.
#
# menu_rows numbers labels for fzf, which has no key column of its own. tmux
# draws the key at the end of the item line, so a native menu must not carry
# the number as well.
# Arguments:
#   Path to the menu file
# Outputs:
#   "command<TAB>label" rows to stdout
#######################################
menu_rows_unnumbered() {
  local file="${1}"
  local row command label
  while IFS= read -r row; do
    [ -n "${row}" ] || continue
    command="${row%$'\t'*}"
    label="${row##*$'\t'}"
    # "1 Fetch" -> "Fetch"; "  Fetch" -> "Fetch"
    label="${label#[0-9] }"
    label="${label#  }"
    printf '%s\t%s\n' "${command}" "${label}"
  done < <(menu_rows "${file}")
}
```

and use `menu_rows_unnumbered "${file}"` in the `menu_fits` branch above.

- [ ] **Step 5: Run the tests and lint**

Run: `cd scripts/scripts && bats tests/fzf_menu.bats && make test && make lint`
Expected: all exit 0.

- [ ] **Step 6: Commit**

```bash
git add scripts/scripts/fzf-menu scripts/scripts/tests/fzf_menu.bats
git commit -m "feat(menus): render menus natively when they fit

The fzf popup stays as the fallback for lists too tall for a native menu,
which tmux would otherwise decline to draw at all. The fit test uses
menu_max_rows so a chaining menu is measured against the tallest screen it
can reach."
```

---

## Task 6: `wt-pick --act`

**Files:**
- Modify: `scripts/scripts/wt-pick`
- Test: `scripts/scripts/tests/wt_pick.bats`

**Interfaces:**
- Consumes: `menu_or_pick`
- Produces: `wt-pick --act <switch|remove> <path>`

**Context:** `main` currently pipes `worktree_rows` into `pick_one` and then
dispatches on the verb. The dispatch becomes `--act`, and the choosing becomes
`menu_or_pick`.

Verbs are validated in both entry points, so `--act` with a bad verb is a
usage error rather than a silent no-op.

- [ ] **Step 1: Write the failing tests**

Append to `scripts/scripts/tests/wt_pick.bats`:

```bash
@test "--act switch hands the path to ts without a picker" {
  setup_fzf_stub
  stub_cmd ts
  run "${WT_PICK}" --act switch "${WT_A}"
  [ "${status}" -eq 0 ]
  run cmd_call_args ts
  [ "${lines[1]}" = "${WT_A}" ]
  refute_fzf_called
}

@test "--act remove goes through the gate" {
  stub_cmd wt-confirm "" 0
  stub_cmd git-worktree-cleanup
  export SCRIPTS_PKG_DIR="${CMD_STUB_BIN}"
  run "${WT_PICK}" --act remove "${WT_A}"
  [ "${status}" -eq 0 ]
  assert_cmd_called wt-confirm
  assert_cmd_called git-worktree-cleanup
}

@test "--act with an unknown verb is a usage error" {
  run "${WT_PICK}" --act frobnicate "${WT_A}"
  [ "${status}" -eq 2 ]
}

@test "--act with no value is a usage error" {
  run "${WT_PICK}" --act switch
  [ "${status}" -eq 2 ]
}

@test "the verb path renders a menu whose items call --act" {
  export TMUX_STUB_CLIENT_HEIGHT=40
  stub_cmd ts
  run "${WT_PICK}" switch
  [ "${status}" -eq 0 ]
  run tmux_call_args display-menu
  [[ "${output}" == *"--act switch"* ]]
  [[ "${output}" == *"${WT_A}"* ]]
}

@test "the verb path falls back to fzf on a short client" {
  export TMUX_STUB_CLIENT_HEIGHT=4
  stub_cmd ts
  export FZF_STUB_SELECTION="${WT_A}"$'\twt-a  feature-a'
  run "${WT_PICK}" switch
  [ "${status}" -eq 0 ]
  refute_tmux_subcommand display-menu
  run cmd_call_args ts
  [ "${lines[1]}" = "${WT_A}" ]
}
```

The existing tests in this file assume the fzf path. Add
`export TMUX_STUB_CLIENT_HEIGHT=4` to `setup()` so they keep exercising the
fallback, and let the two new tests set a tall client explicitly.

- [ ] **Step 2: Run the tests to verify they fail**

Run: `cd scripts/scripts && bats tests/wt_pick.bats`
Expected: the `--act` tests FAIL - the flag is parsed as a verb and rejected.

- [ ] **Step 3: Split `main` into list and act**

In `scripts/scripts/wt-pick`, source the menu library beside the others:

```bash
source "${SCRIPT_DIR}/lib/menu.sh"
```

Add verb validation as a function, since both entry points need it:

```bash
#######################################
# Reject anything that is not a known verb.
# Arguments:
#   The verb
# Returns:
#   0 when valid, PICK_USAGE_ERROR otherwise
#######################################
check_verb() {
  case "${1}" in
    switch|remove) return 0 ;;
    '')
      error "missing required argument: verb"
      printf '\n'
      usage
      return "${PICK_USAGE_ERROR}"
      ;;
    *)
      error "unknown verb: ${1}"
      printf '\n'
      usage
      return "${PICK_USAGE_ERROR}"
      ;;
  esac
}
```

Add the act entry point:

```bash
#######################################
# Act on one already-chosen worktree.
#
# This is what a native menu item invokes: display-menu runs a command rather
# than handing a selection back. The fzf path reaches the same function.
# Arguments:
#   The verb, the worktree path
# Returns:
#   0 on success, PICK_USAGE_ERROR on a bad invocation
#######################################
act() {
  local verb="${1:-}"
  local path="${2:-}"

  check_verb "${verb}" || return "${?}"
  if [ -z "${path}" ]; then
    error "missing required argument: worktree path"
    return "${PICK_USAGE_ERROR}"
  fi

  case "${verb}" in
    switch) do_switch "${path}" ;;
    remove) do_remove "${path}" ;;
  esac
}
```

Replace `main`'s body after the verb check with:

```bash
  worktree_rows \
    | menu_or_pick "Worktree to ${verb}" \
        "$(printf '%q' "${SCRIPT_DIR}/wt-pick") --act ${verb}" \
        --size "" --style default --info hidden \
        --prompt "Worktree to ${verb}> " \
        --empty-message "No other worktrees."
```

and let its status propagate: `menu_or_pick` already returns
`PICKER_QUIET_EXIT` on an escape and `PICKER_EMPTY` on an empty list, which
`fzf-menu --run` and the shell both handle.

Add the flag to the dispatch, before `main`:

```bash
case "${1:-}" in
  --act)
    shift
    act ${1+"${@}"}
    exit "${?}"
    ;;
esac
```

- [ ] **Step 4: Document it**

Add to the usage block and header comment:

```
#        wt-pick --act <verb> <path>   act on one worktree (used by menu items)
```

- [ ] **Step 5: Run the tests and lint**

Run: `cd scripts/scripts && bats tests/wt_pick.bats && make test && make lint`
Expected: all exit 0.

- [ ] **Step 6: Commit**

```bash
git add scripts/scripts/wt-pick scripts/scripts/tests/wt_pick.bats
git commit -m "feat(menus): give wt-pick an act half for menu items

A native menu runs a command instead of returning a selection, so choosing
and acting have to be separable. Both backends now reach the same act path."
```

---

## Task 7: `pr-pick --act`

**Files:**
- Modify: `scripts/scripts/pr-pick`
- Test: `scripts/scripts/tests/pr_pick.bats`

**Interfaces:**
- Consumes: `menu_or_pick`
- Produces: `pr-pick --act <checkout|review|browse|diff> <number>`

**Context:** Identical in shape to Task 6. This is the picker most likely to
hit the fallback in real use — an active repo can have more open PRs than the
client is tall, which is exactly the case a native menu would refuse to draw.

- [ ] **Step 1: Write the failing tests**

Append to `scripts/scripts/tests/pr_pick.bats`:

```bash
@test "--act review hands the number to gh-review without a picker" {
  stub_cmd gh-review
  run "${PR_PICK}" --act review 42
  [ "${status}" -eq 0 ]
  run cmd_call_args gh-review
  [ "${lines[1]}" = "42" ]
  refute_fzf_called
}

@test "--act checkout hands the number to gh-worktree" {
  stub_cmd gh-worktree
  run "${PR_PICK}" --act checkout 41
  run cmd_call_args gh-worktree
  [ "${lines[1]}" = "41" ]
}

@test "--act with an unknown verb is a usage error" {
  run "${PR_PICK}" --act frobnicate 41
  [ "${status}" -eq 2 ]
}

@test "--act with no value is a usage error" {
  run "${PR_PICK}" --act review
  [ "${status}" -eq 2 ]
}

@test "the verb path renders a menu whose items call --act" {
  export TMUX_STUB_CLIENT_HEIGHT=40
  stub_cmd gh "${PR_LIST}"
  stub_cmd gh-review
  run "${PR_PICK}" review
  run tmux_call_args display-menu
  [[ "${output}" == *"--act review"* ]]
  [[ "${output}" == *"41"* ]]
}

# The case that motivates the fallback: more PRs than the terminal is tall.
@test "a long PR list falls back to fzf rather than blanking" {
  export TMUX_STUB_CLIENT_HEIGHT=10
  local rows="" i
  for i in $(seq 1 40); do
    rows="${rows}${i}"$'\t'"PR ${i}"$'\t'"branch-${i}"$'\n'
  done
  stub_cmd gh "${rows}"
  stub_cmd gh-review
  export FZF_STUB_SELECTION=$'7\t#7  PR 7  [branch-7]'
  run "${PR_PICK}" review
  [ "${status}" -eq 0 ]
  refute_tmux_subcommand display-menu
  run cmd_call_args gh-review
  [ "${lines[1]}" = "7" ]
}
```

Add `export TMUX_STUB_CLIENT_HEIGHT=4` to this file's `setup()` so the
existing fzf-path tests keep exercising the fallback.

- [ ] **Step 2: Run the tests to verify they fail**

Run: `cd scripts/scripts && bats tests/pr_pick.bats`
Expected: the `--act` tests FAIL - the flag is parsed as a verb.

- [ ] **Step 3: Apply the same split**

Source `lib/menu.sh`. Add `check_verb` accepting
`checkout|review|browse|diff`, an `act` function dispatching those four to the
bodies currently inline in `main`, and replace `main`'s selection block with:

```bash
  pr_rows \
    | menu_or_pick "PR to ${verb}" \
        "$(printf '%q' "${SCRIPT_DIR}/pr-pick") --act ${verb}" \
        --size "" --style default --info hidden \
        --prompt "PR to ${verb}> " \
        --empty-message "No open PRs."
```

Add the `--act` dispatch before `main`, exactly as in Task 6.

- [ ] **Step 4: Run the tests and lint**

Run: `cd scripts/scripts && bats tests/pr_pick.bats && make test && make lint`
Expected: all exit 0.

- [ ] **Step 5: Commit**

```bash
git add scripts/scripts/pr-pick scripts/scripts/tests/pr_pick.bats
git commit -m "feat(menus): give pr-pick an act half for menu items

This is the list most likely to outgrow the terminal, so it is the one the
fallback exists for - a test pins that 40 PRs on a 10-row client reach fzf
rather than a menu tmux would decline to draw."
```

---

## Task 8: `sc-pick --act`

**Files:**
- Modify: `scripts/scripts/sc-pick`
- Test: `scripts/scripts/tests/sc_pick.bats`

**Interfaces:**
- Consumes: `menu_or_pick`
- Produces: `sc-pick --act <claim|implement|worktree|browse> <sc-ID>`

**Context:** Identical in shape to Tasks 6 and 7. The `browse` verb must keep
using `short story <id> -O`: the uppercase flag opens a browser, the lowercase
one **assigns owners**.

- [ ] **Step 1: Write the failing tests**

Append to `scripts/scripts/tests/sc_pick.bats`:

```bash
@test "--act implement hands the id to shortcut-implement" {
  stub_cmd shortcut-implement
  run "${SC_PICK}" --act implement sc-101
  [ "${status}" -eq 0 ]
  run cmd_call_args shortcut-implement
  [ "${lines[1]}" = "sc-101" ]
  refute_fzf_called
}

@test "--act browse still uses the uppercase flag" {
  stub_cmd short ""
  run "${SC_PICK}" --act browse sc-101
  [ "${status}" -eq 0 ]
  run cmd_calls
  [[ "${output}" == *"-O"* ]]
}

@test "--act with an unknown verb is a usage error" {
  run "${SC_PICK}" --act frobnicate sc-101
  [ "${status}" -eq 2 ]
}

@test "--act with no value is a usage error" {
  run "${SC_PICK}" --act implement
  [ "${status}" -eq 2 ]
}

@test "the verb path renders a menu whose items call --act" {
  export TMUX_STUB_CLIENT_HEIGHT=40
  stub_listing
  stub_cmd shortcut-implement
  run "${SC_PICK}" implement
  run tmux_call_args display-menu
  [[ "${output}" == *"--act implement"* ]]
  [[ "${output}" == *"sc-101"* ]]
}
```

Add `export TMUX_STUB_CLIENT_HEIGHT=4` to this file's `setup()`.

- [ ] **Step 2: Run the tests to verify they fail**

Run: `cd scripts/scripts && bats tests/sc_pick.bats`
Expected: the `--act` tests FAIL.

- [ ] **Step 3: Apply the same split**

Source `lib/menu.sh`. Add `check_verb` accepting
`claim|implement|worktree|browse`, an `act` function, and replace `main`'s
selection block with:

```bash
  story_rows \
    | menu_or_pick "Story to ${verb}" \
        "$(printf '%q' "${SCRIPT_DIR}/sc-pick") --act ${verb}" \
        --size "" --style default --info hidden \
        --prompt "Story to ${verb}> " \
        --empty-message "No stories assigned to you."
```

Add the `--act` dispatch before `main`.

- [ ] **Step 4: Run the tests and lint**

Run: `cd scripts/scripts && bats tests/sc_pick.bats && make test && make lint`
Expected: all exit 0.

- [ ] **Step 5: Commit**

```bash
git add scripts/scripts/sc-pick scripts/scripts/tests/sc_pick.bats
git commit -m "feat(menus): give sc-pick an act half for menu items

browse keeps the uppercase -O: short story -o assigns owners, and the two
are one letter apart."
```

---

## Task 9: Measure `MENU_CHROME_ROWS`

**Files:**
- Modify: `scripts/scripts/tests/manual/verify-menu-fit`
- Modify: `scripts/scripts/lib/menu.sh` (only if the measurement disagrees)

**Interfaces:**
- Consumes: `menu_fits`
- Produces: a measured value for `MENU_CHROME_ROWS`

**Context:** This is the one number in the design that fails badly when wrong.
`POPUP_CHROME_ROWS` was estimated twice and wrong twice; a short estimate
there makes a menu scroll, a short estimate here makes it **blank**. The
starting value of 4 is deliberately generous, so the risk is only that the
fallback triggers early.

`display-menu` blocks while open and cannot be probed in a batch, so the tool
opens one menu at a time and reports whether tmux drew it.

- [ ] **Step 1: Add a `--menu` mode to the manual tool**

The mode takes a client height and an item count, opens a menu of that many
items on its own socket at that height, and reports whether it appeared. Since
a menu that does not fit is simply absent, "appeared" is detected by asking
tmux for the menu's own dimensions immediately after opening it:

```bash
#######################################
# Report whether a menu of N items is displayed at a given client height.
# Arguments:
#   Client height, item count
# Outputs:
#   "height=H items=N shown=yes|no" to stdout
#######################################
probe_menu() {
  local height="${1}"
  local items="${2}"
  local socket="menufit$$"
  local out="${TMPDIR:-/tmp}/menufit.${$}.out"

  local -a menu_args=()
  local i
  for i in $(seq 1 "${items}"); do
    menu_args+=("item ${i}" "" "run-shell true")
  done

  # display-menu blocks while the menu is open, so the probe runs it in the
  # background and asks tmux about popup_height from another command.
  script -q /dev/null tmux -L "${socket}" -f /dev/null \
    new-session -x 100 -y "${height}" \
    "tmux display-menu -T probe $(printf '%q ' "${menu_args[@]}") & \
     sleep 0.5; tmux display-message -p '#{popup_height}' > $(printf '%q' "${out}"); \
     tmux send-keys Escape" > /dev/null 2>&1
  tmux -L "${socket}" kill-server 2>/dev/null || true

  local shown="no"
  [ -s "${out}" ] && [ "$(cat "${out}")" != "0" ] && shown="yes"
  printf 'height=%s items=%s shown=%s\n' "${height}" "${items}" "${shown}"
  \rm -f "${out}"
}
```

- [ ] **Step 2: Find the boundary**

Run, from `scripts/scripts/`:

```bash
for n in 6 7 8 9 10; do tests/manual/verify-menu-fit --menu 12 "${n}"; done
```

Expected: `shown=yes` up to some N and `shown=no` above it. The chrome is
`12 - N_max`.

- [ ] **Step 3: Reconcile with the constant**

If the measured chrome is **greater than 4**, raise `MENU_CHROME_ROWS` to the
measured value and update the `menu_fits` boundary test in
`tests/menu_lib.bats`, which is written in terms of the constant and so needs
no arithmetic change.

If it is **4 or less**, leave the constant at 4 and record the measurement in
the comment. A generous value only costs an early fallback.

- [ ] **Step 4: Record the measurement**

Update the `MENU_CHROME_ROWS` comment with the measured boundary and the
client height it was measured at, so the next person does not re-derive it.

- [ ] **Step 5: Run the tests and lint**

Run: `cd scripts/scripts && make test && make lint`
Expected: both exit 0.

- [ ] **Step 6: Commit**

```bash
git add scripts/scripts/tests/manual/verify-menu-fit scripts/scripts/lib/menu.sh \
        scripts/scripts/tests/menu_lib.bats
git commit -m "test(menus): measure the menu chrome instead of estimating it

A short estimate here does not make a menu scroll, it makes tmux decline to
draw it at all. The tool opens one menu at a time because display-menu
blocks while open."
```

---

## Task 10: Document the backends

**Files:**
- Modify: `CLAUDE.md`, `scripts/scripts/CLAUDE.md`

- [ ] **Step 1: Update the root `CLAUDE.md` Menus section**

Replace the bullet list's picker line and add the backend rule:

```markdown
Two backends, chosen by measurement:

- native `tmux display-menu` whenever the items fit the client
- the fzf picker when they do not, because a menu too tall for the terminal
  is not displayed at all - no scroll, no truncation, no error

`display-menu` runs a command rather than returning a selection, so every
picker has a list half and an `--act <verb> <value>` half. Both backends drive
the same `--act`, which is what makes the fallback safe to rely on.

Previews and type-to-filter exist only on the fzf path.
```

- [ ] **Step 2: Update `scripts/scripts/CLAUDE.md`**

Add under the Menus heading:

```markdown
`lib/menu.sh` owns every `display-menu` invocation the way `lib/picker.sh`
owns fzf's. `menu_or_pick` is the single decision point; nothing else should
be choosing a backend.

`MENU_CHROME_ROWS` is **measured** (`tests/manual/verify-menu-fit --menu`) and
deliberately generous. Too large only means falling back to fzf early; too
small means tmux silently draws nothing, which reads as a broken keybinding.

Values crossing into a menu item's `run-shell` command are escaped twice -
`printf '%q'` for the shell and `menu_tmux_quote` for tmux's own parser.
Dropping either makes a path with a space act on its first word.
```

- [ ] **Step 3: Verify and commit**

```bash
cd scripts/scripts && make test && make lint
git add CLAUDE.md scripts/scripts/CLAUDE.md
git commit -m "docs: describe the two menu backends and why the choice is measured"
```

---

## Task 11: Centre the menu in the pane, not the terminal

**Files:**
- Modify: `scripts/scripts/lib/menu.sh`
- Test: `scripts/scripts/tests/menu_lib.bats`

**Interfaces:**
- Consumes: `menu_show` (Task 2)
- Produces: no new interface; `menu_show` positions itself over the pane

**Context:** `-x C -y C` centres on the whole terminal, which on a split window
puts the menu somewhere other than where you are looking. `-x`/`-y` also
accept a **format**, and tmux exposes `popup_pane_left`, `popup_pane_right`,
`popup_pane_top`, `popup_pane_bottom`, `popup_width` and `popup_height` while
positioning a menu.

Verified: tmux format arithmetic works (`#{e|/:#{e|+:10,20},2}` → `15`), and
the `popup_pane_*` variables are empty outside a menu-positioning context,
which is why they can only be exercised on a live client.

**The one uncertainty:** whether `display-menu -y` names the menu's **top** or
its **bottom** row. Both formulas are given; Step 3 picks by looking.

- [ ] **Step 1: Write the failing tests**

Append to `scripts/scripts/tests/menu_lib.bats`:

```bash
# -x C -y C centres on the terminal, which on a split window is not where the
# user is looking. The pane variables are only expanded while tmux positions
# the menu, so all a unit test can check is that the formats were passed.
@test "the menu is positioned over the pane, not the terminal" {
  printf 'v1\tOne\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  [[ "${output}" == *"popup_pane_left"* ]]
  [[ "${output}" == *"popup_pane_right"* ]]
  [[ "${output}" == *"popup_width"* ]]
  [[ "${output}" != *"-x"$'\x1f'"C"* ]]
}

@test "the vertical position also comes from the pane" {
  printf 'v1\tOne\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  [[ "${output}" == *"popup_pane_top"* ]]
  [[ "${output}" == *"popup_pane_bottom"* ]]
}
```

- [ ] **Step 2: Replace the position arguments**

In `menu_show`, add beside the other constants in `lib/menu.sh`:

```bash
# Centre the menu on the PANE rather than the terminal: -x C -y C centres on
# the whole client, which on a split window is not where the user is looking.
#
# -x/-y accept a format, and tmux expands these pane variables while it is
# positioning the menu (they are empty at any other time, which is why this
# can only be checked on a live client). Arithmetic is tmux's #{e|op:a,b}.
#
#   x = (pane_left + pane_right - menu_width)  / 2
#   y = (pane_top  + pane_bottom + menu_height) / 2
#
# The y formula ADDS the height because display-menu's -y names the menu's
# bottom row, not its top. If a menu ever appears half a screen too low,
# that assumption is what to flip: subtract instead of add.
readonly MENU_POS_X='#{e|/:#{e|-:#{e|+:#{popup_pane_left},#{popup_pane_right}},#{popup_width}},2}'
readonly MENU_POS_Y='#{e|/:#{e|+:#{e|+:#{popup_pane_top},#{popup_pane_bottom}},#{popup_height}},2}'
```

and change the invocation:

```bash
  tmux display-menu \
    -T "#[align=centre] ${title} " \
    -b rounded \
    -x "${MENU_POS_X}" -y "${MENU_POS_Y}" \
    -- "${args[@]}"
```

- [ ] **Step 3: Look at it, then keep or flip the y formula**

Run `tmux source-file ~/.tmux.conf`, split the window (`prefix %`), put the
cursor in one pane and press `prefix g`.

- Menu centred in that pane: done.
- Menu roughly one menu-height too low or too high: swap the `e|+:` around
  `popup_height` in `MENU_POS_Y` for `e|-:` and look again.
- Menu missing entirely: the format failed to expand. Fall back to `-x C -y C`
  and stop - terminal-centring was the requirement, pane-centring the bonus.

Record which formula won in the comment.

- [ ] **Step 4: Run the tests and lint**

Run: `cd scripts/scripts && make test && make lint`
Expected: both exit 0.

- [ ] **Step 5: Commit**

```bash
git add scripts/scripts/lib/menu.sh scripts/scripts/tests/menu_lib.bats
git commit -m "feat(menus): centre the menu on the pane rather than the terminal

-x C -y C centres on the whole client, which on a split window is not where
the user is looking. tmux expands popup_pane_* while positioning a menu, so
the position can be computed with format arithmetic."
```

---

## Manual Verification

Automated tests cannot exercise a live client. After Task 10:

1. `prefix g`, `w`, `r`, `t`, `s`, `m` each open a **native menu**, centred,
   rounded border, title not selectable and not dimmed
2. digit keys choose; arrow keys navigate; Escape dismisses leaving nothing
2b. with the window split, the menu is centred on the **focused pane**
3. `git.menu` → `Status` opens a bordered popup and waits for a key
4. `git.menu` → `Interactive rebase` still opens a new window
5. `worktree.menu` → `Remove a worktree` reaches `wt-confirm`, which opens its
   own popup (it has no tty under `run-shell`)
6. `pr.menu` → `Review PR` on a repo with many open PRs falls back to fzf
   rather than showing nothing
7. shrink the terminal until a menu stops fitting and confirm the fzf popup
   appears instead of a blank
8. `prefix m` into a leaf menu re-decides the backend for that leaf

## Self-Review

**Spec coverage:** A1 → Task 1. A2 → Tasks 1, 9. A3 → Task 2. A4 → Task 3.
Part B → Tasks 4, 5. Part C → Tasks 6, 7, 8. Part D → tests within each task
plus Manual Verification. No gaps.

**Deviation recorded:** the spec did not mention that `menu_rows` numbers its
labels for fzf's benefit. A native menu must not show that number, since tmux
draws the key itself, so Task 5 adds `menu_rows_unnumbered` rather than
changing `menu_rows` and disturbing the fzf path.

**Placeholder scan:** no TBDs; every step carries its literal code, except
Task 9 Step 3, whose branch depends on a measurement that does not exist yet -
both outcomes are specified.

**Name consistency:** `MENU_CHROME_ROWS`, `menu_client_height`, `menu_fits`
(Task 1), `menu_tmux_quote`, `menu_show` (Task 2), `menu_or_pick` (Task 3) are
used under those names in Tasks 4-8. `check_verb` and `act` are per-script and
defined in each of Tasks 6-8. `run_in_popup` and `run_action_from_menu`
(Task 4) are used only within `fzf-menu`.
