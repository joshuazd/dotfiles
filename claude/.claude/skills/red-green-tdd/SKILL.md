---
name: red-green-tdd
description: Implement tasks using isolated RED/GREEN TDD agents — one writes failing tests from requirements, another makes them pass
argument-hint: [task-description]
---

# RED/GREEN TDD

Enforce TDD discipline by isolating test writing from implementation. A RED agent writes one failing test. A GREEN agent makes it pass with minimal code. Repeat until the task is done.

## Orchestration Steps

### Step 1: Decompose into behaviors

Break the task requirements into a list of discrete, testable behaviors. Order them from simplest to most complex — start with the lowest hanging fruit.

**Exactly one behavior per cycle. No grouping. No exceptions.** If two behaviors could each have their own `it` block, they are separate cycles. "Closely related" is NOT a reason to group.

If you find yourself writing a behavior like "validates email format" — that's too broad. Split it:

1. Rejects empty email
2. Rejects email without @
3. Accepts valid email format
4. Rejects duplicate email (case-insensitive)

That's 4 separate RED/GREEN cycles, not 1 or 2.

**Self-check before proceeding:** If your list has fewer behaviors than the task has distinct testable outcomes, you've grouped. Go back and split further.

**Filter out non-behavioral items:** Remove anything that tests appearance rather than logic. CSS classes, styling, visual layout, HTML structure, and static content are NOT behaviors. Only keep items where the code makes a decision, transforms data, enforces a rule, or produces a side effect.

Write this list down before starting any cycles.

### Step 2: RED/GREEN loop

For each behavior in the list, sequentially:

#### RED: Write one failing spec

Use the Agent tool with `subagent_type: "general-purpose"` and this prompt (filling in the behavior and context):

```
You are the RED agent in a RED/GREEN TDD workflow. Your ONLY job is to
write ONE failing spec for a single behavior.

## Behavior to Test

[ONE behavior from the list — be specific]

## Full Task Context

[FULL TEXT of task requirements — so the agent understands the bigger picture]

## RSpec Conventions

- Prefer `build` over `create` — only persist when associations, callbacks, or queries require it
- Test BEHAVIOR, not internal structure
- Follow existing project spec structure and conventions
- Read `~/.claude/skills/rspec/SKILL.md` for full spec type conventions

## Your Job

1. Explore the codebase to understand where specs live, what factories and helpers exist
2. Write the SMALLEST spec that captures this one behavior
   - If a spec file for this area already exists, add to it
   - If not, create one following project conventions
3. Run ONLY the new spec (e.g., `bundle exec rspec spec/models/user_spec.rb:42`) and verify it FAILS for the right reason:
   - Failure = feature missing (NameError, NoMethodError, expected vs got)
   - NOT failure from typos, syntax errors, or wrong setup
4. Commit the failing spec with message: "RED: [brief description]"

## Constraints

- Write ONE spec (or a small tightly-related cluster). Not the whole test suite.
- Do NOT write any implementation code. Not even empty classes or method stubs.
- Do NOT test CSS styling, visual layout, static HTML, or presentational concerns.
  This includes: CSS classes, inline styles, element ordering/nesting for layout,
  placeholder text, icons, colors, spacing, responsive breakpoints, or "renders X tag."
  Only test things where the code makes a **decision** (conditional rendering, computed
  values, error states, authorization gates, data transformations, side effects).

## Report

- **Status:** DONE | BLOCKED | NEEDS_CONTEXT
- Spec file and line numbers
- How the spec failed (paste failure output)
```

**Verify RED:** Spec exists, is committed, and fails for the right reason. If not, re-dispatch with corrections.

#### GREEN: Make it pass with minimal code

Use the Agent tool with `subagent_type: "general-purpose"` and this prompt:

```
You are the GREEN agent in a RED/GREEN TDD workflow. Your ONLY job is to
make the failing spec pass with the MINIMUM code possible.

## Failing Spec

[Spec file path and line numbers from RED agent report]

## Your Job

1. Read the failing spec to understand what behavior is expected
2. Run ONLY the failing spec (e.g., `bundle exec rspec spec/models/user_spec.rb:42`) to see the failure
3. Explore the codebase for existing patterns, base classes, and helpers to reuse
4. Write the MINIMUM code to make this spec pass
   - Do not anticipate future specs. Only satisfy the current failing one.
   - It is OK to write naive or incomplete code that will be improved in later cycles.
   - You have NO knowledge of the broader task. The spec is your only requirement.
5. Run ONLY the failing spec to confirm it passes
6. Commit with message: "GREEN: [brief description]"

## Constraints

- Do NOT modify any spec files. The specs are the contract.
- MINIMUM code means minimum. Hardcoding a return value is fine if it satisfies
  the spec. Later RED specs will force you to generalize.
- Do NOT build ahead. You do not know what future specs will require.
  Solve ONLY what the current spec demands.
- If a spec seems wrong or untestable, report BLOCKED and explain why.
  Do NOT change the spec.

## Report

- **Status:** DONE | BLOCKED
- Files created/modified
- Test results (paste output showing green)
```

**Verify GREEN:** Spec passes, no spec files were modified, implementation is committed. If not, re-dispatch with corrections.

#### Then continue to the next behavior in the list.

### Step 3: Final check

After all behaviors are done, run the full relevant test suite to confirm nothing is broken.

## Standalone Usage

When invoked directly (e.g., `/red-green-tdd add rate limiting to API endpoints`):

1. Treat the argument as the task requirements
2. Run Steps 1–3
3. Skip any review pipeline unless the user requests it
