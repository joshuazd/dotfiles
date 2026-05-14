# Notes

## Routing classifier preferences (lib/route.sh)

User prefers to keep reasoning effort at `xhigh` (or `high` for truly mechanical work) and is more willing to drop the *model* tier than the *effort* tier. Concretely:

- Reasoning levels are coupled to the model:
  - **Opus** → `xhigh` or `high` (xhigh is the only Opus-only effort tier)
  - **Sonnet** → `high` or `medium` (xhigh is NOT supported on Sonnet)
  - Never emit `low`.
- Model tiers in classifier output: only `opus` or `sonnet`. Never `haiku` (haiku stays in the codebase as the *classifier* model and as a manual `--tier haiku` override only).
- Default routing is `opus + xhigh`. Downgrade rules favor dropping the model to `sonnet` (with `high`) before dropping the effort tier further to `medium`.

Why: cost is dominated by the model choice, not the effort level. The user gets more value from full effort on a cheaper model than from a cheaper effort on the heavier model.

How to apply: when editing the classifier prompts in `_classifier_system_prompt` (lib/route.sh), preserve this asymmetry. If you ever add new downgrade triggers, prefer pushing them into the `sonnet + high` bucket before considering `sonnet + medium`.

## Routing hint is informational only

The `<routing-hint>` block injected via `--append-system-prompt` is for the model's self-awareness and for debugging — it does NOT reliably steer subagent dispatch. An earlier `exec_tier` field tried to route execution subagents to Sonnet for Opus-planned stories via a skill-level instruction; in practice the hint was too indirect and the model ignored it. The field was removed.

If you want subagent dispatch to actually honor a tier, the right mechanism is a PreToolUse hook that intercepts `Agent` tool calls and injects the `model` parameter directly, not a prompt-time hint.

## Opus plans, Sonnet executes — via the `opusplan` alias

For shortcut-implement at opus tier with plan mode on, the launch passes `--model opusplan` instead of the literal Opus model ID. `opusplan` is a built-in Claude Code alias that uses Opus while in plan mode and auto-switches to Sonnet the moment plan mode is exited. This is the actual "Opus plans, Sonnet executes" mechanism — much more reliable than skill-level instructions.

Effort is capped at `high` for opusplan launches because Sonnet doesn't support `xhigh` and the launch-time `--effort` flag persists across the mid-session model switch.

gh-review doesn't use plan mode, so opusplan doesn't apply there — PR reviews stay on a single model throughout.
