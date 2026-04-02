# Soc::Investigation Test Data

## Minimum Viable Investigation

An investigation needs these to appear in the Investigations Queue:

1. **Organization** — must match an org the user can see (admins see all)
2. **Agent entity** — `Soc::EntityInvestigation` linking to an `Agent` (not Identity). Required for broadcasts (`broadcast_supported?` checks `entity.is_a?(Agent)`)
3. **Signal** — at least one signal with `signal_added` called to set timestamp fields
4. **Status** — default is `:open`
5. **Owner** — set to `nil` (unassigned) to match the queue's default filter

## Queue Default Filters

`Admin::Soc::InvestigationsGrid.default_grid_params`:
```ruby
{ owners: ["unassigned", User.athena.id.to_s, current_user.id.to_s], status: ["open"] }
```

Records assigned to a random factory user won't appear — set `assigned_to: nil` for unassigned, or assign to the testing user / `User.athena`.

## Factory

```ruby
# Factory: :soc_investigation (spec/factories/soc/investigations.rb)
# Default: creates its own organization and assigned_to user
# Traits: :with_an_agent, :with_an_identity
```

The factory's default `assigned_to` is a random user — **override to nil** for queue visibility.

## Recipe

```ruby
require "factory_bot_rails"

org = Organization.find(1)  # or whatever org you need
agent = org.agents.first || FactoryBot.create(:agent, organization: org)

inv = FactoryBot.create(:soc_investigation, organization: org, assigned_to: nil)
Soc::EntityInvestigation.find_or_create_by!(investigation: inv, entity: agent)
signal = FactoryBot.create(:signal, investigation: inv, entityable: agent)
inv.signal_added(signal)
```

## Pitfalls

- **Account** has many validations (phone, subdomain, receipt_emails, addresses) — always use `FactoryBot.create(:account)`, never `find_or_create_by!`
- **Organization** factory always creates an associated account — to test "no account", use `update_columns(account_id: nil)` on the org AFTER creation, but beware: the `:with_an_agent` trait creates an agent scoped to the org, and that agent creation may fail if the org's account is nil. Create the investigation first, then nil out the org.
- **No-org investigations**: create the investigation normally, then `inv.update_columns(organization_id: nil)` — this bypasses the org presence validation

## Batch Script

```ruby
require "factory_bot_rails"

org = Organization.find(1)
agent = org.agents.first || FactoryBot.create(:agent, organization: org)

5.times do
  inv = FactoryBot.create(:soc_investigation, organization: org, assigned_to: nil)
  Soc::EntityInvestigation.find_or_create_by!(investigation: inv, entity: agent)
  signal = FactoryBot.create(:signal, investigation: inv, entityable: agent)
  inv.signal_added(signal)
  puts "Inv ##{inv.id}"
end
```

## Entity/Org/Account Combos

```ruby
require "factory_bot_rails"

# Agent + org + account (different names)
acct = FactoryBot.create(:account, name: "Acme Corp")
org = FactoryBot.create(:organization, name: "Acme Security", account: acct)
inv = FactoryBot.create(:soc_investigation, :with_an_agent, organization: org, assigned_to: nil)

# Identity + org + account
inv = FactoryBot.create(:soc_investigation, :with_an_identity, organization: org, assigned_to: nil)

# Agent only, no org
inv = FactoryBot.create(:soc_investigation, :with_an_agent, assigned_to: nil)
inv.update_columns(organization_id: nil)

# No entity, org + account
inv = FactoryBot.create(:soc_investigation, organization: org, assigned_to: nil)

# Nothing
inv = FactoryBot.create(:soc_investigation, assigned_to: nil)
inv.update_columns(organization_id: nil)
```

## Signals with Events

The `signals` association is **private** on `Soc::Investigation` — use `inv.send(:signals)` to access.

Signal class is `Signals::Signal` (not `Soc::Signal`).

To get signal details links in the UI, signals need a `first_signal_event_match` and `first_signal_event`. Create them via `signal_event_match` factory traits, then wire them up with `update_columns`.

### Safe signal_event_match traits (no external services)

| Trait | Description |
|---|---|
| `:antivirus_detection` | AV detection, creates resourceable |
| `:huntress_detector` | Huntress MAV action failure |
| `:defender_alert` | Defender alert (no signal_event association — creates bare match) |
| `:canary_file` | Ransomware canary file tripped |
| `:m365_detector` | M365 user entity detection |
| `:autorun_entry` | Autorun/Dridex detection |

### Traits that require external services (avoid in dev)

| Trait | Issue |
|---|---|
| `:elk_detector` | Triggers S3 call via `SigmaDetectorRules` — fails without AWS creds |

### Recipe: Investigation with multiple signal types

```ruby
require "factory_bot_rails"

org = Organization.find(1)
agent = org.agents.first

inv = FactoryBot.create(:soc_investigation, organization: org, assigned_to: nil)
Soc::EntityInvestigation.find_or_create_by!(investigation: inv, entity: agent)

# Helper to create a signal with an event
def create_signal_with_event(inv, org, agent, name:, trait:)
  signal = FactoryBot.create(:signal, organization: org, entityable: agent, investigation: inv, name: name)
  sem = FactoryBot.create(:signal_event_match, trait, signal: signal)
  signal.update_columns(first_signal_event_match_id: sem.id, first_signal_event_id: sem.signal_event_id)
  inv.signal_added(signal)
  signal
end

create_signal_with_event(inv, org, agent, name: "Ransomware Detection", trait: :antivirus_detection)
create_signal_with_event(inv, org, agent, name: "Ransomware Detection", trait: :antivirus_detection)
create_signal_with_event(inv, org, agent, name: "Suspicious Process",   trait: :huntress_detector)
create_signal_with_event(inv, org, agent, name: "Cobalt Strike Beacon", trait: :defender_alert)
create_signal_with_event(inv, org, agent, name: "Canary File Tripped",  trait: :canary_file)

puts "Investigation ##{inv.id} — #{inv.send(:signals).count} signals"
```

## Status Lifecycle

- `status: :open` — default, visible in queue
- `status: :closed` — set via `InvestigationStatusUpdaterJob` when all signals are closed
- `status: :reported` — set when signals are reported (creates infection report)

Investigation status changes happen in `Soc::InvestigationStatusUpdaterJob`, triggered by signal status changes — not directly on the investigation model from the UI.

## Broadcast Requirements

`broadcast_row_updated` fires on `after_update_commit` when `saved_change_to_status?` or `saved_change_to_assigned_to_id?`, but only if `broadcast_supported?` returns true (entity must be an `Agent`, not `Identity`).
