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

How to apply: when editing the classifier prompts in `_classifier_system_prompt` (lib/route.sh), preserve this asymmetry. If you ever add new downgrade triggers, prefer pushing them into the `sonnet + xhigh` bucket before considering `sonnet + high`.
