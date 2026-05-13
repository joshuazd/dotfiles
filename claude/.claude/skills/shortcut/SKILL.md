---
name: shortcut
description: Use when interacting with Shortcut in any way — anything mentioning a story ID (sc-NNNNN, [sc-NNNNN]), a Shortcut URL (app.shortcut.com/...), a branch name containing sc-NNNNN, or words like "story", "ticket", "epic", "iteration", "blocker", "Shortcut". Covers viewing/searching stories, updating owner/state/title/description/labels/epics/iterations, adding comments, creating stories, linking blockers/duplicates/related-to, and reading story metadata. Always use the `short` CLI — never curl api.app.shortcut.com or gh api against Shortcut.
---

# Shortcut CLI Reference

## Overview

Always use the `short` CLI for Shortcut operations. Never use direct API calls.

## Don't reach for

- ❌ `curl https://api.app.shortcut.com/...` — use `short api <path>` instead
- ❌ `gh api ...` — `gh` talks to GitHub, not Shortcut
- ❌ Any `Authorization: Token ...` HTTP request — `short` handles auth
- ❌ MCP / web tools to look up a story — `short story <ID>` is faster and authoritative
- ❌ Guessing at owner/state/epic IDs — use the discovery commands (`short members`, `short workflows`, `short epics`)

## View a Story

```bash
short story <ID>               # View story details
short story <ID> --from-git    # Parse ID from current git branch
short story <ID> -O            # Open in browser
```

## Update Story Fields

```bash
short story <ID> -t "new title"          # Title
short story <ID> -d "new description"    # Description
short story <ID> -o "Owner Name"         # Owner (comma-separated for multiple)
short story <ID> -s "In Progress"        # Workflow state
short story <ID> -e 3                    # Estimate
short story <ID> -y bug                  # Type: feature | bug | chore
short story <ID> --epic "Epic Name"      # Epic
short story <ID> -i "Iteration Name"     # Iteration
short story <ID> -T "Team Name"          # Team
```

Multiple flags work together: `short story <ID> -t "New Title" -s "In Review" -o "Josh"`

## Add a Comment

```bash
short story <ID> -c "Comment text here"
```

## Search Stories

Prefer Shortcut **search operators** (positional args) over the `-t/-o/-s/...` flags. Flags filter client-side *after* fetching everything — the CLI prints `Fetching all stories for search since no search operators were passed` and is very slow. Operators push the query server-side and return in under a second.

```bash
short search -q 'title:InfectionReportManager'           # fast — server-side
short search -q 'title:"exact phrase" type:bug'          # combine operators
short search -q 'owner:chrisgratigny state:"Ready for Development"'
short search -q 'epic:192651'                            # stories in epic
```

Operator reference: https://help.shortcut.com/hc/en-us/articles/360000046646-Search-Operators

Flag form (slower, client-side regex filter) still works for exploratory searches:

```bash
short search -o "Owner Name"          # By owner
short search -s "In Progress"         # By state
short search --epic "Epic Name"       # In epic
short search -i "Iteration Name"      # In iteration
```

Tip: when a story is in the wrong epic, search `title:<distinctive substring>` — sibling stories on the same code path usually reveal the correct epic.

## Create a Story

```bash
short create -t "Story title" -s "State Name" [-p "Project Name"] [-d "desc"] [-o "Owner"] [-y feature|bug|chore] [--epic "Epic Name"] [-T "Team Name"]
```

`short create` does NOT support `-q` (quiet mode). Use `-I` for ID-only output.

## Discovery (Find Names/IDs)

```bash
short members       # List members → find owner names
short workflows     # List workflow states → find state names
short epics         # List epics
short iterations    # List iterations
short projects      # List projects
```

## Useful Flags

| Flag | Purpose |
|------|---------|
| `-q` | Quiet mode — suppress loading dialog (not available on all subcommands) |
| `-I` | ID-only output — useful for chaining |
| `--format` | Template-based output for scripting |

## Raw API Calls

```bash
short api <path>                              # GET request
short api <path> -X POST -f "key=value"       # POST with fields
```

**`-f` uses `key=value` format** — not `-f key value` (space-separated will error).

### Story Links (blockers, duplicates, relations)

```bash
short api /story-links -X POST -f "verb=blocks" -f "subject_id=<blocker_id>" -f "object_id=<blocked_id>"
```

Valid verbs: `blocks`, `duplicates`, `relates to`

## Gotchas

- Owner and state names support partial/regex matches
- `-d` with heredocs silently fails when the string contains backticks — use plain inline strings instead
- `-f` sends all values as strings, but the Shortcut API coerces numeric strings to integers for ID fields
