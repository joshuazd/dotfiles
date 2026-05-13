---
name: watch-pull-request
description: Watch a pull request through CI and review — request Greptile review, address concerns, fix CI failures, rebase conflicts, and loop until green.
user-invocable: true
allowed-tools: Bash(gh pr view:*), Bash(gh pr comment:*), Bash(gh pr checks:*), Bash(gh api:*), Bash(gh run view:*), Bash(git fetch:*), Bash(git rebase:*), Bash(git push:*), Bash(git commit:*), Bash(git log:*), Bash(bundle exec rspec:*), Bash(bin/failedci:*)
---

# Watch Pull Request

Shepherd a PR through Greptile review and CI until it's green.

**Never mark a draft PR as ready for review.** Draft status is the user's decision.

**Portal-specific assumptions:** This skill currently assumes Ruby/RSpec (`bundle exec rspec`) and the portal's `bin/failedci` CircleCI helper. If running on a non-portal repo, adapt steps 5 and 7 accordingly.

## Workflow

### 1. Resolve PR coordinates

Resolve `owner/repo` once and reuse. Don't hardcode. The PR URL is always on the base repo — parse it:

```bash
nwo=$(gh pr view <PR_NUMBER> --json url -q .url | awk -F/ '{print $4 "/" $5}')
owner=${nwo%/*}
repo=${nwo#*/}
```

If `gh pr view` fails, abort and tell the user — don't silently fall back.

### 2. Self-Review

Dispatch a `general-purpose` subagent via the Agent tool to run the `review-pr` skill. The subagent's prompt must instruct it to invoke `Skill review-pr` with the PR number and return the review verbatim. This keeps the review output out of the main context.

For each finding, implement the **minimal** fix, commit, and push so Greptile reviews the cleaned-up state in step 3:

```bash
git push origin HEAD
```

Self-review is one pass — don't loop on it.

### 3. Greptile Feedback Loop

Loop until Greptile's latest review comes back with **no concerns**. Always re-request a review at the top of each iteration — even if you only pushed back and made no fixes, retriggering gives Greptile a chance to confirm the rebuttal and produce a clean review. Cap at **5 iterations** and escalate to the user if Greptile keeps finding new things.

**a. Trigger a new review.** You MUST delete prior `@greptileai review` comments authored by you before posting the new one. This is REQUIRED, not cosmetic — stale trigger comments accumulate on every iteration, pollute the PR conversation, and make it hard for human reviewers scanning the timeline to tell which review is current. The delete + post is a single atomic step; do not skip the delete even when it's a no-op (iteration 1):

```bash
me=$(gh api user -q .login)
gh api "repos/$owner/$repo/issues/<PR_NUMBER>/comments" \
  --jq ".[] | select(.user.login == \"$me\" and .body == \"@greptileai review\") | .id" \
| while read -r id; do
    gh api -X DELETE "repos/$owner/$repo/issues/comments/$id"
  done

trigger_ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
gh pr comment <PR_NUMBER> --body "@greptileai review"
```

Capture `trigger_ts` before posting so step b can detect a *new* Greptile response.

**b. Wait for Greptile's response.** Poll up to **15 times at 1-minute intervals** (~15 min). Stop polling as soon as Greptile-authored content (top-level comment, review, or review thread) has `updatedAt > $trigger_ts`. If the cap elapses, escalate to the user — don't proceed.

