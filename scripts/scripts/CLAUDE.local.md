# Notes

## Routing classifier preferences (lib/route.sh)

User prefers to keep reasoning effort at `xhigh` (or `high` for truly mechanical work) and is more willing to drop the *model* tier than the *effort* tier. Concretely:

- Reasoning levels are coupled to the model:
  - **Opus** → `xhigh` or `high` (xhigh is the only Opus-only effort tier)
  - **Sonnet** / **opusplan** → `high` or `medium` (xhigh is NOT supported once Sonnet is in play)
  - Never emit `low`.
- Model tiers (story implement): `opus`, `opusplan`, or `sonnet`. PR review: `opus` or `sonnet` only (opusplan needs plan mode, which gh-review doesn't use). Never `haiku` (only the classifier itself runs at haiku, and the manual `--tier haiku` override).
- **Default for story implement is `opusplan + high`**: Opus plans, Sonnet executes via the built-in alias. Upgrade to `opus + xhigh` only when execution itself needs Opus reasoning (state machines, cross-cutting work, novel patterns). Downgrade to `sonnet + high` for well-scoped single-component / UI / migration / bug-fix work.
- Default for PR review remains `opus + xhigh`.

Why: cost is dominated by the model choice, not the effort level. The user gets more value from full effort on a cheaper model than from a cheaper effort on the heavier model.

How to apply: when editing the classifier prompts in `_classifier_system_prompt` (lib/route.sh), preserve this asymmetry. New downgrade triggers should land in `sonnet + high` before `sonnet + medium`. The bar for `opus + xhigh` is "execution itself needs Opus reasoning" — not just "this is a real feature." Most real features should land at `opusplan + high`.

## Routing hint is informational only

The `<routing-hint>` block injected via `--append-system-prompt` is for the model's self-awareness and for debugging — it does NOT reliably steer subagent dispatch. An earlier `exec_tier` field tried to route execution subagents to Sonnet for Opus-planned stories via a skill-level instruction; in practice the hint was too indirect and the model ignored it. The field was removed.

If you want subagent dispatch to actually honor a tier, the right mechanism is a PreToolUse hook that intercepts `Agent` tool calls and injects the `model` parameter directly, not a prompt-time hint.

## Opus plans, Sonnet executes — via the `opusplan` alias

`opusplan` is a built-in Claude Code model alias: Opus while in plan mode, Sonnet automatically afterward. The story classifier picks it directly for moderate-complexity work (the default tier). Effort is `high` (not `xhigh`) because the launch-time `--effort` flag persists across the mid-session model switch and Sonnet doesn't accept xhigh.

gh-review doesn't use plan mode, so opusplan is not a valid PR-review tier — PR reviews stay on a single model throughout.
