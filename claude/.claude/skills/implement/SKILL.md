---
description: Implement a Shortcut story — follows project conventions and writes tests
argument-hint: <story-id>
allowed-tools: Bash(short-story-md*)
---

Please implement the following Shortcut story.

Instructions:

1. **Read the story** — Run `short-story-md <story-id>` to fetch the story, then explore the relevant parts of the codebase. Search for existing patterns, helpers, base classes, concerns, and service objects that already solve the problem — reuse over reinvention.

2. **Clarify** — Ask me if anything in the requirements is unclear before proceeding.

3. **Assess complexity** — default to brainstorming. Only skip if the change is trivially mechanical:
   - **Skip brainstorming** only for: pure renames, copy/text tweaks, single-line bug fixes with confirmed root cause, adding a column with obvious type and no business logic, or a change so localized that no design choice exists.
   - **Brainstorm otherwise** — invoke `superpowers:brainstorming` via the Skill tool. This includes: any new model/service/concern/job, any new endpoint or controller action, validation that touches multiple models, scopes/queries with non-obvious shape, anything cross-cutting, anything with multiple viable approaches, ambiguous requirements, or unfamiliar domain. CRUD is rarely "straightforward" — if it has callbacks, authorization, or non-trivial validation, brainstorm. When in doubt, brainstorm.

4. **Plan** — Invoke `superpowers:writing-plans` via the Skill tool.
   - Each task should be scoped to independently testable behavior via RED/GREEN TDD (see `superpowers:test-driven-development`)
   - If tasks are too tightly coupled for independent TDD (e.g., a migration + model change that can't be tested separately), group them into a single task

5. **Execute** — Follow the Execution Workflow section in the plan exactly. If the plan lacks one, invoke `superpowers:executing-plans` (or `superpowers:subagent-driven-development` for parallel work).

6. **Wrap up** — Check whether existing specs need updating for the new behavior. Run the full relevant test suite to confirm nothing is broken. Invoke `superpowers:verification-before-completion` before claiming done.

**When blocked:** Stop and ask. If a test fails repeatedly, requirements are unclear, verification fails, or the plan has a critical gap — surface it to me, don't guess your way through.

**Conciseness:** Be extremely concise in all output. Short sentences, no filler, no summaries of what you just did. Push back on silly ideas.
