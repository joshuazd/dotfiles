# fzf Picker Framework Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give `scripts/` a single fzf picker primitive, a generic menu runner driven by data files, and stop the everyday fzf popup from covering the screen.

**Architecture:** Three tiers over one primitive. `lib/picker.sh` owns every fzf invocation (popup geometry, PATH bootstrap, delimiter, multi-select, exit codes). `fzf-menu` reads `menus/<name>.menu` and dispatches the selected line through a small sigil vocabulary. Bespoke pickers source the lib directly. Nothing else calls `fzf`.

**Tech Stack:** bash 3.2-compatible (stock macOS `/bin/bash` and the `macos-latest` runner), fzf 0.74+, tmux 3.x, bats for tests, shellcheck for lint.

**Spec:** `docs/superpowers/specs/2026-09-04-fzf-picker-framework-design.md`

## Global Constraints

- Target bash 3.2. No associative arrays, no `${var^^}`, no `readarray`. Use the `${1+"${@}"}` idiom when forwarding a possibly-empty argv under `set -o nounset`.
- Every lib gets a source guard: `[[ -n "${__LIB_X_LOADED:-}" ]] && return` then `readonly __LIB_X_LOADED=1`.
- Every function gets a `#######################################` doc comment block with Arguments / Outputs / Returns, matching `lib/tmux.sh`.
- Exit-code constants are `readonly` and named, matching how `lib/tmux.sh` exports `SESSION_EXISTED`.
- `make lint` must pass. Flags are `-x -P SCRIPTDIR -P SCRIPTDIR/lib -e SC2155`.
- `make test` must pass. Tests live in `scripts/scripts/tests/`, load `helper`, and stub external commands via `tests/stubs/` on `PATH`.
- No heredocs in any script (`<<EOF` is banned repo-wide). Use `printf` or a file.
- Commit messages use the `scripts:` / `shell:` / `tmux:` prefix convention already in the log.

---

### Task 1: `lib/picker.sh` — the picker primitive

**Files:**
- Create: `scripts/scripts/lib/picker.sh`
- Create: `scripts/scripts/tests/stubs/fzf`
- Create: `scripts/scripts/tests/picker_lib.bats`
- Modify: `scripts/scripts/tests/helper.bash` (append fzf stub helpers)
- Modify: `scripts/scripts/common.sh` (source the new lib, extend the usage comment)

**Interfaces:**
- Consumes: `error` and `warn` from `lib/output.sh`.
- Produces:
  - `pick_one [options] < rows` → prints one selected row, exit 0
  - `pick_many [options] < rows` → prints selected rows newline-separated, exit 0
  - `picker_bootstrap_path` → idempotently appends popup-safe dirs to `PATH`
  - `PICKER_NO_SELECTION=1`, `PICKER_UNAVAILABLE=2`, `PICKER_DEFAULT_SIZE="center,80%,70%"`
  - Options for both: `--prompt P`, `--header H`, `--with-nth N`, `--preview CMD`, `--size GEO`, `--delimiter D`

- [ ] **Step 1: Write the fzf stub**

Create `scripts/scripts/tests/stubs/fzf`, then `chmod +x` it. It records argv the way the tmux stub does and emits a canned selection.

```bash
#!/usr/bin/env bash
# Test stub for fzf. Records argv to $FZF_STUB_LOG, arguments joined by the
# unit separator so embedded spaces stay parseable, then emits a canned
# selection.
#
# FZF_STUB_SELECTION - exact text to emit as the selection
# FZF_STUB_ABORT     - when set, exit 130 (what fzf does on Escape)
set -o nounset

sep=$'\x1f'
first=1
for arg in "${@}"; do
  if [ "${first}" = 1 ]; then
    printf '%s' "${arg}" >> "${FZF_STUB_LOG}"
    first=0
  else
    printf '%s%s' "${sep}" "${arg}" >> "${FZF_STUB_LOG}"
  fi
done
printf '\n' >> "${FZF_STUB_LOG}"

# Drain stdin so the producing side never sees EPIPE.
stub_rows="$(cat)"

if [ -n "${FZF_STUB_ABORT:-}" ]; then
  exit 130
fi

if [ -n "${FZF_STUB_SELECTION+x}" ]; then
  printf '%s\n' "${FZF_STUB_SELECTION}"
else
  printf '%s\n' "${stub_rows}" | head -1
fi
```

- [ ] **Step 2: Append the fzf helpers to `tests/helper.bash`**

```bash
# The fzf stub joins argv with the unit separator, same as the tmux stub.
readonly FZF_STUB_SEP=$'\x1f'

setup_fzf_stub() {
  export FZF_STUB_LOG="${BATS_TEST_TMPDIR}/fzf-calls.log"
  : > "${FZF_STUB_LOG}"
  export PATH="${BATS_TEST_DIRNAME}/stubs:${PATH}"
}

# Print the argv of the first fzf invocation, one argument per line.
# tr needs the octal escape: it does not understand \x.
fzf_args() {
  head -1 "${FZF_STUB_LOG}" | tr '\037' '\n'
}

# Assert fzf was invoked at least once.
assert_fzf_called() {
  [ -s "${FZF_STUB_LOG}" ]
}

# Assert fzf was never invoked.
refute_fzf_called() {
  [ ! -s "${FZF_STUB_LOG}" ]
}
```

