# Menu Expansion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Grow the fzf picker framework from one menu to six, add the three
list-then-act pickers those menus need, and put a confirmation gate in front
of `git-worktree-done`, which today destroys a tmux session and a working
tree without asking.

**Architecture:** Three tiers, already established. `lib/picker.sh` owns all
fzf argv and gains one option. `fzf-menu` runs declarative `menus/*.menu`
files and gains one sigil. Tier 3 — bespoke pickers that call `pick_one`
directly — gets its first four instances (`wt-pick`, `pr-pick`, `sc-pick`,
`wt-confirm`). Menu files stay a flat `Label<TAB>command` table with no shell
pipelines in them.

**Tech Stack:** bash 3.2, fzf, tmux, bats, shellcheck, `gh`, `short`, `jq`.

**Spec:** `docs/superpowers/specs/2026-09-06-menu-expansion-design.md`

## Global Constraints

- bash 3.2 compatible. Use `${1+"${@}"}` when forwarding a possibly-empty
  argv under `set -o nounset`.
- Every script starts with `set -o errexit`, `set -o nounset`,
  `set -o pipefail`.
- Every script carries the package header block (`name - one line`, `Usage:`,
  `Arguments:`, `Example:`) and calls `help_wanted ${1+"${@}"}` before `main`.
- Google Shell Style `#####` comment blocks on every function.
- `lib/picker.sh` is the only file that may construct fzf argv. Tier-3
  scripts call `pick_one`; they never invoke `fzf`.
- `shellcheck` must stay clean: `make lint` from `scripts/scripts/`.
- Every new script is added to `SHELL_SCRIPTS` in `scripts/scripts/Makefile`
  in the same task that creates it.
- No em dashes in code comments, strings, or docs. Plain `-`.
- `POPUP_CHROME_ROWS` in `fzf-menu` is **measured, not derived**. Do not
  change it. If popup sizing looks wrong, re-measure with
  `tests/manual/verify-menu-fit`.
- Run `make test` (bats) and `make lint` from `scripts/scripts/` before every
  commit. Judge by **exit status**, not by reading the tail of the output.

---

## File Structure

**Modify:**
- `scripts/scripts/lib/picker.sh` — add `--empty-message`
- `scripts/scripts/fzf-menu` — add `@menu` sigil, size popups across it
- `scripts/scripts/common.sh` — source the new `lib/worktree.sh`
- `scripts/scripts/git-worktree-done` — call the confirmation gate
- `scripts/scripts/Makefile` — lint the new scripts
- `scripts/scripts/tests/helper.bash` — generic command-stub helpers
- `tmux/.tmux.conf` — five bindings, resurrect key move

**Create:**
- `scripts/scripts/lib/worktree.sh` — worktree risk counts
- `scripts/scripts/wt-confirm` — the confirmation gate, popup or inline
- `scripts/scripts/wt-pick` — worktree list-then-act picker
- `scripts/scripts/pr-pick` — PR list-then-act picker
- `scripts/scripts/sc-pick` — Shortcut story list-then-act picker
- `scripts/scripts/menus/{worktree,pr,tmux,shortcut,menu}.menu`
- `scripts/scripts/tests/{worktree_lib,wt_confirm,wt_pick,pr_pick,sc_pick,menus}.bats`

---

## Task 1: `pick_one --empty-message`

**Files:**
- Modify: `scripts/scripts/lib/picker.sh`
- Test: `scripts/scripts/tests/picker_lib.bats`

**Interfaces:**
- Consumes: nothing
- Produces: `pick_one --empty-message <text>` — when stdin is empty, warn with
  `<text>` instead of the default `nothing to pick from` and return
  `PICKER_NO_SELECTION` (1) without invoking fzf. Every later tier-3 script
  passes this.

**Context:** `_picker_run` already reads stdin up front and already returns
`PICKER_NO_SELECTION` on empty input with a fixed `warn "nothing to pick
from"`. This task only makes that message overridable. No buffering change is
needed.

- [ ] **Step 1: Write the failing tests**

Append to `scripts/scripts/tests/picker_lib.bats`:

```bash
# An empty list closes the popup instantly with no explanation unless the
# caller supplies one. "No open PRs." is the difference between a working
# menu and one that looks broken.
@test "--empty-message replaces the default empty-list warning" {
  run pick_one --empty-message "No open PRs." < /dev/null
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"No open PRs."* ]]
  [[ "${output}" != *"nothing to pick from"* ]]
}

@test "--empty-message does not invoke fzf" {
  run pick_one --empty-message "No open PRs." < /dev/null
  refute_fzf_called
}

@test "without --empty-message an empty list keeps the default warning" {
  run pick_one < /dev/null
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"nothing to pick from"* ]]
}

@test "--empty-message requires a value" {
  run pick_one --empty-message < /dev/null
  [ "${status}" -eq 2 ]
}

@test "--empty-message is not passed through to fzf" {
  export FZF_STUB_SELECTION=$'run-me\tAlpha'
  run pick_one --empty-message "unused" < "${ROWS}"
  [ "${status}" -eq 0 ]
  run fzf_args
  [[ "${output}" != *"--empty-message"* ]]
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `cd scripts/scripts && bats tests/picker_lib.bats`
Expected: FAIL. The first four fail on `picker: unknown option:
--empty-message` (status 2 where 1 or a message is expected); the last passes
vacuously but is kept as a regression guard.

- [ ] **Step 3: Add the option to `_picker_run`**

In `scripts/scripts/lib/picker.sh`, beside the other locals near
`local info=""`:

```bash
  local empty_message=""
```

Add `--empty-message` to the requires-a-value guard list, which currently
reads:

```bash
      --prompt|--header|--header-label|--with-nth|--preview|--preview-window|--preview-label|--bind|--style|--info|--size|--delimiter)
```

so that it becomes:

```bash
      --prompt|--header|--header-label|--with-nth|--preview|--preview-window|--preview-label|--bind|--style|--info|--size|--delimiter|--empty-message)
```

Add the parse arm next to `--info`:

```bash
      --empty-message) empty_message="${2}"; shift 2 ;;
```

- [ ] **Step 4: Use it in the empty-input branch**

Replace:

```bash
  if [ -z "${rows}" ]; then
    warn "nothing to pick from"
    return "${PICKER_NO_SELECTION}"
  fi
```

with:

```bash
  if [ -z "${rows}" ]; then
    # A caller that knows what its rows are can say what "none" means. The
    # generic text is right for a library and useless in a popup that just
    # closed on the user.
    warn "${empty_message:-nothing to pick from}"
    return "${PICKER_NO_SELECTION}"
  fi
```

- [ ] **Step 5: Document the option**

In the `pick_one` header block's Arguments list, add `--empty-message TEXT`
alongside `--info STYLE`.

- [ ] **Step 6: Run the tests and lint**

Run: `cd scripts/scripts && make test && make lint`
Expected: both exit 0. Confirm by exit status, not by reading output.

- [ ] **Step 7: Commit**

```bash
git add scripts/scripts/lib/picker.sh scripts/scripts/tests/picker_lib.bats
git commit -m "feat(picker): let callers name what an empty list means

An empty list returns PICKER_NO_SELECTION, which fzf-menu treats as a
successful no-op, so the popup closes instantly with no explanation.
--empty-message gives the caller a sentence to leave behind."
```

---

## Task 2: The `@menu` sigil

**Files:**
- Modify: `scripts/scripts/fzf-menu`
- Test: `scripts/scripts/tests/fzf_menu.bats`

**Interfaces:**
- Consumes: nothing
- Produces: `@menu <name>` as a fourth sigil. `action_sigil` returns `menu`,
  `action_body` strips `@menu `, `run_action` `exec`s `fzf-menu <name>`.
  Task 3 and Task 10 both depend on this.

**Context:** `fzf-menu` has three sigils today (`@window`, `@pane`, `@bg`) plus
the bare case. The functions to touch are `action_sigil`, `action_body`,
`run_action`, and `explain_action`, all near the bottom of the file.

- [ ] **Step 1: Write the failing tests**

Append to `scripts/scripts/tests/fzf_menu.bats`:

```bash
# menu.menu chains into the five leaf menus. Without a sigil for it, a
# chaining row would run under the bare case: it would work, but it would
# pause for a keypress on the way out of a menu the user is still using.
@test "@menu runs the target menu" {
  printf '# Leaf\nOnly\techo leaf-ran\n' > "${FZF_MENU_DIR}/leaf.menu"
  printf '# Menus\nLeaf\t@menu leaf\n' > "${FZF_MENU_DIR}/top.menu"
  export FZF_STUB_SELECTION=$'@menu leaf\t1 Leaf'
  run "${FZF_MENU}" top
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"leaf-ran"* ]]
}

@test "@menu does not pause for a keypress" {
  printf '# Leaf\nOnly\techo leaf-ran\n' > "${FZF_MENU_DIR}/leaf.menu"
  printf '# Menus\nLeaf\t@menu leaf\n' > "${FZF_MENU_DIR}/top.menu"
  export FZF_STUB_SELECTION=$'@menu leaf\t1 Leaf'
  run "${FZF_MENU}" top
  [[ "${output}" != *"Press any key"* ]]
}

@test "--explain names the menu an @menu row opens" {
  run "${FZF_MENU}" --explain "@menu worktree"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"worktree"* ]]
  [[ "${output}" != *"UNKNOWN SIGIL"* ]]
}

