---
name: shortcut
description: Use when performing any Shortcut (project management) operations — viewing stories, updating owners, states, titles, descriptions, adding comments, searching, or creating stories. Always use the `short` CLI, never direct API calls.
---

# Shortcut CLI Reference

## Overview

Always use the `short` CLI for Shortcut operations. Never use direct API calls.

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