- [ ] **Step 3: Write the failing tests**

Create `scripts/scripts/tests/picker_lib.bats`:

```bash
#!/usr/bin/env bats

load helper

setup() {
  setup_fzf_stub
  source "${BATS_TEST_DIRNAME}/../lib/picker.sh"
  ROWS="${BATS_TEST_TMPDIR}/rows"
  printf 'run-me\tAlpha\nrun-other\tBravo\n' > "${ROWS}"
}

@test "pick_one returns the selected row" {
  export FZF_STUB_SELECTION=$'run-me\tAlpha'
  run pick_one < "${ROWS}"
  [ "${status}" -eq 0 ]
  [ "${output}" = $'run-me\tAlpha' ]
}

@test "pick_one displays the last field by default" {
  run pick_one < "${ROWS}"
  [ "${status}" -eq 0 ]
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--with-nth" "-1"
}

@test "pick_one requests a centered modal by default" {
  run pick_one < "${ROWS}"
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--tmux" "center,80%,70%"
}

@test "pick_one honors --size" {
  run pick_one --size "bottom,40%" < "${ROWS}"
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--tmux" "bottom,40%"
}

@test "pick_one passes prompt and header through" {
  run pick_one --prompt "Pick> " --header "Choose one" < "${ROWS}"
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--prompt" "Pick> "
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--header" "Choose one"
}

@test "pick_one does not enable multi-select" {
  run pick_one < "${ROWS}"
  run fzf_args
  [[ "${output}" != *"--multi"* ]]
}

@test "pick_many enables multi-select and select-all bindings" {
  run pick_many < "${ROWS}"
  [ "${status}" -eq 0 ]
  run fzf_args
  [[ "${output}" == *"--multi"* ]]
  printf '%s\n' "${output}" | assert_arg_after "--bind" "ctrl-a:select-all,ctrl-d:deselect-all"
}

@test "pick_many returns every selected row" {
  export FZF_STUB_SELECTION=$'run-me\tAlpha\nrun-other\tBravo'
  run pick_many < "${ROWS}"
  [ "${status}" -eq 0 ]
  [ "$(printf '%s' "${output}" | grep -c .)" -eq 2 ]
}

@test "empty stdin returns PICKER_NO_SELECTION without launching fzf" {
  : > "${BATS_TEST_TMPDIR}/empty"
  run pick_one < "${BATS_TEST_TMPDIR}/empty"
  [ "${status}" -eq 1 ]
  run refute_fzf_called
  [ "${status}" -eq 0 ]
}

@test "aborting the picker returns PICKER_NO_SELECTION" {
  export FZF_STUB_ABORT=1
  run pick_one < "${ROWS}"
  [ "${status}" -eq 1 ]
}

@test "a missing fzf returns PICKER_UNAVAILABLE" {
  # PICKER_PATH_DIRS="" disables the bootstrap. Without it the bootstrap
  # appends /opt/homebrew/bin, where the real fzf lives, and this test could
  # never observe a missing fzf no matter what PATH it set.
  PICKER_PATH_DIRS="" PATH="/usr/bin:/bin" run pick_one < "${ROWS}"
  [ "${status}" -eq 2 ]
}

@test "an unknown option returns PICKER_UNAVAILABLE" {
  run pick_one --nonsense < "${ROWS}"
  [ "${status}" -eq 2 ]
}

@test "picker_bootstrap_path is idempotent" {
  PATH="/usr/bin:/bin"
  picker_bootstrap_path
  local once="${PATH}"
  picker_bootstrap_path
  [ "${PATH}" = "${once}" ]
}
```

- [ ] **Step 4: Run the tests to verify they fail**

Run: `cd ~/dotfiles/scripts/scripts && bats tests/picker_lib.bats`
Expected: every test fails, `lib/picker.sh: No such file or directory`.

- [ ] **Step 5: Write `lib/picker.sh`**

