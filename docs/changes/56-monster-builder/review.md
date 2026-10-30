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

## Round 2 — 2026-10-13T17:01Z — a5b3219

Scope: phase B only, `git diff origin/56-monsters-can-have-multiple-versions...HEAD`. This round checks the round 1 fixes (7cffd31, f015ee0, 7736cba, b1420bd) and looks for problems they introduce. No `REVIEW.md` or `REVIEW.local.md` exists, so the reviewer defaults apply: Bugs, Security, Compliance.

Checks run: the nine phase B test files with `PARALLEL_WORKERS=1` (113 runs, 425 assertions, 0 failures), `bundle exec rubocop` on the 27 changed Ruby files without `db/schema.rb` (no offenses), `bin/i18n-tasks health` (clean). A throwaway integration test in the scratchpad confirmed the first finding below. It is not committed.

Round 1 fixes:

- Extra action (7736cba): holds. A select with a blank "Group default" option stores nil, so a Solo keeps its additional standard action, also when an Elite becomes a Solo. The test now checks that the form selects the blank option and submits `""` as the form does.
- Version level (b1420bd): holds. `valid_version?` checks the typed level before anything is saved. The rebuild runs inside the copy transaction, and a refused rebuild raises, so the transaction rolls back. The form keeps the typed level after a refused level or a blank label.
- Level outside 1 to 40 (7cffd31): holds. `monster_built?` requires a 4e rule set and a card level, so the values table and the sheet summary no longer render for level 0 or 41. `MonsterStats` refuses such a level. Reset on an unbuilt monster gets 404.
- Rule set change (7cffd31): holds. The sheet summary hides when `core_rules` is not 4e.
- Values that are not whole numbers (f015ee0): holds for "abc", but see the first finding below.
- `assert_select "body", text: ..., count: 0` never fails, because rails-dom-testing skips it (`selecting_no_body?`). No such assertion remains in phase B. 7736cba replaced the one in the extra action test with `"p"`. Every other `count: 0` assertion selects an element (`p`, `tr`, `tr.roll`, `input`) that the positive case renders.

### Bugs

