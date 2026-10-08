# Plan: 4e encounter difficulty (slice D of 4)

From `intent.md` (2026-10-05) and `spec.md` (2026-10-06). Status: accepted. Branch `56-monster-difficulty`, stacked on `56-monster-powers` (phase C, `plan-c-powers.md`). The PR targets that branch.

## Before this phase starts

Settle with Etienne:

- The campaign picker offers only the GM's own 4e campaigns (this plan). Confirm, or include campaigns the GM plays in.

## Context

A GM cannot see whether a 4e monster is an easy or impossible fight for a party. Phase D lets the GM pick a campaign on the builder page and shows Easy, Standard, Hard or Impossible (spec 18–23). Phase B added the builder and `MonsterStats#experience` and `ENCOUNTER_XP_BUDGET` (Appendix B of `plan-b-builder.md`, saved as `docs/4e-xp-tables.md`).

Facts about the code (verified 2026-10-06):

- `Campaignmanager::Campaign#characters` (`engines/campaignmanager/app/models/campaignmanager/campaign.rb:69`) lists the `ResidentCharacter`s joined through `entitybuilder_campaign_joins`, with a restricted `select` that includes `id`. A campaign's rule set is `campaignmanager_campaigns.core_rules`.
- `Resident#campaigns` (`app/models/resident.rb:16`) lists the campaigns a resident owns.
- No code computes a character's level. `ClassLevel` has a nullable integer `level`. 4e characters get no class level row by default.
- `Entity#campaign_join` / `#campaign` link characters to a campaign; reusing it for a monster would change `Entity#district` and add the monster to `Campaign#entity_joins`.
- There are no class level fixtures and no `dnd4e` campaign fixture. `test/fixtures/entitybuilder/campaign_joins.yml` defines the key `one` twice (the last wins); leave it as it is.

## Design decisions

Made by Etienne in the plan stage (2026-10-06): a joined character without a class level counts as level 1.

Made by this plan:

1. A nullable `encounter_campaign_id` (text, indexed) on `entitybuilder_entities`; `belongs_to :encounter_campaign, class_name: "Campaignmanager::Campaign", optional: true`, in `Entity::MonsterBuildable`. It does not reuse `campaign_join`.
2. The picker offers the resident's own 4e campaigns, `resident.campaigns.where(core_rules: "dnd4e")`. A validation refuses any other id; it runs only when the id changes (`if: :will_save_change_to_encounter_campaign_id?`). A deleted campaign leaves a dangling id; `encounter_campaign` returns nil, no difficulty shows, and other saves keep working.
3. `ResidentCharacter#character_level`: the sum of its class levels, minimum 1.
4. `Entitybuilder::EncounterDifficulty = Data.define(:monster_experience, :party_levels)`: party size is the count; party level is the average, `round`ed; encounter level is the highest level N in 1–40 with `ENCOUNTER_XP_BUDGET[N] × party size ≤ monster experience`, else 0 (spec 21); `rating` is `:easy` (difference −1 or lower), `:standard` (0 or +1), `:hard` (+2 to +4), `:impossible` (+5 or higher), or nil for an empty party.
5. `Entity#encounter_difficulty` returns nil unless the monster is built and has a campaign. The party comes from `encounter_campaign.characters.includes(:class_levels)`.
6. The builder page shows the picker, the rating, the party size and level, and a hint to join characters when the party is empty (spec 23). `encounter_campaign_id` joins the builder's permitted params.
7. Strings are i18n keys in en, nl and it.

## Integration points

- Campaign Manager: `Campaign#characters`, `Resident#campaigns`, read-only. No Campaign Manager file changes.
- Entitybuilder: `ResidentCharacter`, `Entity::MonsterBuildable`, the builder page.
- Locales and the CI `i18n-tasks health` job. Primary database; migration in `db/migrate/`.

## Files that change

New:

- `db/migrate/<ts>_add_encounter_campaign_to_entitybuilder_entities.rb`.
- `engines/entitybuilder/app/models/entitybuilder/encounter_difficulty.rb`.
- `test/integration/monster_difficulty_test.rb`, `test/models/entitybuilder/encounter_difficulty_test.rb`.
- Fixtures: additions to `test/fixtures/entitybuilder/class_levels.yml` (phase A created it); 4e characters in `entities.yml`; their joins in `campaign_joins.yml` (new keys); 4e campaigns in `test/fixtures/campaignmanager/campaigns.yml`. New entity and campaign fixtures leave legacy rich text columns out, or `test/fixtures/action_text/rich_texts_test.rb` fails.

