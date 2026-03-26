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

## Status Lifecycle

- `status: :open` — default, visible in queue
- `status: :closed` — set via `InvestigationStatusUpdaterJob` when all signals are closed
- `status: :reported` — set when signals are reported (creates infection report)

Investigation status changes happen in `Soc::InvestigationStatusUpdaterJob`, triggered by signal status changes — not directly on the investigation model from the UI.

## Broadcast Requirements

`broadcast_row_updated` fires on `after_update_commit` when `saved_change_to_status?` or `saved_change_to_assigned_to_id?`, but only if `broadcast_supported?` returns true (entity must be an `Agent`, not `Identity`).