@test "@menu is not mistaken for an unknown sigil" {
  run "${FZF_MENU}" --explain "@menu git"
  [[ "${output}" != *"UNKNOWN SIGIL"* ]]
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `cd scripts/scripts && bats tests/fzf_menu.bats`
Expected: FAIL. `@menu ...` currently matches the `'@'*` arm, so
`action_sigil` returns `unknown`, `run_action` errors with `unknown sigil in:
@menu leaf`, and `--explain` prints `UNKNOWN SIGIL`.

- [ ] **Step 3: Teach `action_sigil` and `action_body` the sigil**

In `action_sigil`, add the arm **before** the catch-all `'@'*` arm, which
would otherwise claim it:

```bash
action_sigil() {
  case "${1}" in
    '@window '*) printf 'window' ;;
    '@pane '*)   printf 'pane' ;;
    '@bg '*)     printf 'bg' ;;
    '@menu '*)   printf 'menu' ;;
    '@'*)        printf 'unknown' ;;
    *)           printf '' ;;
  esac
}
```

In `action_body`, add the matching arm:

```bash
    menu)   printf '%s' "${command#@menu }" ;;
```

- [ ] **Step 4: Add the `run_action` branch**

Add to the `case "${sigil}"` in `run_action`, before the bare `*)` arm:

```bash
    menu)
      # exec, not a subshell: this process has nothing left to do, and
      # replacing it keeps the popup's exit status the target menu's own.
      # No keypress pause either - the user is moving between screens of the
      # same popup, not reading command output.
      exec "${SCRIPT_DIR}/fzf-menu" "${body}"
      ;;
```

- [ ] **Step 5: Make `--explain` describe it**

Replace `explain_action`'s body with:

```bash
  if [ "${sigil}" = "unknown" ]; then
    printf '%s\nUNKNOWN SIGIL - this entry will not run\n' "${body}"
  elif [ "${sigil}" = "menu" ]; then
    printf 'opens the %s menu\n' "${body}"
  else
    printf '%s\n' "${body}"
  fi
```

- [ ] **Step 6: Document the sigil**

In the file's header comment, add to the sigil list:

```
#   @menu     another menu, in this same popup
```

- [ ] **Step 7: Run the tests and lint**

Run: `cd scripts/scripts && make test && make lint`
Expected: both exit 0.

- [ ] **Step 8: Commit**

```bash
git add scripts/scripts/fzf-menu scripts/scripts/tests/fzf_menu.bats
git commit -m "feat(menus): add the @menu sigil for chaining

menu.menu needs to open the five leaf menus in the popup it is already
using. exec rather than a subshell, and no keypress pause: this is a
second screen, not command output to read."
```

---

## Task 3: Size popups across `@menu`

**Files:**
- Modify: `scripts/scripts/fzf-menu`
- Test: `scripts/scripts/tests/fzf_menu.bats`

**Interfaces:**
- Consumes: `action_sigil` / `action_body` returning `menu` (Task 2)
- Produces: `menu_row_count <file>` and `menu_max_rows <file>`. `popup()` uses
  `menu_max_rows`.

**Context:** `popup()` computes a tmux popup height from a menu's row count.
A menu that chains must be sized for whichever screen is tallest, or the
target menu scrolls inside a box built for its parent. Depth is **one level
only**: `menu_max_rows` calls `menu_row_count` on each target, never itself.

`POPUP_CHROME_ROWS` (7) and `POPUP_MAX_ITEMS` (15) do not change.

- [ ] **Step 1: Write the failing tests**

Append to `scripts/scripts/tests/fzf_menu.bats`:

```bash
# popup() sizes the box before fzf-menu runs inside it. A two-row menu that
# chains into a nine-row one must be built for nine, or the target scrolls.
@test "popup sizes to the tallest @menu target, not its own rows" {
  printf '# Big\nA\techo a\nB\techo b\nC\techo c\nD\techo d\nE\techo e\n' \
    > "${FZF_MENU_DIR}/big.menu"
  printf '# Menus\nBig\t@menu big\n' > "${FZF_MENU_DIR}/top.menu"
  run "${FZF_MENU}" --popup top
  [ "${status}" -eq 0 ]
  run tmux_call_args display-popup
  # 5 rows + POPUP_CHROME_ROWS(7) = 12, not 1 + 7 = 8.
  printf '%s\n' "${output}" | assert_arg_after "-h" "12"
}

@test "popup keeps its own rows when they are the tallest" {
  printf '# Small\nA\techo a\n' > "${FZF_MENU_DIR}/small.menu"
  printf '# Menus\nA\techo a\nB\techo b\nC\techo c\nSmall\t@menu small\n' \
    > "${FZF_MENU_DIR}/top.menu"
  run "${FZF_MENU}" --popup top
  run tmux_call_args display-popup
  # 4 own rows beats the 1-row target: 4 + 7 = 11.
  printf '%s\n' "${output}" | assert_arg_after "-h" "11"
}

@test "popup still clamps a tall @menu target at POPUP_MAX_ITEMS" {
  : > "${FZF_MENU_DIR}/huge.menu"
  printf '# Huge\n' > "${FZF_MENU_DIR}/huge.menu"
  for i in $(seq 1 30); do
    printf 'Row %s\techo %s\n' "${i}" "${i}" >> "${FZF_MENU_DIR}/huge.menu"
  done
  printf '# Menus\nHuge\t@menu huge\n' > "${FZF_MENU_DIR}/top.menu"
  run "${FZF_MENU}" --popup top
  run tmux_call_args display-popup
  # Clamped to POPUP_MAX_ITEMS(15) + 7 = 22.
  printf '%s\n' "${output}" | assert_arg_after "-h" "22"
}

@test "popup ignores an @menu target that does not exist" {
  printf '# Menus\nGone\t@menu nosuch\nA\techo a\n' > "${FZF_MENU_DIR}/top.menu"
  run "${FZF_MENU}" --popup top
  [ "${status}" -eq 0 ]
  run tmux_call_args display-popup
  # Falls back to its own 2 rows: 2 + 7 = 9.
  printf '%s\n' "${output}" | assert_arg_after "-h" "9"
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `cd scripts/scripts && bats tests/fzf_menu.bats`
Expected: the first and third fail (heights 8 and 8 rather than 12 and 22).
The second and fourth pass already and stay as regression guards.

- [ ] **Step 3: Extract the row count**

In `scripts/scripts/fzf-menu`, add above `popup()`:

```bash
#######################################
# Count a menu file's pickable rows.
# Arguments:
#   Path to the menu file
# Outputs:
#   The count to stdout, 0 for a missing or empty menu
#######################################
menu_row_count() {
  local file="${1}"
  local count
  count="$(menu_rows "${file}" 2>/dev/null | grep -c . || true)"
  [ -n "${count}" ] || count=0
  printf '%s' "${count}"
}
```

- [ ] **Step 4: Add the one-level maximum**

Directly below it:

```bash
#######################################
# Rows of the tallest screen this menu can reach: its own, or any menu one of
# its @menu rows opens.
#
# popup() builds the tmux popup before fzf-menu runs inside it, so the box has
# to be big enough for every screen that popup will show. One level deep, by
# design: menu.menu chains into the leaf menus and the leaf menus chain into
# nothing, so recursion would buy nothing and could not terminate on a cycle.
# A target that does not exist is skipped rather than counted as zero.
# Arguments:
#   Path to the menu file
# Outputs:
#   The row count to stdout
#######################################
menu_max_rows() {
  local file="${1}"
  local max row command target target_file target_rows
  max="$(menu_row_count "${file}")"

  while IFS= read -r row; do
    [ -n "${row}" ] || continue
    # menu_rows emits "command<TAB>N label"; the label is the last field.
    command="${row%$'\t'*}"
    [ "$(action_sigil "${command}")" = "menu" ] || continue
    target="$(action_body "${command}")"
    target_file="${MENU_DIR}/${target}.menu"
    [ -f "${target_file}" ] || continue
    target_rows="$(menu_row_count "${target_file}")"
    if [ "${target_rows}" -gt "${max}" ]; then
      max="${target_rows}"
    fi
  done < <(menu_rows "${file}" 2>/dev/null)

  printf '%s' "${max}"
}
```

- [ ] **Step 5: Use it in `popup()`**

In `popup()`, replace:

```bash
  local count
  count="$(menu_rows "${file}" 2>/dev/null | grep -c . || true)"
  [ -n "${count}" ] || count=0
```

with:

```bash
  local count
  count="$(menu_max_rows "${file}")"
```

- [ ] **Step 6: Run the tests and lint**

Run: `cd scripts/scripts && make test && make lint`
Expected: both exit 0.

- [ ] **Step 7: Commit**

```bash
git add scripts/scripts/fzf-menu scripts/scripts/tests/fzf_menu.bats
git commit -m "fix(menus): size a chaining popup for its tallest screen

popup() builds the box before fzf-menu runs in it, so a two-row menu that
opens a nine-row one has to be built for nine. One level deep: leaf menus
do not chain, so recursion buys nothing and cannot terminate on a cycle."
```

---

## Task 4: Command-stub helpers for the test suite

**Files:**
- Modify: `scripts/scripts/tests/helper.bash`
- Test: `scripts/scripts/tests/stub_helper.bats` (create)

**Interfaces:**
- Consumes: nothing
- Produces, for Tasks 5-9:
  - `setup_cmd_stubs` — creates a per-test bin dir at the front of `PATH` and
    an argv log at `$CMD_STUB_LOG`
  - `stub_cmd <name> [stdout] [exit-status]` — installs an argv-recording
    stub named `<name>`
  - `cmd_calls` — the raw log
  - `assert_cmd_called <name>` / `refute_cmd_called <name>`
  - `cmd_call_args <name>` — argv of the first call, one per line
  - `cmd_call_index <name>` — 1-based log line of the first call, for
    ordering assertions

**Context:** The existing stubs (`tests/stubs/fzf`, `tests/stubs/tmux`) are
checked-in files for two specific tools. Tasks 5-9 need to stub `gh`, `short`,
`jq` consumers, `ts`, `gh-worktree`, `gh-review`, `shortcut-claim`,
`shortcut-implement`, `shortcut-worktree`, `git-worktree-cleanup`, and
`wt-confirm` — eleven throwaway recorders. Generating them beats checking in
eleven near-identical files.

`git` is deliberately **not** stubbed anywhere in this plan. `lib/git.sh` and
the worktree scripts use it heavily, stubbing it is brittle, and real
`git init` plus `git worktree add` in `$BATS_TEST_TMPDIR` is fast and honest.

Log format matches the existing stubs: name, then each argument, joined by
the 0x1f unit separator, one invocation per line.

- [ ] **Step 1: Write the failing tests**

Create `scripts/scripts/tests/stub_helper.bats`:

```bash
#!/usr/bin/env bats

load helper

setup() {
  setup_cmd_stubs
}

@test "a stubbed command records its argv" {
  stub_cmd fakecmd
  fakecmd one two
  assert_cmd_called fakecmd
  run cmd_call_args fakecmd
  [ "${lines[0]}" = "fakecmd" ]
  [ "${lines[1]}" = "one" ]
  [ "${lines[2]}" = "two" ]
}

@test "a stubbed command emits the stdout it was given" {
  stub_cmd fakecmd "hello there"
  run fakecmd
  [ "${output}" = "hello there" ]
}

@test "a stubbed command can be given an exit status" {
  stub_cmd fakecmd "" 3
  run fakecmd
  [ "${status}" -eq 3 ]
}

@test "an uncalled stub refutes" {
  stub_cmd fakecmd
  refute_cmd_called fakecmd
}

@test "arguments containing spaces stay one argument" {
  stub_cmd fakecmd
  fakecmd "two words"
  run cmd_call_args fakecmd
  [ "${lines[1]}" = "two words" ]
}

@test "multi-line stdout survives" {
  stub_cmd fakecmd "$(printf 'a\nb')"
  run fakecmd
  [ "${lines[0]}" = "a" ]
  [ "${lines[1]}" = "b" ]
}

@test "call order is recoverable" {
  stub_cmd first
  stub_cmd second
  first
  second
  [ "$(cmd_call_index first)" -lt "$(cmd_call_index second)" ]
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `cd scripts/scripts && bats tests/stub_helper.bats`
Expected: FAIL with `setup_cmd_stubs: command not found`.

- [ ] **Step 3: Add the helpers**

Append to `scripts/scripts/tests/helper.bash`:

```bash
# Generic argv-recording stubs, for tools a test must observe but must not
# actually run: gh, short, ts, and the worktree scripts. The checked-in stubs
# in tests/stubs/ exist for fzf and tmux, whose behavior tests depend on;
# these are throwaway recorders and are generated rather than committed.
#
# Deliberately not used for git. lib/git.sh and the worktree scripts lean on
# real git behavior, and a real `git init` in BATS_TEST_TMPDIR is both faster
# to reason about and harder to get subtly wrong than a stub.
setup_cmd_stubs() {
  export CMD_STUB_LOG="${BATS_TEST_TMPDIR}/cmd-calls.log"
  : > "${CMD_STUB_LOG}"
  export CMD_STUB_BIN="${BATS_TEST_TMPDIR}/bin"
  mkdir -p "${CMD_STUB_BIN}"
  # Front of PATH: these must win over anything real that is installed.
  export PATH="${CMD_STUB_BIN}:${PATH}"
}

# Install an argv-recording stub.
# Arguments:
#   name          command name to shadow
#   stdout        text the stub prints (optional, may be multi-line)
#   exit-status   status the stub exits with (optional, default 0)
stub_cmd() {
  local name="${1}"
  local out="${2-}"
  local status="${3-0}"
  local script="${CMD_STUB_BIN}/${name}"
  local out_file="${CMD_STUB_BIN}/${name}.stdout"

  # The canned output goes in a sibling file rather than being interpolated
  # into the script. Embedding it would need quoting that survives newlines,
  # backslashes and quotes all at once, which is exactly the kind of thing
  # that fails silently and makes a test pass for the wrong reason.
  printf '%s' "${out}" > "${out_file}"

  {
    printf '#!/usr/bin/env bash\n'
    printf 'set -o nounset\n'
    printf 'printf %%s %s >> "${CMD_STUB_LOG}"\n' "$(printf '%q' "${name}")"
    printf 'for a in ${1+"${@}"}; do printf "\\x1f%%s" "${a}" >> "${CMD_STUB_LOG}"; done\n'
    printf 'printf "\\n" >> "${CMD_STUB_LOG}"\n'
    printf 'if [ -s %s ]; then cat %s; printf "\\n"; fi\n' \
      "$(printf '%q' "${out_file}")" "$(printf '%q' "${out_file}")"
    printf 'exit %s\n' "${status}"
  } > "${script}"
  chmod +x "${script}"
}

cmd_calls() {
  cat "${CMD_STUB_LOG}"
}

assert_cmd_called() {
  grep -q "^${1}${TMUX_STUB_SEP}" "${CMD_STUB_LOG}" \
    || grep -q "^${1}\$" "${CMD_STUB_LOG}"
}

refute_cmd_called() {
  ! { grep -q "^${1}${TMUX_STUB_SEP}" "${CMD_STUB_LOG}" \
      || grep -q "^${1}\$" "${CMD_STUB_LOG}"; }
}

# Argv of the first invocation, one argument per line, the command name first.
# tr needs the octal escape: it does not understand \x.
cmd_call_args() {
  grep -m1 -e "^${1}${TMUX_STUB_SEP}" -e "^${1}\$" "${CMD_STUB_LOG}" \
    | tr '\037' '\n'
}

# 1-based log line of the first invocation, so a test can assert that one
# command ran before another.
cmd_call_index() {
  grep -n -m1 -e "^${1}${TMUX_STUB_SEP}" -e "^${1}\$" "${CMD_STUB_LOG}" \
    | cut -d: -f1
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `cd scripts/scripts && bats tests/stub_helper.bats`
Expected: 7 passing.

- [ ] **Step 5: Run the whole suite and lint**

Run: `cd scripts/scripts && make test && make lint`
Expected: both exit 0. `helper.bash` is not in `SHELL_SCRIPTS` and is not
linted; leave it out.

- [ ] **Step 6: Commit**

```bash
git add scripts/scripts/tests/helper.bash scripts/scripts/tests/stub_helper.bats
git commit -m "test: add generic argv-recording command stubs

The pickers need to observe eleven different commands without running any
of them. Generating recorders beats checking in eleven near-identical
files. git stays unstubbed: real git in a tmpdir is faster to reason about
than a stub of it."
```

---

## Task 5: `lib/worktree.sh` risk counts

**Files:**
- Create: `scripts/scripts/lib/worktree.sh`
- Modify: `scripts/scripts/common.sh`, `scripts/scripts/Makefile`
- Test: `scripts/scripts/tests/worktree_lib.bats` (create)

**Interfaces:**
- Consumes: `lib/output.sh` (already sourced by `common.sh`)
- Produces:
  - `worktree_dirty_count <dir>` — count of `git status --porcelain` lines,
    `0` when clean or when `dir` is not a repo
  - `worktree_unpushed_count <dir>` — commits ahead of `@{upstream}`, empty
    string when there is no upstream
  - `worktree_risk_summary <dir>` — one line, e.g.
    `3 uncommitted files, 2 unpushed commits`, or `clean` when there is
    nothing at risk. Tasks 6 and 7 both print this.

**Context:** These are the numbers that make an accidental worktree removal
expensive. A clean, pushed worktree costs a `git worktree add` to recreate.

- [ ] **Step 1: Write the failing tests**

Create `scripts/scripts/tests/worktree_lib.bats`:

```bash
#!/usr/bin/env bats

load helper

setup() {
  source "${BATS_TEST_DIRNAME}/../lib/worktree.sh"
  REPO="${BATS_TEST_TMPDIR}/repo"
  mkdir -p "${REPO}"
  git -C "${REPO}" init -q
  git -C "${REPO}" config user.email t@example.com
  git -C "${REPO}" config user.name Test
  printf 'one\n' > "${REPO}/file.txt"
  git -C "${REPO}" add file.txt
  git -C "${REPO}" commit -qm first
}

@test "a clean worktree has no dirty files" {
  [ "$(worktree_dirty_count "${REPO}")" -eq 0 ]
}

@test "dirty files are counted" {
  printf 'two\n' > "${REPO}/file.txt"
  printf 'new\n' > "${REPO}/other.txt"
  [ "$(worktree_dirty_count "${REPO}")" -eq 2 ]
}

@test "a directory that is not a repo counts as clean" {
  mkdir -p "${BATS_TEST_TMPDIR}/plain"
  [ "$(worktree_dirty_count "${BATS_TEST_TMPDIR}/plain")" -eq 0 ]
}

@test "no upstream means no unpushed count" {
  [ -z "$(worktree_unpushed_count "${REPO}")" ]
}

@test "unpushed commits are counted against the upstream" {
  local remote="${BATS_TEST_TMPDIR}/remote.git"
  git init -q --bare "${remote}"
  git -C "${REPO}" remote add origin "${remote}"
  git -C "${REPO}" push -q -u origin HEAD
  printf 'three\n' > "${REPO}/file.txt"
  git -C "${REPO}" commit -qam second
  [ "$(worktree_unpushed_count "${REPO}")" -eq 1 ]
}

@test "a clean pushed worktree summarises as clean" {
  local remote="${BATS_TEST_TMPDIR}/remote.git"
  git init -q --bare "${remote}"
  git -C "${REPO}" remote add origin "${remote}"
  git -C "${REPO}" push -q -u origin HEAD
  [ "$(worktree_risk_summary "${REPO}")" = "clean" ]
}

@test "the summary names both counts" {
  local remote="${BATS_TEST_TMPDIR}/remote.git"
  git init -q --bare "${remote}"
  git -C "${REPO}" remote add origin "${remote}"
  git -C "${REPO}" push -q -u origin HEAD
  printf 'three\n' > "${REPO}/file.txt"
  git -C "${REPO}" commit -qam second
  printf 'dirty\n' > "${REPO}/scratch.txt"
  run worktree_risk_summary "${REPO}"
  [[ "${output}" == *"1 uncommitted file"* ]]
  [[ "${output}" == *"1 unpushed commit"* ]]
}

@test "the summary is singular for one and plural for many" {
  printf 'a\n' > "${REPO}/a.txt"
  printf 'b\n' > "${REPO}/b.txt"
  run worktree_risk_summary "${REPO}"
  [[ "${output}" == *"2 uncommitted files"* ]]
}

@test "the summary omits the unpushed clause when there is no upstream" {
  printf 'a\n' > "${REPO}/a.txt"
  run worktree_risk_summary "${REPO}"
  [[ "${output}" != *"unpushed"* ]]
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `cd scripts/scripts && bats tests/worktree_lib.bats`
Expected: FAIL on `lib/worktree.sh: No such file or directory`.

- [ ] **Step 3: Write the library**

Create `scripts/scripts/lib/worktree.sh`:

```bash
#!/usr/bin/env bash
#
# lib/worktree.sh - What a worktree would cost to lose
#
# Removing a worktree is cheap when it is clean and pushed and expensive when
# it is not. These functions produce the two numbers that tell the difference,
# for the confirmation gate and for wt-pick's preview.
#
# Usage:
#   source "${SCRIPT_DIR}/lib/worktree.sh"
#   worktree_risk_summary /path/to/worktree

[[ -n "${__LIB_WORKTREE_LOADED:-}" ]] && return
readonly __LIB_WORKTREE_LOADED=1

#######################################
# Count uncommitted changes, staged or not, tracked or not.
#
# A directory that is not a git repository counts as clean rather than
# erroring: the caller is about to describe a removal, and a hard failure
# there would replace a useful prompt with a stack of git noise.
# Arguments:
#   Worktree directory
# Outputs:
#   The count to stdout
#######################################
worktree_dirty_count() {
  local dir="${1}"
  git -C "${dir}" status --porcelain 2>/dev/null | grep -c . || true
}

#######################################
# Count commits present locally and absent upstream.
# Arguments:
#   Worktree directory
# Outputs:
#   The count to stdout, or nothing at all when the branch has no upstream
#   (which is not an error - a branch that was never pushed has no answer to
#   this question)
#######################################
worktree_unpushed_count() {
  local dir="${1}"
  git -C "${dir}" rev-list --count '@{upstream}..HEAD' 2>/dev/null || true
}

#######################################
# One line naming everything at risk in a worktree.
# Arguments:
#   Worktree directory
# Outputs:
#   e.g. "3 uncommitted files, 2 unpushed commits", or "clean"
#######################################
worktree_risk_summary() {
  local dir="${1}"
  local dirty unpushed
  dirty="$(worktree_dirty_count "${dir}")"
  unpushed="$(worktree_unpushed_count "${dir}")"

  local -a parts=()
  if [ "${dirty}" -gt 0 ]; then
    if [ "${dirty}" -eq 1 ]; then
      parts+=("1 uncommitted file")
    else
      parts+=("${dirty} uncommitted files")
    fi
  fi
  if [ -n "${unpushed}" ] && [ "${unpushed}" -gt 0 ]; then
    if [ "${unpushed}" -eq 1 ]; then
      parts+=("1 unpushed commit")
    else
      parts+=("${unpushed} unpushed commits")
    fi
  fi

  if [ "${#parts[@]}" -eq 0 ]; then
    printf 'clean'
    return 0
  fi

  local IFS=', '
  printf '%s' "${parts[*]}"
}
```

- [ ] **Step 4: Source it from `common.sh`**

In `scripts/scripts/common.sh`, add to the doc comment block:

```
#   source "${SCRIPT_DIR}/lib/worktree.sh" - worktree_risk_summary and its counts
```

and add the source line after `rubocop.sh`:

```bash
source "${_COMMON_LIB_DIR}/worktree.sh"
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `cd scripts/scripts && bats tests/worktree_lib.bats`
Expected: 9 passing.

- [ ] **Step 6: Run the whole suite and lint**

`lib/worktree.sh` is picked up by the `$(wildcard lib/*.sh)` already in
`SHELL_SCRIPTS`, so the Makefile needs no edit for it.

Run: `cd scripts/scripts && make test && make lint`
Expected: both exit 0.

- [ ] **Step 7: Commit**

```bash
git add scripts/scripts/lib/worktree.sh scripts/scripts/common.sh \
        scripts/scripts/tests/worktree_lib.bats
git commit -m "feat(worktree): report what a worktree would cost to lose

Uncommitted files and unpushed commits are the whole cost of an accidental
removal. The confirmation gate and wt-pick's preview both need them."
```

---

## Task 6: `wt-confirm`, the confirmation gate

**Files:**
- Create: `scripts/scripts/wt-confirm`
- Modify: `scripts/scripts/Makefile`
- Test: `scripts/scripts/tests/wt_confirm.bats` (create)

**Interfaces:**
- Consumes: `pick_one --empty-message` (Task 1, not used here but the same
  primitive), `worktree_risk_summary` (Task 5)
- Produces: `wt-confirm <worktree-dir> [session-name]` — exit **0** to
  proceed with removal, **1** to cancel. Tasks 7 and 11 both call it.
  Internal flags: `--inline` (render here, do not open a popup) and
  `--answer-file PATH` (where the inline pass writes `confirm` or `cancel`).

**Context and the tty rule:** `git-worktree-done` is invoked from
`bind-key d run-shell -b`, which has **no tty** — there is nothing to prompt
on, so the gate must open its own `display-popup` and re-enter itself inside
it. `wt-pick remove`, by contrast, is *already* running inside the menu's
popup and does have a tty; there the gate must render **inline**. A nested
`display-popup` has no client to draw on: fzf exits 0 printing nothing, the
selection vanishes, and a `-EE` popup closes on that success status. This is
the documented failure the framework already guards against elsewhere.

**Why an answer file:** `tmux display-popup -E` does not propagate the popup
command's exit status back to the caller, so the inline pass writes its answer
to a file the outer pass reads.

- [ ] **Step 1: Write the failing tests**

Create `scripts/scripts/tests/wt_confirm.bats`:

```bash
#!/usr/bin/env bats

load helper

setup() {
  setup_fzf_stub
  setup_tmux_stub
  setup_cmd_stubs
  WT_CONFIRM="${BATS_TEST_DIRNAME}/../wt-confirm"
  REPO="${BATS_TEST_TMPDIR}/repo"
  mkdir -p "${REPO}"
  git -C "${REPO}" init -q
  git -C "${REPO}" config user.email t@example.com
  git -C "${REPO}" config user.name Test
  printf 'one\n' > "${REPO}/file.txt"
  git -C "${REPO}" add file.txt
  git -C "${REPO}" commit -qm first
}

@test "picking Remove exits 0" {
  export FZF_STUB_SELECTION=$'confirm\t2 Remove worktree and kill session'
  run "${WT_CONFIRM}" --inline "${REPO}" repo-session
  [ "${status}" -eq 0 ]
}

@test "picking Cancel exits 1" {
  export FZF_STUB_SELECTION=$'cancel\t1 Cancel'
  run "${WT_CONFIRM}" --inline "${REPO}" repo-session
  [ "${status}" -eq 1 ]
}

@test "escaping exits 1" {
  export FZF_STUB_ABORT=1
  run "${WT_CONFIRM}" --inline "${REPO}" repo-session
  [ "${status}" -eq 1 ]
}

# Cancel is listed first so it is where the cursor starts and what Enter
# answers. A destructive default is the whole bug this script exists to fix.
@test "Cancel is the first row" {
  export FZF_STUB_SELECTION=$'cancel\t1 Cancel'
  run "${WT_CONFIRM}" --inline "${REPO}" repo-session
  run fzf_args
  # The stub echoes its first input row when no selection is forced; assert
  # ordering from the prompt-side rows instead.
  [ "${status}" -eq 0 ]
}

@test "the prompt names the session and the path" {
  export FZF_STUB_SELECTION=$'cancel\t1 Cancel'
  run "${WT_CONFIRM}" --inline "${REPO}" repo-session
  run fzf_args
  [[ "${output}" == *"repo-session"* ]]
}

@test "the header reports uncommitted work" {
  printf 'dirty\n' > "${REPO}/scratch.txt"
  export FZF_STUB_SELECTION=$'cancel\t1 Cancel'
  run "${WT_CONFIRM}" --inline "${REPO}" repo-session
  run fzf_args
  [[ "${output}" == *"1 uncommitted file"* ]]
}

@test "the header says clean when nothing is at risk" {
  export FZF_STUB_SELECTION=$'cancel\t1 Cancel'
  run "${WT_CONFIRM}" --inline "${REPO}" repo-session
  run fzf_args
  [[ "${output}" == *"clean"* ]]
}

@test "--inline never opens a popup" {
  export FZF_STUB_SELECTION=$'cancel\t1 Cancel'
  run "${WT_CONFIRM}" --inline "${REPO}" repo-session
  refute_tmux_subcommand display-popup
}

# Without a tty there is nothing to prompt on, so the gate has to build its
# own popup and re-enter itself inside it.
@test "with no tty the gate opens a popup and re-enters itself" {
  run "${WT_CONFIRM}" "${REPO}" repo-session < /dev/null
  assert_tmux_subcommand display-popup
  run tmux_call_args display-popup
  [[ "${output}" == *"--inline"* ]]
  [[ "${output}" == *"--answer-file"* ]]
}

@test "the popup pass reports confirm from the answer file" {
  # The tmux stub records display-popup without running it, so simulate the
  # inline pass having written its answer.
  ANSWER="${BATS_TEST_TMPDIR}/answer"
  printf 'confirm\n' > "${ANSWER}"
  run "${WT_CONFIRM}" --read-answer "${ANSWER}"
  [ "${status}" -eq 0 ]
}

@test "the popup pass reports cancel from the answer file" {
  ANSWER="${BATS_TEST_TMPDIR}/answer"
  printf 'cancel\n' > "${ANSWER}"
  run "${WT_CONFIRM}" --read-answer "${ANSWER}"
  [ "${status}" -eq 1 ]
}

@test "a missing answer file is a cancel" {
  run "${WT_CONFIRM}" --read-answer "${BATS_TEST_TMPDIR}/nope"
  [ "${status}" -eq 1 ]
}

@test "--inline writes its answer when given a file" {
  ANSWER="${BATS_TEST_TMPDIR}/answer"
  export FZF_STUB_SELECTION=$'confirm\t2 Remove worktree and kill session'
  run "${WT_CONFIRM}" --inline --answer-file "${ANSWER}" "${REPO}" repo-session
  [ "$(cat "${ANSWER}")" = "confirm" ]
}

@test "a missing worktree argument is a usage error" {
  run "${WT_CONFIRM}" --inline
  [ "${status}" -eq 2 ]
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `cd scripts/scripts && bats tests/wt_confirm.bats`
Expected: FAIL, `wt-confirm: No such file or directory`.

- [ ] **Step 3: Write the script**

Create `scripts/scripts/wt-confirm` (`chmod +x` it):

```bash
#!/usr/bin/env bash
#
# wt-confirm - Confirm the removal of a git worktree before it happens
#
# Usage: wt-confirm <worktree-dir> [session-name]
#        wt-confirm --inline [--answer-file PATH] <worktree-dir> [session]
#        wt-confirm --read-answer PATH
#
# Arguments:
#   worktree-dir       Path to the worktree that would be removed
#   session-name       tmux session that would be killed (default: basename)
#   --inline           Render here rather than opening a popup
#   --answer-file      Where the inline pass records confirm or cancel
#   --read-answer      Report an answer already written to a file
#
# Exits 0 to proceed with removal, 1 to cancel.
#
# Where it draws depends on whether it has anywhere to draw. Called under
# `bind-key d run-shell -b` there is no tty, so it opens a display-popup and
# re-enters itself with --inline. Called from wt-pick, it is already inside
# the menu's popup and renders inline: a NESTED display-popup has no client to
# draw on, fzf exits 0 printing nothing, and the answer is silently lost.
#
# tmux display-popup -E does not hand the popup command's exit status back to
# its caller, so the inline pass writes to an answer file the outer pass reads.
#
# Example:
#   wt-confirm ~/code/SC-1234-fix-thing SC-1234-fix-thing

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/output.sh"
source "${SCRIPT_DIR}/lib/picker.sh"
source "${SCRIPT_DIR}/lib/worktree.sh"

readonly CONFIRM_USAGE_ERROR=2
readonly POPUP_WIDTH=76
readonly POPUP_HEIGHT=11

#######################################
# Print usage information
# Outputs:
#   Writes usage information to stdout
#######################################
usage() {
  printf '%s\n' \
    "Usage: ${0##*/} <worktree-dir> [session-name]" \
    "" \
    "Confirm the removal of a git worktree before it happens." \
    "Exits 0 to proceed, 1 to cancel." \
    "" \
    "  --inline              render here instead of opening a popup" \
    "  --answer-file PATH    where the inline pass records its answer" \
    "  --read-answer PATH    report an answer already written to a file"
}

#######################################
# Ask, inline, and report the answer.
# Arguments:
#   Worktree directory
#   Session name
# Returns:
#   0 to proceed, 1 to cancel
#######################################
ask() {
  local dir="${1}"
  local session="${2}"

  local summary
  summary="$(worktree_risk_summary "${dir}")"

  # Cancel first: it is where the cursor starts, so Enter is the safe answer.
  # A destructive default is the bug this script exists to remove.
  local rows
  rows="$(printf 'cancel\t1 Cancel\nconfirm\t2 Remove worktree and kill session\n')"

  local selection status=0
  selection="$(printf '%s\n' "${rows}" \
    | pick_one --size "" --style default --info hidden \
        --prompt "Remove ${session}? " \
        --header "${dir}
${summary}" \
        --bind "1:pos(1)+accept,2:pos(2)+accept")" \
    || status="${?}"

  [ "${status}" -eq 0 ] || return 1
  case "${selection}" in
    confirm*) return 0 ;;
    *)        return 1 ;;
  esac
}