Changed:

- `engines/entitybuilder/app/models/entitybuilder/resident_character.rb` — `character_level`.
- `engines/entitybuilder/app/models/entitybuilder/entity/monster_buildable.rb` — association, validation, `encounter_difficulty`.
- `monster_builds_controller.rb`, `monster_builds/edit.html.erb` — picker and difficulty.
- `config/locales/{en,nl,it}.yml`, `db/schema.rb`.

## Order of work

1. Write the acceptance test `test/integration/monster_difficulty_test.rb` `level 5 standard monster against five level 5 characters is easy`. Run it, watch it fail.
2. Unit tests and `ResidentCharacter#character_level`.
3. Unit tests `test/models/entitybuilder/encounter_difficulty_test.rb`; write `EncounterDifficulty`.
4. Migration; `bin/rails db:migrate`; commit `db/schema.rb` with it.
5. Unit tests for the association, its validation and `encounter_difficulty`; write them.
6. Picker and difficulty on the builder page; locale keys.
7. Make the phase D acceptance tests pass.
8. Run `bin/rails test`, `bin/rails test:system`, `bundle exec rubocop`, `bin/i18n-tasks health`, `bin/pre_push_checks`. All green.
9. Run `bin/dev`: pick a 4e campaign with joined characters on a built monster and read the rating; pick an empty one and read the hint.
10. Re-read the full diff. Push and open the PR against `56-monster-powers`.

## Risks

- `Campaign#characters` uses a restricted `select`; loading class levels per character must keep `id` (it does).
- Characters without class levels count as level 1, which may understate a party that never filled in levels.
- A dangling `encounter_campaign_id` after a campaign is deleted shows no difficulty; acceptable.
- Rejected: reusing `campaign_join` (side effects on district and campaign joins); campaigns the GM only plays in (a GM rates monsters for their own table).

## Out of scope

- Multi-monster encounters; the rating is for one monster.
- Showing the difficulty on the public sheet; it is GM information on the builder page.
- Campaign Manager changes.

## Proof

Acceptance criteria from `spec.md` covered by phase D:

- Level 5 Standard vs five level 5 characters: Easy → `test/integration/monster_difficulty_test.rb` `level 5 standard monster against five level 5 characters is easy`
- Level 5 Solo vs five level 5: Standard → `test/integration/monster_difficulty_test.rb` `level 5 solo against five level 5 characters is standard`
- Level 3 Minion vs four level 3: Easy → `test/integration/monster_difficulty_test.rb` `level 3 minion against four level 3 characters is easy`
- Level 9 Solo vs five level 5: Hard → `test/integration/monster_difficulty_test.rb` `level 9 solo against five level 5 characters is hard`
- Level 10 Solo vs five level 5: Impossible → `test/integration/monster_difficulty_test.rb` `level 10 solo against five level 5 characters is impossible`
- Campaign without joined characters: no difficulty, a hint → `test/integration/monster_difficulty_test.rb` `campaign without characters shows a hint instead of a difficulty`
- A Pathfinder 2e creature shows no difficulty and no power prefill → `test/integration/monster_difficulty_test.rb` `pathfinder 2e creature has no builder, difficulty or power fields`

Per changed file, the unit tests expected:

- `resident_character.rb` (`test/models/entitybuilder/resident_character_test.rb`): `character level sums class levels`, `character level is 1 without class levels`.
- `encounter_difficulty.rb` (`test/models/entitybuilder/encounter_difficulty_test.rb`): `no rating for an empty party`, `encounter level is 0 below the level 1 budget`, `party level rounds the average`, `difference of -1 is easy`, `difference of 0 and 1 is standard`, `difference of 2 and 4 is hard`, `difference of 5 is impossible`.
- `entity/monster_buildable.rb` (`test/models/entitybuilder/entity/monster_buildable_test.rb`): `refuses an encounter campaign the resident does not own`, `refuses a non-4e encounter campaign`, `a deleted encounter campaign does not block saves`, `no difficulty without a built monster or a campaign`.

Test setup: fixtures only. Three 4e campaigns owned by razune: five joined level 5 characters, four joined level 3 characters, and none. Characters, joins and class levels may use ERB loops in the YAML. Built monsters: level 5 Standard, level 5 Solo, level 3 Minion, level 9 Solo, level 10 Solo, each with its campaign set. Reuse the phase A pf2e creature.

---
Domain skills applied: rails-testing (fixtures, integration tests first). Playbook §1: behaviour on the model and value objects, no service objects.
