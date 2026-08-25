---
description: Review a pull request — focuses on architecture, design, and pattern adherence
argument-hint: <pr-number-or-url>
allowed-tools: Bash(gh pr view:*), Bash(gh pr diff:*), Bash(gh api:*), Bash(git merge-base:*), Bash(git rev-parse:*), Bash(short story:*), Bash(rg:*), Bash(grep:*)
---

You are reviewing a pull request. The expectation is that you are already in a git worktree with this PR's branch checked out. You can read files directly to get additional context beyond the diff.

## Preconditions

1. **Verify checkout** — confirm HEAD matches the PR head SHA before proceeding:
   ```
   gh pr view <pr> --json headRefOid -q .headRefOid
   git rev-parse HEAD
   ```
   If they differ, stop and tell the user the worktree is on the wrong commit.

2. **Load PR context** — run these to load the title/body, top-level comments, reviews, and diff:
   ```
   gh pr view <pr> --json title,body,headRefOid,url
   gh pr view <pr> --json comments,reviews
   gh pr diff <pr>
   ```

3. **Load every inline review thread, resolved included** — see [Comments and Reviews](#comments-and-reviews) below. The `gh` skill covers the three-API problem; consult it if anything is unclear.

4. **Load the linked story** — see [Linked Story](#linked-story) below.

### Re-review on a new head

If the user says "new commits" (or HEAD has moved since your last pass), **re-run every precondition above**, do not just diff the delta. Specifically: re-fetch the threads (the author has almost certainly replied since), and re-derive any `file:line` you are still citing.

Then, for each finding still live from the previous pass, pick one:

- **Re-argue it from scratch** against the new code, or
- **Drop it.**

Re-anchoring a finding to a new line number is not re-arguing it. If a commit touched the code a finding rests on, the burden is on the finding to survive, and the author having just changed that code is evidence they thought about it. Say plainly when you withdraw one; a withdrawn finding is a better outcome than a restated one.

Review this pull request. Most code you review is Claude-generated — it tends to be correct but often introduces new patterns instead of following existing ones, over-engineers, or doesn't reuse existing utilities.

Your primary lens is **architecture & design**. Before reporting any finding, verify it against the actual codebase (use `rg` to confirm patterns exist where you claim). Skip formatting, naming, and style preferences. Invoke `superpowers:verification-before-completion` before posting findings.

**Everything you find must clear the gates in [Output Format](#output-format) before it ships**: not already disclosed by the author *anywhere, including resolved review threads*, has a named consumer and symptom you proved, and is not on the standing skip-list. Cap is 3. The sections below tell you where to look; the gates decide what survives. Note that `verification-before-completion` gates *completion claims*, not individual findings — Gate 2 is what gates findings, and it is easy to satisfy the former while shipping a finding that fails the latter.

**You are not CI. Do not re-run the machine checks.** Do not run linters/formatters, build the project, run the test suite, parse/validate config or schema files, or re-execute any check the repo's CI already performs. CI gates the merge; your job is the judgment CI can't make — design, correctness of intent, completeness, pattern fit. If a check would only tell you what a green pipeline already tells you, skip it and spend that effort reading code. The one exception: read-only `rg`/`grep`/file reads to *verify a specific finding* (confirm a pattern exists, a caller is/isn't updated) — that's evidence for a claim, not a CI substitute. When something is genuinely only verifiable by running the repo (registry registration, external schema, live API shape), say so and flag it as "CI/runtime verifies this" — don't reproduce it locally.

## Architecture & Design (primary focus)

For every changed file, read the surrounding code and related modules to answer:
- **Pattern adherence:** Does the code follow existing patterns in the codebase, or does it introduce new ones unnecessarily?
- **Reuse:** Are existing helpers, utilities, abstractions, and components reused? Or are wheels being reinvented? Point to the existing code that should have been used.
- **Abstraction level:** Is there over-engineering, premature abstraction, unnecessary helpers, or excessive config? Three similar lines > a premature abstraction.
- **Right layer/module:** Does the code land where it belongs architecturally? Is there tight coupling that shouldn't exist?
- **Maintenance cost:** Will this cause pain later? Would a simpler approach work?

## State Machine Changes

When a PR adds, removes, or modifies a status/state/enum value:
1. **List all states** the model can be in (read the model, not just the diff)
2. **Draw the transition map** — for the new/changed state, explicitly list: what states lead INTO it, and what states it transitions OUT to
3. **Verify each transition has a trigger** — not just decision logic, but the code that *invokes* that logic. A correct if/else branch is useless if nothing calls it. Trace from the trigger (job, callback, controller action, event handler) through to the state change.
4. **Check both directions** — if the PR adds entry into a state, verify there's a way out. If it adds an exit, verify something can enter.
5. Common miss: adding an intermediate state with correct entry but no exit trigger. The state becomes a dead end because nothing re-evaluates the model after entry conditions are met.

Half-wired state transitions are blocking issues, not nits.

## Blocking Issues

Also flag anything that must be fixed before merge:
- Bugs, logic errors, data loss, race conditions
- Security vulnerabilities
- Significant performance problems
- Missing error handling for realistic failure cases

### Functional Completeness

Read the PR description and any linked story/ticket. For each stated requirement or acceptance criterion:
- **Verify the diff delivers it.** Not "the code is structured to support it" — does the actual behavior exist end-to-end?
- **Trace the happy path** from trigger to outcome. If the story says "X should happen when Y," find the code for Y triggering and X resulting.
- **Watch for half-wired features:** new states with no exit, new columns with no writer, new permissions with no enforcement, new events with no subscriber. The code that's there is correct — but is the circuit complete?

If the PR description is vague, infer requirements from the code's intent and flag anything that looks incomplete.

## What's Missing

Go beyond the diff. Read surrounding code, related files, and callers/consumers to identify things the PR *should* have done but didn't:
- Callers or consumers that need updating to match new behavior
- Related tests that should exist but don't (end-to-end, not just line coverage)
- Database migrations or schema changes the new code implies
- Permissions, authorization, or access control new features need
- Edge cases or code paths the changes don't handle

Only flag things that are genuinely missing and would cause problems. Don't flag nice-to-haves.

This section is the most reliable source of padding in the whole review: "should have done but didn't" is unbounded, so it always yields candidates. Hold each to Gate 2 — name the consumer that breaks and the symptom — and expect most of what you generate here to die there.

## Output Format

**The prior: most PRs by a competent author warrant zero comments.** The deliverable is a verdict. Comments are the exception, and a review with none is a good review, not a lazy one. You are reviewing someone else's work — the only thing worth their time is information they do not already have.

Every previous version of this skill asked for a ranked list and got a padded one. The gates below exist because "be selective" does not work. They are mechanical. Apply them in order.

### Hard cap: 3 findings

At most three. Not "three unless there are more." If more than three candidates survive the gates, you are wrong about some of them — rank, keep the top three, drop the rest silently. Do not mention what you dropped; that just rebuilds the list.

The one exception: a PR that is fundamentally broken. Then the verdict is **No**, and you name the systemic problem in one line rather than enumerating its instances.

### Gate 1: the author already said it

Before writing findings, read the whole disclosure record. That is four sources, and **the fourth is the one that gets skipped**:

1. The PR description.
2. Commit messages on the branch.
3. Top-level PR comments.
4. **Every inline review thread, resolved and outdated included.**

Source 4 is where the reasoning actually lives. A careful author replies to a bot finding explaining what they fixed, what the bot got wrong, and what the fix costs — then resolves the thread. Filtering to unresolved threads deletes exactly the content this gate needs. Fetch them all and read the author's replies, not just the bot's claims.

Anything already disclosed in any of the four — a known gap, a documented race, a deferred story, an accepted cost, a bot claim the author already rebutted — is **ineligible**. Restating an author's own caveats back at them is worse than silence: it reads as not having read the PR.

Before you write a finding, answer in one line: *where would the author have said this, and did I read there?* If you cannot point to the sources you checked, you have not run this gate.

Emit this as one terse line so the gate cannot be skipped silently:

```
**Author already disclosed:** silent-drop on non-bang create (sc-227642), missing unique index. Not re-reported.
```

Name them and stop. No elaboration, no "but I'd add that…".

The only way a disclosed item becomes a finding: you can *prove the author's mitigation is wrong* (the story does not exist, the flag does not actually gate the path, the fix does not work). Then it is a finding about the mitigation, stated as such, and it needs Gate 2 evidence like anything else.

### Gate 2: name the consumer, or it is not a finding

Per candidate, you must have all three. Establish them **before** writing the headline, not when challenged:

1. **Consumer** — the specific `file:line` that breaks, or the specific flow/person harmed.
2. **Symptom** — what is observably wrong when it does.
3. **Proof** — the grep or file read you actually ran that establishes 1 and 2.

Missing the third element → drop it. **If you cannot name the consumer, you have a mechanism, not a finding.** A mechanism is "this value is mutable and nothing rechecks it." A finding is "and `foo.rb:42` reads it expecting uniqueness, so it silently picks one of two."

For any new method, scope, constant, or column: grep for its consumers before writing it up. If the only consumer is the code that introduced it, post-hoc drift in it has nothing to break.

### Gate 3: severity bar for the tag

- **[BLOCK]** — bug, security, data loss, race condition, perf, half-wired state/feature, missing error handling, **and** a reachable path to the bad outcome once the feature is on. Author-documented or story-gated caps severity below BLOCK, whatever the category.

  **A flag being off is not a severity discount.** Always grade as though the flag is on: the flag is a rollout control, not a property of the code being merged, and "off today" is a fact about the config, not the diff. Grading against off means reviewing code that isn't the code you were asked to review. What the flag *does* change is the direction of failure, and that is worth stating: a defect that makes the gated feature refuse when it should act fails closed; one that makes it act when it should refuse fails open. Rank fail-open above fail-closed.
- **[DESIGN]** — pattern violation, over-engineering, wrong layer, reinvented wheel. Must point to the existing pattern/utility, with the `file:line` where it lives.
- **[MISSING]** — caller/test/migration/permission/edge case the PR should have included, where its absence has a named consequence.

### Gate 4: the standing skip-list

These are never findings, no matter how true. They are what padding looks like:

- Method or constant placement and ordering; public vs private on a helper
- Redundant-but-harmless guards, belt-and-braces checks on a feature flag
- Spec file organization, naming, or location
- A spec asserting an implementation detail, absent a behavior it gets wrong
- Formatting, naming, style preferences
- Anything CI already gates (see the not-CI rule above)
- Story/PR scope mismatch where the story was edited after the PR opened — check timestamps before claiming this

### The shape

```
**Merge:** Yes / No / With fixes

**Author already disclosed:** … (omit if nothing was)

## Comment on these
(omit entirely if there are no findings)

1. `file:line` **[TAG]** Headline — the comment you'd type, ≤15 words.
   ↳ optional: ONE short clause of context. Skip it unless the headline is genuinely unclear without it.

## Summary
```

`## Summary` is 1-2 sentences on *what* the PR does and *why*. It goes at the bottom — context, not headline.

If there are no findings, output the verdict line, the disclosure line if any, and the Summary. Nothing else. Do not backfill with observations.

**Optional:** a `## Checked and cleared` section, numbered, one line each, for concerns you investigated and killed. Use it when the PR touches something alarming and "I looked at that" is worth saying. It is a pressure-release valve for the 3-cap, not a second findings list — if an item there has a consequence, it is a finding; if it does not, keep it to one line. Cap it at 5 and drop it entirely when the PR is unremarkable.

Rules:
- **Always number the findings**, so the user can reply "2 and 5 are wrong" instead of quoting them back. Number every list the user might want to reference — findings, cleared-concern notes — each restarting at 1 within its own section. Never emit findings as unnumbered bullets. When a finding is withdrawn mid-discussion, keep the original numbers stable rather than renumbering.
- The **headline is the comment** — write what you'd actually leave on the PR, not a description of the issue. Punchy, ≤15 words.
- `file:line` first so it's clickable. **Get the number from the source file at HEAD, not from the diff.** Diff output has its own line numbering, and `gh pr diff` piped through a pager or saved to a file numbers the *diff*, not the file. Confirm every anchor with `grep -n` against the working tree before you ship it. A wrong anchor makes the user doubt the finding, and they are right to.
- Detail is opt-in: at most ONE indented `↳` sub-line, and only when the headline can't stand alone. Most findings have zero. No semicolon-chained clauses, no "but it's safe because…" hedging, no flag-name soup — if you're tempted to explain the whole control flow, you're writing prose. Cut it; the user will ask.
- Scannability beats completeness. A finding the user can read in 2 seconds and act on beats a complete one they skip.

**Before/after** (real output that was too dense → fixed):

❌ Too dense — a paragraph wearing a bullet's clothes:
> `signal_aggregator.rb:57` [DESIGN] — reported_recently_resolved_investigation is surfaced ungated, but SignalResolver's close is flag-gated; for EDR (signal_resolver_close_previously_reported_edr_enabled default false) a similar signal aggregated via AggregateSignalJob attaches but never closes → dangles. Mirrors the pre-existing path, and ITDR's close flag defaults on, so it's safe by default — but the EDR rollout runbook must enable the close flag…

✅ Scannable:
> 1. `app/models/soc/agentic/signal_aggregator.rb:57` **[DESIGN]** EDR path aggregates the signal but never closes it — close is flag-gated, default off.
>    ↳ EDR rollout runbook must enable the close flag alongside aggregation.

**Worked example of the gates killing findings** (a real review that produced 8 items where 1 was warranted):

- *"Lane derives from mutable `assigned_to_id` but is only checked `on: :create`"* → died on Gate 2. The mechanism was real and verified. But `in_soar_lane`/`in_shared_lane`/`lane` had exactly one consumer in the repo: the validation that introduced them. No reader, no symptom, no finding. The grep took 5 seconds and was not run until the user pushed back.
- *"Non-bang `find_or_create_by` swallows the refusal"* and *"no unique index backs the validation"* → died on Gate 1. Both were in the PR description, with a story filed and the flag gated on it.
- *"Internal helper on public surface"*, *"flag read three ways"*, *"spec locks in the redundancy"* → died on Gate 4.
- *"Story acceptance not delivered"* → died on Gate 4; the story had been rewritten after the PR opened.
- Survivor: the Redfig flag description still said "not owned by SOAR" and cited a story ID belonging to an unrelated feature, both orphaned by a later commit that replaced the SOAR exemption with lanes. One comment. That was the whole review.

**Second worked example — a review across four heads that should have been zero findings and produced six** (every one factually correct, none of them new):

- *"Manual remediations make the gate refuse on a free-text instruction"* → died on Gate 1, but not until the user asked "did you read the thread?" The author had already posted the same analysis in-thread, including the correction that the bot's "executes without validation" framing was wrong, plus a separate reason for keeping the change. The thread was resolved, so the unresolved-only filter never surfaced it.
- *"Every target must resolve to a catalogued RMM"* → died on Gate 1. Disclosed twice in thread replies, with production evidence.
- *"Coverage counts a different table than prevalence"* → survived two heads, then died when a commit tightened coverage to 100% and the argument no longer held. It was **re-anchored to a new line number instead of re-argued**, and only withdrawn when the user asked "does this matter?"
- *Two of three `file:line` anchors were wrong* — read off the saved diff's line numbering rather than the source at HEAD.
- *Severity graded against the flag being off* — which meant grading code other than the code under review.

The pattern: correctness was never the problem. Every failure was reading the wrong source, reading it once, or not re-testing a belief when the evidence moved. The user's two one-line questions each killed a finding faster than any amount of re-reading the diff. Ask yourself both before shipping: **where would the author have already said this, and does this still hold after the last commit?**

**Conciseness:** Be extremely concise. No filler, no preamble. Push back on silly ideas. If a finding needs more than one line, you're writing prose — stop.

---

## Comments and Reviews

PR comments live in **three** separate APIs — fetch all three or you'll miss context. The `gh` skill covers this in detail; the relevant queries:

1. **Top-level comments + reviews** (verdicts):
   ```
   gh pr view <pr> --json comments,reviews
   ```
   `reviews[].state` gives APPROVED / CHANGES_REQUESTED / COMMENTED.

2. **Inline review threads** (REST does not expose resolution status — must use GraphQL). Extract `owner`, `repo`, `number` from the `url` field of `gh pr view --json url` output. Fetch **all** threads, and request enough comments per thread to get the author's replies, not just the opening claim:
   ```
   gh api graphql -f query='
   query($owner: String!, $repo: String!, $pr: Int!) {
     repository(owner: $owner, name: $repo) {
       pullRequest(number: $pr) {
         reviewThreads(first: 100) {
           nodes {
             isResolved
             isOutdated
             comments(first: 20) {
               nodes { body author { login } path line createdAt }
             }
           }
         }
       }
     }
   }' -f owner=OWNER -f repo=REPO -F pr=NUMBER
   ```

   **Do not filter on `isResolved` or `isOutdated`.** They mean different things for the two jobs this fetch does:

   - **Deciding what still needs action** — yes, unresolved-and-not-outdated is the right set.
   - **Running Gate 1** — you need *all* of them. Many authors reply in-thread then resolve, so the resolved threads hold the reasoning: what they fixed, what the bot got wrong, what the fix cost. Filtering them out guarantees you re-report things the author already worked through, which is the single most common way this review goes wrong.

   Read the last comment in each thread, whoever wrote it. An author's rebuttal of a bot claim is a disclosure and binds Gate 1 exactly like the PR description does.

### Greptile Comments

Some threads are from Greptile (an automated reviewer). Treat its comments as hints to investigate, never conclusions — and **read the whole thread before forming a view**, because the author has often already verified or rebutted the claim, and their reply is the more reliable of the two.

For each Greptile comment:
- Check whether the author already replied. If they did, their conclusion is the starting point; do not re-derive it and present it as new.
- Otherwise verify the claim against the actual code.
- If valid and undisclosed, include it like any other finding.
- If invalid, call it out explicitly (e.g. "`file:line` — Greptile flagged X but this is incorrect because Y") — unless the author already said so, in which case it belongs in the disclosure line, not the findings.

**A fix made in response to a bot is not automatically correct.** If the author changed code to satisfy a Greptile claim that was wrong, the resulting change may be wrong too — that is a legitimate finding, but only where the author did not already acknowledge the bot's error and give a separate reason for keeping the change. Check the reply first.

Do not trust Greptile blindly — treat its comments as hints to investigate, not conclusions.

## Linked Story

Fetch the Shortcut story for requirements context. The branch name typically contains the story ID (e.g., `jz/sc-12345/feature-name`):

```
short story --from-git -q
```

If `--from-git` fails (no story ID in branch name), check the PR description for a Shortcut URL or story ID and use `short story <ID> -q` instead.

Use the story's title, description, and acceptance criteria as the source of truth for the Functional Completeness check. If no story is linked, rely on the PR description and note that no story was found.
