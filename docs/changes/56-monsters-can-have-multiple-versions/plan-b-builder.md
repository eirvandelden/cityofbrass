# Plan: 4e monster builder (slice B of 4)

From `intent.md` (2026-10-05) and `spec.md` (2026-10-06). Status: accepted. Branch `56-monster-builder`, stacked on `56-monsters-can-have-multiple-versions` (phase A, `plan.md`). The PR targets that branch.

## Before this phase starts

Settle with Etienne:

- Anything phase A taught about the copy (`Entity::Versionable#create_version`), since step 10 extends it.

## Context

A GM fills in every 4e monster number by hand. Phase B adds an opt-in builder for 4e resident creatures and NPCs: level, role and group fill in the "Monster Manual 3 on a business card" numbers (spec 6–8, 11). Hand-edited values survive recalculation and show "needs manual revision". A new version at another level recalculates (spec 16, 17). Phase A (`plan.md`) already added versions.

Facts about the code (verified 2026-10-06):

- The rule set is the text slug `entitybuilder_entities.core_rules` (`"dnd4e"`). `lib/core_rules/entity.rb` reads flags from `config/core_rules/*.json`, for example `show_core_blocks?`. No code branches on `dnd4e` today.
- `CoreRules::Entity.add_defaults` gives 4e creatures the `creature` template: defenses "Armor Class" (base 14, Dexterity), "Fortitude", "Reflex", "Will" (base 12), movement "Initiative" (base 0, Dexterity), trackables "Hit Points" and "Action Points", descriptors "Level", "Role", "Experience" and others, no saving throws. 4e NPCs get the `character` template: "Armor Class" base 10, paired "Fortitude (Str)"/"Fortitude (Con)", "Reflex (Dex)"/"Reflex (Int)", "Will (Wis)"/"Will (Cha)", no "Level"/"Role"/"Experience" descriptors.
- Child rows compute a total from an explicit `bonus` (override) or else `base + misc_modifier + the stored modifier of the linked ability score + Modifier rows` (`defense.rb:13-37`, `movement.rb:22-42`). The ability `modifier` is a stored column. Defense and movement forms show `bonus` as a locked "Calculated bonus" field.
- Child row names are unique per entity.
- Descriptors keep their value in `description`. The profile reads the "Level" and "Experience" descriptors (`entities_controller.rb:173`).
- The sheet's core blocks use `defenses.first` as AC, `trackables.first` as HP (shown only when `current` is present) and the movement named "Initiative".
- `defenses/_form_list.html.erb` shows a defense's total only `if defense.object.base.present?`.
- The 4e menu (`config/core_rules/4th-edition.json`) has no Saving Throws entry, so the builder page is the only place to edit the builder's saving throws.
- Twenty-odd `update_list` actions and the details form call `@parent_object.update(...)`, which runs every entity validation.
- `JsonArrayColumns` (`app/models/concerns/json_array_columns.rb`) gives `json_array_column`, already used for `tags`.
- Child controllers use `set_parent_type`, `set_parent_object`, `check_parent_authorization`.
- There are no `dnd4e` fixtures and no defense, trackable, movement or saving throw fixture files.

## Design decisions

Made by Etienne in the plan stage (2026-10-06):

- The criterion "level 3 Soldier Elite shows AC 19 (14 + 3 + 2 + 2)" is a typo. This plan uses AC 21.
- 4e NPCs: on opt-in the builder creates every missing target row by exact name. The paired character rows stay; the GM may delete them.
- The builder also writes the "Level", "Role" and "Experience" descriptors, with the same hand-edit rules.
- Hand edits are detected by comparison, not stored (decision 7). Etienne kept this after the critique showed two failure cases (see Risks).
- Existing monsters are correct by their creator's design; published monsters differ from the card on purpose. On first opt-in, a row that still holds its 4e template values, or a missing row, gets the card value. Any other value stays as designed and shows "needs manual revision".

Made by this plan:

