# Plan: monster versions (slice A of 4)

From `intent.md` (2026-10-05) and `spec.md` (2026-10-06). Status: accepted.

## Phases

Issue #56 ships as four stacked pull requests. Each phase has its own plan file in this folder:

| Phase | Plan file | Branch | Stacked on | Content |
|---|---|---|---|---|
| A | `plan.md` (this file) | `56-monsters-can-have-multiple-versions` | `main` | Versions, every rule set |
| B | `plan-b-builder.md` | `56-monster-builder` | A | 4e builder numbers, hand edits, version recalculation |
| C | `plan-c-powers.md` | `56-monster-powers` | B | 4e power prefill, action type, Elite and Solo marks |
| D | `plan-d-difficulty.md` | `56-monster-difficulty` | C | 4e difficulty against a campaign party |

This branch builds phase A only. Each later phase starts with a short conversation with Etienne; its file lists the decisions to settle.

## Context

Today one monster cannot exist in several versions. A GM who wants an "Orc Warrior" at every 5 levels makes separate, unrelated monsters. Phase A adds versions to Entitybuilder (`/eb`) for every rule set: a resident creature or NPC gets copies linked to one parent, each with a short label such as "Level 10". `spec.md` holds the accepted requirements; this file refers to them as "spec N".

Facts about the code (verified 2026-10-06):

- `Entitybuilder::Entity` (`engines/entitybuilder/app/models/entitybuilder/entity.rb`) is an STI base; the resident subclasses are `ResidentCharacter`, `ResidentCreature`, `ResidentNpc`; stock ones are `StockCreature`, `StockNpc`. The rule set is the text slug `core_rules`.
- An entity owns child rows through `entity_id`: descriptors, ability_scores, movements, class_levels, caster_levels, base_values, skills, trackables, attacks, defenses, saving_throws, currencies, linked_rules (join to `Rulebuilder::Rule`), known_spells (join to `Rulebuilder::Spell`), inventory_items (join to `Rulebuilder::Item`), modifiers. `notables` hang off it polymorphically (`notableable`). `eb_/sb_/cm_/ap_notables` are rows elsewhere that point at the entity. It has rich text `full_description`, `introduction`, `notes`, a `gallery_image_join` and a `campaign_join`.
- `Modifier` belongs to the entity and to a polymorphic `modifierable` (AbilityScore, ClassLevel, Movement, Skill, Descriptor, LinkedRule or InventoryItem).
- No copy, duplicate or clone code exists anywhere in the repo. `CoreRules::Entity.add_defaults` (`lib/core_rules/entity.rb:55-87`) saves child rows with `save(validate: false)`. Its `linked_rules` step creates a separate unshared `Rulebuilder::Rule` per entity, and the linked-rules form can create them too.
- `Entitybuilder::LinkedRule` has `after_destroy :destroy_rule`, which destroys the rule unless `rule.is_shared`. `Rulebuilder::Rule` has `has_many :linked_rules, dependent: :destroy`.
- `Entity.short` (`entity.rb:15`) selects named columns only: `id, type, resident_id, name, short_description, core_rules, privacy, sheet_privacy`. The index lists use it.
- The STI `type` column holds the full class name, for example `Entitybuilder::ResidentCreature`.
- `Entity#set_privacy` (`entity.rb:184-186`) overwrites `privacy` with "Residents" and `sheet_privacy` with "Private" on every new record. The new-entity form does not send privacy.
- `ApplicationRecord` assigns a UUID in `after_initialize`; tables use `id: :text, default: -> { "uuid()" }`.
- Routes: `engines/entitybuilder/config/routes.rb` defines `resident_creatures` and `resident_npcs` under `/resident/` with the `:entity_core` concern. Child controllers use `set_parent_type`, `set_parent_object` and `check_parent_authorization` from `engines/entitybuilder/app/controllers/entitybuilder/application_controller.rb`.
- The summary page renders `entities/layouts/_show.html.erb`. The manage menu is `menus/_manage.html.erb`, with three blocks (desktop list, off-canvas, small dropdown).
- All entitybuilder tests live in the main app `test/` (Minitest, `fixtures :all`). `users(:dan)` (active) owns resident `razune`; `users(:lucas)` is another user. `resident_creature_one` is a pf1e creature of razune. There is no pf2e creature fixture.
- CI runs `bin/i18n-tasks health` over en, nl and it. Entitybuilder views hardcode English today; Campaign Manager uses `t(...)`.

