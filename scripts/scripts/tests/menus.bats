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
    if [[ "${first}" != '#'* ]]; then
      printf 'no header: %s\n' "${file}" >&2
      return 1
    fi
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
          if [ ! -f "${MENU_DIR}/${target}.menu" ]; then
            printf 'missing target: %s -> %s\n' "${file}" "${target}" >&2
            return 1
          fi
          ;;
      esac
    done < "${file}"
  done
}

# Only commands shipped by this package are checked. gh and short are not
# installed on the CI runners, and a test that required them would fail there
# for reasons that have nothing to do with the menus.
@test "every package script a menu names exists and is executable" {
  local file line command body word checked=0
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
        checked=$((checked + 1))
        if [ ! -x "${PKG_DIR}/${word}" ]; then
          printf 'not executable: %s\n' "${word}" >&2
          return 1
        fi
      fi
    done < "${file}"
  done
  # Guard against the loop silently checking nothing, which would make this
  # test pass for a menu dir full of typos.
  [ "${checked}" -ge 8 ]
}

# menu.menu chains one level. A leaf that also chained would be sized wrong,
# because menu_max_rows deliberately does not recurse.
@test "only menu.menu carries @menu rows" {
  local file line
  for file in "${MENU_DIR}"/*.menu; do
    if [ "$(basename "${file}")" = "menu.menu" ]; then
      continue
    fi
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

# The pickers are the reason the menu rows stay one line each. If a verb is
# renamed and a menu is not, the row silently becomes a usage error at the
# moment the user picks it.
@test "every picker verb a menu names is a verb that picker accepts" {
  local file line command script verb
  for file in "${MENU_DIR}"/*.menu; do
    while IFS= read -r line || [ -n "${line}" ]; do
      [ -n "${line}" ] || continue
      case "${line}" in '#'*) continue ;; esac
      command="${line#*$'\t'}"
      case "${command}" in
        wt-pick\ *|pr-pick\ *|sc-pick\ *) ;;
        *) continue ;;
      esac
      script="${command%% *}"
      verb="${command#* }"
      run "${PKG_DIR}/${script}" --help
      if [[ "${output}" != *"${verb}"* ]]; then
        printf 'unknown verb: %s %s\n' "${script}" "${verb}" >&2
        return 1
      fi
    done < "${file}"
  done
}
