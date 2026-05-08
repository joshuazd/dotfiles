---
name: agent-eval
description: Use when creating, updating, or reviewing agentic agent eval fixtures and baselines — covers fixture schema, presenter_data mapping, assertion pitfalls, and baseline generation
---

# Agent Eval Fixtures

## Overview

Agent eval fixtures test SOC agent prompts by running them against stubbed data and asserting on the LLM output. Fixtures live in `lib/agentic_agent_eval/fixtures/`.

## Directory Structure

```
lib/agentic_agent_eval/fixtures/
  presenter_data/        # Input fixtures (you write these)
    <category>/          # e.g., itdr/, event_summary/, qc/
      <agent_name>/
        scenario.yml
  baselines/             # Auto-generated snapshots (committed to git)
    <category>/
      <agent_name>/
        scenario.yml
```

## Fixture Schema

```yaml
---
agent: <prompt_name>                               # Maps to a prompt via Soc::Agentic::Prompt.build
name: "Human-readable test name"
description: "What this tests and expected behavior"
result_tool: "Soc::Iris::Results::SomeResultTool"  # Tool that captures agent output
data_tools:                                        # Optional — tools the agent calls for data
  - "Soc::Iris::SomeDataTool"
presenter_data:                                    # Template variables for Liquid rendering
  # ... matches prompt's {{ variable }} placeholders
  # varies entirely by agent — check the prompt YAML and presenter class
tool_responses:                                    # Stubbed responses keyed by tool name
  "Soc::Iris::SomeDataTool":                       # Full class name OR short name both work
    some_field: "value"                            # (e.g., "FindInfectionReportTool" is valid)
expected:                                          # At least ONE assertion required
  confidence: "HIGH"                               # Exact match on output.confidence
  recommendation: "BENIGN"                         # Exact match on output.recommendation
  field_assertions:                                # Structured field comparisons
    - field: "benign_context"
      operator: "=="                               # >=, <=, >, <, ==, !=
      value: "BENIGN"
  must_include:                                    # Regex patterns required in text output
    - "(?i)pattern"
  must_not_include:                                # Regex patterns forbidden in text output
    - "(?i)bad_pattern"
```

## Critical Pitfalls

### field_assertions only support flat top-level keys

`Result#[]` calls `output.dig(key)` with a single string — it does NOT traverse nested hashes.

```yaml
# BROKEN — returns nil, always fails
- field: "device_analysis.device_switch_detected"
  operator: "=="
  value: true

# WORKS — flat top-level key
- field: "benign_context"
  operator: "=="
  value: "BENIGN"
```

For nested fields, use `must_include` / `must_not_include` regex patterns on the text output instead.

### presenter_data maps directly to Liquid template variables

The fixture's `presenter_data` keys are passed as-is to the Liquid template engine. Check the prompt YAML's `{{ variable }}` placeholders to know what keys to provide. Each agent has different variables — always check both:
1. The prompt YAML (`config/locales/soc/copilot/<prompt_name>.en.yml`) for the template placeholders
2. The presenter class for any computed/extra keys (e.g., `prior_agent_findings`, `event_summary`)

### tool_responses keys can be full class name or short name

Both formats work: `"Soc::Iris::ListITDRLoginActivityTool"` and `"FindInfectionReportTool"`. Check existing fixtures in the same category for the convention used.

### LLM output is non-deterministic — write resilient assertions

- Don't assert exact confidence levels unless the scenario makes it unambiguous
- Use `must_include` with flexible regex over exact field matches for LLM-generated text
- Run fixtures 2-3 times before committing to catch flakiness

## Finding Agent Config

To create a fixture, you need to identify the agent's prompt, presenter, result tool, and data tools. Start from the `agent` name in the fixture:

1. **Prompt YAML** — `Soc::Agentic::Prompt.build(name: "<agent>")` loads from `config/locales/soc/copilot/<agent>.en.yml`
2. **Presenter class** — look for `<AgentName>Presenter` under `app/models/soc/iris/prompts/` — defines `tools` and `prompt_placeholders`
3. **Result tool** — the last tool in the presenter's `tools` array (captures output)
4. **Data tools** — all other tools in the presenter's `tools` array

## Commands

```bash
# Lint all fixtures
bundle exec rake agentic_agent_eval:lint

# Run fixtures for a specific agent (matches agent name or directory path)
bundle exec rake "agentic_agent_eval:run[agent_name]"

# Run and record baselines
bundle exec rake "agentic_agent_eval:run[agent_name]" BASELINE=true

# Run a single fixture by path
bundle exec rake "agentic_agent_eval:fixture[category/agent_name/scenario]"

# Run all
bundle exec rake agentic_agent_eval:all

# Retry only failures from last run
bundle exec rake agentic_agent_eval:retry
```

## Workflow

1. Create presenter_data fixture YAML
2. `rake agentic_agent_eval:lint` — validate schema
3. `rake "agentic_agent_eval:run[agent]" BASELINE=true` — run and record baseline
4. If assertions fail, adjust assertions (not the prompt) and re-run
5. Run 2-3 more times without `BASELINE=true` to confirm stability
6. Commit both `presenter_data/` and `baselines/` files
