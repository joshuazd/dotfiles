---
name: test-data
description: Use when creating dev/test data via rails runner or console — covers FactoryBot loading, common pitfalls, association requirements, and model-specific recipes
---

# Creating Test Data

## Setup

FactoryBot is not loaded by default in `rails runner`. Always require it:

```ruby
RAILS_ENV=development bin/rails runner '
require "factory_bot_rails"
# ...
'
```

## Rules

- **Never create seed files** for ephemeral data — use `bin/rails runner` or the console
- **Check factory defaults** before passing attributes — factories often create their own associations (e.g., `:soc_investigation` creates a random `organization`)
- **Use `find_or_create_by!`** for shared fixtures (orgs, agents) to avoid duplicates on re-runs
- **Use `update_columns`** to set state without triggering callbacks when you just need data in a certain state

## Common Pitfalls

### Validation errors on associations
Some models (e.g., `Membership`) have validations that prevent simple `find_or_create_by!`. If you hit validation errors, try:
- Using `update_columns` to bypass validations
- Creating via the factory with required traits
- Checking what the factory provides by default

### Records not showing in the UI
When records exist but don't appear in a grid/queue, check:
1. **Filter defaults** — grids have `default_grid_params` that filter by owner, status, etc.
2. **Account/org scoping** — some views scope to the current user's account or org
3. **Authorization** — `load_and_authorize_resource` restricts access via CanCan abilities
4. **Missing associations** — a record might need related records (signals, entity_investigations) to be meaningful

### Callbacks and side effects
`FactoryBot.create` triggers callbacks. If callbacks enqueue jobs or send broadcasts, and you're creating many records, consider:
- Creating records with `update_columns` for fields that trigger callbacks
- Wrapping in a transaction if you want atomicity

## Model-Specific Recipes

Check the `references/` directory for model-specific instructions:

```
~/.claude/skills/test-data/references/
```

Each file documents the minimum viable setup for creating usable test data for that model, including required associations, default filter gotchas, and example scripts.
