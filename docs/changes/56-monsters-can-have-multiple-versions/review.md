# Review: 56-monsters-can-have-multiple-versions

## Round 1 — 2026-10-08 15:26 UTC — 738f5cd

Scope: phase A (`plan.md`) only; `plan-b/c/d` are later phases. Suite state at review: `bin/rails test` green (1177 runs, 0 failures, run with `PARALLEL_WORKERS=1`; a parallel run hit `SQLite3::BusyException` in `pf2e_stock_creature_test.rb`, which went away when the tests ran one at a time), `bundle exec rubocop` clean, `bin/i18n-tasks health` clean.

Compliance — acceptance criteria (spec, phase A):

- Parent lists all its versions; each version links back → `test/integration/monster_versions_test.rb` `parent lists its versions and each version links back`
- Pathfinder 2e creature gets a version without level, role or group → `test/integration/monster_versions_test.rb` `pathfinder 2e creature gets a version without builder fields`
- Version of a Private monster is owned by the same resident and starts Private → `test/integration/monster_versions_test.rb` `version of a private monster stays private and owned by the same resident`

Compliance — `## Proof` tests: all 17 `versionable_test.rb` tests, all 3 `versions_controller_test.rb` tests and both view tests in `monster_versions_test.rb` exist. The three `entity_test.rb` tests are missing (see below). No existing test was weakened, skipped or deleted. All fixture changes only add rows.

- [x] Important: The `## Proof` tests `set_privacy gives a new entity Residents and Private`, `set_privacy keeps given privacy values` and `short scope includes the version label` do not exist. `test/models/entitybuilder/entity_test.rb` is unchanged. The `set_privacy` change and the `short` scope change have no direct test — `engines/entitybuilder/app/models/entitybuilder/entity.rb:185` and `engines/entitybuilder/app/models/entitybuilder/entity.rb:15` →
- [x] Nit: The reflection guard checks `Entity.reflect_on_all_associations` only. A `has_many`/`has_one` declared on `ResidentCreature` or `ResidentNpc` (both already declare `has_one :user`) escapes the copied/skipped check — `test/models/entitybuilder/entity/versionable_test.rb:26` →
- [x] Nit: `copy_rich_text` calls `source.public_send(name)`. For `has_rich_text`, that builds an empty unsaved `ActionText::RichText` on the parent entity and on each unshared source rule as a side effect. Reading `rich_text_<name>` avoids the build — `engines/entitybuilder/app/models/entitybuilder/entity/versionable.rb:102` →
- [x] Nit: No test covers the plan risk "the summary would leak a Private parent's name" on a version's summary. Only the private-version case is tested. The `can_show?` guard exists but is unproven — `engines/entitybuilder/app/views/entitybuilder/entities/layouts/_versions.html.erb:2` →
- [x] Nit: The `concerns:` continuation lines start at column 0, apart from the `resources` call they belong to. They do not line up with the neighbouring `resident_characters` line either — `engines/entitybuilder/config/routes.rb:115` →
- [x] Nit: `_versions.html.erb` calls `can_show?` on each version, which can load its resident one by one (N+1) for Friends/Private versions. Unlike `_badge` and `_campaign`, it also passes the full `type` and not `type.demodulize`. This works today, but it is inconsistent — `engines/entitybuilder/app/views/entitybuilder/entities/layouts/_versions.html.erb:5` →

1 more nit was not listed.

## Round 2 — 2026-10-09 09:00 UTC — 2fe5dc7

Scope: phase A (`plan.md`) only, commits 2f1abc8..2fe5dc7 on top of round 1. Suite state at review: `PARALLEL_WORKERS=1 bin/rails test` green (1183 runs, 0 failures, 0 errors, 0 skips), `bundle exec rubocop` clean, `bin/i18n-tasks health` clean.

Round 1 follow-up: all six listed findings are resolved and ticked above. The N+1 part of the last nit is accepted as not a defect. `can_edit?` loads `version.resident` per version, but every version has the parent's `resident_id`, so each lookup is the same SQL with the same bind and the request query cache answers it. `Affiliation.are_affiliates` gets the same arguments each time, so it hits the cache too. Round 1's unlisted nit is not recorded anywhere; this round lists every nit it found.

Compliance — acceptance criteria (spec, phase A):

- Parent lists all its versions; each version links back → `test/integration/monster_versions_test.rb` `parent lists its versions and each version links back`
- Pathfinder 2e creature gets a version without level, role or group → `test/integration/monster_versions_test.rb` `pathfinder 2e creature gets a version without builder fields`
- Version of a Private monster is owned by the same resident and starts Private → `test/integration/monster_versions_test.rb` `version of a private monster stays private and owned by the same resident`

Compliance — `## Proof` tests: 27 of 28 named tests exist by name, including the three `entity_test.rb` tests added in 2f1abc8. `every entity association is listed as copied or skipped` was renamed (see the first nit below). No existing test was weakened, skipped or deleted. The renamed test checks a superset of the old reflections.