```bash
#!/usr/bin/env bash
#
# lib/picker.sh - fzf picker primitive for popup-driven selection
#
# Owns every fzf invocation in this package: popup geometry, the PATH
# bootstrap a `tmux display-popup` needs, the TAB delimiter convention, and
# the exit-code contract. Callers supply rows on stdin and read selections
# from stdout.
#
# Rows are TAB-delimited with the DISPLAY COLUMN LAST, so `--with-nth` is
# uniform and callers can carry hidden leading fields (an id, a path, a
# session name) that the user never sees.
#
# Usage:
#   source "${SCRIPT_DIR}/lib/picker.sh"
#   printf 'run-me\tAlpha\n' | pick_one --prompt "Pick> "

[[ -n "${__LIB_PICKER_LOADED:-}" ]] && return
readonly __LIB_PICKER_LOADED=1

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/output.sh"

# Nothing was selected: the user pressed Escape, or there was nothing to show.
# This is the common path, not a failure. Callers use `|| return 0`.
readonly PICKER_NO_SELECTION=1
# The picker could not run at all: fzf is missing, or the options were bad.
readonly PICKER_UNAVAILABLE=2

# Deliberately a centered modal. This overrides the unobtrusive
# `--tmux bottom,50%` that .fzfrc sets for everyday C-t / C-r / M-c: a picker
# the user asked for by name has earned the screen, an incidental history
# search has not.
readonly PICKER_DEFAULT_SIZE="center,80%,70%"

#######################################
# Ensure PATH covers the tools a picker needs when it runs inside
# `tmux display-popup`, which starts a non-login, non-interactive shell that
# reads no profile at all.
#
# Appends rather than prepends, so a caller's own PATH choices still win, and
# skips directories already present so repeated sourcing cannot grow PATH
# without bound.
#
# The directory list comes from PICKER_PATH_DIRS, space separated. It uses
# ${VAR-default}, not ${VAR:-default}: an explicitly empty value means "add
# nothing", which is how a caller (or a test) opts out of the bootstrap
# entirely. Same idiom as the no-client case in tests/stubs/tmux.
# Outputs:
#   Exports the amended PATH
#######################################
picker_bootstrap_path() {
  local dir
  local dirs="${PICKER_PATH_DIRS-${HOME}/scripts ${HOME}/.local/bin /opt/homebrew/bin /opt/homebrew/sbin /usr/local/bin}"
  for dir in ${dirs}; do
    case ":${PATH}:" in
      *":${dir}:"*) ;;
      *) [ -d "${dir}" ] && PATH="${PATH}:${dir}" ;;
    esac
  done
  export PATH
}

#######################################
# Shared implementation behind pick_one and pick_many.
# Arguments:
#   multi - "true" to allow multi-select, "false" otherwise
#   ...   - the caller's options
# Inputs:
#   Rows on stdin
# Outputs:
#   Selected rows on stdout
# Returns:
#   0 on a selection, PICKER_NO_SELECTION if none, PICKER_UNAVAILABLE on error
#######################################
_picker_run() {
  local multi="${1}"
  shift

  local prompt="> "
  local header=""
  local with_nth="-1"
  local preview=""
  local size="${PICKER_DEFAULT_SIZE}"
  local delimiter
  delimiter=$'\t'

  while [ "${#}" -gt 0 ]; do
    case "${1}" in
      --prompt)    prompt="${2}";    shift 2 ;;
      --header)    header="${2}";    shift 2 ;;
      --with-nth)  with_nth="${2}";  shift 2 ;;
      --preview)   preview="${2}";   shift 2 ;;
      --size)      size="${2}";      shift 2 ;;
      --delimiter) delimiter="${2}"; shift 2 ;;
      *)
        error "picker: unknown option: ${1}"
        return "${PICKER_UNAVAILABLE}"
        ;;
    esac
  done

  picker_bootstrap_path

  if ! command -v fzf > /dev/null 2>&1; then
    error "fzf not found"
    return "${PICKER_UNAVAILABLE}"
  fi

  # Read stdin up front so an empty list never opens an empty modal.
  local rows
  rows="$(cat)"
  if [ -z "${rows}" ]; then
    warn "nothing to pick from"
    return "${PICKER_NO_SELECTION}"
  fi

  local -a args=(
    --ansi
    --cycle
    --layout=reverse
    --delimiter "${delimiter}"
    --with-nth "${with_nth}"
    --prompt "${prompt}"
    --tmux "${size}"
  )
  [ -n "${header}" ] && args+=(--header "${header}")
  [ -n "${preview}" ] && args+=(--preview "${preview}")
  if [ "${multi}" = "true" ]; then
    args+=(--multi --bind "ctrl-a:select-all,ctrl-d:deselect-all")
  fi

  local selection
  selection="$(printf '%s\n' "${rows}" | fzf "${args[@]}")" \
    || return "${PICKER_NO_SELECTION}"
  [ -n "${selection}" ] || return "${PICKER_NO_SELECTION}"

  printf '%s\n' "${selection}"
}

#######################################
# Pick exactly one row.
# Arguments:
#   --prompt P, --header H, --with-nth N, --preview CMD, --size GEO,
#   --delimiter D (all optional)
# Inputs:
#   TAB-delimited rows on stdin, display column last
# Outputs:
#   The selected row on stdout
# Returns:
#   0, PICKER_NO_SELECTION, or PICKER_UNAVAILABLE
#######################################
pick_one() {
  _picker_run false ${1+"${@}"}
}

#######################################
# Pick zero or more rows. Tab marks, C-a selects all, C-d deselects all.
# Arguments:
#   Same as pick_one
# Inputs:
#   TAB-delimited rows on stdin, display column last
# Outputs:
#   The selected rows on stdout, newline separated
# Returns:
#   0, PICKER_NO_SELECTION, or PICKER_UNAVAILABLE
#######################################
pick_many() {
  _picker_run true ${1+"${@}"}
}
```

- [ ] **Step 6: Run the tests to verify they pass**

Run: `cd ~/dotfiles/scripts/scripts && bats tests/picker_lib.bats`
Expected: all 13 tests PASS.

