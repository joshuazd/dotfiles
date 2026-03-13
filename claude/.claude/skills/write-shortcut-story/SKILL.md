---
name: write-shortcut-story
description: Use when writing or drafting a new Shortcut story, or when asked to refine, improve, or create a story for a feature, bug, or chore.
---

# Writing Shortcut Stories

## Overview

Stories communicate **what** to build and **why** — not **how**. Leave implementation decisions to the engineer.

## Story Structure

Every story has three sections:

1. **Description** — context and goal
2. **Requirements** — what the feature/fix must do
3. **Acceptance Criteria** — how to verify it's done

## Gathering Context

Before writing, gather context from the **codebase**, not Shortcut.

**Do:** Explore relevant code, views, models, grids, and controllers to understand the current behavior.

**Don't:** Query Shortcut for related stories, epics, or teammates' stories. That path leads to repeated failed searches. If the epic or related context isn't immediately available, skip it and use the codebase instead.

```
✅ Search codebase for the feature area, read relevant files
❌ short search -t "..." repeatedly trying to find related context
```

One `Explore` subagent call against the codebase gives more accurate context than multiple Shortcut queries.

## Step-by-Step

### 1. Write the Title

Clear, action-oriented, concise. Describes the user-facing outcome.

```
✅ "User can reset their password via email"
❌ "Add forgot password endpoint and mailer"
```

### 2. Write the Description

2–4 sentences covering:
- **Why** this work matters (user/business need)
- **Who** is affected
- **What** the current situation is (if a bug or gap)

Do NOT describe how to implement it. Do NOT mention tech stack, classes, methods, or database tables.

```
Users who forget their password have no self-service recovery path and must contact support.
This story adds a password reset flow so users can regain access independently.
```

### 3. Write Requirements

Bullet list of concrete behaviors the feature must exhibit. Write from the user's perspective.

- Use "The system..." or "A user..." phrasing
- One behavior per bullet
- No mention of implementation (no endpoints, SQL, class names, libraries)

```
- A user can request a password reset by entering their email address
- The system sends a reset link to that email if the account exists
- The reset link expires after 24 hours
- A user can set a new password using the reset link
- The system rejects reuse of the previous password
```

### 4. Write Acceptance Criteria

Verifiable conditions that prove the story is complete. Each criterion should be independently testable.

Format: **Given / When / Then** or a checklist. Use whichever is clearer.

```
- [ ] Submitting a valid email shows a confirmation message regardless of whether the account exists
- [ ] A reset email is received within 60 seconds for valid accounts
- [ ] Following an expired link shows an informative error
- [ ] Setting a new password with the reset link logs the user in
- [ ] Attempting to reuse the previous password shows a validation error
```

### 5. Set Story Type and Metadata

```bash
short create -t "Title" -y feature   # or bug, chore
short story <ID> -d "$(cat description.md)"
```

## What NOT to Include

| Avoid | Instead |
|-------|---------|
| Class/method names | Describe the behavior |
| Database schema | Describe the data need |
| API endpoint paths | Describe the user action |
| Library/framework choices | Leave to the engineer |
| Step-by-step implementation | Requirements, not recipe |

## Common Mistakes

**Too vague:** "Improve error handling" — add specific scenarios and expected behavior

**Too technical:** "Add `POST /api/v1/reset` endpoint" — describe the user action instead

**Missing acceptance criteria:** Requirements say what to build; AC proves it's built correctly — both are required

**Mixing "what" and "how":** If a sentence names a class, table, or library, rewrite it in user terms
