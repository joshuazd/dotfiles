---
name: writing-migrations
description: Use when creating or modifying Rails database migrations — covers timestamp generation, strong_migrations requirements, custom Rubocop cops, and multi-database gotchas
---

# Writing Migrations

## Creating Migration Files

Always use the Rails generator — never create migration files manually.

```bash
bin/rails generate migration AddIndexesToSomeTable --no-test-framework
```

This produces a proper UTC timestamp (e.g., `20260327174641`). Hand-picked timestamps like `20260327000000` look wrong and don't follow conventions.

## strong_migrations

The `strong_migrations` gem blocks unsafe operations. Common patterns:

### Adding Indexes

Indexes must be added concurrently to avoid blocking writes:

```ruby
class AddIndexesToSomeTable < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :some_table, :column_name, algorithm: :concurrently
  end
end
```

**Required elements:**
- `disable_ddl_transaction!` — concurrent operations can't run inside a transaction
- `algorithm: :concurrently` — prevents table lock during index creation

### Adding Columns with Defaults

```ruby
# ✅ Rails 5+ handles this safely for most types
add_column :table, :col, :boolean, default: false
```

### Removing Columns

Ignore the column in the model first, deploy, then remove in a follow-up migration. `strong_migrations` will tell you this if you forget.

## Custom Rubocop Cops

### CustomCops/MigrationAddIndexIfNotExists

All `add_index` calls must include `if_not_exists: true`:

```ruby
add_index :table, :column, if_not_exists: true, algorithm: :concurrently
```

The linter auto-corrects this, but knowing it avoids a round-trip.

## Multi-Database

This project uses multiple databases. Namespaced tasks are required for single-migration operations:

```bash
# ❌ Fails
bin/rails db:migrate:down VERSION=20260327174641

# ✅ Works
bin/rails db:migrate:down:primary VERSION=20260327174641
```

Available databases: `primary`, `rio`, `timescale`, `clickhouse`, `clickhouse_internal`, `tenant`, `rio_shard1`, `rio_shard5`.

`bin/rails db:migrate` (without namespace) runs all databases and works fine.