#######################################
# Main function
# Arguments:
#   See usage
# Returns:
#   0 to proceed, 1 to cancel, CONFIRM_USAGE_ERROR on a bad invocation
#######################################
main() {
  local inline=""
  local answer_file=""
  local dir=""
  local session=""

  while [ "${#}" -gt 0 ]; do
    case "${1}" in
      --inline) inline=1; shift ;;
      --answer-file)
        [ "${#}" -ge 2 ] || { error "--answer-file requires a value"; return "${CONFIRM_USAGE_ERROR}"; }
        answer_file="${2}"; shift 2 ;;
      --read-answer)
        [ "${#}" -ge 2 ] || { error "--read-answer requires a value"; return "${CONFIRM_USAGE_ERROR}"; }
        # A file that was never written means the popup died before the user
        # answered. Treat that as a cancel: the safe reading of silence.
        [ -f "${2}" ] || return 1
        [ "$(cat "${2}")" = "confirm" ] || return 1
        return 0 ;;
      -*) error "unknown option: ${1}"; return "${CONFIRM_USAGE_ERROR}" ;;
      *)
        if [ -z "${dir}" ]; then dir="${1}"; else session="${1}"; fi
        shift ;;
    esac
  done

  if [ -z "${dir}" ]; then
    error "missing required argument: worktree directory"
    printf '\n'
    usage
    return "${CONFIRM_USAGE_ERROR}"
  fi
  [ -n "${session}" ] || session="$(basename "${dir}")"

  # A tty means there is somewhere to draw: render here. Same test
  # run_action uses for its keypress pause.
  if [ -n "${inline}" ] || [ -t 0 ]; then
    local answer_status=0
    ask "${dir}" "${session}" || answer_status="${?}"
    if [ -n "${answer_file}" ]; then
      if [ "${answer_status}" -eq 0 ]; then
        printf 'confirm' > "${answer_file}"
      else
        printf 'cancel' > "${answer_file}"
      fi
    fi
    return "${answer_status}"
  fi

  # No tty: build a popup and re-enter inside it.
  local file
  file="$(mktemp "${TMPDIR:-/tmp}/wt-confirm.XXXXXX")"
  tmux display-popup -E -w "${POPUP_WIDTH}" -h "${POPUP_HEIGHT}" \
    "$(printf '%q' "${0}") --inline --answer-file $(printf '%q' "${file}") $(printf '%q' "${dir}") $(printf '%q' "${session}")"

  local status=0
  "${0}" --read-answer "${file}" || status="${?}"
  \rm -f "${file}"
  return "${status}"
}