- [ ] **Step 7: Wire the lib into `common.sh`**

In `scripts/scripts/common.sh`, add to the usage comment block after the `lib/tmux.sh` line:

```
#   source "${SCRIPT_DIR}/lib/picker.sh"   — pick_one / pick_many fzf primitive
```

and add the source after the `tmux.sh` line:

```bash
source "${_COMMON_LIB_DIR}/picker.sh"
```

- [ ] **Step 8: Verify lint and the full suite still pass**

Run: `cd ~/dotfiles/scripts/scripts && make lint && make test`
Expected: shellcheck clean (`lib/*.sh` is already a wildcard, so `picker.sh` is covered), all tests pass.

- [ ] **Step 9: Commit**

```bash
cd ~/dotfiles
git add scripts/scripts/lib/picker.sh scripts/scripts/tests/picker_lib.bats \
        scripts/scripts/tests/stubs/fzf scripts/scripts/tests/helper.bash \
        scripts/scripts/common.sh
git commit -m "scripts: add lib/picker.sh fzf primitive"
```

---

### Task 2: `fzf-menu` — menu file loading and rendering

**Files:**
- Create: `scripts/scripts/fzf-menu`
- Create: `scripts/scripts/tests/fzf_menu.bats`
- Modify: `scripts/scripts/Makefile` (add `fzf-menu` to `SHELL_SCRIPTS`)

**Interfaces:**
- Consumes: `pick_one`, `PICKER_NO_SELECTION` from `lib/picker.sh`; `error`, `warn`, `info`, `help_wanted` from `lib/output.sh`.
- Produces:
  - `fzf-menu <name>` CLI
  - `FZF_MENU_DIR` env override for the menu directory (defaults to `<script dir>/menus`), which is how the tests point it at a fixture directory
  - `menu_header <file>` → header text on stdout
  - `menu_rows <file>` → `command<TAB>label` rows on stdout, warnings on stderr
  - `list_menus` → available menu names, one per line

This task stops at rendering. Selecting an entry prints the command rather than running it; Task 3 replaces that with real dispatch.

- [ ] **Step 1: Write the failing tests**

Create `scripts/scripts/tests/fzf_menu.bats`:

```bash
#!/usr/bin/env bats

load helper

# Fixtures deliberately use `echo`, never real git commands. Task 3 makes a
# bare command actually execute, and a fixture that shells out to git would
# turn this suite into a slow, side-effecting one the moment that lands.

setup() {
  setup_fzf_stub
  export FZF_MENU_DIR="${BATS_TEST_TMPDIR}/menus"
  mkdir -p "${FZF_MENU_DIR}"
  MENU="${FZF_MENU_DIR}/demo.menu"
  printf '# Demo actions\nFetch\techo fetch-ran\nStatus\techo hidden-command-ran\n' > "${MENU}"
  FZF_MENU="${BATS_TEST_DIRNAME}/../fzf-menu"
}

@test "the header comes from the first comment line" {
  export FZF_STUB_SELECTION=$'echo fetch-ran\tFetch'
  run "${FZF_MENU}" demo
  [ "${status}" -eq 0 ]
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--header" "Demo actions"
}

@test "a menu without a header comment falls back to the menu name" {
  printf 'Fetch\techo fetch-ran\n' > "${FZF_MENU_DIR}/bare.menu"
  export FZF_STUB_SELECTION=$'echo fetch-ran\tFetch'
  run "${FZF_MENU}" bare
  [ "${status}" -eq 0 ]
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--header" "bare"
}

@test "labels are the display column and commands are hidden" {
  export FZF_STUB_SELECTION=$'echo hidden-command-ran\tStatus'
  run "${FZF_MENU}" demo
  [ "${status}" -eq 0 ]
  # The marker appears whether main prints the command (this task) or runs it
  # (Task 3), so this assertion survives the dispatch change.
  [[ "${output}" == *"hidden-command-ran"* ]]
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--with-nth" "-1"
}

@test "a missing menu exits 2 and lists what is available" {
  run "${FZF_MENU}" nope
  [ "${status}" -eq 2 ]
  [[ "${output}" == *"no such menu: nope"* ]]
  [[ "${output}" == *"demo"* ]]
}

@test "a missing argument exits 2 with usage" {
  run "${FZF_MENU}"
  [ "${status}" -eq 2 ]
  [[ "${output}" == *"Usage:"* ]]
}

@test "a line with no tab is skipped with a warning" {
  printf '# Broken\nnotabhere\nStatus\techo ok\n' > "${FZF_MENU_DIR}/broken.menu"
  export FZF_STUB_SELECTION=$'echo ok\tStatus'
  run "${FZF_MENU}" broken
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"broken.menu:2"* ]]
}

@test "comment lines after the header are ignored" {
  printf '# Head\n# a note\nStatus\techo ok\n' > "${FZF_MENU_DIR}/noted.menu"
  export FZF_STUB_SELECTION=$'echo ok\tStatus'
  run "${FZF_MENU}" noted
  [ "${status}" -eq 0 ]
  run fzf_args
  [[ "${output}" != *"a note"* ]]
}

@test "aborting the picker exits 0 and runs nothing" {
  export FZF_STUB_ABORT=1
  run "${FZF_MENU}" demo
  [ "${status}" -eq 0 ]
}

@test "--help exits 0" {
  run "${FZF_MENU}" --help
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"Usage:"* ]]
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `cd ~/dotfiles/scripts/scripts && bats tests/fzf_menu.bats`
Expected: all fail, `fzf-menu: No such file or directory`.

- [ ] **Step 3: Write `fzf-menu`**

Create `scripts/scripts/fzf-menu`, then `chmod +x` it.

```bash
#!/usr/bin/env bash
#
# fzf-menu - Run a declarative menu of actions through an fzf picker
#
# Usage: fzf-menu <name>
#
# Loads <menu dir>/<name>.menu, presents its entries with pick_one, and runs
# the selected command. The menu directory defaults to `menus/` beside this
# script and can be overridden with FZF_MENU_DIR.
#
# Menu file format — one file per menu:
#   # Header shown above the picker
#   Label<TAB>command
#   Label<TAB>@window command
#
# A leading sigil on the command decides where it runs:
#   (none)    run in this popup, pause for a keypress
#   @window   new tmux window in the current pane's directory
#   @pane     send-keys into the current pane
#   @bg       detached, output appended to ~/.cache/fzf-menu.log
#
# Example:
#   fzf-menu git

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/output.sh"
source "${SCRIPT_DIR}/lib/picker.sh"