## Design decisions

1. Scope: resident creatures and NPCs only. `Entitybuilder::Entity::Versionable` is included in `ResidentCreature` and `ResidentNpc`. Characters and stock creatures and NPCs get no versions.
2. Storage (spec decision): a nullable self-reference `parent_id` (text, indexed) and `version_label` (string, limit 64) on `entitybuilder_entities`.
3. A version of a version links to the root parent, so a family is one level deep.
4. Destroying a parent nullifies its versions' `parent_id`. The versions survive as standalone monsters.
5. A version keeps the parent's name, resident and type. The label tells versions apart, in the summary and in the index list.
6. `version_label` is required on a version (presence when `parent_id` is set), at most 64 characters.
7. `Versionable#create_version(version_label:)` copies in one transaction:
   - the entity row, with `parent` set to the root and the parent's `privacy` and `sheet_privacy`;
   - the rich text bodies and the gallery image join (same image);
   - every child row listed in Context; notables are copied through `notableable`, never through `entity_id` (that is the target entity);
   - linked rules: a rule with `is_shared` true is shared, so the copied join row points at the same rule. A rule with `is_shared` false or nil belongs to this monster alone, so the copy gets its own rule (its rich text fields, tags and categories, gallery join and `parent_id` copied too). Reason: `LinkedRule` has `after_destroy :destroy_rule` (`self.rule.destroy unless self.rule.is_shared`) and `Rulebuilder::Rule` has `has_many :linked_rules, dependent: :destroy`, so a shared unshared rule would cascade-delete across parent and versions, and edits through `LinkedRulesController#update` (`rule_attributes`) would show on both;
   - the Modifier rows, last: every child row is saved first, building an old-id to new-id map; then each modifier is copied with `entity_id` and the polymorphic `modifierable_id` remapped. A modifier whose `modifierable` is not in the map is skipped, never pointed back at the parent's rows.
   - It skips the campaign join and the `eb_/sb_/cm_/ap_notables` that point at the monster.
   - The copy keeps an explicit list of copied and of skipped associations. A test asserts that every `has_many` and `has_one` reflection on `Entity` sits in one of the two lists, so a new association cannot be forgotten silently.
   - Child rows are saved with `save!(validate: false)`, like `add_defaults`, so legacy data copies as it is. `dup` gives no id (`after_initialize` runs while the record still counts as persisted); `ApplicationRecord`'s `before_create` assigns the UUID on save.
   - It returns the version, persisted, or unsaved with errors.
8. `Entity#set_privacy` changes to fill only blank values. Normal creation still gets Residents/Private; a version keeps the parent's values (spec 5).
9. Web layer, CRUD: a nested `resources :versions, only: [:new, :create]` inside a new `:monster` route concern, added to `resident_creatures` and `resident_npcs`. `Entitybuilder::VersionsController` runs `set_parent_type`, `set_parent_object`, `check_parent_authorization` (owner only). It has no quota check (Etienne, 2026-10-08): the difference between free, paying and VIP users will be removed. Params stay nested: `version: [:version_label]`. A top-level key containing `creature_id`, `npc_id` or `character_id` would break `parent_type`. Success redirects to the version's edit page. A blank label renders the form again with the error.
10. Views:
    - `entities/layouts/_versions.html.erb` on the summary shows "Version of <parent link>" on a version, only when the viewer `can_show?` the parent. On a parent it lists the versions the viewer `can_show?`. Private versions and parents stay hidden from others.
    - The manage menu gets "New version", linked with `new_polymorphic_path([@parent_object, :version])`.
    - `entities/_list.html.erb` shows the label next to the name. `Entity.short` (`entity.rb:15`) selects named columns only, so it gains `parent_id` and `version_label`; otherwise every index raises `MissingAttributeError`.
    - `menus/_manage.html.erb`, `layouts/_show.html.erb` (also rendered by `_show_remote`) and `_list.html.erb` are shared with characters and stock entities. They guard the new parts with `respond_to?(:versions)`.
