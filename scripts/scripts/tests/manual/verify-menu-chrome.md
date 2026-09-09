# Measuring MENU_CHROME_ROWS

`MENU_CHROME_ROWS` in `lib/menu.sh` decides when `menu_or_pick` gives up on a
native menu and falls back to fzf. Getting it wrong is not cosmetic:

> `man tmux`: If the menu is too large to fit on the terminal, it is not
> displayed.

Too large a value only means falling back to fzf a little early. Too small
means tmux silently draws nothing, which reads as a broken keybinding. It is
therefore set generously (4) and should only ever be **lowered** against a
measurement.

## This cannot be measured headlessly

Two approaches were tried and both fail. Do not spend an evening rediscovering
them:

1. **Query `popup_height` while the menu is open.** It reads empty from a
   separate `tmux display-message`; the variable only resolves inside the
   menu's own format context.
2. **Open a menu in the background and `send-keys` its shortcut.** `send-keys`
   targets a *pane*. A menu consumes keys at the *client* level, so the key
   never reaches it - the probe reports "not shown" even for a three-item menu
   that plainly fits.

`display-menu` also blocks while its menu is open, so probes cannot be batched
into one script: the second call never runs.

## The live procedure

In a real client, with `lib/menu.sh` sourced:

```sh
# 1. What is the client height?
tmux display-message -p '#{client_height}'

# 2. Resize the terminal down until a known menu stops appearing.
#    git.menu has 6 entries, so it needs 6 + MENU_CHROME_ROWS rows.
#    Shrink one row at a time and press `prefix g` after each.
```

The height at which `prefix g` shows **nothing at all** (rather than falling
back to fzf) would mean the constant is too small. With the fallback in place
you should instead see the fzf popup take over one row *before* the menu would
have vanished - that gap is the row of slack the constant includes.

If a native menu ever fails to appear while `menu_fits` says it should,
increase `MENU_CHROME_ROWS` by the difference and record the measurement here.

## Measurements

| Date | tmux | Client height | Entries | Result |
|---|---|---|---|---|
| 2026-09-06 | 3.7c | - | - | Not yet measured. Constant set to 4 on the reasoning that a border is 2 rows, the title 1, plus 1 of slack. |
