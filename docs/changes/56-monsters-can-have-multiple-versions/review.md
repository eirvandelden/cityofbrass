# Review: 56-monsters-can-have-multiple-versions

## Round 1 — 2026-10-08 15:26 UTC — 738f5cd

Scope: phase A (`plan.md`) only; `plan-b/c/d` are later phases. Suite state at review: `bin/rails test` green (1177 runs, 0 failures, run with `PARALLEL_WORKERS=1`; a parallel run hit `SQLite3::BusyException` in `pf2e_stock_creature_test.rb`, which went away when the tests ran one at a time), `bundle exec rubocop` clean, `bin/i18n-tasks health` clean.

Compliance — acceptance criteria (spec, phase A):

- Parent lists all its versions; each version links back → `test/integration/monster_versions_test.rb` `parent lists its versions and each version links back`
- Pathfinder 2e creature gets a version without level, role or group → `test/integration/monster_versions_test.rb` `pathfinder 2e creature gets a version without builder fields`
- Version of a Private monster is owned by the same resident and starts Private → `test/integration/monster_versions_test.rb` `version of a private monster stays private and owned by the same resident`

Compliance — `## Proof` tests: all 17 `versionable_test.rb` tests, all 3 `versions_controller_test.rb` tests and both view tests in `monster_versions_test.rb` exist. The three `entity_test.rb` tests are missing (see below). No existing test was weakened, skipped or deleted. All fixture changes only add rows.

- [ ] Important: The `## Proof` tests `set_privacy gives a new entity Residents and Private`, `set_privacy keeps given privacy values` and `short scope includes the version label` do not exist. `test/models/entitybuilder/entity_test.rb` is unchanged. The `set_privacy` change and the `short` scope change have no direct test — `engines/entitybuilder/app/models/entitybuilder/entity.rb:185` and `engines/entitybuilder/app/models/entitybuilder/entity.rb:15` →
- [ ] Nit: The reflection guard checks `Entity.reflect_on_all_associations` only. A `has_many`/`has_one` declared on `ResidentCreature` or `ResidentNpc` (both already declare `has_one :user`) escapes the copied/skipped check — `test/models/entitybuilder/entity/versionable_test.rb:26` →
- [ ] Nit: `copy_rich_text` calls `source.public_send(name)`. For `has_rich_text`, that builds an empty unsaved `ActionText::RichText` on the parent entity and on each unshared source rule as a side effect. Reading `rich_text_<name>` avoids the build — `engines/entitybuilder/app/models/entitybuilder/entity/versionable.rb:102` →
- [ ] Nit: No test covers the plan risk "the summary would leak a Private parent's name" on a version's summary. Only the private-version case is tested. The `can_show?` guard exists but is unproven — `engines/entitybuilder/app/views/entitybuilder/entities/layouts/_versions.html.erb:2` →
- [ ] Nit: The `concerns:` continuation lines start at column 0, apart from the `resources` call they belong to. They do not line up with the neighbouring `resident_characters` line either — `engines/entitybuilder/config/routes.rb:115` →
- [ ] Nit: `_versions.html.erb` calls `can_show?` on each version, which can load its resident one by one (N+1) for Friends/Private versions. Unlike `_badge` and `_campaign`, it also passes the full `type` and not `type.demodulize`. This works today, but it is inconsistent — `engines/entitybuilder/app/views/entitybuilder/entities/layouts/_versions.html.erb:5` →

1 more nit was not listed.
