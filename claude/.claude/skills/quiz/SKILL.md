---
name: quiz
description: Use when the user wants to test their own understanding of code that was just written - after creating a PR, after merging, or on demand for a PR number or commit range. Quizzes via active recall, grades strictly, then shows the real code. Also invoked automatically by the create-pr skill.
version: 1.0.0
---

# Quiz

Test the user's mental model of a change through active recall. The user has been delegating implementation to Claude; the goal is that they can still trace, predict, and justify the code that landed under their name.

**This is a test, not a walkthrough.** Do not explain the change before asking. Do not soften grades. A quiz that everyone passes teaches nothing.

## Arguments

- No args → diff the current branch against `origin/<default_branch>`
- A number (e.g. `34608`) → that PR, via `gh pr diff <n>`
- A commit range (e.g. `abc123..def456`) or a single SHA → that range

Resolve the default branch with `gh repo view --json defaultBranchRef -q .defaultBranchRef.name`.

## Step 1: Read the change

Get the full diff, not just the stat. Then read enough surrounding code to know how the changed code is *reached* and who *consumes* it - the quiz depends on context the diff does not contain. Look up callers of changed methods, and for a new class, find where it gets instantiated.

## Step 2: Novelty gate

Decide whether this change is worth quizzing. **Never use line or file counts** - a 20-line change to a contract matters more than a 600-line mechanical sweep.

Quiz-worthy - the change introduces or alters a concept, contract, or decision:

- A new class, module, or service object
- A newly registered WFE activity, job, or workflow step
- A changed method signature or return shape that has callers outside the diff
- A new state, transition, or branch in control flow
- A new failure path, timeout, retry, or guard
- Changed prompt behavior, tool schema, or model-facing instructions
- Changed data written to the database, or a new column's semantics
- A non-obvious ordering or placement decision (something moved out of a transaction, a callback made async, a lock added)

Not quiz-worthy - the change carries no new model:

- Renames, moves, copy and string edits, comment changes
- Dependency bumps, generated schema dumps, annotations, lockfiles
- Specs that assert behavior the user already designed elsewhere
- Lint and formatting fixes
- Mechanical propagation of a pattern the user demonstrably already holds - the fifteenth activity wired for shadow mode teaches nothing the second didn't. Check `git log` for prior instances of the same pattern by this author before deciding this applies.

If it fails the gate, print one line - what the change is and why it carries no new model - and stop. Do not offer to quiz anyway.

## Step 3: Build questions

**Question count scales to the change's design content, not to a quota.** Count the genuinely distinct decisions in the change - the calls someone could have made differently. Ask one question per decision, and stop. A one-line migration with two real decisions ("why no model code?", "why no backfill?") gets **two** questions, not four. Most changes land at 2-4; reserve 5-6 for a change that genuinely introduces that many separable decisions. Never invent a question to hit a floor - if you've exhausted the real decisions, you're done. Padding a thin change with mechanism trivia is worse than a two-question quiz.

The best questions are brief and straightforward, aimed squarely at the change itself: "Why was no model code needed?" "Why don't we have a backfill?" One clause, no preamble, answerable by anyone who owns the decision - and unanswerable by someone who only watched the code get written. If a question needs a setup paragraph or a walk-the-path instruction, it has drifted into mechanics; cut it or lift it back up to the decision.

Every question must be one of these four types:

| Type | Shape | Example |
|---|---|---|
| Wiring | What reads or reaches this? | "The relay server gets extracted here. What consumes it downstream, and in what form?" |
| Consequence | What breaks if X? | "If the parser returns nil for the relay server, what does the investigation step render?" |
| Rationale | Why this way? | "Why is this enqueue outside the transaction block?" |
| Boundary | What about the edge? | "This runs per signal. What happens on the second signal for the same host?" |

### Calibration: the colleague test

Before writing each question, apply this filter: **if a colleague asked you this about the system, could you answer without re-reading the diff?** Bias every question toward that bar - system behavior, design tradeoffs, and consequences a teammate would actually ask about - not implementation mechanics that only someone re-deriving the diff line-by-line would need.

