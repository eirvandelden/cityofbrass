# Rulebuilder

Shared catalogue of game-content records — **rules** (abilities, feats, stunts, etc.),
**spells** (powers, magic), and **items** (equipment, treasure) — that other engines
link to. Entities (characters, NPCs, creatures) in `entitybuilder` pull from this
catalogue via `linked_rules`, `known_spells`, and `inventory_items`.

Rulebuilder records are **game-system-aware**: every record stores a `core_rules`
string that names the game system it belongs to (`"5th Edition"`, `"PFRPG"`,
`"Fate Core"`, etc.). The legal values come from JSON files in
`config/core_rules/` — see [System config (JSON)](#system-config-json) below.

---

## Contents

- [Models at a glance](#models-at-a-glance)
- [The three ownership tiers](#the-three-ownership-tiers)
- [Schema reference](#schema-reference)
- [The `core_rules` + `rule_type` contract](#the-core_rules--rule_type-contract)
- [System config (JSON)](#system-config-json)
- [Routing and controllers](#routing-and-controllers)
- [Relationships to entities](#relationships-to-entities)
- [Hierarchy (`parent_id`)](#hierarchy-parent_id)
- [Adding content via seeds](#adding-content-via-seeds)
- [Extending the engine](#extending-the-engine)
- [Gotchas](#gotchas)
- [See also](#see-also)

---

## Models at a glance

Three parent models, each with three Single-Table-Inheritance variants by
ownership. The variant is stored in the `type` column.

| Parent             | Table                  | Stock variant                  | Resident variant                  | Proprietary variant                  |
| ------------------ | ---------------------- | ------------------------------ | --------------------------------- | ------------------------------------ |
| `Rulebuilder::Rule`  | `rulebuilder_rules`    | `Rulebuilder::StockRule`         | `Rulebuilder::ResidentRule`         | `Rulebuilder::ProprietaryRule`         |
| `Rulebuilder::Spell` | `rulebuilder_spells`   | `Rulebuilder::StockSpell`        | `Rulebuilder::ResidentSpell`        | `Rulebuilder::ProprietarySpell`        |
| `Rulebuilder::Item`  | `rulebuilder_items`    | `Rulebuilder::StockItem`         | `Rulebuilder::ResidentItem`         | `Rulebuilder::ProprietaryItem`         |

The parent classes (e.g. `Rulebuilder::Rule`) hold all validations, scopes, and
relationships. The STI variants are mostly empty shells — they exist so
authorization and ownership policy can differ per tier without forking the
schema.

Parent files:

- `app/models/rulebuilder/rule.rb`
- `app/models/rulebuilder/spell.rb`
- `app/models/rulebuilder/item.rb`

---

## The three ownership tiers

| Tier             | Owner                       | Who can edit         | Visible to     | Typical use                                              |
| ---------------- | --------------------------- | -------------------- | -------------- | -------------------------------------------------------- |
| **Stock**        | The platform (no `resident_id`) | Admins only       | All users      | Free / SRD content shipped with the app                  |
| **Resident**     | A single user (`resident_id` required) | That resident; admins | Per the record's privacy policy (`can_show?`, `can_edit?`) | User-created homebrew content                  |
| **Proprietary**  | Third-party publisher (`is_3pp = true`) | Admins only       | All users (often gated by purchase) | Licensed/paid content from outside publishers |

Authorization is enforced in the controllers, not the models:

- `StockRulesController#check_authorization` requires `admin_signed_in?`
  (`app/controllers/rulebuilder/stock_rules_controller.rb:29-33`).
- `ResidentRulesController#can_show` / `#can_edit` defer to the record's
  `can_show?` / `can_edit?` methods
  (`app/controllers/rulebuilder/resident_rules_controller.rb:36-46`).
- `ResidentRule` is the only variant that validates `resident_id` presence
  (`app/models/rulebuilder/resident_rule.rb:12`).

Spells and items follow the same pattern; see their `stock_*`, `resident_*`,
and `proprietary_*` files alongside the rule equivalents.

---

## Schema reference

Field lists are taken from `db/schema.rb`. All three tables use string primary
keys (UUIDs). Indexes are omitted here — see the schema for the full picture.

### `rulebuilder_rules` (`db/schema.rb:638-664`)

| Column              | Type    | Required | Notes                                                                       |
| ------------------- | ------- | -------- | --------------------------------------------------------------------------- |
| `type`              | string  | yes      | STI discriminator (`Rulebuilder::StockRule`, etc.)                          |
| `resident_id`       | string  | conditional | Required on `ResidentRule`; absent on Stock; optional on Proprietary    |
| `parent_id`         | string  | no       | Self-reference for variants / sub-rules — see [Hierarchy](#hierarchy-parent_id) |
| `core_rules`        | string  | **yes**  | Game system name (must match a `name` in a `config/core_rules/*.json` file) |
| `rule_type`         | string  | **yes**  | Must be in the system's declared `rulebuilder.rules` list (e.g. `Ability`, `Feat`, `Stunt`) |
| `is_shared`         | boolean | no       | Set to `true` on create; combined with `scope :shared` for catalogue listings |
| `name`              | string  | yes      | Max 64 chars; uses `validates_confirmation_of`                              |
| `short_description` | string  | no       | Max 255 chars                                                               |
| `full_description`  | text    | no       | Max 12 000 chars                                                            |
| `prerequisites`     | string  | no       | Max 255 chars                                                               |
| `benefit`           | text    | no       | Max 6 000 chars                                                             |
| `normal`            | text    | no       | Max 6 000 chars (what happens without the rule, in d20-style write-ups)     |
| `special`           | text    | no       | Max 6 000 chars (edge-case behaviour)                                       |
| `publisher`         | string  | no       | Max 255 chars                                                               |
| `source`            | string  | no       | Max 255 chars (book / supplement name)                                      |
| `is_3pp`            | boolean | no       | Marks third-party-publisher content                                         |
| `tags`              | text    | no       | Stored as text, exposed as a JSON array via `JsonArrayColumns` — see `tag_list` setter (`rule.rb:56`) |
| `categories`        | text    | no       | Same pattern as `tags`                                                      |

### `rulebuilder_spells` (`db/schema.rb:666-696`)

Same core fields (`type`, `resident_id`, `parent_id`, `core_rules`, `name`,
descriptions, `publisher`, `source`, `is_3pp`, `tags`) plus spell-specific
columns:

| Column             | Type    | Notes                                                                       |
| ------------------ | ------- | --------------------------------------------------------------------------- |
| `school`           | string  | Magic school / discipline                                                   |
| `casting_time`     | string  |                                                                             |
| `components`       | string  |                                                                             |
| `range`            | string  |                                                                             |
| `effect`           | string  |                                                                             |
| `target`           | string  |                                                                             |
| `area`             | string  |                                                                             |
| `duration`         | string  |                                                                             |
| `saving_throw`     | string  |                                                                             |
| `spell_resistance` | string  |                                                                             |
| `levels`           | text    | JSON array via `JsonArrayColumns` — class/level pairings                    |

Spells do **not** validate `rule_type` (they aren't typed beyond being a spell).
Spell-class membership lives on the join record (`entitybuilder_known_spells`).

### `rulebuilder_items` (`db/schema.rb:616-636`)

Same core fields plus:

| Column     | Type    | Notes                                                                       |
| ---------- | ------- | --------------------------------------------------------------------------- |
| `category` | text    | Max 64 chars (weapon, armor, gear, …)                                       |
| `weight`   | decimal |                                                                             |

Items also do not have a `rule_type`.

---

## The `core_rules` + `rule_type` contract

A rule record binds to a game system in **two coupled ways**:

1. `core_rules` — the system's name as a string.
2. `rule_type` — the kind of rule within that system (e.g. `"Feat"` for PFRPG,
   `"Stunt"` for Fate Core).

Validation lives on the parent model
(`app/models/rulebuilder/rule.rb:84-88`):

```ruby
def valid_rule_type
  unless self.core_rules.present? && self.rule_type.present? &&
         (CoreRules::Rule.rule_types(self.core_rules).include? self.rule_type)
    errors.add(:rule_type, "is not valid.")
  end
end
```

`CoreRules::Rule.rule_types(core_rules)` reads the system's JSON file and
returns the list of permitted rule types
(`lib/core_rules/rule.rb:35-39`). A rule with `core_rules: "PFRPG"` and
`rule_type: "Stunt"` will fail validation, because PFRPG's JSON only declares
`Ability` and `Feat`.

Spells and items skip this check — they validate only `core_rules` presence.

---

## System config (JSON)

Game systems are not database rows. Each system is a JSON file in
`config/core_rules/`. The initializer
(`config/initializers/core_rules.rb`) loads them all at boot into
`CoreRules.rulebooks` (`lib/core_rules.rb:6`).

Only the part of the JSON that the rulebuilder cares about is documented here;
for the full schema (sheet layout, default character structure, skill list,
publisher info), see the `entitybuilder` documentation.

### What the rulebuilder reads

The `rulebuilder` block declares which rule and spell kinds the system permits:

```json
{
  "name": "PFRPG",
  "active": "true",
  "stock": "true",
  "rulebuilder": {
    "rules":  [
      { "name": "Ability", "is_shared": "true" },
      { "name": "Feat",    "is_shared": "true" }
    ],
    "powers": [
      { "name": "Spell", "is_shared": "true" }
    ]
  }
}
```

| Key                     | What it controls                                                                                                  |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------- |
| `name`                  | The string stored in every record's `core_rules` column. Pick carefully — it is referenced as a plain string everywhere and renaming it orphans existing records. |
| `active`                | `"true"` to show the system in user-facing pickers. `"false"` hides it from new content, existing rows still work. |
| `stock`                 | `"true"` if the platform ships stock content for this system.                                                     |
| `rulebuilder.rules[]`   | Permitted `rule_type` values for `Rulebuilder::Rule` records. Enforced by `valid_rule_type` validation.           |
| `rulebuilder.rules[].is_shared` | Default for the `is_shared` flag on records of that type.                                                 |
| `rulebuilder.powers[]`  | Names of power categories (e.g. `Spell`, `Power`). Used by entity sheet menus more than by the rulebuilder itself; an empty array (Fate Core) means the system has no spells. |

### Adding a new game system

1. Drop a new JSON file in `config/core_rules/` (filename convention: kebab-case).
2. Declare at minimum:
   ```json
   {
     "name": "My System",
     "active": "true",
     "stock": "false",
     "rulebuilder": { "rules": [], "powers": [] },
     "entitybuilder": { ... }
   }
   ```
3. Restart the Rails app — JSON files are loaded once at boot.
4. New rule/spell/item records can now use `core_rules: "My System"`.

### Adding a new `rule_type` to an existing system

1. Add an entry to the system's `rulebuilder.rules` array:
   ```json
   { "name": "Trait", "is_shared": "true" }
   ```
2. Restart the app.
3. Records with `core_rules: "PFRPG"` and `rule_type: "Trait"` will now validate.

### Renaming or removing a system

Don't, unless you also migrate every row whose `core_rules` equals the old name.
There is no FK or cascading update — orphaned records will silently fail
`valid_rule_type` validation on next save.

---

## Routing and controllers

Mounted in the host app (typically under `/rulebuilder`). The engine's
`config/routes.rb` exposes:

```
resources :rules                            # generic, polymorphic-by-type
scope '/resident/'    do resources :resident_{rules,spells,items} end
scope '/stock/'       do resources :stock_{rules,spells,items}    end
scope '/proprietary/' do resources :proprietary_{rules,spells,items} end
```

Each tiered controller (e.g. `StockRulesController`,
`ResidentRulesController`, `ProprietaryRulesController`) inherits from the
generic `RulesController` and provides:

- `set_type` — sets `@type` to a string like `'StockRule'`
  (`stock_rules_controller.rb:12-14`).
- `set_rule` / `set_rules` — loads the right model and applies tier-specific
  scoping (e.g. `current_user.resident.resident_rules` for ResidentRules).
- `check_authorization` / `can_show` / `can_edit` — tier-specific access checks.
- `check_quota` — only `Resident*` controllers enforce a per-user cap (free
  users) via the `Quota` model.

The shared `RulesController` uses `@type` to dynamically resolve the right STI
subclass (`rules_controller.rb:104-106`):

```ruby
def klass
  "Rulebuilder::#{@type}".constantize
end
```

Strong-params are keyed off `@type.underscore`
(`rules_controller.rb:110`), so adding a new STI subclass picks up the same
params block automatically.

There is also a tiered `/options` action on each resource
(`routes.rb:4-6` + `RulesController#options`). It is a UI affordance for the
"options" panel of a record; behaviour is in the view, not the controller.

---

## Relationships to entities

Every rulebuilder record can be linked to many entities. The join records live
in `entitybuilder`:

| Rulebuilder model | Join model                         | Join purpose                                                |
| ----------------- | ---------------------------------- | ----------------------------------------------------------- |
| `Rule`            | `Entitybuilder::LinkedRule`        | An entity "has" this ability/feat/stunt                     |
| `Spell`           | `Entitybuilder::KnownSpell`        | An entity knows this spell, plus per-entity prepared/used   |
| `Item`            | `Entitybuilder::InventoryItem`     | An entity carries / equips this item, plus quantity         |

All three are `has_many` from the rulebuilder side, with `dependent: :destroy`
on the join (deleting a rule deletes all the links to it but does not delete
the entities).

Every rulebuilder model also has an optional `has_one :gallery_image_join`
(polymorphic, `imageable`) via the `gallery` engine, allowing one piece of
artwork per record. Use `accepts_nested_attributes_for :gallery_image_join` to
attach the image through the same form.

---

## Hierarchy (`parent_id`)

`Rule`, `Spell`, and `Item` are each self-referential:

```ruby
belongs_to :parent, class_name: "Rule"
has_many   :children, -> { order(:name) }, class_name: "Rule", foreign_key: "parent_id"
```

`parent_id` lets a record be a **variant or sub-entry** of another (e.g. a
"Greater" version of an ability, or a magic-item variant of a base item).
Children inherit nothing automatically — the relationship is purely structural,
so the UI can render variant lists under a base record.

`parent_id` is **never** used to link a rule to a different game system. Both
parent and child should share the same `core_rules` value; the code does not
enforce this, but mixing systems will break sheet display.

---

## Adding content via seeds

The simplest path. Authorization is bypassed when seeding from the console or a
rake task, because there is no `current_user`.

```ruby
# A stock 5e feat shipped with the platform
Rulebuilder::StockRule.create!(
  core_rules:        "5th Edition",
  rule_type:         "Feat",
  name:              "Alert",
  short_description: "Always on the lookout for danger.",
  benefit:           "You gain a +5 bonus to initiative. ...",
  is_shared:         true,
  publisher:         "Wizards of the Coast",
  source:            "Player's Handbook"
)

# A resident-owned Pathfinder spell
resident = Resident.find_by!(slug: "evdh")
Rulebuilder::ResidentSpell.create!(
  resident:     resident,
  core_rules:   "PFRPG",
  name:         "Whispering Wind",
  school:       "Transmutation",
  casting_time: "1 standard action",
  components:   "V, S",
  range:        "1 mile/level",
  duration:     "No more than 1 hour/level or until discharged"
)

# A 3pp item
Rulebuilder::ProprietaryItem.create!(
  core_rules: "PFRPG",
  name:       "Sunwrought Lantern",
  category:   "wondrous item",
  weight:     1.0,
  is_3pp:     true,
  publisher:  "Some Publisher",
  source:     "Their Book"
)
```

Tags and categories use comma-separated setters
(`rule.rb:56-69`):

```ruby
rule.tag_list      = "fire, ranged, area"
rule.category_list = "combat, evocation"
```

Levels (on spells) work the same way (`spell.rb:65-69`).

---

## Extending the engine

Pick the smallest change that does the job:

| You want to…                                                  | Do this                                                                                 |
| ------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| Permit a new kind of rule (e.g. "Trait") in an existing system | Add to that system's `rulebuilder.rules[]` JSON. No code change.                        |
| Permit a new game system                                       | Add a new JSON file. No code change.                                                    |
| Add a new ownership tier (e.g. "Curated")                      | Create `Rulebuilder::CuratedRule < Rule`, a matching `CuratedRulesController < RulesController`, and route entries in three scoped resources. Strong-params and `klass` resolution work automatically. |
| Add a new persisted column to all rules                        | Migration on `rulebuilder_rules`, then update `rule_params` in `rules_controller.rb` and add a validation if needed. |
| Add a brand-new content type (e.g. "Encounter")                | New parent model + table + migrations + STI variants + controllers + routes. Mirror the `Rule` / `Spell` / `Item` triplet. |

When adding STI subclasses, remember:

- The class name **after** `Rulebuilder::` must match what `set_type` sets in
  the controller — `klass.constantize` resolves it.
- If the subclass requires an extra column (e.g. `resident_id`), validate
  presence in the subclass, not the parent (see `ResidentRule`).
- Empty STI subclasses (`StockRule`, `ProprietaryRule`) are fine — their
  existence is what differentiates rows, not their behaviour.

---

## Gotchas

- **`core_rules` is a string, not a foreign key.** No referential integrity.
  Validation only runs at the application layer, on save. Bulk-inserting rows
  that bypass validation (e.g. `insert_all`) will not be checked.

- **Two tables exist but have no models: `rulebuilder_abilities` and
  `rulebuilder_feats`** (`db/schema.rb:570-614`). They look like a planned
  refactor that never happened. Abilities and feats currently live in
  `rulebuilder_rules` with `rule_type` set accordingly. Do not start using these
  tables without a deliberate migration plan — there is test-fixture data
  (`test/fixtures/rulebuilder/abilities.yml`, `feats.yml`) but no model code.

- **`Rulebuilder::Rule::OPTIONS = ['Ability', 'Feat', 'Stunt']`** is declared at
  `rule.rb:8` but is not referenced by `valid_rule_type`, which goes through
  the JSON config. Treat the constant as stale; the JSON is the source of
  truth.

- **System config is loaded once at boot.** Edit JSON, restart. There is no
  hot-reload.

- **JSON values are strings, not booleans.** `"active": "true"` is a string
  `"true"`, compared with `== 'true'`
  (`lib/core_rules.rb:12, 22, 32`). Writing `true` (boolean) will silently
  not match.

- **Spells and items do not validate against the system's permitted types.**
  Only `Rule` enforces `rule_type`. If you need a "spell school" or
  "item category" whitelist, you must add it.

- **`is_shared` defaults to `true` on create** in the controller, not via
  database default (`rules_controller.rb:56`). Records created outside the
  controller (seeds, console) need to set it explicitly to show up in shared
  catalogue listings (`scope :shared`).

- **Renaming a system's `name` in JSON orphans every existing record** with the
  old name. There is no cascade. Plan a data migration alongside the rename.

---

## See also

- `lib/core_rules.rb` — the runtime registry that loads JSON configs at boot.
- `lib/core_rules/rule.rb` — `rule_types(core_rules)` helper used by validation.
- `lib/core_rules/entity.rb` — the `entitybuilder`-side counterpart that seeds
  default character/creature structure from the same JSON files.
- `engines/entitybuilder/` — consumes rulebuilder records via `linked_rules`,
  `known_spells`, `inventory_items`.
- `config/core_rules/*.json` — the system definitions. Read one alongside this
  document to ground the contract.