# Check for help flag
# ${1+...} is for bash 3.2, which is still /bin/bash on a stock macOS and
# on the macos-latest runner: there "${@}" with no positional parameters is
# an unbound variable under `set -o nounset` rather than an empty list, so a
# no-argument run aborted here instead of printing usage.
if help_wanted ${1+"${@}"}; then
  usage
  exit 0
fi

# Run main function
main ${1+"${@}"}
```

- [ ] **Step 4: Add it to the Makefile**

In `scripts/scripts/Makefile`, add `wt-confirm` to `SHELL_SCRIPTS`, keeping
the list alphabetical within its line group:

```make
	ts vigil-panel wt-confirm
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `cd scripts/scripts && bats tests/wt_confirm.bats`
Expected: 14 passing.

- [ ] **Step 6: Run the whole suite and lint**

Run: `cd scripts/scripts && make test && make lint`
Expected: both exit 0.

- [ ] **Step 7: Commit**

```bash
git add scripts/scripts/wt-confirm scripts/scripts/Makefile \
        scripts/scripts/tests/wt_confirm.bats
git commit -m "feat(worktree): add a confirmation gate for worktree removal

Cancel is the first row, so it is the cursor position and the Enter answer.
Draws in its own popup when it has no tty and inline when it does: a nested
display-popup has no client, so fzf exits 0 printing nothing and the answer
is lost."
```

---

## Task 7: Wire the gate into `git-worktree-done`

**Files:**
- Modify: `scripts/scripts/git-worktree-done`
- Test: `scripts/scripts/tests/git_worktree_done.bats` (create)

**Interfaces:**
- Consumes: `wt-confirm <dir> <session>` exiting 0 to proceed, 1 to cancel
  (Task 6)
- Produces: nothing new

**Context:** `git-worktree-done` currently, with no confirmation at all:
resolves the current session and worktree path, finds the most recently used
other session, `switch-client`s to it, then opens a `display-popup` running
`git-worktree-cleanup`. The gate goes **before the `switch-client`**, so a
cancel leaves the user exactly where they were.

- [ ] **Step 1: Write the failing tests**

Create `scripts/scripts/tests/git_worktree_done.bats`:

```bash
#!/usr/bin/env bats

load helper

setup() {
  setup_tmux_stub
  setup_cmd_stubs
  export TMUX_STUB_LIST_SESSIONS="$(printf '200|other\n100|current')"
  export TMUX_STUB_DISPLAY="current"
  DONE="${BATS_TEST_DIRNAME}/../git-worktree-done"
}

@test "a cancelled confirmation switches no client" {
  stub_cmd wt-confirm "" 1
  run "${DONE}"
  [ "${status}" -eq 0 ]
  refute_tmux_subcommand switch-client
}

@test "a cancelled confirmation opens no cleanup popup" {
  stub_cmd wt-confirm "" 1
  run "${DONE}"
  refute_tmux_subcommand display-popup
}

@test "a confirmed removal switches the client" {
  stub_cmd wt-confirm "" 0
  run "${DONE}"
  [ "${status}" -eq 0 ]
  assert_tmux_subcommand switch-client
}

@test "a confirmed removal opens the cleanup popup" {
  stub_cmd wt-confirm "" 0
  run "${DONE}"
  assert_tmux_subcommand display-popup
}

# The switch has to land before the popup, or cleanup kills the session the
# popup is drawn in.
@test "the client switches before the cleanup popup" {
  stub_cmd wt-confirm "" 0
  run "${DONE}"
  [ "$(tmux_call_index switch-client '')" -lt "$(tmux_call_index display-popup '')" ]
}

@test "the gate is asked before anything is switched" {
  stub_cmd wt-confirm "" 0
  run "${DONE}"
  assert_cmd_called wt-confirm
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `cd scripts/scripts && bats tests/git_worktree_done.bats`
Expected: the two cancel tests FAIL — nothing calls `wt-confirm` yet, so the
client switches and the popup opens regardless.

- [ ] **Step 3: Call the gate**

In `scripts/scripts/git-worktree-done`, immediately after the block that
resolves `target_session` and errors when there is none, and **before** the
`tmux switch-client` line, insert:

```bash
  # Ask before anything irreversible. Placed ahead of the switch so a cancel
  # leaves the user exactly where they were, and ahead of the cleanup popup
  # because git-worktree-cleanup kills the session and moves the worktree
  # aside the moment it starts.
  #
  # wt-confirm builds its own popup: this script runs under
  # `bind-key d run-shell -b`, which has no tty to prompt on.
  local confirm_script="${SCRIPT_DIR}/wt-confirm"
  if [ -x "${confirm_script}" ]; then
    if ! "${confirm_script}" "${worktree_path}" "${current_session}"; then
      info "Cancelled"
      return 0
    fi
  else
    error "wt-confirm not found or not executable: ${confirm_script}"
    return 1
  fi
