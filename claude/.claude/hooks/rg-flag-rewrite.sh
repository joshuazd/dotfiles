#!/bin/bash
# Rewrite ripgrep's `-r<letters>` short-flag clusters (e.g. `rg -rn`, `rg -rln`)
# to drop the `r`. In grep `-r` means recursive, but ripgrep recurses by default
# and `-r`/`--replace` consumes the next chars as a replacement string, so `-rn`
# is parsed as --replace=n and silently rewrites every match to "n" in output.
#
# Scoped to `rg` command segments only: `grep -rn`, `cp -r`, `rm -r`, `chmod -R`
# etc. are left untouched. A standalone `-r <value>` (genuine --replace) is also
# left alone; only clusters where `r` is bundled with other flag letters are fixed.
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')
[ -z "$COMMAND" ] && exit 0

REWRITTEN=$(printf '%s' "$COMMAND" | perl -e '
  my $cmd = do { local $/; <STDIN> };
  # Split on shell separators, keeping them so the command reconstructs exactly.
  my @seg = split /(&&|\|\||;|\||&|\n)/, $cmd;
  for my $s (@seg) {
    # Segment is an rg invocation: first word (after env VAR=... and command/time) is rg.
    next unless $s =~ /^\s*(?:\w+=\S+\s+)*(?:command\s+|time\s+)?rg\b/;
    # Drop the r from -r<letters> option tokens: -rn -> -n, -rln -> -ln.
    $s =~ s/(^|\s)-r([a-zA-Z]+)/$1-$2/g;
  }
  print join("", @seg);
')

if [ "$COMMAND" != "$REWRITTEN" ]; then
  jq -n --arg cmd "$REWRITTEN" \
    '{"systemMessage":("rg: dropped -r (ripgrep recurses by default; -r is --replace) -> " + $cmd),"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow","updatedInput":{"command":$cmd}}}'
fi
