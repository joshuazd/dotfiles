# Notes

## Routing classifier preferences (lib/route.sh)

**Effort is the primary dial, not the model.** Opus is only ~1.67x Sonnet's per-token price, so the model gap is small: staying on Opus and laddering the reasoning *effort* down for simpler work is both cheaper-per-task (at low effort) and higher-quality than dropping to a weaker model. This *inverts* the old "drop the model before the effort" heuristic, which assumed a ~5x model gap. We now keep Opus and move effort.

**The classifier emits `opus`, plus `fable` for one tier per kind.** Both kinds are Opus with effort as the dial, except the complex tier, which is `fable+medium` (see Rejected tiers). Nothing routed runs at `xhigh`. Sonnet is too weak for this work, and the ~1.67x per-token saving does not buy back the quality loss. `sonnet`, `opusplan` and `haiku` are reachable only through the manual `--tier` override.

Effort matrix (capability, not preference):
- **Opus** and **Fable** accept the full ladder: `xhigh | high | medium | low`. Fable is 1M context by default, so its CLI alias carries no `[1m]` suffix.
- **Sonnet** / **opusplan** cap at `high` (no `xhigh`) and never run `low` — manual-override territory only. For opusplan the launch-time `--effort` flag persists across the plan→execute model switch, and Sonnet doesn't accept xhigh.
- `haiku` is classifier-internal only (plus the manual `--tier haiku` override).

**PR review — single pass, default `opus+high`.** Effort ladders on what the changed *paths are* (not counts). `fable+medium` is not the step above the default: it needs a named risk (concurrency, authz / tenant isolation, a data-rewriting migration or backfill, a state-machine change). Its first trigger, "spans multiple production areas", sent ordinary multi-area PRs to Fable. Checked against the live classifier: a multi-area PR adding data sources → opus+high (3/3), a webhook race fix → fable, a PR removing backfill jobs → opus+high.

**Story implement — always plan mode, default `opus+high`.** The same model plans and executes at every tier. Routes description-first: the description is the primary complexity signal; `story_type` (feature/bug/chore) is weak/secondary (a "bug" can be one line or a deadlock). Stories aren't pointed, so there's no `estimate` signal.

**The tiers themselves are NOT listed here** — they live in the `_route_matrix` table in `lib/route.sh`, the single source of truth. The classifier prompt, JSON enums, per-kind default, and this doc all derive from it. To see the live matrix:

```bash
bash lib/route.sh print-matrix
```

To change routing, edit that table (one row per tier) — not the prompt prose. New simpler triggers ladder effort *down on Opus*, they do not switch model. Two calibration notes for the story ladder:

- `fable+medium` uses the same named-risk bar as PR review (concurrency, authz / tenant isolation, a data-rewriting migration or backfill, a state-machine change). Its first trigger, "cross-cutting / multi-subsystem / novel pattern", matched most real stories. Breadth, size and new patterns land on the `opus+high` default. Checked against the live classifier: a multi-subsystem binding story → opus+high (2/2), a webhook race fix → fable, a count bug plus backfill of missed records → opus+high.
- `opus+medium` is deliberately broad: the test is whether the **approach** is already settled by the description, NOT how many files the work touches. A mechanical change across a dozen files, or a field/endpoint added along an existing pattern, is medium. Breadth alone never escalates; open design decisions do, and those land on the `opus+high` default.

### The sticky default + confidence gate

- **The default is sticky.** Moving off the default requires *enumerated positive evidence* in the signal. A thin/vague/ambiguous PR or story holds at the default — never move on absence of information.
- **PR payload** carries `file_paths` (the real signal), `title`, `body`, `labels`, `branch` — not counts/additions/deletions.
- **Confidence gate (fail toward the default).** Both prompts emit a `confidence:"high|low"` field. In `_classify`, a `low` verdict is discarded and replaced with `_route_default_json <kind>` — the per-kind safe default, NOT a blanket opus+xhigh. Classifier *failure/timeout* also falls back to `_route_default_json`, which is `opus+high` for both kinds. "Fail upward" = fail to the *default*, not to the top tier.
- **Manual overrides honor the matrix.** `shortcut-implement`/`gh-review` pass `--reasoning` through bare (no `:-xhigh`) so `manual_route`'s per-tier default applies when omitted. `manual_route` clamps sonnet/opusplan `xhigh` → `high` and rejects `low` for those tiers; Opus and Fable pass through all four efforts unchanged. A bare `--tier opus` defaults to `high`, `--tier fable` to `medium`; `xhigh` is reachable only by asking for it with `--reasoning`.

### Rejected tiers

- **`opus+xhigh`, both kinds** - removed 2026-10-19. For stories it was the complex tier and ran far too long, regularly doing work the story did not ask for; for PRs it was the default. The complex tier of each kind is now `fable+medium`: Fable is the more capable model, so medium effort on it covers hard work without the xhigh runtime. The PR default dropped to `opus+high`, absorbing the old single-production-area tier. `_classify` drops any verdict whose model+effort pair is not a matrix row, so the classifier cannot drift into `fable+xhigh` or back to `opus+xhigh`; an off-matrix pair falls back to the default like a low-confidence verdict.
- **Any `opusplan` tier** — removed from the story matrix 2026-09-17. It was the default (`opusplan+high`), which meant Sonnet executed most stories; the output quality was not acceptable. The plan→execute handoff also forced an effort cap (`high`, since Sonnet rejects xhigh) onto the planning half. Sonnet never executes a routed story.

## Routing hint is informational only

The `<routing-hint>` block injected via `--append-system-prompt` is for the model's self-awareness and for debugging — it does NOT reliably steer subagent dispatch. An earlier `exec_tier` field tried to route execution subagents to Sonnet for Opus-planned stories via a skill-level instruction; in practice the hint was too indirect and the model ignored it. The field was removed.

If you want subagent dispatch to actually honor a tier, the right mechanism is a PreToolUse hook that intercepts `Agent` tool calls and injects the `model` parameter directly, not a prompt-time hint.

## Stories always launch in plan mode

`shortcut-implement` passes `--permission-mode plan` unconditionally — there is no non-planning story tier (the old `sonnet+medium` skip-plan branch is gone). The model plans, the user accepts, the same model executes. `opusplan` is still a valid `--tier` value for a manual launch, and plan mode is what its Sonnet handoff needs; the classifier never picks it.

gh-review uses no plan mode, so a PR review is a single Opus pass throughout.

## Post-plan-accept context clear

`showClearContextOnPlanAccept: true` is set in settings.json, so accepting a plan wipes the conversation context. Anything that needs to survive the wipe must live in:

1. The system prompt (`--append-system-prompt` content survives — that's where the routing hint and `<execution-default>` block in `shortcut-implement` live)
2. Auto-discovered `CLAUDE.md` files (reloaded on the new context)
3. The plan document itself (on disk, re-readable)

The implement skill's own instructions DO NOT survive — they're loaded mid-session via `/implement` and get wiped. That's why the "default to subagent-driven-development" guidance is duplicated into a system-prompt `<execution-default>` block by `shortcut-implement`, not just in the skill.

When adding new post-plan-accept behavioral defaults, put them in the system-prompt block, not in the skill.