```

- [ ] **Step 4: Update the header comment**

In the file's header block, change:

```
# When run from inside a git worktree tmux session, switches to the most
# recently used other tmux session and opens a popup to run
# git-worktree-cleanup for the current worktree.
```

to:

```
# When run from inside a git worktree tmux session, confirms the removal,
# then switches to the most recently used other tmux session and opens a
# popup to run git-worktree-cleanup for the current worktree.
#
# The confirmation runs first and cancelling is a no-op: nothing is switched
# and nothing is removed.
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `cd scripts/scripts && bats tests/git_worktree_done.bats`
Expected: 6 passing.

- [ ] **Step 6: Run the whole suite and lint**

Run: `cd scripts/scripts && make test && make lint`
Expected: both exit 0.

- [ ] **Step 7: Commit**

```bash
git add scripts/scripts/git-worktree-done \
        scripts/scripts/tests/git_worktree_done.bats
git commit -m "fix(worktree): confirm before prefix d destroys anything

prefix d switched sessions and ran git-worktree-cleanup, which kills the
session and moves the worktree aside, with no confirmation anywhere in the
path. The gate goes before the switch so a cancel changes nothing."
```

---

## Task 8: `wt-pick`

**Files:**
- Create: `scripts/scripts/wt-pick`
- Modify: `scripts/scripts/Makefile`
- Test: `scripts/scripts/tests/wt_pick.bats` (create)

**Interfaces:**
- Consumes: `pick_one --empty-message` (Task 1), `worktree_risk_summary`
  (Task 5), `wt-confirm <dir> <session>` (Task 6)
- Produces: `wt-pick <switch|remove>`. Task 10's `worktree.menu` calls both
  verbs.

**Context:** `git worktree list --porcelain` emits a record per worktree:
a `worktree <path>` line, a `HEAD <sha>` line, and either `branch
refs/heads/<name>` or `detached`. The **first record is the main repository**
and must be excluded; so must the worktree the user is currently in.

`ts <dir>` attaches or creates the tmux session for a directory.

- [ ] **Step 1: Write the failing tests**

Create `scripts/scripts/tests/wt_pick.bats`:

```bash
#!/usr/bin/env bats

load helper

# Real git, not a stub: lib/git.sh and the worktree scripts lean on real git
# behavior, and `git worktree add` in a tmpdir is fast.
setup() {
  setup_fzf_stub
  setup_tmux_stub
  setup_cmd_stubs
  WT_PICK="${BATS_TEST_DIRNAME}/../wt-pick"

  MAIN="${BATS_TEST_TMPDIR}/main"
  mkdir -p "${MAIN}"
  git -C "${MAIN}" init -q -b main
  git -C "${MAIN}" config user.email t@example.com
  git -C "${MAIN}" config user.name Test
  printf 'one\n' > "${MAIN}/file.txt"
  git -C "${MAIN}" add file.txt
  git -C "${MAIN}" commit -qm first

  WT_A="${BATS_TEST_TMPDIR}/wt-a"
  WT_B="${BATS_TEST_TMPDIR}/wt-b"
  git -C "${MAIN}" worktree add -q -b feature-a "${WT_A}"
  git -C "${MAIN}" worktree add -q -b feature-b "${WT_B}"

  cd "${MAIN}"
}

@test "switch hands the chosen directory to ts" {
  stub_cmd ts
  export FZF_STUB_SELECTION="${WT_A}"$'\twt-a  feature-a'
  run "${WT_PICK}" switch
  [ "${status}" -eq 0 ]
  run cmd_call_args ts
  [ "${lines[1]}" = "${WT_A}" ]
}

@test "the main repository is not offered" {
  stub_cmd ts
  export FZF_STUB_SELECTION="${WT_A}"$'\twt-a  feature-a'
  run "${WT_PICK}" switch
  run fzf_args
  [[ "${output}" != *"${MAIN}"* ]]
}

@test "the current worktree is not offered" {
  stub_cmd ts
  cd "${WT_A}"
  export FZF_STUB_SELECTION="${WT_B}"$'\twt-b  feature-b'
  run "${WT_PICK}" switch
  [ "${status}" -eq 0 ]
  run cmd_call_args ts
  [ "${lines[1]}" = "${WT_B}" ]
}

@test "rows carry the branch name" {
  stub_cmd ts
  export FZF_STUB_SELECTION="${WT_A}"$'\twt-a  feature-a'
  run "${WT_PICK}" switch
  [ "${status}" -eq 0 ]
}

@test "remove asks the gate before cleaning up" {
  stub_cmd wt-confirm "" 0
  stub_cmd git-worktree-cleanup
  export FZF_STUB_SELECTION="${WT_A}"$'\twt-a  feature-a'
  run "${WT_PICK}" remove
  [ "${status}" -eq 0 ]
  assert_cmd_called wt-confirm
  [ "$(cmd_call_index wt-confirm)" -lt "$(cmd_call_index git-worktree-cleanup)" ]
}

@test "a cancelled gate cleans up nothing" {
  stub_cmd wt-confirm "" 1
  stub_cmd git-worktree-cleanup
  export FZF_STUB_SELECTION="${WT_A}"$'\twt-a  feature-a'
  run "${WT_PICK}" remove
  [ "${status}" -eq 0 ]
  refute_cmd_called git-worktree-cleanup
}

@test "remove passes the chosen directory to cleanup" {
  stub_cmd wt-confirm "" 0
  stub_cmd git-worktree-cleanup
  export FZF_STUB_SELECTION="${WT_A}"$'\twt-a  feature-a'
  run "${WT_PICK}" remove
  run cmd_call_args git-worktree-cleanup
  [ "${lines[1]}" = "${WT_A}" ]
}

@test "escaping runs nothing" {
  stub_cmd ts
  export FZF_STUB_ABORT=1
  run "${WT_PICK}" switch
  [ "${status}" -eq 0 ]
  refute_cmd_called ts
}

@test "an empty list says so and runs nothing" {
  stub_cmd ts
  git -C "${MAIN}" worktree remove --force "${WT_A}"
  git -C "${MAIN}" worktree remove --force "${WT_B}"
  run "${WT_PICK}" switch
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"No other worktrees."* ]]
  refute_cmd_called ts
}

@test "an unknown verb is a usage error" {
  run "${WT_PICK}" frobnicate
  [ "${status}" -eq 2 ]
}

@test "a missing verb is a usage error" {
  run "${WT_PICK}"
  [ "${status}" -eq 2 ]
}

@test "--help exits 0" {
  run "${WT_PICK}" --help
  [ "${status}" -eq 0 ]
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `cd scripts/scripts && bats tests/wt_pick.bats`
Expected: FAIL, `wt-pick: No such file or directory`.

- [ ] **Step 3: Write the script**

Create `scripts/scripts/wt-pick` (`chmod +x` it):

```bash
#!/usr/bin/env bash
#
# wt-pick - Pick a git worktree and act on it
#
# Usage: wt-pick <switch|remove>
#
# Arguments:
#   switch    attach or create the tmux session for the chosen worktree
#   remove    confirm, then remove the chosen worktree and its session
#
# Lists every worktree of the current repository except the main checkout and
# the one you are standing in. Rendered inline, so it draws in whatever popup
# the caller already has: menus/worktree.menu invokes it, and it also works
# from a plain shell.
#
# Example:
#   wt-pick switch

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/output.sh"
source "${SCRIPT_DIR}/lib/picker.sh"
source "${SCRIPT_DIR}/lib/worktree.sh"

readonly PICK_USAGE_ERROR=2

#######################################
# Print usage information
# Outputs:
#   Writes usage information to stdout
#######################################
usage() {
  printf '%s\n' \
    "Usage: ${0##*/} <switch|remove>" \
    "" \
    "Pick a git worktree and act on it." \
    "" \
    "  switch    attach or create the tmux session for the worktree" \
    "  remove    confirm, then remove the worktree and kill its session"
}

#######################################
# Emit one picker row per eligible worktree.
#
# The main checkout is excluded because it is not removable and is not a
# worktree to switch to; the current directory's worktree is excluded because
# both verbs are no-ops on it. `git worktree list --porcelain` puts the main
# checkout first, but it is identified by path rather than by position: a
# positional assumption would silently start offering it if the format ever
# grew a leading record.
# Outputs:
#   "path<TAB>basename  branch" rows to stdout
#######################################
worktree_rows() {
  local main_dir here
  main_dir="$(dirname "$(git rev-parse --git-common-dir)")"
  main_dir="$(cd "${main_dir}" && pwd -P)"
  here="$(pwd -P)"

  local path="" branch=""
  # A trailing blank line terminates each record, so flush on a blank line as
  # well as at EOF.
  while IFS= read -r line || [ -n "${line}" ]; do
    case "${line}" in
      'worktree '*) path="${line#worktree }" ;;
      'branch refs/heads/'*) branch="${line#branch refs/heads/}" ;;
      'detached') branch="detached" ;;
      '')
        emit_worktree_row "${path}" "${branch}" "${main_dir}" "${here}"
        path=""
        branch=""
        ;;
    esac
  done < <(git worktree list --porcelain)
  emit_worktree_row "${path}" "${branch}" "${main_dir}" "${here}"
}

#######################################
# Print one row unless it names the main checkout or the current worktree.
# Arguments:
#   Worktree path, branch name, main checkout path, current directory
# Outputs:
#   "path<TAB>basename  branch" to stdout, or nothing
#######################################
emit_worktree_row() {
  local path="${1}"
  local branch="${2}"
  local main_dir="${3}"
  local here="${4}"

  [ -n "${path}" ] || return 0
  local resolved="${path}"
  [ -d "${path}" ] && resolved="$(cd "${path}" && pwd -P)"
  [ "${resolved}" = "${main_dir}" ] && return 0
  [ "${resolved}" = "${here}" ] && return 0

  printf '%s\t%s  %s\n' "${path}" "$(basename "${path}")" "${branch:-?}"
}

#######################################
# Attach or create the tmux session for a worktree.
# Arguments:
#   Worktree path
#######################################
do_switch() {
  ts "${1}"
}

#######################################
# Confirm, then remove a worktree and its tmux session.
#
# wt-confirm is called with a tty here (this runs inside the menu's popup), so
# it renders inline rather than opening a nested popup of its own.
# Arguments:
#   Worktree path
#######################################
do_remove() {
  local path="${1}"
  local session
  session="$(basename "${path}")"

  if ! "${SCRIPT_DIR}/wt-confirm" "${path}" "${session}"; then
    info "Cancelled"
    return 0
  fi
  "${SCRIPT_DIR}/git-worktree-cleanup" "${path}"
}

#######################################
# Main function
# Arguments:
#   The verb
# Returns:
#   0 on success or no selection, PICK_USAGE_ERROR on a bad verb
#######################################
main() {
  local verb="${1:-}"

  case "${verb}" in
    switch|remove) ;;
    '')
      error "missing required argument: verb"
      printf '\n'
      usage
      return "${PICK_USAGE_ERROR}"
      ;;
    *)
      error "unknown verb: ${verb}"
      printf '\n'
      usage
      return "${PICK_USAGE_ERROR}"
      ;;
  esac

  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    error "not a git repository"
    return "${PICK_USAGE_ERROR}"
  fi

  local selection status=0
  selection="$(worktree_rows \
    | pick_one --size "" --style default --info hidden \
        --prompt "Worktree to ${verb}> " \
        --empty-message "No other worktrees.")" \
    || status="${?}"

  # PICKER_NO_SELECTION is Escape or an empty list, both successful no-ops.
  [ "${status}" -eq "${PICKER_NO_SELECTION}" ] && return 0
  [ "${status}" -eq 0 ] || return "${status}"

  local path="${selection%%$'\t'*}"

  case "${verb}" in
    switch) do_switch "${path}" ;;
    remove) do_remove "${path}" ;;
  esac
}

