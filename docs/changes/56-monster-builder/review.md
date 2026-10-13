# Review for 56-monster-builder

## Round 1 — 2026-10-13T13:00Z — 292dfbd

Scope: phase B only, `git diff origin/56-monsters-can-have-multiple-versions...HEAD` (11 commits). Phase A is reviewed in PR #157. No `REVIEW.md` or `REVIEW.local.md` exists at the repository root, so the reviewer defaults apply: Bugs, Security, Compliance.

Checks run: the phase B test files (131 runs, 0 failures), `bin/i18n-tasks health` (clean), `bundle exec rubocop` on the changed Ruby files (only `db/schema.rb`, the generated file, reports offenses).

### Bugs

- [x] Important: The builder form always submits the extra action as `0` or `1`, so the nil group default never survives a browser save. `f.check_box` adds a hidden `0`, and the box starts unchecked on an unbuilt monster because `extra_action?` is false for a blank group. A GM who builds a Solo through the page stores `false`, and the sheet does not show "Additional standard action". The same happens when an Elite becomes a Solo later. The acceptance test `solo extra action defaults on and elite extra action defaults off` passes only because its `build` helper drops the key with `.compact` (`test/integration/monster_builder_test.rb:14-17`), so it never exercises the real form. — `engines/entitybuilder/app/views/entitybuilder/monster_builds/_inputs.html.erb:37` → fixed (Keep the group default for a monster's extra action)
- [x] Important: `create_version` ignores the result of the rebuild. A version level the builder refuses (for example 0 or 41, or a non-number that casts to nil) leaves the version saved at the parent's level. The controller then redirects with the "created" notice, and the GM sees no error. The rebuild also runs outside the copy transaction, so a `save!` that raises during `write_monster_targets` leaves a half-finished version behind and returns a 500. — `engines/entitybuilder/app/models/entitybuilder/entity/version_copy.rb:18` → fixed (Refuse a version at a level the builder refuses)
- [x] Important: Submitting a level above 40 on the builder page returns a 500 instead of the form with errors. The validation refuses it and `update` renders `:edit`. `monster_built?` is then true for the unsaved level, so `_values` calls `monster_values`. `MonsterStats#experience` reads `STANDARD_XP[40]`, which is nil, and raises `NoMethodError: undefined method '*' for nil`, checked with `rails runner`. Level 0 does not crash, but the table shows the level 40 experience (111000) because `STANDARD_XP[-1]` wraps around. The controller test only covers level 0. — `engines/entitybuilder/app/models/entitybuilder/monster_stats.rb:62` → fixed (Count a monster as built only at a card level in a 4e rule set)
- [x] Nit: A DELETE on `monster_build/overrides/<key>` for a 4e monster that is not built yet raises `NoMethodError`, because `monster_stats` is nil and `target.calculated(nil)` calls a method on it. The page shows no Reset button there, so only a hand-crafted request reaches it. A 404, like the unknown key, fits better. — `engines/entitybuilder/app/models/entitybuilder/entity/monster_buildable.rb:41` → fixed (Count a monster as built only at a card level in a 4e rule set)
- [x] Nit: `store_monster_values` accepts any text. "abc" for Armor Class casts to 0 through `to_i`, and "abc" for Saving Throws removes the row. A blank value is ignored, so a GM cannot clear a descriptor value from the table. — `engines/entitybuilder/app/models/entitybuilder/entity/monster_buildable.rb:49` → fixed (Refuse monster values that are not whole numbers)
- [x] Nit: After a refused version (blank label), the form shows the parent's level again, not the level the GM typed, because the field value is fixed to `@parent_object.monster_level`. — `engines/entitybuilder/app/views/entitybuilder/versions/_form.html.erb:10` → fixed (Refuse a version at a level the builder refuses)
- [x] Nit: The sheet's monster summary checks only `monster_built?`. A GM can change `core_rules` on the details form (`entities_controller.rb:248` permits it). A built 4e monster moved to another rule set then still shows "Level 5 Soldier" on its sheet, while the builder link and page are gone. — `engines/entitybuilder/app/views/entitybuilder/entities/layouts/sheet/_monster.html.erb:1` → fixed (Count a monster as built only at a card level in a 4e rule set)

### Security

Nothing found. Both new controllers run `check_parent_authorization` (`can_edit?`) before `check_monster_buildable`. Strong parameters permit only the builder inputs and the known target keys. `MonsterTarget.fetch` sees only a key that `check_target` already matched against the known list. Reset uses `button_to`, so the DELETE carries the CSRF token.

### Compliance

Phase B acceptance criteria from `plan.md` `## Proof`, each with its test:

- Level 5 Soldier Standard card numbers → `monster_builder_test.rb` `level 5 standard soldier shows its card numbers`
- Level 4 Lurker initiative 7 → `level 4 lurker with dexterity 14 shows initiative 7`
- Level 4 Brute initiative 2 → `level 4 brute shows initiative 2`
- Level 3 Soldier Elite AC 21 → `level 3 elite soldier shows armor class 21`
- Elite picks Reflex and Will → `elite with reflex and will picked raises only those two`
- Level 3 Elite saves and action point → `level 3 elite shows saving throws 2 and one action point`
- Level 3 Solo saves and action points → `level 3 solo shows saving throws 5 and two action points`
- Level 3 Standard no saves, no action points → `level 3 standard shows no saving throws and no action points`
- Solo extra action on, Elite off → `solo extra action defaults on and elite extra action defaults off` (exists, but it bypasses the form; see the first Important finding)
- Third defense refused → `elite cannot pick a third defense`
- Level 3 Brute Solo AC 17 → `level 3 solo brute shows armor class 17`
- Level 3 Brute Standard AC 15, HP 56 → `level 3 standard brute shows armor class 15 and 56 hit points`
- Level 3 Lurker Elite HP 78 → `level 3 elite lurker shows 78 hit points`
- Level 2 Controller Solo HP 160 → `level 2 solo controller shows 160 hit points`
- Minion 1 HP → `minion shows 1 hit point`
- Edited AC survives a level change, marked → `edited armor class survives a level change and needs manual revision`
- Reset clears the mark → `reset restores the calculated armor class and clears the mark`
- Existing 4e creature keeps its numbers → `existing 4e creature keeps its numbers until it opts in`, `existing 4e creature keeps its designed numbers after opting in`
- Version at level 10 → `monster_versions_test.rb` `version at level 10 shows level 10 numbers`
- Version keeps an edited AC, marked → `version keeps an edited armor class and marks it`

Intent criteria for difficulty and power prefill belong to phases D and C and are out of scope here.

Every unit, controller and library test named in `plan.md` exists: `monster_stats_test.rb` (13), `monster_target_test.rb` (8), `entity/monster_buildable_test.rb` (17), `entity/versionable_test.rb` (2 new), `versions_controller_test.rb` (1 new), `entity_monster_builder_test.rb` (2), `monster_builds_controller_test.rb` (5). No existing test was weakened, skipped or deleted.

Counts: Important 3, Nit 4.