This means preferring questions like "does this fix generalize past the one reported bug, or did we just patch the specific case?" and "why doesn't this need a feature flag?" over questions like "which object wins in this ternary" or "does `.to_a` force materialization before a transaction rolls back." The second kind tests whether the user can trace a diff; the first kind tests whether they own the design. Default toward the first kind. Reserve framework/ORM-mechanics questions (exact query timing, callback ordering, transaction/rollback internals, N+1 triggers) for cases where the mechanism itself *is* the reviewed design decision (e.g. the PR's whole point was moving a job enqueue out of a transaction) - never as incidental trivia about how the surrounding framework happens to work.

If a first-draft question reads like "trace this call chain and name what's returned at each step," rewrite it one level up: what does that returned value let the system do, or fail to do, that someone outside the code would care about.

Banned question types:

- Naming or location trivia ("what is the class called", "which file holds X")
- Anything the question text itself answers
- Anything answerable without having read the code, from general Rails knowledge alone
- Anything whose answer is a value Claude picked arbitrarily and the user never reviewed
- Framework/ORM mechanics that aren't themselves the design decision under test (see Calibration above)

Each question must have a verifiable answer grounded in specific code. Before asking, confirm you can point to the exact `path:line` that settles it. If you can't, the question is bad - replace it.

Order questions so no question leaks the answer to a later one. Order by altitude too: open with design/behavior questions (the ones the colleague test favors) and only drop into mechanism-level detail, if at all, once the higher-level questions are answered - never lead with plumbing.

## Step 4: Ask

**One question per message.** Wait for the answer before asking the next.

Free-form typed answers - never multiple choice, never `AskUserQuestion`. Recognition is not recall; a list of options hands over the answer.

No hints unless the user asks. If they say "no idea" or "pass", grade it as a miss and move on.

## Step 5: Grade immediately

After each answer, before the next question:

1. **Verdict** - `Correct`, `Partial`, or `Missed`.
2. **One sentence** on what was right or wrong. No praise padding.
3. **The actual code, inline**, as a fenced block labeled with `path:line`. Always show it, including on a correct answer - confirmation is part of the learning. The user cannot see Read tool output, so the code must be printed in your message.

Grading standard: naming the right noun without the mechanism is **Partial**, not Correct. "It gets passed to the investigation" when the answer is "serialized into the step's evidence payload and rendered by the grid presenter" is Partial. Be exact about what was missing.

If the user's answer reveals a *better* understanding than yours - they know something about the system you inferred wrong - say so plainly and correct yourself.

## Step 6: Close

- Score as `N/M`.
- For each miss, one line naming the specific thing they don't have a model of - the subsystem or contract, not the question. "You don't have the evidence-payload serialization path" beats "you missed question 3."
- If everything was correct, say so in one line and stop. No summary needed.

## Anti-patterns

| Pattern | Why it fails |
|---|---|
| Explaining the change, then quizzing | Hands over every answer. Test first, always. |
| Grading generously to be encouraging | The point is finding gaps. A false pass hides one. |
| Asking all questions at once | Lets the user pattern-match across questions instead of recalling each. |
| Quizzing a mechanical diff because it's large | Size is not novelty. Trust the gate. |
| Padding to a question count when the change has fewer real decisions | The count follows the design content. Two decisions, two questions - inventing a third pulls you into plumbing. |
| Referencing method names instead of printing code | The user can't see your tool output. Print the block. |
| Leading with "which object wins in this ternary" style questions | Tests diff-tracing, not ownership of the design. Apply the colleague test and start at design altitude. |
| Vague or invented vocabulary for domain concepts | Name the exact identifier and its correct type - the specific feature flag (`soc_investigation_triage_package`), column, class, or method. Never paraphrase a domain term into something fuzzy like "has no controls" or "the setting", and never mislabel the kind of thing it is (a feature flag is a feature flag, not a "control"). Use the codebase's own word. A wrong or vague noun makes the question unanswerable and erodes trust. |