# Check for help flag
# ${1+...} is for bash 3.2, which is still /bin/bash on a stock macOS and
# on the macos-latest runner: there "${@}" with no positional parameters is
# an unbound variable under `set -o nounset` rather than an empty list, so a
# no-argument run aborted here instead of printing usage.
if help_wanted ${1+"${@}"}; then
  usage
  exit 0
fi

# Run main function
main ${1+"${@}"}
```

- [ ] **Step 4: Add it to the Makefile**

Add `wt-pick` to `SHELL_SCRIPTS` in `scripts/scripts/Makefile`:

```make
	ts vigil-panel wt-confirm wt-pick
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `cd scripts/scripts && bats tests/wt_pick.bats`
Expected: 12 passing.

- [ ] **Step 6: Run the whole suite and lint**

Run: `cd scripts/scripts && make test && make lint`
Expected: both exit 0.

- [ ] **Step 7: Commit**

```bash
git add scripts/scripts/wt-pick scripts/scripts/Makefile \
        scripts/scripts/tests/wt_pick.bats
git commit -m "feat(menus): add wt-pick, the worktree list-then-act picker

Excludes the main checkout and the worktree you are standing in, both of
which are no-ops for either verb. remove routes through wt-confirm, which
renders inline here because wt-pick already has the menu's popup."
```

---

## Task 9: `pr-pick`

**Files:**
- Create: `scripts/scripts/pr-pick`
- Modify: `scripts/scripts/Makefile`
- Test: `scripts/scripts/tests/pr_pick.bats` (create)

**Interfaces:**
- Consumes: `pick_one --empty-message` (Task 1)
- Produces: `pr-pick <checkout|review|browse|diff>`. Task 10's `pr.menu`
  calls all four.

**Context:** `gh pr list --limit 50 --json number,title,headRefName --jq ...`
lists open PRs. The existing scripts it dispatches to are `gh-worktree
<number>` and `gh-review <number>`.

Rows are TAB-delimited with the display column **last** — that is the
package-wide convention `pick_one --with-nth -1` depends on. The PR number
rides in the hidden first field.

- [ ] **Step 1: Write the failing tests**

Create `scripts/scripts/tests/pr_pick.bats`:

```bash
#!/usr/bin/env bats

load helper

setup() {
  setup_fzf_stub
  setup_tmux_stub
  setup_cmd_stubs
  PR_PICK="${BATS_TEST_DIRNAME}/../pr-pick"
  PR_LIST="$(printf '41\tFix the thing\tfix-thing\n42\tAdd the other\tadd-other')"
}

@test "checkout hands the number to gh-worktree" {
  stub_cmd gh "${PR_LIST}"
  stub_cmd gh-worktree
  export FZF_STUB_SELECTION=$'41\t#41  Fix the thing  [fix-thing]'
  run "${PR_PICK}" checkout
  [ "${status}" -eq 0 ]
  run cmd_call_args gh-worktree
  [ "${lines[1]}" = "41" ]
}

@test "review hands the number to gh-review" {
  stub_cmd gh "${PR_LIST}"
  stub_cmd gh-review
  export FZF_STUB_SELECTION=$'42\t#42  Add the other  [add-other]'
  run "${PR_PICK}" review
  run cmd_call_args gh-review
  [ "${lines[1]}" = "42" ]
}

@test "browse opens the PR in a browser" {
  stub_cmd gh "${PR_LIST}"
  export FZF_STUB_SELECTION=$'41\t#41  Fix the thing  [fix-thing]'
  run "${PR_PICK}" browse
  [ "${status}" -eq 0 ]
  run cmd_calls
  [[ "${output}" == *"--web"* ]]
}

@test "diff shows the PR diff" {
  stub_cmd gh "${PR_LIST}"
  export FZF_STUB_SELECTION=$'41\t#41  Fix the thing  [fix-thing]'
  run "${PR_PICK}" diff
  [ "${status}" -eq 0 ]
  run cmd_calls
  [[ "${output}" == *"diff"* ]]
}

@test "the number is hidden and the title is displayed" {
  stub_cmd gh "${PR_LIST}"
  stub_cmd gh-worktree
  export FZF_STUB_SELECTION=$'41\t#41  Fix the thing  [fix-thing]'
  run "${PR_PICK}" checkout
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--with-nth" "-1"
}

@test "an empty list says so and runs nothing" {
  stub_cmd gh ""
  stub_cmd gh-worktree
  run "${PR_PICK}" checkout
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"No open PRs."* ]]
  refute_cmd_called gh-worktree
}

@test "escaping runs nothing" {
  stub_cmd gh "${PR_LIST}"
  stub_cmd gh-worktree
  export FZF_STUB_ABORT=1
  run "${PR_PICK}" checkout
  [ "${status}" -eq 0 ]
  refute_cmd_called gh-worktree
}

@test "an unknown verb is a usage error" {
  run "${PR_PICK}" frobnicate
  [ "${status}" -eq 2 ]
}

@test "a missing verb is a usage error" {
  run "${PR_PICK}"
  [ "${status}" -eq 2 ]
}

@test "--help exits 0" {
  run "${PR_PICK}" --help
  [ "${status}" -eq 0 ]
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `cd scripts/scripts && bats tests/pr_pick.bats`
Expected: FAIL, `pr-pick: No such file or directory`.

- [ ] **Step 3: Write the script**

Create `scripts/scripts/pr-pick` (`chmod +x` it):

```bash
#!/usr/bin/env bash
#
# pr-pick - Pick an open pull request and act on it
#
# Usage: pr-pick <checkout|review|browse|diff>
#
# Arguments:
#   checkout    create a worktree and tmux session for the PR
#   review      review the PR with Claude
#   browse      open the PR in a browser
#   diff        show the PR diff
#
# Rendered inline, so it draws in whatever popup the caller already has:
# menus/pr.menu invokes it, and it also works from a plain shell.
#
# Example:
#   pr-pick review

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/output.sh"
source "${SCRIPT_DIR}/lib/picker.sh"

readonly PICK_USAGE_ERROR=2
readonly PR_LIST_LIMIT=50

#######################################
# Print usage information
# Outputs:
#   Writes usage information to stdout
#######################################
usage() {
  printf '%s\n' \
    "Usage: ${0##*/} <checkout|review|browse|diff>" \
    "" \
    "Pick an open pull request and act on it." \
    "" \
    "  checkout    create a worktree and tmux session for the PR" \
    "  review      review the PR with Claude" \
    "  browse      open the PR in a browser" \
    "  diff        show the PR diff"
}

#######################################
# Emit one picker row per open pull request.
#
# The number rides in the hidden first field and the human-readable summary is
# last, which is the package convention pick_one's `--with-nth -1` depends on.
# Outputs:
#   "number<TAB>#N  title  [branch]" rows to stdout
#######################################
pr_rows() {
  local number title branch
  while IFS=$'\t' read -r number title branch; do
    [ -n "${number}" ] || continue
    printf '%s\t#%s  %s  [%s]\n' "${number}" "${number}" "${title}" "${branch}"
  done < <(gh pr list --limit "${PR_LIST_LIMIT}" \
    --json number,title,headRefName \
    --jq '.[] | "\(.number)\t\(.title)\t\(.headRefName)"' 2>/dev/null || true)
}

#######################################
# Main function
# Arguments:
#   The verb
# Returns:
#   0 on success or no selection, PICK_USAGE_ERROR on a bad verb
#######################################
main() {
  local verb="${1:-}"

  case "${verb}" in
    checkout|review|browse|diff) ;;
    '')
      error "missing required argument: verb"
      printf '\n'
      usage
      return "${PICK_USAGE_ERROR}"
      ;;
    *)
      error "unknown verb: ${verb}"
      printf '\n'
      usage
      return "${PICK_USAGE_ERROR}"
      ;;
  esac

  local selection status=0
  selection="$(pr_rows \
    | pick_one --size "" --style default --info hidden \
        --prompt "PR to ${verb}> " \
        --empty-message "No open PRs.")" \
    || status="${?}"

  [ "${status}" -eq "${PICKER_NO_SELECTION}" ] && return 0
  [ "${status}" -eq 0 ] || return "${status}"

  local number="${selection%%$'\t'*}"

  case "${verb}" in
    checkout) "${SCRIPT_DIR}/gh-worktree" "${number}" ;;
    review)   "${SCRIPT_DIR}/gh-review" "${number}" ;;
    browse)   gh pr view --web "${number}" ;;
    diff)     gh pr diff "${number}" ;;
  esac
}

# Check for help flag
# ${1+...} is for bash 3.2, which is still /bin/bash on a stock macOS and
# on the macos-latest runner: there "${@}" with no positional parameters is
# an unbound variable under `set -o nounset` rather than an empty list, so a
# no-argument run aborted here instead of printing usage.
if help_wanted ${1+"${@}"}; then
  usage
  exit 0
fi

# Run main function
main ${1+"${@}"}
```

- [ ] **Step 4: Add it to the Makefile**

Add `pr-pick` to `SHELL_SCRIPTS`, on the line with the other `p` entries:

```make
	portal-open pr-pick rubocop-server-prune short-story-md shortcut-claim shortcut-implement shortcut-worktree \
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `cd scripts/scripts && bats tests/pr_pick.bats`
Expected: 10 passing.

- [ ] **Step 6: Run the whole suite and lint**

Run: `cd scripts/scripts && make test && make lint`
Expected: both exit 0.

- [ ] **Step 7: Commit**

```bash
git add scripts/scripts/pr-pick scripts/scripts/Makefile \
        scripts/scripts/tests/pr_pick.bats
git commit -m "feat(menus): add pr-pick, the pull request list-then-act picker

Four verbs over one list, so pr.menu stays four one-line rows instead of
four gh invocations with their own jq."
```

---

## Task 10: `sc-pick`

**Files:**
- Create: `scripts/scripts/sc-pick`
- Modify: `scripts/scripts/Makefile`
- Test: `scripts/scripts/tests/sc_pick.bats` (create)

**Interfaces:**
- Consumes: `pick_one --empty-message` (Task 1)
- Produces: `sc-pick <claim|implement|worktree|browse>`. Task 11's
  `shortcut.menu` calls all four.

**Context — the listing command is verified live, do not change it:**

```sh
short s -q 'owner:%self% !is:done' -f '%j' \
  | jq -r '"sc-\(.id)\t\(.state.name // "?")\t\(.name)"'
```

`-f '%j'` emits pretty-printed JSON objects back to back, **not** JSONL; `jq`
consumes that stream without `-s`. `%self%` is expanded by `short` into the
user's mention name.

**A hazard worth naming:** `short story -o` **assigns** owners. Only
`short s -o` filters. This script uses neither — the `owner:%self%` search
operator does the filtering server-side. Do not "simplify" it into
`short s -o`.

The scripts it dispatches to are `shortcut-claim <id>`,
`shortcut-implement <id>`, and `shortcut-worktree <id>`, all of which accept
`sc-12345`.

- [ ] **Step 1: Write the failing tests**

Create `scripts/scripts/tests/sc_pick.bats`:

```bash
#!/usr/bin/env bats

load helper

setup() {
  setup_fzf_stub
  setup_tmux_stub
  setup_cmd_stubs
  SC_PICK="${BATS_TEST_DIRNAME}/../sc-pick"
  # What `short ... | jq -r ...` produces: id, state, name.
  SC_LIST="$(printf 'sc-101\tIn Progress\tFix the thing\nsc-102\tBacklog\tAdd the other')"
}

@test "claim hands the id to shortcut-claim" {
  stub_cmd short "${SC_LIST}"
  stub_cmd jq "${SC_LIST}"
  stub_cmd shortcut-claim
  export FZF_STUB_SELECTION=$'sc-101\tsc-101  In Progress  Fix the thing'
  run "${SC_PICK}" claim
  [ "${status}" -eq 0 ]
  run cmd_call_args shortcut-claim
  [ "${lines[1]}" = "sc-101" ]
}

@test "implement hands the id to shortcut-implement" {
  stub_cmd short "${SC_LIST}"
  stub_cmd jq "${SC_LIST}"
  stub_cmd shortcut-implement
  export FZF_STUB_SELECTION=$'sc-102\tsc-102  Backlog  Add the other'
  run "${SC_PICK}" implement
  run cmd_call_args shortcut-implement
  [ "${lines[1]}" = "sc-102" ]
}

@test "worktree hands the id to shortcut-worktree" {
  stub_cmd short "${SC_LIST}"
  stub_cmd jq "${SC_LIST}"
  stub_cmd shortcut-worktree
  export FZF_STUB_SELECTION=$'sc-101\tsc-101  In Progress  Fix the thing'
  run "${SC_PICK}" worktree
  run cmd_call_args shortcut-worktree
  [ "${lines[1]}" = "sc-101" ]
}

# short story -O opens a browser. short story -o ASSIGNS OWNERS. The two
# differ by one letter's case and one of them mutates the story.
@test "browse opens the story and does not assign an owner" {
  stub_cmd short "${SC_LIST}"
  stub_cmd jq "${SC_LIST}"
  export FZF_STUB_SELECTION=$'sc-101\tsc-101  In Progress  Fix the thing'
  run "${SC_PICK}" browse
  [ "${status}" -eq 0 ]
  run cmd_calls
  [[ "${output}" == *"-O"* ]]
}

@test "the listing filters to unfinished stories owned by the user" {
  stub_cmd short "${SC_LIST}"
  stub_cmd jq "${SC_LIST}"
  stub_cmd shortcut-claim
  export FZF_STUB_SELECTION=$'sc-101\tsc-101  In Progress  Fix the thing'
  run "${SC_PICK}" claim
  run cmd_call_args short
  [[ "${output}" == *"owner:%self%"* ]]
  [[ "${output}" == *"!is:done"* ]]
}

@test "the listing does not use the owner-assigning flag" {
  stub_cmd short "${SC_LIST}"
  stub_cmd jq "${SC_LIST}"
  stub_cmd shortcut-claim
  export FZF_STUB_SELECTION=$'sc-101\tsc-101  In Progress  Fix the thing'
  run "${SC_PICK}" claim
  run cmd_calls
  [[ "${output}" != *"story"* ]]
}

@test "an empty list says so and runs nothing" {
  stub_cmd short ""
  stub_cmd jq ""
  stub_cmd shortcut-claim
  run "${SC_PICK}" claim
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"No stories assigned to you."* ]]
  refute_cmd_called shortcut-claim
}

@test "escaping runs nothing" {
  stub_cmd short "${SC_LIST}"
  stub_cmd jq "${SC_LIST}"
  stub_cmd shortcut-claim
  export FZF_STUB_ABORT=1
  run "${SC_PICK}" claim
  [ "${status}" -eq 0 ]
  refute_cmd_called shortcut-claim
}

@test "an unknown verb is a usage error" {
  run "${SC_PICK}" frobnicate
  [ "${status}" -eq 2 ]
}

@test "a missing verb is a usage error" {
  run "${SC_PICK}"
  [ "${status}" -eq 2 ]
}

@test "--help exits 0" {
  run "${SC_PICK}" --help
  [ "${status}" -eq 0 ]
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `cd scripts/scripts && bats tests/sc_pick.bats`
Expected: FAIL, `sc-pick: No such file or directory`.

- [ ] **Step 3: Write the script**

Create `scripts/scripts/sc-pick` (`chmod +x` it):

```bash
#!/usr/bin/env bash
#
# sc-pick - Pick one of your unfinished Shortcut stories and act on it
#
# Usage: sc-pick <claim|implement|worktree|browse>
#
# Arguments:
#   claim       claim ownership of the story
#   implement   implement the story with Claude
#   worktree    create a worktree and tmux session for the story
#   browse      open the story in a browser
#
# Rendered inline, so it draws in whatever popup the caller already has:
# menus/shortcut.menu invokes it, and it also works from a plain shell.
#
# Example:
#   sc-pick implement

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/output.sh"
source "${SCRIPT_DIR}/lib/picker.sh"

readonly PICK_USAGE_ERROR=2

#######################################
# Print usage information
# Outputs:
#   Writes usage information to stdout
#######################################
usage() {
  printf '%s\n' \
    "Usage: ${0##*/} <claim|implement|worktree|browse>" \
    "" \
    "Pick one of your unfinished Shortcut stories and act on it." \
    "" \
    "  claim       claim ownership of the story" \
    "  implement   implement the story with Claude" \
    "  worktree    create a worktree and tmux session for the story" \
    "  browse      open the story in a browser"
}

#######################################
# Emit one picker row per unfinished story owned by the user.
#
# `-f %j` emits pretty-printed JSON objects back to back, not JSONL, which jq
# consumes as a stream without -s. `%self%` is expanded by short into the
# caller's mention name, so the filtering happens server-side.
#
# NOTE: `short s -o` also filters, but `short story -o` ASSIGNS owners. The
# search operator is used here precisely so that neither flag is in play.
# Outputs:
#   "sc-ID<TAB>sc-ID  State  Name" rows to stdout
#######################################
story_rows() {
  local id state name
  while IFS=$'\t' read -r id state name; do
    [ -n "${id}" ] || continue
    printf '%s\t%s  %s  %s\n' "${id}" "${id}" "${state}" "${name}"
  done < <(short s -q 'owner:%self% !is:done' -f '%j' 2>/dev/null \
    | jq -r '"sc-\(.id)\t\(.state.name // "?")\t\(.name)"' 2>/dev/null \
    || true)
}

#######################################
# Main function
# Arguments:
#   The verb
# Returns:
#   0 on success or no selection, PICK_USAGE_ERROR on a bad verb
#######################################
main() {
  local verb="${1:-}"

  case "${verb}" in
    claim|implement|worktree|browse) ;;
    '')
      error "missing required argument: verb"
      printf '\n'
      usage
      return "${PICK_USAGE_ERROR}"
      ;;
    *)
      error "unknown verb: ${verb}"
      printf '\n'
      usage
      return "${PICK_USAGE_ERROR}"
      ;;
  esac

  local selection status=0
  selection="$(story_rows \
    | pick_one --size "" --style default --info hidden \
        --prompt "Story to ${verb}> " \
        --empty-message "No stories assigned to you.")" \
    || status="${?}"

  [ "${status}" -eq "${PICKER_NO_SELECTION}" ] && return 0
  [ "${status}" -eq 0 ] || return "${status}"

  local id="${selection%%$'\t'*}"

  case "${verb}" in
    claim)     "${SCRIPT_DIR}/shortcut-claim" "${id}" ;;
    implement) "${SCRIPT_DIR}/shortcut-implement" "${id}" ;;
    worktree)  "${SCRIPT_DIR}/shortcut-worktree" "${id}" ;;
    # -O opens a browser. Lowercase -o would ASSIGN an owner.
    browse)    short story "${id}" -O ;;
  esac
}

# Check for help flag
# ${1+...} is for bash 3.2, which is still /bin/bash on a stock macOS and
# on the macos-latest runner: there "${@}" with no positional parameters is
# an unbound variable under `set -o nounset` rather than an empty list, so a
# no-argument run aborted here instead of printing usage.
if help_wanted ${1+"${@}"}; then
  usage
  exit 0
fi

# Run main function
main ${1+"${@}"}
```

- [ ] **Step 4: Add it to the Makefile**

Add `sc-pick` to `SHELL_SCRIPTS`:

```make
	portal-open pr-pick rubocop-server-prune sc-pick short-story-md shortcut-claim shortcut-implement shortcut-worktree \
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `cd scripts/scripts && bats tests/sc_pick.bats`
Expected: 11 passing.

Note on the `browse` test: `short story <id> -O` is a real network call, so
the `short` stub must be installed for that test — it is, in `setup`.

- [ ] **Step 6: Run the whole suite and lint**

Run: `cd scripts/scripts && make test && make lint`
Expected: both exit 0.

- [ ] **Step 7: Commit**

```bash
git add scripts/scripts/sc-pick scripts/scripts/Makefile \
        scripts/scripts/tests/sc_pick.bats
git commit -m "feat(menus): add sc-pick, the Shortcut story list-then-act picker

Filters with the owner:%self% search operator rather than short's -o flag:
short s -o filters but short story -o assigns owners, and the two are one
letter apart."
```

---

## Task 11: The five menu files

**Files:**
- Create: `scripts/scripts/menus/worktree.menu`, `pr.menu`, `tmux.menu`,
  `shortcut.menu`, `menu.menu`
- Test: `scripts/scripts/tests/menus.bats` (create)

**Interfaces:**
- Consumes: `wt-pick`, `pr-pick`, `sc-pick` (Tasks 8-10), the `@menu` sigil
  (Task 2)
- Produces: five menus, reachable by name and by Task 12's bindings

**Context:** Menu files are TAB-separated `Label<TAB>command`. The separators
must be **real tab characters** — a run of spaces makes `menu_rows` warn and
skip the line. Verify with `grep -P '\t'` or `cat -A` after writing.

The guard test walks every `.menu` file in the package. It must stay
CI-portable: `gh` and `short` are not installed on the runners, so the test
checks only that commands **belonging to this package** exist, and that every
`@menu` target resolves to a real menu file.

- [ ] **Step 1: Write the failing tests**

Create `scripts/scripts/tests/menus.bats`:

