# InfectionReport Test Data

## Minimum Viable Infection Report

```ruby
require "factory_bot_rails"

acct = FactoryBot.create(:account, name: "Test Account")
org = FactoryBot.create(:organization, name: "Test Org", account: acct)
agent = FactoryBot.create(:agent, organization: org)

ir = FactoryBot.create(:infection_report, reportable: agent, organization: org, account: acct)
# admin path: /admin/infection_reports/#{ir.id}
```

The `:infection_report` factory defaults: `reportable` = new `:agent`, with its own `account` and `organization`. Pass an existing agent/org/account when you need them linked to other records.

## Pitfalls

- **Don't reuse `Organization.first`** in dev — the show page calls `infection_report.integrations` which loads `account.integrations.active`. Long-lived dev accounts often have stale `integrations.type` values pointing to deleted STI classes (e.g. `Integrations::EscalationEmail`), which raises `ActiveRecord::SubclassNotFound` on render. Always create a fresh account.

## Linking Investigations to a Report

Association is `has_many :investigations, through: :infection_report_investigations` (`Soc::InfectionReportInvestigation` join model).

```ruby
inv = FactoryBot.create(:soc_investigation, organization: org, assigned_to: nil)
Soc::EntityInvestigation.find_or_create_by!(investigation: inv, entity: agent)
signal = FactoryBot.create(:signal, investigation: inv, entityable: agent, organization: org)
inv.signal_added(signal)

Soc::InfectionReportInvestigation.create!(infection_report: ir, investigation: inv)
```

See [soc_investigation.md](soc_investigation.md) for full investigation setup including signals.

## Full Recipe — Report + N Investigations

```ruby
require "factory_bot_rails"

acct = FactoryBot.create(:account, name: "Test Account")
org = FactoryBot.create(:organization, name: "Test Org", account: acct)
agent = FactoryBot.create(:agent, organization: org)

ir = FactoryBot.create(:infection_report, reportable: agent, organization: org, account: acct)

2.times do
  inv = FactoryBot.create(:soc_investigation, organization: org, assigned_to: nil)
  Soc::EntityInvestigation.find_or_create_by!(investigation: inv, entity: agent)
  signal = FactoryBot.create(:signal, investigation: inv, entityable: agent, organization: org)
  inv.signal_added(signal)
  Soc::InfectionReportInvestigation.create!(infection_report: ir, investigation: inv)
end

puts "/admin/infection_reports/#{ir.id}"
```