11. Strings, conflict flagged: the playbook (`rails-ui`) says every user-facing string is a translation key; entitybuilder views use none. This plan follows the playbook: new strings are keys under `entitybuilder.` in `config/locales/en.yml`, `nl.yml` and `it.yml`. Existing hardcoded strings stay. `bin/i18n-tasks health` includes the normalized check, so run `bin/i18n-tasks normalize` after adding keys. Unused-key checks are strict, so use literal keys, never `t("...#{value}")`. Models use absolute keys (they are not in `relative_roots`). Interpolation names match across en, nl and it.
12. Phase B extends `create_version` with an optional `monster_level:` that rebuilds a built 4e copy. Phase A leaves that out.

## Integration points

- Entitybuilder resident creature and NPC models, summary, index list, manage menu, routes.
- Rulebuilder: shared rules, spells and items are linked from the version through copied join rows; unshared rules are copied (decision 7).
- Gallery: versions share the parent's image.
- Locales `config/locales/{en,nl,it}.yml` and the CI `i18n-tasks health` job.
- Primary database only. The migration goes in `db/migrate/` and updates `db/schema.rb`.

## Files that change

New:

- `db/migrate/<ts>_add_versions_to_entitybuilder_entities.rb` — `parent_id`, `version_label`, index on `parent_id`. `ActiveRecord::Migration[8.1]`.
- `engines/entitybuilder/app/models/entitybuilder/entity/versionable.rb` — concern: `belongs_to :parent`, `has_many :versions` (`dependent: :nullify`), label validation, `create_version`, the copy.
- `engines/entitybuilder/app/controllers/entitybuilder/versions_controller.rb`.
- `engines/entitybuilder/app/views/entitybuilder/versions/new.html.erb`, `_form.html.erb`.
- `engines/entitybuilder/app/views/entitybuilder/entities/layouts/_versions.html.erb`.
- Tests listed under Proof.
- Fixture files phase A creates (phases B–D only add to them): `test/fixtures/entitybuilder/{movements,class_levels,skills,trackables,defenses,saving_throws,currencies,modifiers,notables}.yml`. Additions to `entities.yml`, `linked_rules.yml` and `test/fixtures/rulebuilder/rules.yml`.

Changed:

- `engines/entitybuilder/app/models/entitybuilder/entity.rb` — `set_privacy` fills blanks only; `scope :short` selects `parent_id` and `version_label` too.
- `engines/entitybuilder/app/models/entitybuilder/resident_creature.rb`, `resident_npc.rb` — include `Entity::Versionable`.
- `engines/entitybuilder/config/routes.rb` — `:monster` concern with `versions`.
- `engines/entitybuilder/app/views/entitybuilder/entities/layouts/_show.html.erb` — render `_versions`.
- `engines/entitybuilder/app/views/entitybuilder/entities/_list.html.erb` — label next to the name.
- `engines/entitybuilder/app/views/entitybuilder/menus/_manage.html.erb` — "New version" in all three blocks.
- `config/locales/{en,nl,it}.yml` — new keys.
- `db/schema.rb` — regenerated.

## Order of work

Run every test command narrowest first, with `-f`.

1. Write the acceptance test `test/integration/monster_versions_test.rb` `parent lists its versions and each version links back`. Run it, watch it fail (no route).
2. Unit tests for `Entity#set_privacy`; change `set_privacy`.
3. Migration; `bin/rails db:migrate`; commit `db/schema.rb` with it.
4. Unit tests `test/models/entitybuilder/entity/versionable_test.rb`; write `Entity::Versionable`; include it in `ResidentCreature` and `ResidentNpc`.
5. Controller tests `test/controllers/entitybuilder/versions_controller_test.rb`; add the route concern, `VersionsController` and its views.
6. Add `_versions` to the summary, the menu link, the label in `_list`, the `short` scope columns and the locale keys (`bin/i18n-tasks normalize`). Make all phase A acceptance tests pass.
7. Run `bin/rails test`, `bundle exec rubocop`, `bin/i18n-tasks health`, `bin/pre_push_checks`. All green.
8. Run `bin/dev`. As `user@example.com`, create a version "Level 10" of a creature; check the summary of both, the index list and the privacy.
9. Re-read the full diff; revert any hunk the task does not need. Push and open the PR against `main`.

