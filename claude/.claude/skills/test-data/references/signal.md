# Signals::Signal Test Data

## Minimum Viable Signal (Admin Queue)

A signal needs these to appear in the admin signals queue (`/admin/signals`):

1. **Status** — `open` or `reporting_in_progress`
2. **Priority** — `critical` or `high`
3. **Source types** — non-empty, matching an active entitlement on the account
4. **Active entitlement** — account must have an entitlement matching the source type (EDR for `:autorun_entries`, M365 for ITDR types, Logs for SIEM types)
5. **Created recently** — default `from_date` filter is `1.day.ago`
6. **Not assigned to SOAR/Athena** — `exclude_soar` filter is on by default

## Queue Default Filters

`Admin::SignalsDatatable.default_filters`:
```ruby
{ priority: %w[critical high],
  status: %w[open reporting_in_progress],
  from_date: 1.day.ago.to_date,
  assignment: %w[exclude_soar] }
```

## Critical Hidden Filter

The datatable applies `.with_valid_product` which joins to entitlements:
- EDR entitlement required for `source_types: [:autorun_entries]` (and other EDR types)
- M365 entitlement required for ITDR source types
- Logs entitlement required for SIEM source types

Signals without `source_types` or without a matching entitlement are **silently excluded**.

## Factory

```ruby
# Factory: :signal (spec/factories/signals/signals.rb)
# Default: creates org, account, agent entity. priority: :experimental, status: nil
# Traits:
#   :open             — status: :open
#   :closed           — status: :closed, contexts: [:false_positive]
#   :reported         — status: :reported, creates infection report
#   :assigned         — adds analyst user
#   :account_edr_active   — org with active EDR entitlement
#   :account_m365_active  — org with active M365 entitlement
#   :edr_source_types     — source_types: [:autorun_entries]
#   :m365_source_types    — source_types: [:m365_detections]
#   :logs_source_types    — source_types: [:siem_detections]
```

## Recipe (minimal — queue visibility only)

```ruby
require "factory_bot_rails"
include FactoryBot::Syntax::Methods

signal = create(:signal, :open, :account_edr_active, :edr_source_types, priority: :high)
puts "Signal ##{signal.id} — org: #{signal.organization.name}"
```

## Recipe (with signal event — needed for end-to-end testing)

Without a `first_signal_event`, background jobs like `as_mcp_json` blow up with `NoMethodError: undefined method 'resource_attributes_schema' for nil`.

```ruby
require "factory_bot_rails"
include FactoryBot::Syntax::Methods

signal = create(:signal, :open, :account_edr_active, :edr_source_types, priority: :high)
sem = create(:signal_event_match, :antivirus_detection, signal: signal)
signal.update_columns(
  first_signal_event_match_id: sem.id,
  first_signal_event_id: sem.signal_event_id,
  resource_attributes: sem.signal_event&.resource_attributes
)
```

### Safe signal_event_match traits

| Trait | Description |
|---|---|
| `:antivirus_detection` | AV detection, creates resourceable |
| `:huntress_detector` | Huntress MAV action failure |
| `:defender_alert` | Defender alert (bare match, no signal_event) |
| `:canary_file` | Ransomware canary file tripped |
| `:m365_detector` | M365 user entity detection |
| `:autorun_entry` | Autorun/Dridex detection — **has uniqueness constraint on type, can only create one per DB** |

### Traits that require external services (avoid in dev)

| Trait | Issue |
|---|---|
| `:elk_detector` | Triggers S3 call via `SigmaDetectorRules` — fails without AWS creds |

## Partner Queue

For signals visible in the partner/account queue (`partner_visible` scope):
- `status: :closed` or `status: :reported`
- `suppressed: false`
- Not a `Mailbox` entity
- Created within the last 180 days

## Pitfalls

- **Default priority is `:experimental`** — won't show in admin queue (needs `critical` or `high`)
- **Default `source_types` is empty** — fails `with_valid_product`, silently hidden
- **No `first_signal_event` by default** — factory doesn't create signal events. Background jobs (`as_mcp_json`) crash with `NoMethodError` on `nil`. Use the "with signal event" recipe for end-to-end testing.
- **Factory creates a new org/account each time** — the signal won't be on your dev user's org. Use the admin queue or pass a specific org
- **`from_date` filter** — if somehow the signal's `created_at` is backdated, it won't show with default filters
- **`:autorun_entry` trait has a uniqueness constraint** — can only create one per DB. Use `:antivirus_detection` for multiple signals
- **Never reuse existing agents/entities** — existing agents may have stale data (nil signals, broken associations) that cause unrelated errors. Always `create(:agent, organization: org)` for a clean entity