1. Scope: resident creatures and NPCs. `Entitybuilder::Entity::MonsterBuildable` is included in `ResidentCreature` and `ResidentNpc`.
2. Gate: `"monster_builder": "true"` in the `entitybuilder` block of `config/core_rules/4th-edition.json`, read by `CoreRules::Entity.monster_builder?(core_rules)`. Other rule sets lack the key and return false. `Entity#monster_buildable?` combines it with the type.
3. Inputs on the entity (spec decision): `monster_level` (integer 1–40), `monster_role` (Artillery, Brute, Controller, Lurker, Skirmisher, Soldier; no Leader), `monster_group` (Minion, Standard, Elite, Solo), `monster_defense_bonuses` (JSON array; at most two of Fortitude, Reflex, Will; Elite and Solo only), `monster_extra_action` (nullable boolean). Level, role and group are all present or all blank. "Built" means `monster_level` is present.
   - The builder validations run only when a builder input changes (`will_save_change_to_monster_level?` and so on), so the many unrelated `@parent_object.update(...)` calls never fail on builder data.
   - A `before_validation` clears the defense picks when the group becomes Standard or Minion, instead of refusing the save. More than two picks is refused.
   - Role and group are stored as the English game terms and translated only on display.
4. `monster_extra_action` nil means the group default: on for Solo ("Additional standard action"), off for Elite ("Additional attack"). Other groups have no option. The sheet shows the text when on.
5. `Entitybuilder::MonsterStats = Data.define(:level, :role, :group, :defense_bonuses)` holds every card and XP table as constants (spec decision: one place) and small methods: `armor_class`, `fortitude`, `reflex`, `will`, `attack_bonus`, `average_damage`, `hit_points`, `saving_throw_bonus`, `action_points`, `initiative_base`, `experience`, `role_label`, `power_damage(usage:, multi_target:)`. Damage multipliers (Minion ½, Brute 5/4, Encounter 5/4, multi-target 3/4) multiply as Rationals and round down once. Phases C and D use `power_damage`, `attack_bonus`, `experience` and `ENCOUNTER_XP_BUDGET`.
6. Write targets: the builder writes into existing child rows, so sheet, card, profile and Activeplay keep working. `Entitybuilder::MonsterTarget` (a `Data` value object) names each target once:

   | key | row | field written | value |
   |---|---|---|---|
   | armor_class, fortitude, reflex, will | defense "Armor Class", "Fortitude", "Reflex", "Will" | `bonus` | card value |
   | initiative | movement "Initiative" | `base` | half level + role bonus; the stored Dexterity modifier still adds at display time |
   | hit_points | trackable "Hit Points" | `maximum`; `current` follows | card value |
   | action_points | trackable "Action Points" | `maximum` | 0, 1 or 2 |
   | saving_throws | saving throw "Saving Throws" | `bonus` | row exists only while the value is above 0 |
   | level, role, experience | descriptor "Level", "Role", "Experience" | `description` | "5", "Elite Soldier", "400" |

   - A missing row is created by exact name, appended to the sort order. A created "Armor Class" or "Hit Points" row gets the lowest sort order instead, because the sheet treats `defenses.first` as AC and `trackables.first` as HP.
   - A created defense row gets `base` 0 next to its `bonus`, so the defenses list shows its total.
   - Hit Points: `current` follows `maximum` only when `current` was blank or equal to the old `maximum`, so wounds tracked on the sheet survive a rebuild.
   - Descriptors hold the English game terms ("Elite Soldier"), whatever the GM's locale, so the comparison in decision 7 never depends on the locale.
   - Stored and calculated values compare as strings for descriptors and as integers elsewhere. A missing "Saving Throws" row counts as 0; any other missing row counts as blank.