## Risks

- The copy misses a child association added later, and versions silently drop data. Mitigation: the reflection test (decision 7) and a test that counts rows in every copied association.
- Unshared linked rules shared by mistake would cascade-delete and leak edits between parent and version. Mitigation: decision 7 and two isolation tests.
- `dup` leaves the id nil until `before_create`; modifier remapping therefore runs after the child rows are saved.
- `set_privacy` now honours a privacy value sent on create. The form never sends one and an owner may set privacy on edit anyway.
- With no quota check, a free user can exceed the creature limit (2) and NPC limit (0) through versions. Accepted: the user tiers will be removed.
- The summary would leak Private versions or a Private parent's name; both filter on `can_show?`.
- `test/fixtures/action_text/rich_texts_test.rb` fails for an entity fixture that sets the legacy `full_description`, `introduction` or `notes` columns without a matching `action_text/rich_texts.yml` row. New fixtures leave those columns out or mirror them.
- A large monster copies many rows in one request. Acceptable at today's sizes.
- Rejected: one creature with several stat blocks (spec chose separate linked entities); a `deep_cloneable`-style gem (no new dependency for one copy method); sharing every linked rule (data loss, see decision 7).

## Out of scope

- Phases B, C and D (see their plan files).
- Versions for characters and for stock creatures and NPCs.
- Quota checks on versions; the free, paying and VIP distinction will be removed.
- A stat-block switching UI; each version is a normal entity page.
- Translating existing hardcoded entitybuilder strings.

## Proof

Acceptance criteria from `spec.md` covered by phase A:

- Parent lists all its versions; each version links back → `test/integration/monster_versions_test.rb` `parent lists its versions and each version links back`
- A Pathfinder 2e creature gets a version without level, role or group → `test/integration/monster_versions_test.rb` `pathfinder 2e creature gets a version without builder fields`
- A version of a Private monster is owned by the same resident and starts Private → `test/integration/monster_versions_test.rb` `version of a private monster stays private and owned by the same resident`

The other spec criteria belong to phases B, C and D.

Per changed file, the unit tests expected (edge and invalid cases first, nested classes for context):

- `entity.rb` (`test/models/entitybuilder/entity_test.rb`): `set_privacy gives a new entity Residents and Private`, `set_privacy keeps given privacy values`.
- `entity/versionable.rb` (`test/models/entitybuilder/entity/versionable_test.rb`): `refuses a blank version label`, `refuses a label over 64 characters`, `every entity association is listed as copied or skipped`, `copies every child association with fresh ids`, `remaps modifiers to the copied rows`, `skips a modifier whose target was not copied`, `copies rich text and the gallery image`, `copies notables through notableable only`, `does not copy the campaign join or notables pointing at the monster`, `shares a shared linked rule`, `gives the version its own copy of an unshared linked rule`, `destroying the parent keeps the version's linked rules`, `editing the version's unshared rule leaves the parent's rule unchanged`, `keeps resident, name, type and privacy`, `links a version of a version to the root parent`, `destroying the parent keeps its versions`, `copies an npc`.
- `entity.rb` scope (`test/models/entitybuilder/entity_test.rb`): `short scope includes the version label`.
- `versions_controller.rb` (`test/controllers/entitybuilder/versions_controller_test.rb`): `non-owner gets 403`, `blank label renders the form with an error`, `creates a version and redirects to its edit page`.
- Views (`test/integration/monster_versions_test.rb`): `non-owner does not see a private version on the summary`, `creature index shows the version label`.

Test setup: fixtures only. Add a pf2e resident creature and a Private creature for razune. For the copy test, a creature fixture with one row in every copied association (descriptor, ability score with a modifier, movement, class level, caster level, base value, skill, trackable, attack, defense, saving throw, currency, a shared and an unshared linked rule, known spell, inventory item, notable) plus a campaign join and an `eb_notables` row pointing at it. New entity fixtures leave the legacy rich text columns out. Sign in with `users(:dan)` (owns resident razune); `users(:lucas)` is the non-owner.

---
Domain skills applied: rails-ui (i18n keys), rails-testing (fixtures, integration tests first, nested context classes). Playbook §1: behaviour in model concerns, CRUD nested resources, no service objects.