- [x] Nit: The `## Proof` test `every entity association is listed as copied or skipped` no longer exists by that name. 74bf11d renamed it to `every versionable association is listed as copied or skipped`. The coverage is stronger, but `plan.md` and the test no longer match — `test/models/entitybuilder/entity/versionable_test.rb:24` →
- [x] Nit: `has_many :versions` orders by `version_label` as text, so "Level 10" and "Level 15" sort before "Level 5". The new test asserts that order (`versionable_test.rb:83`). For the issue's "every 5 levels" case, the summary lists versions out of level order. Creation order (`created_at`) avoids this — `engines/entitybuilder/app/models/entitybuilder/entity/versionable.rb:25` →
- [x] Nit: a5df9f8 moved the version visibility filter to the model, but the parent check stays inline in the view. One half of `_versions` asks the model and the other half decides by itself — `engines/entitybuilder/app/views/entitybuilder/entities/layouts/_versions.html.erb:2` →

## Round 3 — 2026-10-09 22:16 UTC — aed5dc6

Scope: phase A (`plan.md`) only, commits 8a0123f..aed5dc6 on top of round 2. Suite state at review: `PARALLEL_WORKERS=1 bin/rails test` green (1185 runs, 0 failures, 0 errors, 0 skips), `bundle exec rubocop` clean, `bin/i18n-tasks health` clean.

Round 2 follow-up: all three findings are resolved and ticked above. 8a0123f restores the plan's test name. aed5dc6 sorts `versions_visible_to` in natural, case-insensitive label order, and a test covers it. 6c93b11 adds `Versionable#parent_visible_to`, the view uses it, and a test covers the owner, the non-owner and the root.

Length of `versionable.rb`: the file has 124 lines, but the module body has 98 lines of code. The rest is blank lines and comments. Every method has 7 lines or fewer, and rubocop reports no length offence. Two parts share the module: the family (association, validation, visibility, about 25 lines) and the deep copy (constants and copy helpers, about 75 lines). A split is not warranted now, because the copy is one cohesive job. Phase B adds `monster_level:` to `create_version`. At that point, move the copy into its own concern under `Entity`, not a service object.

Compliance — acceptance criteria (spec, phase A):

- Parent lists all its versions; each version links back → `test/integration/monster_versions_test.rb` `parent lists its versions and each version links back`
- Pathfinder 2e creature gets a version without level, role or group → `test/integration/monster_versions_test.rb` `pathfinder 2e creature gets a version without builder fields`
- Version of a Private monster is owned by the same resident and starts Private → `test/integration/monster_versions_test.rb` `version of a private monster stays private and owned by the same resident`

Compliance — `## Proof` tests: all 28 named tests exist by name. The two new tests (`lists versions in natural label order`, `shows the parent only to a viewer who may see it`) are additions. No existing test was weakened, skipped or deleted. The changed assertion in `lists only the versions a viewer may see` follows the agreed natural order and checks the same visibility.

- [x] Nit: `has_many :versions` still orders by `version_label` as text in SQL. The only reader, `versions_visible_to`, sorts again in Ruby. The SQL order is dead weight, and any later caller of `versions` gets an order that differs from the summary ("Level 10" before "Level 5") — `engines/entitybuilder/app/models/entitybuilder/entity/versionable.rb:25` →
- [x] Nit: `natural_sort_key` gives equal keys to labels such as "Level 5", "level 5" and "Level 05". Ruby's `sort_by` is not stable, so the order of such labels can change between requests. A tie-breaker (for example the raw label) makes the order deterministic — `engines/entitybuilder/app/models/entitybuilder/entity/versionable.rb:56` →

## Round 4 — 2026-10-10 05:34 UTC — 82eec53

Scope: phase A (`plan.md`) only, commit 82eec53 on top of round 3. Suite state at review: `PARALLEL_WORKERS=1 bin/rails test test/models/entitybuilder/entity/versionable_test.rb test/integration/monster_versions_test.rb` green (28 runs, 0 failures, 0 errors, 0 skips). `bundle exec rubocop` on the changed files is clean. The full suite (1186 runs, 0 failures) and `bin/i18n-tasks health` were green on this tree before the review and were not run again.

Round 3 follow-up: both findings are resolved and ticked above. 82eec53 removes the SQL order from `has_many :versions`. No caller other than `versions_visible_to` reads `versions`. `versions_visible_to` breaks natural-order ties by the exact label, then by id, so the order is deterministic. The new test `breaks natural order ties by the exact label` covers it, and its expected order is correct for byte order.

Compliance — acceptance criteria (spec, phase A):

- Parent lists all its versions; each version links back → `test/integration/monster_versions_test.rb` `parent lists its versions and each version links back`
- Pathfinder 2e creature gets a version without level, role or group → `test/integration/monster_versions_test.rb` `pathfinder 2e creature gets a version without builder fields`
- Version of a Private monster is owned by the same resident and starts Private → `test/integration/monster_versions_test.rb` `version of a private monster stays private and owned by the same resident`

Compliance — `## Proof` tests: all 28 named tests exist by name. `links a version of a version to the root parent` now sorts the labels before it compares them. This is not a weakening: the association has no order now, and the test still checks the root parent and both labels.

Nothing found.