7. Hand edits — deviation from the spec decision "stores the list of hand-edited values", agreed by Etienne: no list is stored. Each target compares its written field (table above). For Initiative a present `bonus` also counts as an edit.
   - A target needs manual revision when its written field differs from the value calculated for the current inputs.
   - On a rebuild, the builder first calculates the previous inputs' values, read with `attribute_in_database` before the new inputs are assigned (`monster_defense_bonuses` comes back as raw JSON text there and must be parsed). It overwrites a target only when its written field still equals that previous value.
   - On first opt-in there are no previous inputs. The previous value of a target is then "untouched template": the row is missing, or its fields still equal the 4e template row of the same name (from `CoreRules::Entity` defaults for the entity's type; for a defense: `base`, `bonus`, `misc_modifier`, `ability_score`; for a trackable: `maximum`; for a descriptor: `description`). An untouched row gets the card value. Any other row stays as its creator designed it and shows the mark.
8. Reset (spec 11) writes the calculated value into the target, which clears the mark.
9. On a built monster, Modifier rows in the "Defenses" category no longer change AC, Fortitude, Reflex or Will, because the card total sits in `bonus`. Intended: the card numbers are totals.
10. Web layer, CRUD, added to the `:monster` route concern from phase A:

    ```ruby
    resource :monster_build, only: [:edit, :update] do
      resources :overrides, only: :destroy, controller: "monster_overrides"
    end
    ```

    - `MonsterBuildsController#edit/update`: parent filters; 404 unless `monster_buildable?`. The page holds two forms that both PATCH the builder. The inputs form: level, role, group, defense picks, extra action. The values form: a table of every target with an editable stored value, the calculated value and the "needs manual revision" mark. The GM edits AC, HP, saving throws and the rest here, because the defense and initiative inputs elsewhere are locked. `update` applies the inputs first (rebuild), then writes each submitted value that differs from its stored value. Params, nested under the entity's param key: `monster_level, monster_role, monster_group, monster_extra_action, monster_defense_bonuses: [], monster_values: { <target key> => value }`.
    - Each Reset is a `button_to` placed outside both forms, because browsers drop nested forms.
    - `MonsterOverridesController#destroy`: `:id` is a target key; it resets that target and redirects to the builder page; an unknown key gets 404.
    - The manage menu gets "Monster builder" when `monster_buildable?`.
    - The sheet gets `entities/layouts/sheet/_monster.html.erb` for built monsters (role label, extra action text).
11. Versions: `create_version` gains `monster_level:`. For a built copy at another level it calls `rebuild_monster(monster_level:)`, so unedited values recalculate and edited ones stay marked. The version form shows a level field when the parent is built.
12. Reference documents: `docs/4e-business-card.md` (Appendix A) and `docs/4e-xp-tables.md` (Appendix B).
13. Strings are i18n keys in en, nl and it (see `plan.md` decision 11). Role and group names get keys; nl and it may keep the English game term.

## Integration points

- Entitybuilder: resident creature and NPC models, child rows (defenses, movements, trackables, saving throws, descriptors), sheet, manage menu, routes, version form.
- `lib/core_rules/entity.rb`, `config/core_rules/4th-edition.json`.
- Locales and the CI `i18n-tasks health` job.
- Primary database; migration in `db/migrate/`.

## Files that change

New:

- `db/migrate/<ts>_add_monster_builder_to_entitybuilder_entities.rb` — `monster_level` (integer), `monster_role`, `monster_group` (string, limit 16), `monster_defense_bonuses` (text, default `"[]"`), `monster_extra_action` (boolean, nullable).
- `engines/entitybuilder/app/models/entitybuilder/monster_stats.rb`, `monster_target.rb`.
- `engines/entitybuilder/app/models/entitybuilder/entity/monster_buildable.rb` — validations, `monster_buildable?`, `monster_built?`, `monster_stats`, `rebuild_monster(attributes)`, `monster_values` (per target: stored, calculated, `needs_manual_revision?`), `reset_monster_value(key)`, `extra_action?`, `extra_action_label`.
- `engines/entitybuilder/app/controllers/entitybuilder/monster_builds_controller.rb`, `monster_overrides_controller.rb`.
- `engines/entitybuilder/app/views/entitybuilder/monster_builds/edit.html.erb` (and partials), `entities/layouts/sheet/_monster.html.erb`.
- `docs/4e-business-card.md`, `docs/4e-xp-tables.md`.
- Fixtures: additions to `test/fixtures/entitybuilder/{entities,ability_scores,descriptors,defenses,trackables,movements,saving_throws}.yml` (phase A created the files).

Changed:

- `engines/entitybuilder/app/models/entitybuilder/entity.rb` — `json_array_column :monster_defense_bonuses`.
- `resident_creature.rb`, `resident_npc.rb` — include `Entity::MonsterBuildable`.
- `entity/versionable.rb`, `versions_controller.rb`, `versions/_form.html.erb` — `monster_level`.
- `engines/entitybuilder/config/routes.rb`, `menus/_manage.html.erb`, `entities/layouts/sheet/_default.html.erb`.
- `lib/core_rules/entity.rb`, `config/core_rules/4th-edition.json`, `config/locales/{en,nl,it}.yml`, `db/schema.rb`.

## Order of work

1. Write the acceptance test `test/integration/monster_builder_test.rb` `level 5 standard soldier shows its card numbers`. Run it, watch it fail.
2. Write `docs/4e-business-card.md` and `docs/4e-xp-tables.md` from the appendices.
3. Test and add `CoreRules::Entity.monster_builder?` and the JSON flag.
4. Unit tests `test/models/entitybuilder/monster_stats_test.rb`; write `MonsterStats`.
5. Migration; `bin/rails db:migrate`; commit `db/schema.rb` with it.
6. Unit tests `test/models/entitybuilder/monster_target_test.rb`; write `MonsterTarget`.
7. Unit tests `test/models/entitybuilder/entity/monster_buildable_test.rb`; write `Entity::MonsterBuildable`.
8. Controller tests `test/controllers/entitybuilder/monster_builds_controller_test.rb`; routes, controllers, builder page, sheet partial, menu link, locale keys.
9. Make the builder acceptance tests pass.
10. Add `monster_level` to `create_version`, `VersionsController` and the version form. Make the two version acceptance tests pass.
11. Run `bin/rails test`, `bundle exec rubocop`, `bin/i18n-tasks health`, `bin/pre_push_checks`. All green.
12. Run `bin/dev`: build an "Orc Warrior" at level 5 Soldier Standard, edit AC to 23, change the level, reset AC, create version "Level 10". Open a Pathfinder 2e creature; no builder link shows.
13. Re-read the full diff. Push and open the PR against `56-monsters-can-have-multiple-versions`.

## Risks

- Comparison failure cases, accepted by Etienne:
  - A later correction to a `MonsterStats` table makes every stored value differ from the "previous calculation". Every built monster then freezes, with all values marked, until the GM resets them.
  - The GM edits AC to 23 at level 5 and moves to level 7, where the calculation is also 23, so the mark clears. Moving back to level 5 overwrites it with 21; the edit is lost without warning.
- A monster designed before opt-in keeps its numbers and shows many marks at once. Intended: the marks say "differs from the card", not "wrong".
- Modifier rows stop affecting builder defenses (decision 9).
- An edit through a field the builder does not watch (for example a defense's `misc_modifier` under a builder `bonus`) has no effect on the sheet, because `bonus` wins.
- A 4e NPC shows both the paired character rows and the builder rows until the GM deletes the paired ones.
- Rejected: storing a hand-edited list (decision 7); changing the 4e NPC template in `add_defaults`; refusing a group change while defense picks exist (it would break unrelated saves).

## Out of scope

- Powers (phase C) and difficulty (phase D).
- Leaving the builder after opting in.
- A Leader role.
- A warning when damage falls outside 25%–50% (issue #150).
- Stock creatures and NPCs, characters.

## Proof

Acceptance criteria from `spec.md` covered by phase B:

- Level 5 Soldier Standard, Dex 10: AC 21, Fortitude/Reflex/Will 17, HP 64, initiative 4, attack +10 → `test/integration/monster_builder_test.rb` `level 5 standard soldier shows its card numbers`
- Level 4 Lurker, Dex 14: initiative 7 → `test/integration/monster_builder_test.rb` `level 4 lurker with dexterity 14 shows initiative 7`
- Level 4 Brute, Dex 10: initiative 2 → `test/integration/monster_builder_test.rb` `level 4 brute shows initiative 2`
- Level 3 Soldier Elite: AC 21 (corrected) → `test/integration/monster_builder_test.rb` `level 3 elite soldier shows armor class 21`
- Elite picks Reflex and Will: 17, 17, Fortitude 15 → `test/integration/monster_builder_test.rb` `elite with reflex and will picked raises only those two`
- Level 3 Elite: saving throws +2, 1 action point → `test/integration/monster_builder_test.rb` `level 3 elite shows saving throws 2 and one action point`
- Level 3 Solo: saving throws +5, 2 action points → `test/integration/monster_builder_test.rb` `level 3 solo shows saving throws 5 and two action points`
- Level 3 Standard: no saving throws, no action points → `test/integration/monster_builder_test.rb` `level 3 standard shows no saving throws and no action points`
- Solo shows "additional standard action" on; Elite shows "additional attack" off → `test/integration/monster_builder_test.rb` `solo extra action defaults on and elite extra action defaults off`
- A third defense for an Elite or Solo is refused → `test/integration/monster_builder_test.rb` `elite cannot pick a third defense`
- Level 3 Brute Solo: AC 17 → `test/integration/monster_builder_test.rb` `level 3 solo brute shows armor class 17`
- Level 3 Brute Standard: AC 15, HP 56 → `test/integration/monster_builder_test.rb` `level 3 standard brute shows armor class 15 and 56 hit points`
- Level 3 Lurker Elite: HP 78 → `test/integration/monster_builder_test.rb` `level 3 elite lurker shows 78 hit points`
- Level 2 Controller Solo: HP 160 → `test/integration/monster_builder_test.rb` `level 2 solo controller shows 160 hit points`
- Minion: 1 HP → `test/integration/monster_builder_test.rb` `minion shows 1 hit point`
- Edited AC 23 stays after a level change, marked → `test/integration/monster_builder_test.rb` `edited armor class survives a level change and needs manual revision`
- Reset shows the calculated number, mark gone → `test/integration/monster_builder_test.rb` `reset restores the calculated armor class and clears the mark`
- Existing 4e creature without builder data keeps its numbers → `test/integration/monster_builder_test.rb` `existing 4e creature keeps its numbers until it opts in` (and, per Etienne, its designed numbers after opt-in: `existing 4e creature keeps its designed numbers after opting in`)
- Version "Level 10" of a level 5 Orc Warrior shows level 10 numbers → `test/integration/monster_versions_test.rb` `version at level 10 shows level 10 numbers`
- A version at another level keeps an edited AC, marked → `test/integration/monster_versions_test.rb` `version keeps an edited armor class and marks it`

Per changed file, the unit tests expected:

- `monster_stats.rb` (`test/models/entitybuilder/monster_stats_test.rb`): `armor class adjusts for soldier, brute and artillery`, `elite and solo add 2 to armor class`, `picked defenses gain 2 only for elite and solo`, `hit points per role`, `elite doubles and solo quadruples hit points`, `minion has 1 hit point`, `saving throw bonus and action points per group`, `initiative base is half level plus role bonus`, `experience per group uses the table`, `minion experience uses the rounded table values`, `power damage multiplies adjustments and rounds down once`, `role label combines group and role`.
- `monster_target.rb` (`test/models/entitybuilder/monster_target_test.rb`): `creates a missing row by exact name`, `creates a missing armor class row first in the sort order`, `gives a created defense row base 0`, `moves current hit points along only when unwounded`, `removes the saving throws row at 0`, `counts a missing saving throws row as 0`, `treats a present initiative bonus as an edit`, `recognises a row that still holds its template values`.
- `entity/monster_buildable.rb` (`test/models/entitybuilder/entity/monster_buildable_test.rb`): `refuses the builder outside 4e`, `refuses level outside 1 to 40`, `refuses an unknown role or group`, `refuses level, role or group alone`, `refuses more than two defense picks`, `clears defense picks when the group becomes standard`, `unrelated entity updates skip builder validations`, `first opt-in fills untouched template rows`, `first opt-in keeps designed values and marks them`, `rebuild keeps values that differ from the previous calculation`, `rebuild reads the previous inputs from the database`, `needs manual revision when stored differs from calculated`, `reset writes the calculated value`, `npc opt-in adds missing rows and keeps paired character rows`, `stores the role descriptor in English under any locale`, `extra action defaults per group`.
- `entity/versionable.rb` (`test/models/entitybuilder/entity/versionable_test.rb`): `rebuilds a built copy at the given level`, `ignores a level for an unbuilt copy`.
- `lib/core_rules/entity.rb` (`test/lib/core_rules/entity_monster_builder_test.rb`): `4th edition enables the monster builder`, `pathfinder 2e does not`.
- Controllers (`test/controllers/entitybuilder/monster_builds_controller_test.rb`): `non-owner gets 403`, `non-4e creature gets 404`, `invalid inputs render the form with errors`, `a submitted value is stored and marked`, `reset of an unknown key gets 404`.

Test setup: fixtures only. Add for razune: an unbuilt 4e creature with untouched template rows (Dex 10, modifier 0), a 4e creature with Dex 14 (modifier 2), an unbuilt 4e NPC with the character template rows, a built level 5 Soldier Standard "Orc Warrior" with AC stored at 23, and an existing 4e creature with designed numbers (for example AC base 19) and no builder data. Each carries the rows its 4e template gives (defenses, trackables, movements, descriptors, ability scores) in the fixture files phase A created. New entity fixtures leave the legacy rich text columns out. Reuse the phase A pf2e creature.

## Appendix A — business card transcription (for `docs/4e-business-card.md`)

Source: Monster Manual 3 "on a business card", Blog of Holding, 29 July 2010, https://www.blogofholding.com/?p=512. The card is published as an image only; this transcription comes from `spec.md` requirements 8 and 9, confirmed by Etienne. L is the monster level.

- AC: 14 + L. Soldier +2. Brute and Artillery −2. Elite and Solo +2 (DMG: raise up to three defenses by 2, AC always one of them).
- Fortitude, Reflex, Will: 12 + L. Elite and Solo: +2 on up to two of them, chosen by the GM, none by default.
- Attack bonus: 5 + L.
- Average damage: 8 + L.
- Hit points: Skirmisher, Controller, Soldier 24 + 8L. Brute 26 + 10L. Artillery, Lurker 21 + 6L (confirmed by Etienne; one transcription said 26 + 10L).
- Elite: 2 × role HP, saving throws +2, 1 action point. Solo: 4 × role HP, saving throws +5, 2 action points (the DMG heading says "add 1", its text says 2). Minion: 1 HP. Standard and Minion: no saving throw bonus, no action points.
- Initiative (not on the card): Dexterity modifier + half level (rounded down), Skirmisher and Soldier +2, Lurker +3.
- Damage adjustments: Minion ½, Brute +25%, Encounter power +25% (the card says +25–50%; Etienne chose +25%), multi-target −25%. They multiply and round down.

## Appendix B — XP tables (for `docs/4e-xp-tables.md`)

From the DMG (2008) "Experience Point Rewards" table, drafted by the planner and verified by Etienne (2026-10-08). Elite is 2 × Standard, Solo is 5 × Standard. Minion is ¼ × Standard, rounded half up as printed (level 2 is 31, level 3 is 38).

| Level | Standard | Minion | Elite | Solo |
|---|---|---|---|---|
| 1 | 100 | 25 | 200 | 500 |
| 2 | 125 | 31 | 250 | 625 |
| 3 | 150 | 38 | 300 | 750 |
| 4 | 175 | 44 | 350 | 875 |
| 5 | 200 | 50 | 400 | 1,000 |
| 6 | 250 | 63 | 500 | 1,250 |
| 7 | 300 | 75 | 600 | 1,500 |
| 8 | 350 | 88 | 700 | 1,750 |
| 9 | 400 | 100 | 800 | 2,000 |
| 10 | 500 | 125 | 1,000 | 2,500 |
| 11 | 600 | 150 | 1,200 | 3,000 |
| 12 | 700 | 175 | 1,400 | 3,500 |
| 13 | 800 | 200 | 1,600 | 4,000 |
| 14 | 1,000 | 250 | 2,000 | 5,000 |
| 15 | 1,200 | 300 | 2,400 | 6,000 |
| 16 | 1,400 | 350 | 2,800 | 7,000 |
| 17 | 1,600 | 400 | 3,200 | 8,000 |
| 18 | 2,000 | 500 | 4,000 | 10,000 |
| 19 | 2,400 | 600 | 4,800 | 12,000 |
| 20 | 2,800 | 700 | 5,600 | 14,000 |
| 21 | 3,200 | 800 | 6,400 | 16,000 |
| 22 | 4,150 | 1,038 | 8,300 | 20,750 |
| 23 | 5,100 | 1,275 | 10,200 | 25,500 |
| 24 | 6,050 | 1,513 | 12,100 | 30,250 |
| 25 | 7,000 | 1,750 | 14,000 | 35,000 |
| 26 | 9,000 | 2,250 | 18,000 | 45,000 |
| 27 | 11,000 | 2,750 | 22,000 | 55,000 |
| 28 | 13,000 | 3,250 | 26,000 | 65,000 |
| 29 | 15,000 | 3,750 | 30,000 | 75,000 |
| 30 | 19,000 | 4,750 | 38,000 | 95,000 |
| 31 | 23,000 | 5,750 | 46,000 | 115,000 |
| 32 | 27,000 | 6,750 | 54,000 | 135,000 |
| 33 | 31,000 | 7,750 | 62,000 | 155,000 |
| 34 | 39,000 | 9,750 | 78,000 | 195,000 |
| 35 | 47,000 | 11,750 | 94,000 | 235,000 |
| 36 | 55,000 | 13,750 | 110,000 | 275,000 |
| 37 | 63,000 | 15,750 | 126,000 | 315,000 |
| 38 | 79,000 | 19,750 | 158,000 | 395,000 |
| 39 | 95,000 | 23,750 | 190,000 | 475,000 |
| 40 | 111,000 | 27,750 | 222,000 | 555,000 |

Encounter XP Budget, per character: the Standard column for levels 1–40. DMG: an encounter of level N for P characters is worth P × the XP of one standard level N monster; level 1 for five characters is 500. Phase D uses it.

---
Domain skills applied: rails-ui (i18n keys), rails-testing (fixtures, integration tests first, nested context classes). Playbook §1: behaviour in model concerns and value objects, CRUD nested resources, no service objects.
