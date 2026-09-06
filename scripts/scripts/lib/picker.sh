#!/usr/bin/env bash
#
# lib/picker.sh - fzf picker primitive for popup-driven selection
#
# Owns every fzf invocation's argv in this package: popup geometry, the PATH
# bootstrap a `tmux display-popup` needs, the TAB delimiter convention, and
# the exit-code contract. It does not neutralize FZF_DEFAULT_OPTS or
# FZF_DEFAULT_OPTS_FILE, so the user's `.fzfrc` binds still apply underneath -
# explicit argv here wins wherever the two conflict. Callers supply rows on
# stdin and read selections from stdout.
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
# There was nothing to pick from. Distinct from PICKER_NO_SELECTION because a
# caller has to tell "the user backed out" from "we told the user there was
# nothing here": the first should close silently, the second leaves a message
# on screen that the user has to be given time to read.
readonly PICKER_EMPTY=3
# A caller ran, decided nothing happened, and wants its popup closed without
# the "Press any key" pause. fzf-menu's bare-command branch honours this; from
# a plain shell it is just an unusual exit status.
# shellcheck disable=SC2034 # used by fzf-menu and the *-pick scripts
readonly PICKER_QUIET_EXIT=97

# Deliberately a centered modal. This overrides the unobtrusive
# `--tmux bottom,50%` that .fzfrc sets for everyday C-t / C-r / M-c: a picker
# the user asked for by name has earned the screen, an incidental history
# search has not.
#
# ONLY for a picker invoked from a normal pane. A caller that is already
# inside a `tmux display-popup` must pass `--size ""` and render inline
# instead: `--tmux` spawns a nested popup, and with no client for that popup
# to draw on fzf exits 0 having printed nothing, so the selection vanishes
# rather than erroring. `fzf-menu` therefore always passes `--size ""`.
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
  local preview_window=""
  local header_label=""
  local preview_label=""
  local extra_bind=""
  local style=""
  local info=""
  local empty_message=""
  local size="${PICKER_DEFAULT_SIZE}"
  local delimiter
  delimiter=$'\t'

  while [ "${#}" -gt 0 ]; do
    case "${1}" in
      --prompt|--header|--header-label|--with-nth|--preview|--preview-window|--preview-label|--bind|--style|--info|--size|--delimiter|--empty-message)
        if [ "${#}" -lt 2 ]; then
          error "picker: ${1} requires a value"
          return "${PICKER_UNAVAILABLE}"
        fi
        ;;
    esac
    case "${1}" in
      --prompt)    prompt="${2}";    shift 2 ;;
      --header)    header="${2}";    shift 2 ;;
      --with-nth)  with_nth="${2}";  shift 2 ;;
      --header-label) header_label="${2}"; shift 2 ;;
      --preview)   preview="${2}";   shift 2 ;;
      --preview-window) preview_window="${2}"; shift 2 ;;
      --preview-label)  preview_label="${2}";  shift 2 ;;
      --bind)      extra_bind="${2}";  shift 2 ;;
      --style)     style="${2}";       shift 2 ;;
      --info)      info="${2}";        shift 2 ;;
      --empty-message) empty_message="${2}"; shift 2 ;;
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
    # A caller that knows what its rows are can say what "none" means. The
    # generic text is right for a library and useless in a popup that just
    # closed on the user.
    warn "${empty_message:-nothing to pick from}"
    return "${PICKER_EMPTY}"
  fi

  # --margin is TRBL and leaves blank cells OUTSIDE fzf's border (--padding is
  # inside it). Those blanks are the flicker mitigation: tmux repaints an
  # overlay's outermost cells when a pane flushes a DECSET 2026 frame, and
  # anything drawn there tears - border glyphs, ASCII glyphs and title text
  # all do, while blank cells have nothing to tear.
  #
  # Bottom is 0 because the tearing was only ever reported on the top edge,
  # and a blank row there is one row of popup height spent on nothing. If the
  # bottom border starts tearing, this is the line to change back to 1.
  #
  # --style is not set by default: the per-section borders and labels are the
  # user's aesthetic and a picker has no business replacing them. A caller
  # that wants a simpler frame asks for one explicitly.
  # --padding is, because it is pure spacing rather than style - two rows of
  # it inside a popup sized to its contents is two rows the entries could
  # have had, and the popup's own edge already provides the breathing room
  # the padding exists for in a full-screen finder.
  local -a args=(
    --ansi
    --cycle
    --layout=reverse
    --padding 0
    --margin "1,1,0,1"
    --delimiter "${delimiter}"
    --with-nth "${with_nth}"
    --prompt "${prompt}"
  )
  # An empty --size means "render inline, fill whatever we are already in".
  # This is not a nicety: `--tmux` makes fzf re-launch itself in a NEW tmux
  # popup, and when there is no client for that popup to draw on - which is
  # the case inside an existing `display-popup` - fzf exits 0 with EMPTY
  # output. The selection is silently lost, the caller reads it as "nothing
  # picked", and a `-EE` popup closes on the success status. That is exactly
  # the "popup flashes and nothing happens" symptom fzf-menu shipped with.
  if [ -n "${size}" ]; then
    args+=(--tmux "${size}")
  else
    args+=(--height 100%)
  fi
  [ -n "${style}" ] && args+=(--style "${style}")
  [ -n "${info}" ] && args+=(--info "${info}")
  [ -n "${header}" ] && args+=(--header "${header}")
  # ~/.fzfrc hardcodes `--header-label ' File Type '`, which is right for a
  # file finder and nonsense over a list of actions. A caller that knows what
  # its rows are should say so.
  [ -n "${header_label}" ] && args+=(--header-label "${header_label}")
  # A picker's rows are arbitrary TAB-delimited records, not filenames, so the
  # user's ~/.fzfrc `--preview` (which shells out to a file previewer on {})
  # would run against a command string or a session id and render an error
  # pane. Explicitly disable it unless this caller asked for one of its own;
  # argv beats FZF_DEFAULT_OPTS_FILE, so this is what turns the bleed-through
  # off.
  if [ -n "${preview}" ]; then
    args+=(--preview "${preview}")
    [ -n "${preview_window}" ] && args+=(--preview-window "${preview_window}")
    if [ -n "${preview_label}" ]; then
      # The static label is not enough on its own: ~/.fzfrc binds
      # `focus:transform-preview-label` to print "Previewing [<row>]", and that
      # transform rewrites the label on every focus event, clobbering whatever
      # --preview-label set. Re-binding the same event in argv replaces the
      # file's bind, which is what actually makes the label stick.
      args+=(--preview-label "${preview_label}")
      args+=(--bind "focus:transform-preview-label:printf '%s' $(printf '%q' "${preview_label}")")
    fi
  else
    args+=(--no-preview)
  fi
  if [ "${multi}" = "true" ]; then
    args+=(--multi --bind "ctrl-a:select-all,ctrl-d:deselect-all")
  fi
  # A caller's own bindings come last so they win over anything above.
  [ -n "${extra_bind}" ] && args+=(--bind "${extra_bind}")

  local selection fzf_status=0
  selection="$(printf '%s\n' "${rows}" | fzf "${args[@]}")" || fzf_status="${?}"
  if [ "${fzf_status}" -eq 2 ]; then
    error "fzf exited with an error"
    return "${PICKER_UNAVAILABLE}"
  fi
  [ "${fzf_status}" -eq 0 ] || return "${PICKER_NO_SELECTION}"
  [ -n "${selection}" ] || return "${PICKER_NO_SELECTION}"

  printf '%s\n' "${selection}"
}

#######################################
# Pick exactly one row.
# Arguments:
#   --prompt P, --header H, --header-label L, --with-nth N, --preview CMD,
#   --preview-window W, --preview-label L, --bind SPEC, --style STYLE,
#   --info STYLE, --empty-message TEXT,
#   --size GEO,
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
