---
description: Implement a Shortcut story — follows project conventions and writes tests
argument-hint: <story-id>
allowed-tools: Bash(short-story-md*)
---

Please implement the following Shortcut story.

Instructions:

1. **Plan** — Use the Agent tool with `subagent_type: "superpowers:writing-plans"` to create a structured implementation plan. Tell the plan writer:
   - Each task will be executed via RED/GREEN TDD, so tasks should be scoped to independently testable behavior
   - If tasks are too tightly coupled for independent TDD (e.g., a migration + model change that can't be tested separately), group them into a single task
   - **The plan MUST include an "Execution Workflow" section at the top** with these exact instructions, so they survive context compression:

     ```
     ## Execution Workflow

     For each task below, execute sequentially:
     1. Use the Skill tool to call `red-green-tdd` with the full task description as the argument
        (e.g., `skill: "red-green-tdd", args: "<full task description>"`)
     2. After RED/GREEN completes, use the Agent tool with `subagent_type: "superpowers:code-reviewer"`
        to review the task against the plan and coding standards
     3. Fix any issues before moving to the next task

     After ALL tasks are done, run the full relevant test suite to confirm nothing is broken.
     ```

2. **Execute** — Exit plan mode, then follow the Execution Workflow section in the plan exactly.

3. **Wrap up** — After all tasks are done, run the full relevant test suite to confirm nothing is broken.

Ask me if anything in the requirements is unclear before proceeding.

**Conciseness:** Be extremely concise in all output. Short sentences, no filler, no summaries of what you just did. Push back on silly ideas.

---

!`short-story-md "$ARGUMENTS"`
