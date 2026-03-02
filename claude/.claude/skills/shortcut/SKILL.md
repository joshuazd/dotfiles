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

```bash
short search                          # All stories
short search -o "Owner Name"          # By owner
short search -s "In Progress"         # By state
short search -t "keyword"             # By text in name
short search -y bug                   # By type
short search --epic "Epic Name"       # In epic
short search -i "Iteration Name"      # In iteration
```

## Create a Story

```bash
short create -t "Story title" -s "State Name" [-p "Project Name"] [-d "desc"] [-o "Owner"] [-y feature|bug|chore]
```

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
| `-q` | Quiet mode — suppress loading dialog |
| `-I` | ID-only output — useful for chaining |
| `--format` | Template-based output for scripting |

## Edge Cases

```bash
short api <path>    # Raw API call for anything not covered above
```

Owner and state names support partial/regex matches.
