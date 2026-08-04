---
name: subsystem-digest
description: Use when generating a weekly digest of changes to the user's subsystems - what landed in their areas of the portal codebase, theirs and teammates'. Invoked on demand or by the weekly scheduled job.
version: 1.0.0
---

# Subsystem Digest

Summarize the last week of merged changes in the user's areas of ownership, so heavy delegation to Claude doesn't cost them awareness of their own subsystems - or of what teammates changed underneath them.

The teammates' half is the point. The user's own PRs they at least saw once; changes made *around* their code by others are the real blind spot.

## Scope

**Edit this list to widen or narrow coverage.** It is deliberately the only place scope is defined.

```
app/models/soc/
spec/models/soc/
app/jobs/soc/agentic/
app/tools/soc/agentic/
app/workflow_engine/activities/soc/activities/agentic_investigation/
app/workflow_engine/activities/edr/activities/agent/
config/locales/soc/copilot/
lib/agentic_agent_eval/
app/grids/admin/soc/
spec/grids/admin/soc/
app/views/admin/soc/
doc/soc/
doc/athena-pipeline-wfe/
```

Repo: `~/portal`. Author identity for the "yours" split: `joshuazd`.

## Step 1: Collect

From the portal repo, on an up-to-date main:

```bash
git fetch origin main --quiet
git log origin/main --since="7 days ago" --no-merges \
  --format='%h%x09%an%x09%s' -- <scope paths>
```

If the window is empty, say so in one line and stop - do not pad a digest with nothing in it.

For each commit, get the file list (`git show --stat --format= <sha>`). Read the actual diff only for commits you cannot categorize from paths and subject alone. Most can be categorized without the diff; don't read all of them.

## Step 2: Categorize

Group by what the change *means*, not by author or directory:

- **New abstractions** - new classes, modules, service objects, tools, activities
- **Changed contracts** - method signatures, return shapes, DB columns, serialized payloads, anything with callers beyond the diff
- **Removals** - deleted classes, dropped columns, retired flags
- **Prompt and model-facing changes** - `config/locales/soc/copilot/` edits, tool schemas, eval fixtures and baselines
- **Everything else** - one compressed line, or omit if genuinely mechanical

Within each group, split **Yours** and **Teammates'**. Lead with Teammates'.

Skip entirely: dependency bumps, generated schema and annotation churn, lint fixes, copy edits.

## Step 3: Write the file

Write to `~/digests/YYYY-MM-DD-soc-digest.md` (create `~/digests/` if absent; use the current date). Format:

```markdown
# SOC subsystem digest - <date range>

## Teammates' changes
### Changed contracts
- <one line, what changed and what it means for you> (`abc1234`, PR #NNNNN, author)

### New abstractions
- ...

## Your changes
- ...

## Worth a closer look
- <up to 3 items, with why>
```

One line per item. State what changed and why the user would care - not the commit subject reworded. PR numbers come from the `(#NNNNN)` suffix in squash-merge subjects.

The "Worth a closer look" section is the highest-value part: at most 3 items where the user's mental model is now probably stale. Something that changed a contract their code depends on, or reworked a subsystem they own but didn't touch. If nothing qualifies, omit the section rather than filling it.

**Write the file before attempting delivery.** If Slack fails, the digest must still exist on disk.

## Step 4: Deliver

DM the digest to the user (their own Slack user ID as the channel - this is a self-note, not a message to another person, so it does not fall under the never-message-humans rule).

Slack has a 5000-character limit per text element. If the digest exceeds it, send the Teammates' section plus "Worth a closer look", and reference the file path for the rest.

If the Slack tool is unavailable - likely in a headless scheduled run where MCP auth is absent - fall back to a macOS notification pointing at the file:

```bash
osascript -e 'display notification "SOC digest ready" with title "Weekly digest" subtitle "<file path>"'
```

Never fail silently. If delivery fails entirely, the file path must appear in the run output.

## Anti-patterns

| Pattern | Why it fails |
|---|---|
| Listing every commit | A digest you skim past is worthless. Categorize and compress. |
| Reworded commit subjects | The user can read `git log`. Say what it means for their model. |
| Leading with the user's own PRs | They already saw those. Teammates' changes first. |
| Padding an empty week | Erodes trust in the digest. Say "quiet week" and stop. |
| Reading every diff | Slow and unnecessary; most commits categorize from paths and subject. |