readonly MENU_DIR="${FZF_MENU_DIR:-${SCRIPT_DIR}/menus}"
readonly MENU_LOG="${HOME}/.cache/fzf-menu.log"

# Exit status for "the menu could not be run", distinct from "nothing picked",
# which is a successful no-op.
readonly MENU_UNAVAILABLE=2

#######################################
# Print usage information
# Outputs:
#   Writes usage information to stdout
#######################################
usage() {
  printf '%s\n' \
    "Usage: ${0##*/} <name>" \
    "" \
    "Run a declarative menu of actions through an fzf picker." \
    "" \
    "Menus are read from ${MENU_DIR}/<name>.menu" \
    "" \
    "Available menus:"
  local name
  for name in $(list_menus); do
    printf '  %s\n' "${name}"
  done
}

#######################################
# List the available menu names, one per line.
# Outputs:
#   Menu names to stdout, nothing if the directory is absent or empty
#######################################
list_menus() {
  local file
  for file in "${MENU_DIR}"/*.menu; do
    [ -f "${file}" ] || continue
    basename "${file}" .menu
  done
}

#######################################
# Print a menu's header: its first line with the leading "# " stripped, or
# the menu's own name when the file does not open with a comment.
# Arguments:
#   Path to the menu file
# Outputs:
#   Header text to stdout
#######################################
menu_header() {
  local file="${1}"
  local first=""
  IFS= read -r first < "${file}" || first=""
  case "${first}" in
    '#'*) printf '%s' "${first#\# }" ;;
    *)    printf '%s' "$(basename "${file}" .menu)" ;;
  esac
}

#######################################
# Convert a menu file into picker rows.
#
# Emits "command<TAB>label" so the label is the last field and pick_one's
# default --with-nth of -1 displays it while the command rides along hidden.
# A malformed line is warned about and skipped rather than aborting the menu:
# one bad row must not cost the user the other nine.
# Arguments:
#   Path to the menu file
# Outputs:
#   Rows to stdout, warnings to stderr
#######################################
menu_rows() {
  local file="${1}"
  local lineno=0
  local line label command

  while IFS= read -r line || [ -n "${line}" ]; do
    lineno=$((lineno + 1))
    [ -z "${line}" ] && continue
    case "${line}" in '#'*) continue ;; esac

    case "${line}" in
      *$'\t'*) ;;
      *)
        warn "$(basename "${file}"):${lineno}: no tab separator, skipping"
        continue
        ;;
    esac

    label="${line%%$'\t'*}"
    command="${line#*$'\t'}"
    if [ -z "${label}" ] || [ -z "${command}" ]; then
      warn "$(basename "${file}"):${lineno}: empty label or command, skipping"
      continue
    fi

    printf '%s\t%s\n' "${command}" "${label}"
  done < "${file}"
}

#######################################
# Main function
# Arguments:
#   Menu name
# Returns:
#   0 on success or on no selection, MENU_UNAVAILABLE on a bad invocation
#######################################
main() {
  local name="${1:-}"

  if [ -z "${name}" ]; then
    error "missing required argument: menu name"
    printf '\n'
    usage
    return "${MENU_UNAVAILABLE}"
  fi

  local file="${MENU_DIR}/${name}.menu"
  if [ ! -f "${file}" ]; then
    error "no such menu: ${name}"
    error "available: $(list_menus | tr '\n' ' ')"
    return "${MENU_UNAVAILABLE}"
  fi

  local rows
  rows="$(menu_rows "${file}")"

  local selection
  selection="$(printf '%s\n' "${rows}" \
    | pick_one --prompt "${name}> " --header "$(menu_header "${file}")")" \
    || return 0

  # The label is the last field and cannot contain a tab, so stripping the
  # final field leaves the command intact even if it contains tabs itself.
  local command="${selection%$'\t'*}"

  printf '%s\n' "${command}"
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

- [ ] **Step 4: Run the tests to verify they pass**

Run: `cd ~/dotfiles/scripts/scripts && bats tests/fzf_menu.bats`
Expected: all 9 tests PASS.

- [ ] **Step 5: Add `fzf-menu` to the lint list**

In `scripts/scripts/Makefile`, add `fzf-menu` to `SHELL_SCRIPTS`, keeping the list alphabetical within its line group:

```make
	claude-trust dispatch dispatch-from-chrome fzf-menu \
	gh-review gh-worktree \
```

- [ ] **Step 6: Verify lint and the full suite**

Run: `cd ~/dotfiles/scripts/scripts && make lint && make test`
Expected: clean.

- [ ] **Step 7: Commit**

```bash
cd ~/dotfiles
git add scripts/scripts/fzf-menu scripts/scripts/tests/fzf_menu.bats scripts/scripts/Makefile
git commit -m "scripts: add fzf-menu, loading and rendering .menu files"
```

---

### Task 3: `fzf-menu` — sigil dispatch

**Files:**
- Modify: `scripts/scripts/fzf-menu` (replace the `printf` at the end of `main` with `run_action`)
- Modify: `scripts/scripts/tests/fzf_menu.bats` (append dispatch tests)

**Interfaces:**
- Consumes: `pick_one` from Task 1, `menu_rows` / `menu_header` from Task 2, and the tmux stub from `tests/helper.bash` (`setup_tmux_stub`, `assert_tmux_subcommand`, `tmux_call_args`, `assert_arg_after`).
- Produces: `run_action <command>` → dispatches per sigil; returns `MENU_UNAVAILABLE` on an unknown sigil.

- [ ] **Step 1: Write the failing tests**

Append to `scripts/scripts/tests/fzf_menu.bats`. Note the added `setup_tmux_stub` call — the existing `setup()` gains one line:

```bash
@test "@window opens a new tmux window" {
  setup_tmux_stub
  printf '# Win\nEdit\t@window vim\n' > "${FZF_MENU_DIR}/win.menu"
  export FZF_STUB_SELECTION=$'@window vim\tEdit'
  run "${FZF_MENU}" win
  [ "${status}" -eq 0 ]
  run assert_tmux_subcommand "new-window"
  [ "${status}" -eq 0 ]
  run tmux_call_args "new-window"
  [[ "${output}" == *"vim"* ]]
  [[ "${output}" != *"@window"* ]]
}

@test "@pane sends keys to the current pane" {
  setup_tmux_stub
  printf '# Pane\nList\t@pane ls -la\n' > "${FZF_MENU_DIR}/pane.menu"
  export FZF_STUB_SELECTION=$'@pane ls -la\tList'
  run "${FZF_MENU}" pane
  [ "${status}" -eq 0 ]
  run tmux_call_args "send-keys"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"ls -la"* ]]
  [[ "${output}" == *"Enter"* ]]
}

@test "@bg runs detached and reports the log path" {
  setup_tmux_stub
  printf '# Bg\nTouch\t@bg touch %s/bg-ran\n' "${BATS_TEST_TMPDIR}" \
    > "${FZF_MENU_DIR}/bg.menu"
  export FZF_STUB_SELECTION="$(printf '@bg touch %s/bg-ran\tTouch' "${BATS_TEST_TMPDIR}")"
  run "${FZF_MENU}" bg
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"background"* ]]
}

@test "an unknown sigil exits 2 without running the line" {
  setup_tmux_stub
  printf '# Bad\nOops\t@nope echo hi\n' > "${FZF_MENU_DIR}/bad.menu"
  export FZF_STUB_SELECTION=$'@nope echo hi\tOops'
  run "${FZF_MENU}" bad
  [ "${status}" -eq 2 ]
  [[ "${output}" == *"unknown sigil"* ]]
  run refute_tmux_subcommand "new-window"
  [ "${status}" -eq 0 ]
}

@test "a bare command runs in the popup and reports a nonzero status" {
  setup_tmux_stub
  printf '# Bare\nFail\texit 3\n' > "${FZF_MENU_DIR}/bare2.menu"
  export FZF_STUB_SELECTION=$'exit 3\tFail'
  run "${FZF_MENU}" bare2
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"exited 3"* ]]
}

@test "a bare command's output is shown and does not block without a tty" {
  setup_tmux_stub
  printf '# Bare\nSay\techo bare-ran\n' > "${FZF_MENU_DIR}/bare3.menu"
  export FZF_STUB_SELECTION=$'echo bare-ran\tSay'
  run "${FZF_MENU}" bare3
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"bare-ran"* ]]
  [[ "${output}" != *"Press any key"* ]]
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `cd ~/dotfiles/scripts/scripts && bats tests/fzf_menu.bats`
Expected: the 6 new tests fail; the 9 from Task 2 still pass.

- [ ] **Step 3: Add `run_action` to `fzf-menu`**

Insert this function after `menu_rows` and before `main`:

```bash
#######################################
# Run a selected menu command according to its leading sigil.
#
# The sigil answers "where does this run", which is the one thing a flat
# label-to-command table cannot express and the usual reason a menu would
# otherwise have to become a script.
# Arguments:
#   The command string, sigil included
# Returns:
#   0 on success, MENU_UNAVAILABLE on an unknown sigil
#######################################
run_action() {
  local command="${1}"
  local sigil=""
  local body="${command}"

  case "${command}" in
    '@window '*) sigil="window"; body="${command#@window }" ;;
    '@pane '*)   sigil="pane";   body="${command#@pane }" ;;
    '@bg '*)     sigil="bg";     body="${command#@bg }" ;;
    '@'*)
      error "unknown sigil in: ${command}"
      return "${MENU_UNAVAILABLE}"
      ;;
  esac

  case "${sigil}" in
    window)
      tmux new-window -c "#{pane_current_path}" "${body}"
      ;;
    pane)
      tmux send-keys "${body}" Enter
      ;;
    bg)
      mkdir -p "$(dirname "${MENU_LOG}")"
      nohup sh -c "${body}" >> "${MENU_LOG}" 2>&1 &
      info "running in background, logging to ${MENU_LOG/#${HOME}/~}"
      ;;
    *)
      # A failing action must not look like a failing menu, so its status is
      # reported rather than propagated - and reported before the pause, so it
      # is readable instead of flashing past as the popup closes.
      local status=0
      sh -c "${body}" || status="${?}"
      if [ "${status}" -ne 0 ]; then
        warn "exited ${status}"
      fi
      # Only pause when there is a terminal to pause for. The prompt exists so
      # a popup does not close before its output can be read; with no tty
      # (a test, a pipe) there is nothing to wait on and blocking would hang.
      if [ -t 0 ]; then
        printf '\n'
        read -r -n 1 -p "Press any key to close... " _ || true
      fi
      ;;
  esac
}
```

- [ ] **Step 4: Call it from `main`**

Replace the final `printf '%s\n' "${command}"` in `main` with:

```bash
  run_action "${command}"
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `cd ~/dotfiles/scripts/scripts && bats tests/fzf_menu.bats`
Expected: all 15 tests PASS.

- [ ] **Step 6: Verify lint and the full suite**

Run: `cd ~/dotfiles/scripts/scripts && make lint && make test`
Expected: clean.

- [ ] **Step 7: Commit**

```bash
cd ~/dotfiles
git add scripts/scripts/fzf-menu scripts/scripts/tests/fzf_menu.bats
git commit -m "scripts: dispatch fzf-menu actions by sigil"
```

---

### Task 4: The first menu and its tmux binding

**Files:**
- Create: `scripts/scripts/menus/git.menu`
- Modify: `tmux/.tmux.conf` (add the binding in the KEY BINDINGS section)

**Interfaces:**
- Consumes: the `fzf-menu` CLI and the sigil vocabulary from Task 3.
- Produces: `prefix g` opens the git menu. `g` is currently unbound; the bound prefix keys are `" ] * % 0 C-c C-d C-f C-p C-Space C-u C-v d f j p Space u v Z`.

- [ ] **Step 1: Create the menu file**

Create `scripts/scripts/menus/git.menu`. Every separator between a label and its command must be a real TAB.

```
# Git actions
Fetch and prune	git fetch --all --prune
Status	git status
Rebase on origin/main	git rebase origin/main
Interactive rebase	@window git rebase -i origin/main
Log (graph)	@window git log --oneline --decorate --graph --all
Push (force with lease)	git push --force-with-lease
Open PR in browser	@bg gh pr view --web
```

- [ ] **Step 2: Verify the file has real tabs**

Run: `cd ~/dotfiles && grep -cP '\t' scripts/scripts/menus/git.menu`
Expected: `7` — every line except the header comment.

If it prints `0`, the editor expanded tabs to spaces. Re-create the file with `printf` instead.

- [ ] **Step 3: Verify the menu renders and dispatches**

Run: `cd ~/dotfiles && FZF_MENU_DIR=scripts/scripts/menus scripts/scripts/fzf-menu git`
Expected: a centered fzf modal headed `Git actions` listing seven labels with no commands visible. Escape closes it with exit 0.

- [ ] **Step 4: Add the tmux binding**

In `tmux/.tmux.conf`, in the `### KEY BINDINGS ###` section under `# Utilities`, add:

```tmux
bind-key g display-popup -E -w 80% -h 70% "$HOME/scripts/fzf-menu git"
bind-key C-g display-popup -E -w 80% -h 70% "$HOME/scripts/fzf-menu git"
```

The `C-g` duplicate matches the existing convention where `v`/`C-v`, `p`/`C-p`, `u`/`C-u`, `d`/`C-d`, and `f`/`C-f` are all bound in pairs.

- [ ] **Step 5: Verify the config parses**

Run: `cd ~/dotfiles && tmux -f tmux/.tmux.conf list-keys > /dev/null && echo OK`
Expected: `OK`.

- [ ] **Step 6: Reload and exercise the binding**

Run: `tmux source-file ~/.tmux.conf`
Then press `prefix g`. Expected: the git menu opens in a popup. Pick "Status" and confirm the output appears and waits for a keypress.

- [ ] **Step 7: Commit**

```bash
cd ~/dotfiles
git add scripts/scripts/menus/git.menu tmux/.tmux.conf
git commit -m "scripts: add the git menu and bind it to prefix g"
```

---

### Task 5: Config changes — unobtrusive fzf and readable Claude windows

**Files:**
- Modify: `shell/.fzfrc:10` (the `--tmux` line)
- Modify: `tmux/.tmux_custom/colors/nord.tmux` (both window-status format lines)

**Interfaces:**
- Consumes: nothing. Independent of Tasks 1-4, but shares their motivation.
- Produces: everyday fzf docks to the bottom half; `PICKER_DEFAULT_SIZE` from Task 1 is what opts pickers back into a centered modal.

- [ ] **Step 1: Dock the everyday fzf popup**

In `shell/.fzfrc`, replace:

```
--tmux 90%,70%
```

with:

```
--tmux bottom,50%
```

`--tmux` defaults to `center`, so `90%,70%` was a centered modal covering roughly 63% of the screen, which is what buries the content being referenced. `bottom,50%` pins it to the lower half and leaves the top half readable.

- [ ] **Step 2: Verify the new geometry**

Run: `printf 'alpha\nbravo\ncharlie\n' | fzf`
Expected: the picker occupies the bottom half of the window; the top half still shows prior terminal output. Escape to dismiss.

- [ ] **Step 3: Show the Claude task title in the window list**

In `tmux/.tmux_custom/colors/nord.tmux`, in BOTH `window-status-current-format` and `window-status-format`, replace `#I:#W` with:

```
#I:#{?#{||:#{m:SC-*,#{session_name}},#{m:PR-*,#{session_name}}},#W,#{?#{m:✳ *,#{pane_title}},#{=24:pane_title},#W}}
```

The two lines become:

```tmux
setw -g window-status-current-format '#[fg=colour4,bg=colour0] #I:#{?#{||:#{m:SC-*,#{session_name}},#{m:PR-*,#{session_name}}},#W,#{?#{m:✳ *,#{pane_title}},#{=24:pane_title},#W}}#{?#{&&:#{==:#{window_name},claude},#{window_bell_flag}},✦,#F} '
setw -g window-status-format ' #I:#{?#{||:#{m:SC-*,#{session_name}},#{m:PR-*,#{session_name}}},#W,#{?#{m:✳ *,#{pane_title}},#{=24:pane_title},#W}}#{?#{&&:#{==:#{window_name},claude},#{window_bell_flag}},✦,#F} '
```

Claude Code renames its own window to `claude`, which sets that window's `automatic-rename` to 0 — so an ad-hoc Claude window is indistinguishable from the one `create_tmux_session` creates with `-n claude`, and neither the window name nor `pane_current_command` (the versioned binary, e.g. `2.1.260`) tells them apart. `pane_title` already carries a per-window task summary; this displays it.

**Dispatched sessions are deliberately excluded** so their windows keep reading `claude` and `server`. Since no window-level attribute separates the two cases, the gate is the session name: `session_name_from_title` always prefixes a dispatched session with `SC-` or `PR-`. If that prefix convention ever changes, this expression must change with it.

- [ ] **Step 4: Verify the format expression against live windows**

Run:
```bash
tmux list-windows -a -F 'sess=#{session_name} -> [#{?#{||:#{m:SC-*,#{session_name}},#{m:PR-*,#{session_name}}},#W,#{?#{m:✳ *,#{pane_title}},#{=24:pane_title},#W}}]'
```
Expected: `SC-*` and `PR-*` sessions print `claude` / `server` / `zsh` unchanged; other sessions print the Claude task summary truncated to 24 characters, and non-Claude windows there still print their names.

- [ ] **Step 5: Verify the config parses, then reload**

Run: `cd ~/dotfiles && tmux -f tmux/.tmux.conf list-keys > /dev/null && echo OK`
Expected: `OK`.

Then: `tmux source-file ~/.tmux.conf`
Expected: the `main` session's window list changes from four windows all reading `claude` to four distinct task summaries. Switch to any `SC-*` or `PR-*` session and confirm its windows still read `claude` and `server`.

- [ ] **Step 6: Commit**

```bash
cd ~/dotfiles
git add shell/.fzfrc tmux/.tmux_custom/colors/nord.tmux
git commit -m "shell: dock the fzf popup and show Claude task titles in tmux"
```

---

## Verification

After all five tasks:

```bash
cd ~/dotfiles/scripts/scripts && make lint && make test
cd ~/dotfiles && tmux -f tmux/.tmux.conf list-keys > /dev/null && echo "tmux OK"
bash -c 'source shell/.bash_profile' && echo "bash OK"
zsh -c 'source shell/.zshrc' && echo "zsh OK"
```

Manual: `prefix g` opens the git menu; `C-r` docks to the bottom half; the `main` session's window list shows distinct Claude task titles while `SC-*` / `PR-*` sessions still read `claude` and `server`.
