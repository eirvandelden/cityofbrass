# Plan: 4e monster powers (slice C of 4)

From `intent.md` (2026-10-05) and `spec.md` (2026-10-06). Status: accepted. Branch `56-monster-powers`, stacked on `56-monster-builder` (phase B, `plan-b-builder.md`). The PR targets that branch.

## Before this phase starts

Settle with Etienne:

- Where the power fields sit in the attack form, and whether "Usage" stays blank until chosen (this plan: blank).
- Confirm a local Chrome or Chromium for the Cuprite system tests.

## Context

A GM looks up the attack bonus and damage of every 4e monster power. Phase C prefills them live in the attack form from the monster's level, role and group (spec 9, 10). It adds an action type and the Elite and Solo marks (spec 12–14). Phase B added the builder (`Entity::MonsterBuildable`, `MonsterStats#attack_bonus`, `#power_damage(usage:, multi_target:)`).

Facts about the code (verified 2026-10-06):

- 4e "Powers" in the menu are `known_spells`, links to shared `Rulebuilder::Spell` rows. `entitybuilder_attacks` has its own `attack_bonus` and `damage_bonus`. The spec puts powers on the attack record; this plan follows it. The 4e menu lists "Attacks" too.
- `attacks/_form.html.erb` is a jQuery remote form (`form_with ..., local: false`), loaded through `new.js.erb`. `attack_bonus` and `damage_bonus` render `disabled` under a locked "Calculated bonus" label until `unlock_field()` (`engines/entitybuilder/app/assets/javascripts/entitybuilder/attacks.js`) enables them. A disabled input is not submitted.
- The engine has no Stimulus and no Turbo Frames; small inline scripts wire jQuery handlers (`attacks/_form.html.erb:107-120`).
- `AttacksController` (`attacks_controller.rb:118-146`) permits the attack fields; `attack_type` (Melee, Range, Special) is required.
- The sheet and profile render each attack through `attacks/sheet/_show_detail.html.erb`, which calls the `attack_display_profile` helper.
- System tests use `ApplicationSystemTestCase` (Cuprite) and sign in through the form, as in `test/system/sign_in_test.rb`.

## Design decisions

Made by Etienne in the plan stage (2026-10-06): prefill happens live in the form, proven by Cuprite system tests.

Made by this plan:

1. New attack columns: `power_usage` (blank, "At-will", "Encounter"), `action_type` ("Standard" default, "Minor", "Immediate interrupt", "Immediate reaction"), `multi_target`, `recharges_when_bloodied`, `usable_at_will` (booleans, default false, not null). Power fields render only on built 4e monsters; other attacks behave as today.
2. `Attack#power_prefill_options` returns the attack bonus and damage for every combination of usage, multi-target and usable-at-will, from `entity.monster_stats`. A "usable at will" power gets the at-will damage (spec 14).
3. `attacks/_power_fields.html.erb` renders the power fields with those options as `data-` attributes. `prefill_power()` in `attacks.js` fills `attack_bonus` and `damage_bonus` whenever the GM changes usage, multi-target or usable-at-will. It overwrites what the fields held; the GM edits afterwards.
   - It unlocks both inputs the way `unlock_field()` does, removing `disabled` and switching the icon to `fa-unlock`. `unlock_field()` toggles on the `disabled` attribute, so leaving the icon locked would make the next click re-disable the field and drop its value.
   - The damage shows as a flat number ("+15") with no dice; the GM adds dice by hand.
4. Validations on the attack: `recharges_when_bloodied` needs an Elite monster, an Encounter power and no other marked power on the entity. `usable_at_will` needs a Solo monster, an Encounter power and no other marked power. `action_type` and `power_usage` must be known values. The mark validations run only when the attack's power fields change (`will_save_change_to_recharges_when_bloodied?`, `..._usable_at_will?`, `..._power_usage?`). Otherwise reordering attacks through `update_list`, which autosaves a changed `sort_order`, would fail silently in JavaScript after a group change.
5. When the GM later changes the group, the marks stay stored. The sheet shows a mark only while the group allows it.
6. The sheet shows, for built monsters, each power's usage, action type, "Gains another use when first bloodied" and "Usable at will".
7. Strings are i18n keys in en, nl and it. JavaScript follows the surrounding jQuery code; the playbook's Stimulus preference is flagged and not followed, because the app has no Stimulus.

## Integration points

- Entitybuilder attacks: model, controller, form, sheet partial, `attacks.js`.
- `Entity::MonsterBuildable` and `MonsterStats` from phase B, read-only.
- Locales and the CI `i18n-tasks health` job. Primary database; migration in `db/migrate/`.

## Files that change

New:

- `db/migrate/<ts>_add_power_fields_to_entitybuilder_attacks.rb`.
- `engines/entitybuilder/app/views/entitybuilder/attacks/_power_fields.html.erb`.
- `test/system/monster_power_prefill_test.rb`, `test/integration/monster_powers_test.rb`.
- Fixtures: built level 4 Brute, Skirmisher and Minion creatures, a built level 3 Elite and Solo, their rows, and attacks in `attacks.yml` (one Elite encounter power already marked, one Solo encounter power already marked).

