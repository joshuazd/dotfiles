---
name: backfill-jobs
description: Use when creating backfill jobs for data migrations or bulk updates — covers the generator, BaseJob contract, cursor iteration, testing, CODEOWNERS, and post-deploy enablement
---

# Backfill Jobs

Backfill jobs are resumable, idempotent batch operations for migrating or updating large datasets. They inherit from `Backfill::BaseJob`, run automatically via a scheduler, and self-disable on completion.

Full documentation: `doc/backfill_jobs.md`

## When to Use

- **Backfill job**: Large dataset updates that need cursor-based resumption, time windows, or runtime config
- **Migration**: Schema changes (add column, add index). Never put data updates in migrations.
- **Rails runner**: One-off dev/test data, small ad-hoc fixes

## Creating a Job

Always use the generator:

```bash
bin/rails generate backfill_job descriptive_name_here
```

Creates:
- `app/jobs/backfill/descriptive_name_here_job.rb`
- `spec/jobs/backfill/descriptive_name_here_job_spec.rb`

## Job Structure

```ruby
module Backfill
  class DescriptiveNameHereJob < BaseJob
    class Config < BaseJob::Config
      # Optional custom attributes:
      # attribute :batch_size, :integer, default: 1000
    end

    unique! timeout_in_sec: 1.hour, drop: true

    private

    def backfill
      scope = MyModel.where(field: nil)

      find_each_with_cursor(scope) do |record|
        record.update!(field: computed_value)
      end
    end
  end
end
```

### The `backfill` Method Contract

- **Must be idempotent** — safe to run multiple times on the same data
- **When it returns**, the job is marked complete and auto-disables
- Use `find_each_with_cursor` for per-record iteration (most common)
- Use `in_batches_with_cursor` for bulk operations (`update_all`, etc.)

### Cursor Methods

```ruby
# Per-record (most common)
find_each_with_cursor(scope, batch_size: 1000, order: :asc) do |record|
  record.update!(field: value)
end

# Batch operations
in_batches_with_cursor(scope, of: 500) do |batch|
  batch.update_all(field: value)
end
```

Both methods automatically track progress in Redis and resume from where they left off.

## Common Pitfalls

### Scope must filter to only records needing work

```ruby
# Good — only processes records that need updating
scope = MyModel.where(field: nil)

# Bad — processes everything, not idempotent if using increment
scope = MyModel.all
```

### Use `update_columns` or `update!` appropriately

- `update_columns` — skips validations and callbacks, fastest
- `update!` — runs validations and callbacks, use when side effects are needed

### Don't forget the Config class

Every job needs `class Config < BaseJob::Config; end` even if empty. The generator includes this.

### Guard against missing associations

```ruby
find_each_with_cursor(scope) do |record|
  next unless record.associated_record
  record.update!(field: record.associated_record.value)
end
```

## CODEOWNERS

Add entries for both job and spec to `.github/CODEOWNERS` under the appropriate team section:

```
/app/jobs/backfill/descriptive_name_here_job.rb @huntresslabs/your-team
/spec/jobs/backfill/descriptive_name_here_job_spec.rb @huntresslabs/your-team
```

## Testing

```ruby
require "rails_helper"

RSpec.describe Backfill::DescriptiveNameHereJob do
  subject { described_class.new.send(:backfill) }

  it "updates records that match the criteria" do
    record = create(:my_model, field: nil)
    expect { subject }.to change { record.reload.field }.from(nil).to(expected_value)
  end

  it "does not update records that don't match" do
    record = create(:my_model, field: "already_set")
    expect { subject }.not_to change { record.reload.field }
  end
end
```

## Post-Deploy

Jobs are disabled by default. After deploying, enable via Rails console:

```ruby
Backfill::DescriptiveNameHereJob.enable!
```

The `Backfill::ExecuteJob` scheduler picks it up within 1 minute. Monitor via:

```ruby
Backfill::DescriptiveNameHereJob.enabled?
Backfill::DescriptiveNameHereJob.cursors
```

## Time Windows (Optional)

For heavy operations, restrict execution to low-traffic hours:

```ruby
# Daily at 2am UTC for 4 hours
window_for :backfill, repeats: :daily, at: "02:00", duration: "PT4H"
```

Durations use ISO 8601: `PT12H` (12 hours), `P7D` (7 days), `PT30M` (30 minutes).

## Remove Generated Comments

The generator adds explanatory comments in the `backfill` method. Remove them — they're scaffolding noise.