**CRITICAL: do filtering with `gh api graphql --jq` (gh's internal jq), not by piping to local `jq`.** Greptile review bodies sometimes contain literal control characters (U+0000–U+001F) that cause local `jq` to error with `Invalid string: control characters from U+0000 through U+001F must be escaped`. `gh`'s internal jq handles these — local jq does not. **In bash, this fails silently:** if `jq` errors, `$(...)` captures an empty string; arithmetic comparisons like `[ "$x" -gt 0 ]` then evaluate false on empty input, so the loop polls forever without surfacing the parse error. Always probe with `--jq`, and never pipe `gh api graphql` JSON output through external `jq` for greptile content. Also avoid asking for `body` in this probe — bodies are where the control chars live, and we only need `updatedAt` to detect a fresh response.

**Note:** `gh api --jq` accepts a single filter string — it does NOT accept `--arg foo bar` like standalone `jq`. To pass shell variables (like `$trigger_ts`) into the filter, use a double-quoted string and interpolate them inline (escaping inner quotes with `\"`).

```bash
for i in {1..15}; do
  sleep 60
  fresh=$(gh api graphql -f query='
    query($owner: String!, $repo: String!, $pr: Int!) {
      repository(owner: $owner, name: $repo) {
        pullRequest(number: $pr) {
          comments(first: 100) { nodes { author { login } updatedAt } }
          reviews(first: 50) { nodes { author { login } updatedAt } }
          reviewThreads(first: 100) { nodes { comments(first: 1) { nodes { author { login } updatedAt } } } }
        }
      }
    }' -f owner="$owner" -f repo="$repo" -F pr=<PR_NUMBER> \
    --jq "
      [
        (.data.repository.pullRequest.comments.nodes[]?       | select(.author.login // \"\" | startswith(\"greptile\")) | select(.updatedAt > \"$trigger_ts\")),
        (.data.repository.pullRequest.reviews.nodes[]?        | select(.author.login // \"\" | startswith(\"greptile\")) | select(.updatedAt > \"$trigger_ts\")),
        (.data.repository.pullRequest.reviewThreads.nodes[]?.comments.nodes[]? | select(.author.login // \"\" | startswith(\"greptile\")) | select(.updatedAt > \"$trigger_ts\"))
      ] | length")
  echo "[$i/15] fresh greptile items: ${fresh:-<EMPTY>}"
  if [ -z "$fresh" ]; then echo "ABORT: gh --jq returned empty (parse error or auth issue)"; exit 1; fi
  if [ "$fresh" -gt 0 ]; then echo "GOT RESPONSE"; break; fi
done
```

**Important: Greptile updates its existing summary comment in place** — it does NOT post a new one each round. Filter on `updatedAt`, not `createdAt`, or you'll miss every iteration past the first. The summary's `Reviews (N):` footer line is a useful sanity check that the count incremented.

**Greptile bot login:** match `author.login` with the prefix `greptile` (e.g. `greptile-apps`, `greptile-app`, `greptileai`). Do NOT hardcode a single login — the exact value varies by GitHub App installation.

**c. Pull ALL Greptile feedback — top-level comments, reviews, and review threads.** Greptile leaves feedback in up to three places; check all three. **Always extract `body` fields with `gh api graphql --jq`, never by piping to local `jq`** (control-char issue described in step b).

```bash
gh api graphql -f query='
  query($owner: String!, $repo: String!, $pr: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $pr) {
        comments(first: 100) { nodes { body author { login } updatedAt } }
      }
    }
  }' -f owner="$owner" -f repo="$repo" -F pr=<PR_NUMBER> \
  --jq '.data.repository.pullRequest.comments.nodes[] | select(.author.login // "" | startswith("greptile")) | .body'
```

- **Top-level summary comment** (from `comments[]`): Greptile's main "Greptile Summary" with confidence score and important files lands here, NOT in `reviews[]`. Find the Greptile-authored comment (`author.login` starts with `greptile`); on subsequent iterations the same comment is updated in place, so check `updatedAt > $trigger_ts` to confirm a fresh review. Read its full body — substantive concerns and the confidence score live here.
- **Review verdict** (from `reviews[]`): if Greptile posted a review (APPROVED / CHANGES_REQUESTED / COMMENTED), its `state` and `body` indicate the verdict. May be empty for some installations.
- **Review threads** (from `reviewThreads[]`): partition by `comments[0].author.login` starting with `greptile` to isolate Greptile threads. Only consider threads where `isResolved: false` AND `isOutdated: false`.

**d. Check the exit condition.** Exit the loop and continue to step 4 if ALL of:
- The Greptile summary comment indicates no actionable concerns (e.g. "Confidence Score: 5/5", "Safe to merge", or no remaining unresolved concerns called out)
- Any Greptile review verdict is `APPROVED` or absent (no `CHANGES_REQUESTED`)
- No unresolved/non-outdated Greptile review threads remain

**e. Address every concern** (from review body and from threads). Always post a reply so Greptile sees the response on its next review:

- If valid: implement the **minimal** fix → commit → push (`git push origin HEAD`, or `--force-with-lease` if you amended).
  - **Thread concerns:** reply to the thread explaining what changed, then resolve the thread.
  - **Review-body concerns:** post a top-level PR comment (`gh pr comment <PR_NUMBER> --body "..."`) explaining what changed.
- If invalid:
  - **Thread concerns:** reply explaining why, then resolve the thread.
  - **Review-body concerns:** post a top-level PR comment explaining your pushback.

Resolving a review thread requires a GraphQL mutation:

```bash
gh api graphql -f query='
mutation($threadId: ID!) {
  resolveReviewThread(input: { threadId: $threadId }) {
    thread { isResolved }
  }
}' -f threadId="$thread_id"
```

**f. Loop back to step a.**

### 4. Address Human Review Comments

Run the fetch query once more for fresh state. Check all three sources for human reviewer feedback (non-Greptile):

- **Review verdicts** — `reviews` with `state == CHANGES_REQUESTED` and body text from human authors
- **Inline review threads** — unresolved threads from non-Greptile authors
- **Top-level comments** — conversation comments from human reviewers

**Never respond to human comments on GitHub** — only the user should reply to humans.

For each human comment:
1. Evaluate whether the requested change is valid
2. If valid: implement the change, commit (no push — step 6 batches it), and tell the user what you changed and why
3. If questionable: tell the user what was requested and why you think pushback may be warranted — let them decide

Report all human comments to the user with your assessment, even if you already made the fix.

### 5. Run Specs Locally (only if commits were made)

Skip steps 5 and 6 entirely if step 4 produced no new commits — there's nothing to test or push. Check:

```bash
git log '@{u}..HEAD' --oneline
```

If empty, jump to step 7. Otherwise, run the specs touched by the new commits:

```bash
bundle exec rspec <changed_spec_files>
```

If specs fail, fix and commit before proceeding. Don't push known-broken code.

### 6. Rebase and Push

Rebase onto the PR's base branch — not necessarily `main`. If `gh pr view` fails here, abort. If `git rebase` hits conflicts, run `git rebase --abort` and stop — tell the user; don't try to resolve them yourself.

```bash
base=$(gh pr view <PR_NUMBER> --json baseRefName -q .baseRefName) || { echo "Could not resolve base branch"; exit 1; }
git fetch origin "$base"
git rebase "origin/$base" || { git rebase --abort; echo "Rebase conflicts — escalate to user"; exit 1; }
git push --force-with-lease origin HEAD
```

### 7. Wait for CI

```bash
gh pr checks <PR_NUMBER> --watch
```

- **All green** — done. Report success.
- **Failures** — run `CIRCLECI_TOKEN=$(cat ~/.circleci/token) bin/failedci` (or `gh run view --log-failed` if `bin/failedci` isn't available), diagnose, fix, commit. Then re-fetch comments (Reference query) in case new ones arrived during CI, address them as in step 4, run specs (step 5), rebase + push (step 6), and repeat from step 7.

If `gh pr checks --watch` is unavailable, poll `gh pr checks <PR_NUMBER>` every minute manually until green or failed.

## Reference: Fetch All PR Feedback

GitHub stores PR feedback in three separate places. The `gh` skill covers this in detail. This single GraphQL query fetches all three (REST APIs miss resolution status on inline comments).

**Filter and extract with `--jq` flag — do not pipe to local `jq`.** Greptile bodies and some bot comments contain literal control characters that crash external `jq`; gh's internal jq tolerates them. If you need bodies in shell, extract them with `--jq` (one body per call) — never read the full GraphQL JSON into a shell variable for re-parsing.

```bash
gh api graphql -f query='
query($owner: String!, $repo: String!, $pr: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $pr) {
      comments(first: 100) {
        nodes { body author { login } createdAt updatedAt }
      }
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          isOutdated
          comments(first: 10) {
            nodes { body author { login } path line createdAt updatedAt }
          }
        }
      }
      reviews(first: 50) {
        nodes { state body author { login } createdAt updatedAt }
      }
    }
  }
}' -f owner="$owner" -f repo="$repo" -F pr=<PR_NUMBER> --jq '<jq filter here>'
```

Returns:
- **`comments`** — top-level conversation comments (bot messages, general discussion). **Greptile's main review summary lands here**, not in `reviews[]`. Greptile **updates this comment in place** on each re-review — filter on `updatedAt`, not `createdAt`.
- **`reviewThreads`** — inline diff comments with resolution/outdated status. Each thread has an `id` (use for the `resolveReviewThread` mutation in step 3e). Greptile inline concerns appear here.
- **`reviews`** — review verdicts (APPROVED, CHANGES_REQUESTED, COMMENTED) and their body text. May be empty for Greptile depending on installation; don't rely on this alone.

## Notes

- **Never** mark a PR ready for review or change its draft status
- **Never** reply to human review comments on GitHub — report them to the user instead
- Always rebase on the PR's base branch before pushing — don't merge
- Use `--force-with-lease` when pushing after a rebase or amend (never `--force`)
- If a test failure looks flaky (passes locally, fails in CI), check if it's a known flaky test before debugging
- Don't create new commits for lint fixes — amend the HEAD commit with `git commit --amend --no-edit`. If the lint offense is in an earlier commit, create a fixup commit (`git commit --fixup <sha>`) and autosquash (`git rebase --autosquash origin/$base`).
