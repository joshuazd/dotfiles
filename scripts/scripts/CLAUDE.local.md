# Notes

## Routing classifier preferences (lib/route.sh)

**Effort is the primary dial, not the model.** Opus is only ~1.67x Sonnet's per-token price, so the model gap is small: staying on Opus and laddering the reasoning *effort* down for simpler work is both cheaper-per-task (at low effort) and higher-quality than dropping to a weaker model. This *inverts* the old "drop the model before the effort" heuristic, which assumed a ~5x model gap. We now keep Opus and move effort.

Effort matrix (capability, not preference):
- **Opus** accepts the full ladder: `xhigh | high | medium | low`. `xhigh` is Opus-only.
- **Sonnet** / **opusplan** cap at `high` (no `xhigh`) and never run `low`. opusplan is locked to `high` (the launch-time `--effort` flag persists across the plan→execute model switch, and Sonnet doesn't accept xhigh).
- `haiku` is classifier-internal only (plus the manual `--tier haiku` override).

**PR review — pure Opus, single pass.** No plan-then-execute split, so opusplan/sonnet are never routed (gh-review uses no plan mode). Effort ladders on what the changed *paths are* (not counts).

**Story implement — always plan mode, default `opusplan+high`.** Opus plans, Sonnet executes the token-heavy middle (the one tier where Sonnet runs — execution is where tokens pile up, so even a 1.67x gap compounds). Every other tier stays on Opus through execution. Routes description-first: the description is the primary complexity signal; `story_type` (feature/bug/chore) is weak/secondary (a "bug" can be one line or a deadlock). Stories aren't pointed, so there's no `estimate` signal.

**The tiers themselves are NOT listed here** — they live in the `_route_matrix` table in `lib/route.sh`, the single source of truth. The classifier prompt, JSON enums, per-kind default, and this doc all derive from it. To see the live matrix:

```bash
bash lib/route.sh print-matrix
```

To change routing, edit that table (one row per tier) — not the prompt prose. The bar for `opus+xhigh` (story) is "execution itself needs sustained Opus reasoning," not "this is a real feature"; most real features land at `opusplan+high`. New simpler triggers ladder effort *down on Opus*, they do not switch model.

### The sticky default + confidence gate

- **The default is sticky.** Moving off the default requires *enumerated positive evidence* in the signal. A thin/vague/ambiguous PR or story holds at the default — never move on absence of information.
- **PR payload** carries `file_paths` (the real signal), `title`, `body`, `labels`, `branch` — not counts/additions/deletions.
- **Confidence gate (fail toward the default).** Both prompts emit a `confidence:"high|low"` field. In `_classify`, a `low` verdict is discarded and replaced with `_route_default_json <kind>` — the per-kind safe default, NOT a blanket opus+xhigh. Classifier *failure/timeout* also falls back to `_route_default_json` (`pr → opus+xhigh`, `story → opusplan+high`). "Fail upward" = fail to the *default*, which for stories is opusplan+high, not opus+xhigh.
- **Manual overrides honor the matrix.** `shortcut-implement`/`gh-review` pass `--reasoning` through bare (no `:-xhigh`) so `manual_route`'s per-tier default applies when omitted. `manual_route` clamps sonnet/opusplan `xhigh` → `high` and rejects `low` for those tiers; Opus passes through all four efforts unchanged.

### Deferred / rejected tiers

- **`opusplan+xhigh`** — deferred pending a manual test of whether `--effort xhigh` resets per-model across the opusplan plan→execute switch (Opus plans at xhigh, Sonnet executes at its cap) or persists into Sonnet and breaks execution.
- **`opusplan+medium`** — rejected. It forces plan-mode ceremony (plan-accept + context wipe) onto work that the `opus+medium`/`opus+low` tiers already handle plan-free. opusplan stays locked to `high` for the moderate default only; its niche is "Opus judgment on a token-heavy execution," not cheap mechanical work.

## Routing hint is informational only

The `<routing-hint>` block injected via `--append-system-prompt` is for the model's self-awareness and for debugging — it does NOT reliably steer subagent dispatch. An earlier `exec_tier` field tried to route execution subagents to Sonnet for Opus-planned stories via a skill-level instruction; in practice the hint was too indirect and the model ignored it. The field was removed.

If you want subagent dispatch to actually honor a tier, the right mechanism is a PreToolUse hook that intercepts `Agent` tool calls and injects the `model` parameter directly, not a prompt-time hint.

## Opus plans, Sonnet executes — via the `opusplan` alias

`opusplan` is a built-in Claude Code model alias: Opus while in plan mode, Sonnet automatically afterward. The story classifier picks it directly for moderate-complexity work (the default tier). Effort is `high` (not `xhigh`) because the launch-time `--effort` flag persists across the mid-session model switch and Sonnet doesn't accept xhigh.

**Stories always launch in plan mode.** `shortcut-implement` passes `--permission-mode plan` unconditionally — every routed story tier is `opus` or `opusplan`, so there's no longer a non-planning story tier (the old `sonnet+medium` skip-plan branch is gone). For the `opus+*` tiers, Opus plans *and* executes; for `opusplan`, Opus plans and Sonnet executes. The opus-vs-opusplan choice is purely "who executes after accept," not "is there a plan."

gh-review doesn't use plan mode, so opusplan is not a valid PR-review tier — PR reviews stay on Opus throughout (single pass).

## Post-plan-accept context clear

`showClearContextOnPlanAccept: true` is set in settings.json, so accepting a plan wipes the conversation context. Anything that needs to survive the wipe must live in:

1. The system prompt (`--append-system-prompt` content survives — that's where the routing hint and `<execution-default>` block in `shortcut-implement` live)
2. Auto-discovered `CLAUDE.md` files (reloaded on the new context)
3. The plan document itself (on disk, re-readable)

The implement skill's own instructions DO NOT survive — they're loaded mid-session via `/implement` and get wiped. That's why the "default to subagent-driven-development" guidance is duplicated into a system-prompt `<execution-default>` block by `shortcut-implement`, not just in the skill.

When adding new post-plan-accept behavioral defaults, put them in the system-prompt block, not in the skill.