- [x] Nit: `store_monster_values` checks only the whole-number format, not the range the child row validates. "1000000" for Armor Class, "1000" for Initiative or Saving Throws, or a descriptor longer than 255 characters passes `accepts?`. Then `MonsterTarget#write` calls `row.save!`, which raises `ActiveRecord::RecordInvalid`. The controller does not rescue it, so the GM gets the generic error page instead of the form with a message. The transaction rolls back, so nothing is saved. Checked with an integration test: the PATCH with `armor_class: "1000000"` raised `RecordInvalid` and AC stayed 23. A fix could validate the row before the write, or rescue `RecordInvalid` and add its messages to `errors`. — `engines/entitybuilder/app/models/entitybuilder/monster_target.rb:37` → fixed (Show the form with an error for a value outside the row's range)
- [x] Nit: A refused value now discards every value the GM typed in the same submit. The values table re-renders `value.stored` from the database, so the refused "abc" and the valid values next to it all revert to their stored numbers. The GM sees the error but must type all values again. Before f015ee0, the valid values were saved. Showing the submitted values on re-render keeps the all-or-nothing save and fixes this. — `engines/entitybuilder/app/views/entitybuilder/monster_builds/_values.html.erb:20` → fixed (Show the submitted values again after a refused value)

### Security

Nothing new. The fixes add no params and no routes. `monster_extra_action` still goes through the strong parameters, and the boolean cast turns `""` into nil. `check_monster_built` runs after `check_parent_authorization`.

### Compliance

Each fix has a test: `level above 40 renders the form with errors`, `reset on an unbuilt monster gets 404`, `a value that is not a whole number renders the form with an error`, `a refused level renders the form with the typed level`, `blank label keeps the typed level`, `a built monster moved to another rule set hides its builder summary`, `refuses a level outside 1 to 40`, `a level outside 1 to 40 is not built`, `a monster moved to another rule set is not built`, `refuses a value that is not a whole number`, `a blank value clears a text value`, `refuses a version at a level the builder refuses`. The extra action acceptance test now follows the form. The plan's decision 4 (nil means the group default) holds through the page. The new strings have en, nl and it keys. No test was weakened, skipped or deleted.

Counts: Important 0, Nit 2.

## Round 3 — 2026-10-14T19:24Z — 8462d4f

Scope: phase B only, `git diff origin/56-monsters-can-have-multiple-versions...HEAD`. Phase A is reviewed in PR #157. This round checks the round 2 fixes (b98acf3, bd5d8d1) and looks for new problems. No `REVIEW.md` or `REVIEW.local.md` exists, so the reviewer defaults apply: Bugs, Security, Compliance.

Checks run: the nine phase B test files with `PARALLEL_WORKERS=1` (115 runs, 433 assertions, 0 failures), `bundle exec rubocop` on the 27 changed Ruby files without `db/schema.rb` (no offenses), `bin/i18n-tasks health` (clean). A throwaway controller test in the scratchpad confirmed the first finding below. It is not committed.

Round 2 fixes:

- Value outside the row's range (b98acf3): holds. `write_monster_values` rescues `ActiveRecord::RecordInvalid` and returns false, so the GM gets the form with a message and a 422 instead of the error page. The controller calls `store_monster_values` outside any other transaction, so the rollback discards the values written before the refused one. The test checks that a valid Fortitude next to the refused Armor Class is not saved. See the first finding for the message text.
- Submitted values on re-render (bd5d8d1): holds. The values table shows `@submitted_values` after a refused submit, for both a refused format ("abc") and a refused range. `value_params.to_h` is a `HashWithIndifferentAccess`, so the symbol keys from `monster_values` find the string param keys. A refused inputs form submits no values, so the table falls back to the stored values.
- `assert_select "body", text: ..., count: 0`: none in phase B. Every `count: 0` assertion selects an element that the positive case renders: `input[name=?]`, `tr.roll`, `p` (the sheet summary is a `<p>`) and `tr`.

### Bugs

- [x] Nit: The out-of-range message names neither the row nor the other refused values. The rescue reports the first row that `save!` refuses and stops. Checked with a PATCH of Armor Class "1000000", Initiative "5000" and a 300-character Role: the page shows only "Bonus must be less than 1000000". The values table has no "Bonus" column, and Armor Class, Fortitude, Reflex and Will all give the same text, so the GM cannot tell which value to fix. A fix could prefix the target's `row_name`, as `monster_value_error` does for the whole-number check, or validate every changed row before the write and report each one. — `engines/entitybuilder/app/models/entitybuilder/entity/monster_buildable.rb:97` → fixed (Name every refused row in the out-of-range error)
- [x] Nit: A version POST with `version[monster_level]` and no `version[version_label]` returns a 500. `create_version(**version_params.to_h.symbolize_keys)` then has no `version_label:` keyword, and the method requires it, so Ruby raises `ArgumentError`. Before phase B the controller passed `version_params[:version_label]`, which gives nil and the form with an error. The form always sends the label, so only a hand-crafted request gets here. — `engines/entitybuilder/app/controllers/entitybuilder/versions_controller.rb:16` → fixed (Show the form with an error when a version has no label)

### Security

Nothing new. The fixes add no params, routes or queries. `@submitted_values` comes from the permitted `monster_values` keys only, and `text_field_tag` escapes the value. The error message comes from model validation text, not from user input.

### Compliance

Each round 2 fix has a test: `a whole number out of the row's range renders the form with an error and saves nothing` and `a refused submit shows the submitted values again`. Neither test checks the message text, which is how the first finding above went unnoticed. The phase B acceptance criteria and named unit tests from round 1 still pass. No test was weakened, skipped or deleted.

Counts: Important 0, Nit 2.

## Round 4 — 2026-10-30T11:09Z — 79a9465

Scope: phase B only, `git diff origin/56-monsters-can-have-multiple-versions...HEAD`. Phase A is reviewed in PR #157. This round checks the round 3 fixes (79296b7, fca4fdb) and looks for new problems. No `REVIEW.md` or `REVIEW.local.md` exists, so the reviewer defaults apply: Bugs, Security, Compliance.

Checks run: the nine phase B test files with `PARALLEL_WORKERS=1` (117 runs, 440 assertions, 0 failures), `bundle exec rubocop` on the 27 changed Ruby files without `db/schema.rb` (no offenses), `bin/i18n-tasks health` (clean), `bundle exec brakeman -q` (9 warnings, none in a phase B file). A throwaway controller test confirmed the first fix for a row that does not exist yet. It was removed after the run and is not committed.

Round 3 fixes:

- Out-of-range error names every row (79296b7): holds. `write_monster_value` rescues each refused `save!`, adds `"<row name>: <message>"`, and the loop continues, so each refused row gets its own message. `raise ActiveRecord::Rollback` then discards the rows written in the same submit. The throwaway test sent Saving Throws "5000" on a Standard monster with no saving throws row, Will "3" and a 300-character Role. The page showed "Saving Throws: Bonus must be less than 1000" and "Role: Description is too long (maximum is 255 characters)", returned 422, and saved no saving throws row, no Will and no Role. The new `refused_value` key exists in en, nl and it.
- Missing label param (fca4fdb): holds. The controller passes `version_params[:version_label]` and `version_params[:monster_level]`, so an absent key gives nil and the label validation refuses the version with the form and a 422. An absent level on a built monster skips the rebuild, as before.

### Bugs

Nothing found.

### Security

Nothing new. The fixes add no params, routes or queries. The refusal message joins the row name from the fixed `MonsterTarget::ROWS` list with model validation text, and the view escapes it. Brakeman reports no warning in a phase B file.

### Compliance

Each round 3 fix has a test: `an out-of-range error names every refused row` checks the message text for two rows, and `a missing label param renders the form with an error` checks the 422 and that no entity is created. The phase B acceptance criteria and named unit tests from round 1 still pass. No test was weakened, skipped or deleted.

Counts: Important 0, Nit 0.
