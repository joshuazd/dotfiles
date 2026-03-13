---
name: rspec
description: Use when writing, updating, or reviewing RSpec specs in the portal codebase — covers factory usage, spec type conventions, what to test and what to skip
---

# RSpec Conventions

## Factory Usage

- Prefer `build` over `create` — only persist to the database when the test requires it
- `build` is faster and avoids unnecessary DB writes; use `create` only when associations, callbacks, or queries require a persisted record

## What to Test by Spec Type

### Grids (`spec/grids/`)
- Column content and formatting
- Links rendered in cells
- Permission-based column visibility
- Sorting behavior
- CSV/XLSX export

### Components (`spec/components/`)
- Props and slots
- Data attributes and CSS classes
- Conditional rendering

### View logic (`spec/views/`)
- Permission-based visibility (`can?`) **only**
- Do NOT write view specs for plain conditionals or data-driven rendering in partials

### System tests (`spec/system/`)
- End-to-end workflows
- JS interactions
- Form submissions

## What NOT to Test

- CSS styling or visual layout
- Static HTML that doesn't involve logic or permissions
- View templates just to confirm they render without errors

## SimpleCov Branch Coverage

- A test can pass for the wrong reason — verify which branch is actually being exercised
- Adding more test cases through the same code path does not increase branch coverage
- Distinguish "new branches covered" from "more confidence on existing branches" before writing tests

## Rails: Pending Migrations

- If specs fail with `ActiveRecord::PendingMigrationError`, run `bin/rails db:migrate` first

## After Making Changes

- Always run relevant spec files to confirm nothing is broken
- Check whether existing specs need updating when implementing a story