Changed:

- `engines/entitybuilder/app/models/entitybuilder/attack.rb` — validations, `power_prefill_options`.
- `engines/entitybuilder/app/controllers/entitybuilder/attacks_controller.rb` — permit the five fields.
- `attacks/_form.html.erb` — render `_power_fields`, wire `prefill_power()`.
- `attacks/sheet/_show_detail.html.erb` — usage, action type and marks.
- `engines/entitybuilder/app/assets/javascripts/entitybuilder/attacks.js` — `prefill_power()`.
- `config/locales/{en,nl,it}.yml`, `db/schema.rb`.

## Order of work

1. Write the system test `test/system/monster_power_prefill_test.rb` `at-will power of a level 4 brute prefills attack 9 and damage 15`. Run it, watch it fail.
2. Migration; `bin/rails db:migrate`; commit `db/schema.rb` with it.
3. Unit tests in `test/models/entitybuilder/attack_test.rb`; validations and `power_prefill_options`.
4. Permit the fields; `_power_fields`, `prefill_power()`, the sheet display, locale keys.
5. Make the phase C acceptance tests pass.
6. Run `bin/rails test`, `bin/rails test:system`, `bundle exec rubocop`, `bin/i18n-tasks health`, `bin/pre_push_checks`. All green.
7. Run `bin/dev`: add an at-will and an encounter power to a built monster; watch the prefill; mark an Elite power; check the sheet.
8. Re-read the full diff. Push and open the PR against `56-monster-builder`.

## Risks

- Live prefill overwrites a number the GM typed when the GM then changes usage. Accepted: changing usage asks for the new prefill.
- An inline script in a form injected by `new.js.erb`: follow the existing `unlock_field` wiring, which already works there.
- The prefill must enable the locked inputs, or the values are not submitted; the system tests save and check the stored values.
- Marks stay stored after a group change; the sheet hides disallowed marks.
- Rejected: prefill on save only (Etienne chose live); Stimulus (absent from the app); powers on `known_spells` (shared `Rulebuilder::Spell` rows cannot carry per-monster numbers).

## Out of scope

- Converting average damage into dice expressions.
- Automating Elite or Solo extra actions in Activeplay.
- The "Powers" menu (`known_spells`).
- A warning when damage falls outside 25%–50% (issue #150).

## Proof

Acceptance criteria from `spec.md` covered by phase C:

- At-will power, level 4 Brute: attack +9, damage 15 → `test/system/monster_power_prefill_test.rb` `at-will power of a level 4 brute prefills attack 9 and damage 15`
- Encounter power, level 4 Skirmisher: damage 15 → `test/system/monster_power_prefill_test.rb` `encounter power of a level 4 skirmisher prefills damage 15`
- Minion at-will power, level 4: damage 6 → `test/system/monster_power_prefill_test.rb` `at-will power of a level 4 minion prefills damage 6`
- Multi-target power, level 4 Skirmisher: damage 9 → `test/system/monster_power_prefill_test.rb` `multi-target power of a level 4 skirmisher prefills damage 9`
- Solo marks an encounter power "usable at will"; its damage prefills as at-will → `test/system/monster_power_prefill_test.rb` `solo encounter power usable at will prefills at-will damage`
- Elite marks an encounter power "recharges when first bloodied"; the sheet says so → `test/integration/monster_powers_test.rb` `elite power that recharges when first bloodied shows another use on the sheet`
- Elite refuses a second "recharges" mark → `test/integration/monster_powers_test.rb` `elite refuses a second power that recharges when first bloodied`
- Standard monster refuses the "recharges" mark → `test/integration/monster_powers_test.rb` `standard monster refuses recharges when first bloodied`
- Solo refuses a second "usable at will" mark → `test/integration/monster_powers_test.rb` `solo refuses a second power usable at will`
- Action type Immediate interrupt shows on the sheet → `test/integration/monster_powers_test.rb` `sheet shows an immediate interrupt action type`

Per changed file, the unit tests expected:

- `attack.rb` (`test/models/entitybuilder/attack_test.rb`): `refuses an unknown action type or power usage`, `refuses recharges when first bloodied on an at-will power`, `refuses usable at will outside a solo`, `refuses usable at will on an at-will power`, `a marked attack still saves a new sort order after a group change`, `power prefill options cover every usage and multi-target combination`, `usable at will prefills at-will damage`.
- The system tests save each prefilled power and check the stored `attack_bonus` and `damage_bonus`, which proves the unlocked inputs submit.

Test setup: fixtures only, on top of phase B's 4e fixtures: built level 4 Brute, Skirmisher and Minion creatures, built level 3 Elite and Solo creatures, one marked encounter power on each of the Elite and the Solo, and a level 3 Standard monster. System tests sign in as `users(:dan)` through the form.

---
Domain skills applied: rails-ui (i18n keys; Stimulus conflict flagged), rails-testing (system tests for JS flows, fixtures). Playbook §1: behaviour on the model, no service objects.