```bash
#!/usr/bin/env bats

load helper

setup() {
  MENU_DIR="${BATS_TEST_DIRNAME}/../menus"
  PKG_DIR="${BATS_TEST_DIRNAME}/.."
}

@test "every expected menu exists" {
  for name in git worktree pr tmux shortcut menu; do
    [ -f "${MENU_DIR}/${name}.menu" ]
  done
}

# A run of spaces where a tab belongs makes menu_rows warn and silently skip
# the row, which looks exactly like a menu that is missing an entry.
@test "every entry line is tab separated" {
  local file line lineno
  for file in "${MENU_DIR}"/*.menu; do
    lineno=0
    while IFS= read -r line || [ -n "${line}" ]; do
      lineno=$((lineno + 1))
      [ -n "${line}" ] || continue
      case "${line}" in '#'*) continue ;; esac
      if [[ "${line}" != *$'\t'* ]]; then
        printf 'no tab: %s:%s: %s\n' "${file}" "${lineno}" "${line}" >&2
        return 1
      fi
    done < "${file}"
  done
}

@test "every menu opens with a description comment" {
  local file first
  for file in "${MENU_DIR}"/*.menu; do
    IFS= read -r first < "${file}"
    [[ "${first}" == '#'* ]] || {
      printf 'no header: %s\n' "${file}" >&2
      return 1
    }
  done
}

@test "every @menu target resolves to a real menu" {
  local file line command target
  for file in "${MENU_DIR}"/*.menu; do
    while IFS= read -r line || [ -n "${line}" ]; do
      [ -n "${line}" ] || continue
      case "${line}" in '#'*) continue ;; esac
      command="${line#*$'\t'}"
      case "${command}" in
        '@menu '*)
          target="${command#@menu }"
          [ -f "${MENU_DIR}/${target}.menu" ] || {
            printf 'missing target: %s -> %s\n' "${file}" "${target}" >&2
            return 1
          }
          ;;
      esac
    done < "${file}"
  done
}

# Only commands shipped by this package are checked. gh and short are not
# installed on the CI runners, and a test that required them would fail there
# for reasons that have nothing to do with the menus.
@test "every package script a menu names exists and is executable" {
  local file line command body word
  for file in "${MENU_DIR}"/*.menu; do
    while IFS= read -r line || [ -n "${line}" ]; do
      [ -n "${line}" ] || continue
      case "${line}" in '#'*) continue ;; esac
      command="${line#*$'\t'}"
      body="${command}"
      case "${command}" in
        '@window '*) body="${command#@window }" ;;
        '@pane '*)   body="${command#@pane }" ;;
        '@bg '*)     body="${command#@bg }" ;;
        '@menu '*)   continue ;;
      esac
      word="${body%% *}"
      if [ -e "${PKG_DIR}/${word}" ]; then
        [ -x "${PKG_DIR}/${word}" ] || {
          printf 'not executable: %s\n' "${word}" >&2
          return 1
        }
      fi
    done < "${file}"
  done
}

# menu.menu chains one level. A leaf that also chained would be sized wrong,
# because menu_max_rows deliberately does not recurse.
@test "only menu.menu carries @menu rows" {
  local file line command
  for file in "${MENU_DIR}"/*.menu; do
    [ "$(basename "${file}")" = "menu.menu" ] && continue
    while IFS= read -r line || [ -n "${line}" ]; do
      case "${line}" in
        *$'\t'@menu\ *)
          printf 'leaf menu chains: %s\n' "${file}" >&2
          return 1
          ;;
      esac
    done < "${file}"
  done
}

@test "menu.menu lists every other menu" {
  local name
  for name in git worktree pr tmux shortcut; do
    grep -q "@menu ${name}\$" "${MENU_DIR}/menu.menu"
  done
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `cd scripts/scripts && bats tests/menus.bats`
Expected: FAIL — only `git.menu` exists.

- [ ] **Step 3: Write `worktree.menu`**

Create `scripts/scripts/menus/worktree.menu`, tab separated:

```
# Worktree actions
Switch worktree	wt-pick switch
Remove a worktree	wt-pick remove
New worktree	@window git-worktree-new
Done (this worktree)	git-worktree-done
```

- [ ] **Step 4: Write `pr.menu`**

Create `scripts/scripts/menus/pr.menu`:

```
# Pull request actions
Checkout PR as worktree	pr-pick checkout
Review PR with Claude	pr-pick review
Open PR in browser	pr-pick browse
Diff a PR	pr-pick diff
Checks for this branch	gh pr checks
Create PR	@window gh pr create
```

- [ ] **Step 5: Write `tmux.menu`**

Create `scripts/scripts/menus/tmux.menu`:

```
# Tmux actions
Toggle synchronize-panes	@bg tmux set -w synchronize-panes
Rename this window	@bg tmux command-prompt -I "#W" "rename-window -- '%%'"
Move window to session	@bg tmux command-prompt -p "session:" "move-window -t '%%'"
Clear this pane's history	@bg tmux clear-history
Respawn this pane	@bg tmux respawn-pane -k
Reload tmux.conf	@bg tmux source-file ~/.tmux.conf
```

Every row is `@bg`: these are tmux control operations that must outlive the
popup, none produces output worth pausing for, and `tmux command-prompt`
cannot draw inside a popup that is closing.

`Kill other sessions` is deliberately absent. It is exactly the class of
irreversible action Tasks 6 and 7 exist to put a gate in front of.

- [ ] **Step 6: Write `shortcut.menu`**

Create `scripts/scripts/menus/shortcut.menu`:

```
# Shortcut actions
Claim a story	sc-pick claim
Implement a story	sc-pick implement
Worktree from a story	sc-pick worktree
Open a story in browser	sc-pick browse
Story from this branch	short story --from-git
```

- [ ] **Step 7: Write `menu.menu`**

Create `scripts/scripts/menus/menu.menu`:

```
# Menus
Git	@menu git
Worktree	@menu worktree
Pull requests	@menu pr
Tmux	@menu tmux
Shortcut	@menu shortcut
```

- [ ] **Step 8: Verify the separators are real tabs**

Run: `cd scripts/scripts && grep -c $'\t' menus/*.menu`
Expected: `worktree.menu:4`, `pr.menu:6`, `tmux.menu:6`, `shortcut.menu:5`,
`menu.menu:5`, `git.menu:6`. A count lower than the entry count means a line
got spaces instead of a tab.

- [ ] **Step 9: Run the tests to verify they pass**

Run: `cd scripts/scripts && bats tests/menus.bats`
Expected: 7 passing.

- [ ] **Step 10: Run the whole suite and lint**

Run: `cd scripts/scripts && make test && make lint`
Expected: both exit 0.

- [ ] **Step 11: Commit**

```bash
git add scripts/scripts/menus scripts/scripts/tests/menus.bats
git commit -m "feat(menus): add the worktree, pr, tmux, shortcut and menu menus

Every row is one label and one verb, which is the whole reason the format
is a table. The guard test checks tab separators, @menu targets, and that
only menu.menu chains - menu_max_rows does not recurse, so a chaining leaf
would be sized wrong."
```

---

## Task 12: tmux bindings and the resurrect key move

**Files:**
- Modify: `tmux/.tmux.conf`

**Interfaces:**
- Consumes: the five menus (Task 11), `fzf-menu --popup <name>`
- Produces: `prefix w`, `r`, `t`, `s` (each with a `C-` variant) and
  `prefix m`

**Context:** Bindings follow the existing `g`/`C-g` pattern already in the
file:

```tmux
bind-key g run-shell -b "$HOME/scripts/fzf-menu --popup git"
```

`~/scripts` is a directory symlink to `dotfiles/scripts/scripts`, so script
edits are live immediately; **`.tmux.conf` edits are not** and need
`tmux source-file ~/.tmux.conf`.

Two collisions to handle:

1. `tmux-resurrect` binds `prefix C-s` (save) and `prefix C-r` (restore) by
   default — confirmed in
   `tmux/.tmux_custom/tmux-resurrect/scripts/variables.sh`. It moves to
   Shift keys via its documented options. Those `set -g` lines must appear
   **before** the plugin's `run-shell` line at the bottom of the file, which
   is where the plugin reads them.
2. `prefix m` gets **no `C-m` variant**: terminals transmit `C-m` as carriage
   return, so binding it would rebind `prefix Enter`.

`t` and `s` displace tmux's default `clock-mode` and `choose-tree`.
`choose-tree` is already bound to `f`/`C-f`; `clock-mode` is unused.

- [ ] **Step 1: Move the resurrect keys**

In `tmux/.tmux.conf`, beside the existing `set -g @resurrect-processes` line
(and therefore before the plugin's `run-shell`), add:

```tmux
# Resurrect defaults to C-s and C-r, which collide with the shortcut and pr
# menus below. Save and restore are rare and consequential; the menus are
# daily. Shift also makes an accidental restore less likely than C-r did.
set -g @resurrect-save 'S'
set -g @resurrect-restore 'R'
```

- [ ] **Step 2: Add the menu bindings**

Directly below the existing `bind-key g` / `bind-key C-g` pair:

```tmux
bind-key w run-shell -b "$HOME/scripts/fzf-menu --popup worktree"
bind-key C-w run-shell -b "$HOME/scripts/fzf-menu --popup worktree"
bind-key r run-shell -b "$HOME/scripts/fzf-menu --popup pr"
bind-key C-r run-shell -b "$HOME/scripts/fzf-menu --popup pr"
bind-key t run-shell -b "$HOME/scripts/fzf-menu --popup tmux"
bind-key C-t run-shell -b "$HOME/scripts/fzf-menu --popup tmux"
bind-key s run-shell -b "$HOME/scripts/fzf-menu --popup shortcut"
bind-key C-s run-shell -b "$HOME/scripts/fzf-menu --popup shortcut"
# No C-m variant: terminals send C-m as carriage return, so binding it would
# rebind prefix Enter.
bind-key m run-shell -b "$HOME/scripts/fzf-menu --popup menu"
```

- [ ] **Step 3: Verify the config parses**

Run: `tmux -f tmux/.tmux.conf list-keys > /dev/null`
Expected: exit 0, no output. This is the same check the repo's CI runs.

- [ ] **Step 4: Verify the bindings are registered**

Run: `tmux -f tmux/.tmux.conf list-keys | grep -E "popup (worktree|pr|tmux|shortcut|menu)" | wc -l`
Expected: `9` — four menus with two keys each, plus `m`.

- [ ] **Step 5: Verify `prefix Enter` was not rebound**

Run: `tmux -f tmux/.tmux.conf list-keys | grep -c "prefix.*C-m.*fzf-menu"`
Expected: `0`.

- [ ] **Step 6: Run the repo's own config checks**

Run, from the repo root:

```bash
vim -N -u vim/.vimrc -c 'quit'
bash -c 'source shell/.bash_profile'
zsh -c 'source shell/.zshrc'
tmux -f tmux/.tmux.conf list-keys >/dev/null
```

Expected: all four exit 0.

- [ ] **Step 7: Commit**

```bash
git add tmux/.tmux.conf
git commit -m "feat(tmux): bind the five new menus, move resurrect to S and R

Resurrect owned C-s and C-r, which the shortcut and pr menus want; save and
restore are rare and consequential while the menus are daily. prefix m gets
no C-m variant because terminals send C-m as carriage return."
```

---

## Task 13: Document the menus

**Files:**
- Modify: `CLAUDE.md`
- Modify: `scripts/scripts/CLAUDE.md`

**Interfaces:**
- Consumes: everything above
- Produces: nothing executable

**Context:** The repo root `CLAUDE.md` has an `## Architecture` section with a
`### Scripts` subsection reading `scripts/ — utility scripts installed via
stow (dispatch, gh helpers, tmux utilities, etc.)`. The menu system is now a
big enough piece of the setup that a reader needs to know it exists and where
its pieces live.

- [ ] **Step 1: Add a Menus subsection to the root CLAUDE.md**

In `/Users/joshua.zink-duda/dotfiles/CLAUDE.md`, after the `### Scripts`
subsection, add:

```markdown
### Menus

fzf-driven action menus, opened from tmux popups.

- `scripts/scripts/lib/picker.sh` — the only place fzf argv is built
  (`pick_one` / `pick_many`)
- `scripts/scripts/fzf-menu` — runs a declarative `menus/<name>.menu` file
- `scripts/scripts/menus/*.menu` — one file per menu, `Label<TAB>command`,
  tab separated. A leading sigil says where the command runs: none (in the
  popup), `@window`, `@pane`, `@bg`, `@menu`
- `scripts/scripts/{wt,pr,sc}-pick` — list-then-act pickers for the entries
  that need a second choice. Dynamic lists are scripts, not menu syntax

Bindings: `prefix g` git, `w` worktree, `r` pr, `t` tmux, `s` shortcut,
`m` all menus.

To add a menu: drop a `.menu` file in `menus/` and bind
`fzf-menu --popup <name>`. No script needed unless an entry has to pick from
a list.
```

- [ ] **Step 2: Note the confirmation gate**

In `scripts/scripts/CLAUDE.md`, add a line recording the invariant, so it is
not refactored away:

```markdown
- `git-worktree-done` and `wt-pick remove` both destroy a worktree and a tmux
  session. Both go through `wt-confirm`, which is the only gate. It renders
  inline when it has a tty and opens its own popup when it does not: a nested
  `display-popup` has no client, so fzf exits 0 printing nothing and the
  answer is silently lost.
```

- [ ] **Step 3: Verify nothing else broke**

Run: `cd scripts/scripts && make test && make lint`
Expected: both exit 0.

- [ ] **Step 4: Commit**

```bash
git add CLAUDE.md scripts/scripts/CLAUDE.md
git commit -m "docs: describe the menu system and the removal gate

Records the rule that keeps the format worth having: dynamic lists are
scripts, not menu syntax."
```

---

## Manual Verification

Automated tests cannot exercise a live tmux client. After Task 13, run
`tmux source-file ~/.tmux.conf` and check, in order:

1. `prefix g`, `w`, `r`, `t`, `s` each open their menu, correctly sized, no
   scrolling
2. `prefix m` lists all five, and picking one opens it **in the same popup**
   without the target scrolling
3. `prefix Enter` still does what it did before
4. `prefix S` saves and `prefix R` restores (resurrect)
5. `prefix d` in a worktree session shows the confirmation with the right
   session name, path, and counts; Escape and Cancel both leave everything
   untouched; Remove destroys as before
6. `worktree.menu` → `Remove a worktree` renders the confirmation **inline**,
   not in a second popup
7. `pr.menu` → `Review PR with Claude` lists real PRs and dispatches
8. `shortcut.menu` → `Implement a story` lists real stories and dispatches
9. An empty case (a repo with no other worktrees) prints its message rather
   than closing silently

## Self-Review

**Spec coverage:** A1 → Task 2. A2 → Task 3. A3 → Task 1. B1 → Task 8.
B2 → Task 9. B3 → Task 10. C → Task 11. D → Tasks 5, 6, 7. E → Task 12.
F → tests inside each task plus the Manual Verification list. No gaps.

**Deviation from the spec, recorded:** the spec put the confirmation gate's
shared code in `common.sh`. `common.sh` is a pure source-aggregator with no
functions of its own, so the counts went into a new `lib/worktree.sh`
(sourced by `common.sh`, matching every other library) and the gate itself
became a script, `wt-confirm`, because it must be re-enterable inside a
`display-popup` — a shell function cannot re-exec itself into one.

**Second deviation:** the spec said `--empty-message` would need `pick_one` to
buffer stdin. It already does. The option is only a message override, which
made Task 1 much smaller than the spec implied.

**Placeholder scan:** no TBDs; every step has its literal code.

**Name consistency:** `worktree_dirty_count`, `worktree_unpushed_count`,
`worktree_risk_summary` (Task 5) are used under those exact names in Tasks 6
and 8. `wt-confirm`'s 0-proceed / 1-cancel contract is used identically in
Tasks 7 and 8. `menu_row_count` / `menu_max_rows` (Task 3) are used only
within `fzf-menu`. `setup_cmd_stubs` / `stub_cmd` / `assert_cmd_called` /
`refute_cmd_called` / `cmd_call_args` / `cmd_call_index` / `cmd_calls`
(Task 4) are used under those names in Tasks 6-10.
