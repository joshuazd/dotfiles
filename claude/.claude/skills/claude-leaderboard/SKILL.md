---
name: claude-leaderboard
description: |
  Use when the user asks about Claude Code usage, team leaderboard, or who's using Claude Code.
  Generates a ranked leaderboard for SOC Platform team from a platform.claude.com CSV export.
---

# Claude Code Usage Leaderboard

Generate a ranked leaderboard showing SOC Platform team members' Claude Code usage relative to the rest of the org.

## Prerequisites

1. A CSV export from platform.claude.com with columns: `User`, `Spend this Month (USD)`, `Lines this Month`
2. The CSV should be saved to `~/Downloads/` (or the user will specify the path)

## Steps

### 1. Get the team roster

Fetch SOC Platform team members from GitHub:

```bash
gh api orgs/huntresslabs/teams/soc-platform/members --jq '.[].login' --paginate
```

Then map GitHub usernames to email addresses in the CSV. Use first.last patterns to match (e.g. `justincampbell` -> `justin.campbell@huntresslabs.com`).

### 2. Find the CSV

Look for the most recent CSV in `~/Downloads/` matching `claude_code_team*.csv`. If multiple exist, use the newest one. If none found, ask the user for the path.

### 3. Parse and rank

- Parse all rows from the CSV (skip API key entries for ranking purposes)
- Assign org rank by spend (descending)
- Calculate percentile for each user: `p = round((1 - rank/total) * 100)`
- Match team members to their rows by email

### 4. Output format

Display as a plain aligned list (no table borders), sorted by org rank:

```
 #1    Chris Gratigny        $1,083.56    29,041 lines    p99
 #3    John Tuley              $787.87     5,973 lines    p98
 #4    Justin Campbell         $682.34    29,308 lines    p98
#15    Joshua Zink-Duda        $289.45    13,611 lines    p92
```

- Right-align rank numbers and dollar amounts
- Right-align line counts
- Include percentile as `pNN`
- For team members not found in the CSV, show them at the bottom with `--` and a note (e.g. `(new)`, `(EM)`)
- Add a team total and team average at the bottom
