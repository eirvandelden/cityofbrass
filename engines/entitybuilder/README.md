# Entitybuilder

Character, NPC, and creature sheets. Every sheet's **structure** — which ability
scores, skills, defenses, trackables, and so on it has — comes from the
`entitybuilder` block of the active game system's JSON config in
`config/core_rules/`. Behaviour (calculations, validations, routing) lives in
this engine.

If you haven't already, read the [`rulebuilder` README](../rulebuilder/README.md)
first. It explains the `core_rules` string contract, the Stock/Resident/Proprietary
ownership pattern, and the JSON file layout. This document covers only the
`entitybuilder` half.

---

## Contents

- [Models at a glance](#models-at-a-glance)
- [Schema reference](#schema-reference)
- [Entity creation: how JSON becomes sheet rows](#entity-creation-how-json-becomes-sheet-rows)
- [System config: the `entitybuilder` JSON block](#system-config-the-entitybuilder-json-block)
  - [Top-level keys](#top-level-keys)
  - [`menu[]`](#menu)
  - [`core_skills[]`](#core_skills)
  - [`character` and `creature` blocks](#character-and-creature-blocks)
    - [`ability_scores[]`](#ability_scores)
    - [`base_values[]`](#base_values)
    - [`currencies[]`](#currencies)
    - [`defenses[]`](#defenses)
    - [`descriptors[]`](#descriptors)
    - [`movements[]`](#movements)
    - [`saving_throws[]`](#saving_throws)
    - [`skills[]`](#skills)
    - [`trackables[]`](#trackables)
    - [`linked_rules[]`](#linked_rules)
    - [`attacks[]`](#attacks)
- [Modifiers](#modifiers)
- [Calculations](#calculations)
- [Routing and controllers](#routing-and-controllers)
- [Adding default content for a new system](#adding-default-content-for-a-new-system)
- [Customising per system](#customising-per-system)
- [Gotchas](#gotchas)
- [See also](#see-also)

---

## Models at a glance

The engine's models fall into four groups.

### 1. Entity STI tree

`Entitybuilder::Entity` is the parent. Seven concrete subclasses split entities
along two axes — **kind** (character / NPC / creature) and **ownership**
(stock / resident / proprietary):

| Subclass                                       | Kind      | Ownership   | Allowed |
| ---------------------------------------------- | --------- | ----------- | ------- |
| `Entitybuilder::ResidentCharacter`             | character | resident    | only player-character variant |
| `Entitybuilder::ResidentNpc`                   | NPC       | resident    | |
| `Entitybuilder::ResidentCreature`              | creature  | resident    | |
| `Entitybuilder::StockNpc`                      | NPC       | stock       | |
| `Entitybuilder::StockCreature`                 | creature  | stock       | |
| `Entitybuilder::ProprietaryNpc`                | NPC       | proprietary | |
| `Entitybuilder::ProprietaryCreature`           | creature  | proprietary | |

There is intentionally no `StockCharacter` or `ProprietaryCharacter` — only
residents own characters.

The `type` column is the STI discriminator. `is_character?` and `simple_type`
on the parent (`entity.rb:126-160`) classify by substring match on `type`.

### 2. Sub-models (one row per "row" on the sheet)

Every sub-model has `belongs_to :entity` and a `sort_order` column. The parent
declares each of these as `has_many ..., -> { order(:sort_order) }, dependent: :destroy`
(`entity.rb:37-48`).

| Sub-model       | Table                              | Purpose                                                                |
| --------------- | ---------------------------------- | ---------------------------------------------------------------------- |
| `AbilityScore`  | `entitybuilder_ability_scores`     | Strength, Dexterity, … (no rows on Fate Core)                          |
| `Skill`         | `entitybuilder_skills`             | One row per skill on the sheet                                         |
| `Attack`        | `entitybuilder_attacks`            | A weapon / attack action (attack roll + damage roll)                   |
| `Defense`       | `entitybuilder_defenses`           | Armour Class, Touch, Fortitude (in 4e), …                              |
| `SavingThrow`   | `entitybuilder_saving_throws`      | Fortitude / Reflex / Will style saves                                  |
| `Movement`      | `entitybuilder_movements`          | Initiative, Speed, Climb, Fly, …                                       |
| `ClassLevel`    | `entitybuilder_class_levels`       | "Fighter 3", "Wizard 5", with HP per level                             |
| `CasterLevel`   | `entitybuilder_caster_levels`      | Per-class spell DC, per-day slots                                      |
| `Trackable`     | `entitybuilder_trackables`         | HP, Fate Points, Action Points, Stress, anything bounded               |
| `Currency`      | `entitybuilder_currencies`         | Coins, gems, system-specific currencies                                |
| `BaseValue`     | `entitybuilder_base_values`        | Named constants on the sheet (Half Level, Combat Advantage, Proficiency Bonus, …) |
| `Descriptor`    | `entitybuilder_descriptors`        | Race, Alignment, Background, Trouble, anything name+description        |

### 3. Joins to other engines

| Join model        | Other side                | Source                                |
| ----------------- | ------------------------- | ------------------------------------- |
| `LinkedRule`      | `Rulebuilder::Rule`       | Abilities, feats, aspects, stunts the entity has |
| `KnownSpell`      | `Rulebuilder::Spell`      | Spells / powers the entity knows, prepared, used |
| `InventoryItem`   | `Rulebuilder::Item`       | Items the entity carries / equips     |
| `Notable`         | `Entitybuilder::Entity`   | Entities this entity references (allies, enemies, contacts) — polymorphic via `notableable` |
| `CampaignJoin`    | `Campaignmanager::Campaign` | An entity may participate in one campaign |

`LinkedRule` has a small surprise: `after_destroy :destroy_rule` destroys the
underlying `Rule` if it isn't `is_shared` (`linked_rule.rb:32-34`). That makes
the per-character, one-off rules created by Fate's `linked_rules` JSON (see
below) clean themselves up.

### 4. Polymorphic: modifiers

`Modifier` (`entitybuilder_modifiers`) is `belongs_to :modifierable, polymorphic: true`
and can attach to any of: `Descriptor`, `AbilityScore`, `Movement`, `ClassLevel`,
`Skill`, `LinkedRule`, `InventoryItem`. See [Modifiers](#modifiers).

---

## Schema reference

### `entitybuilder_entities` (`db/schema.rb:332-352`)

| Column              | Type    | Required | Notes                                                              |
| ------------------- | ------- | -------- | ------------------------------------------------------------------ |
| `type`              | string  | yes      | STI discriminator (`Entitybuilder::ResidentCharacter`, etc.)       |
| `resident_id`       | string  | conditional | Required on `Resident*` subclasses (`resident_character.rb:12`) |
| `name`              | string  | yes      | Max 64 chars, uses `validates_confirmation_of`                     |
| `core_rules`        | string  | **yes**  | Names the game system; resolved through `CoreRules.rulebooks`      |
| `privacy`           | string  | yes      | One of `Private`, `Friends`, `Residents` (`entity.rb:8`)           |
| `sheet_privacy`     | string  | yes      | Same enum, scoped to the sheet view                                |
| `short_description` | string  | no       | Max 255 chars                                                      |
| `full_description`  | text    | no       | Max 12 000 chars                                                   |
| `introduction`      | text    | no       | Free-form intro shown on profile                                   |
| `notes`             | text    | no       | Max 12 000 chars (private notes)                                   |
| `publisher`         | string  | no       | Max 255 chars                                                      |
| `source`            | string  | no       | Max 255 chars                                                      |
| `is_3pp`            | boolean | no       | Marks third-party-publisher content                                |
| `tags`              | text    | no       | JSON array via `JsonArrayColumns` (see `tag_list`)                 |

### Sub-models — common shape

Every sub-model row has these columns:

- `entity_id` (string FK to `entitybuilder_entities`)
- `sort_order` (integer; controls UI order, set during JSON-driven creation)
- `name` (limit 255, usually `null: false`)
- `created_at`, `updated_at`

Sub-model-specific columns are summarised under each
[`character` / `creature` block](#character-and-creature-blocks) entry below.

---

## Entity creation: how JSON becomes sheet rows

When an entity is first created (via controller or seed), the application calls
`CoreRules::Entity.add_defaults(entity)` (`lib/core_rules/entity.rb:55-87`). It:

1. Resolves the entity to a kind: `entity_type = entity.type.include?("Creature") ? "creature" : "character"`.
2. Looks up the system's JSON: `CoreRules.rulebooks.detect { |v| v['name'] == entity.core_rules }`.
3. Reads the keys of `entitybuilder.<entity_type>` as `default_types`.
4. For each `default_type`:
   - If it's `linked_rules`, calls `add_linked_rules` (special case, see below).
   - Otherwise, iterates the JSON array and creates one row per entry via
     `entity.send(default_type).new`. Each JSON key/value pair is assigned
     verbatim onto the new row.
5. Calls `add_core_skills(entity)` if the entity is a character and no skills
   were seeded by the character block. Skills come from `core_skills` (the
   shared per-system list) when this fires.

Two consequences worth internalising:

- **Every key in `character` / `creature` must match a `has_many` association
  on `Entitybuilder::Entity`** — the loader calls `entity.send(key).new`. Add a
  `defenses` array to JSON and rows appear on `entity.defenses`. Add a `mood`
  array and you get `NoMethodError` at creation time.
- **Each JSON field name is assigned 1:1 to a column on the sub-model.**
  Misspelled key → silent miss (the assignment lands on a non-existent attribute
  and `save(:validate => false)` discards it). The columns on each sub-model
  are listed below per block.

The whole thing runs inside a single `ActiveRecord::Base.transaction`. Errors
are rescued and logged (`Rails.logger.error`), not re-raised — so a malformed
JSON config does **not** roll back the entity itself, only the defaults.

---

## System config: the `entitybuilder` JSON block

This section walks through every key under `entitybuilder` using **4th Edition
as the canonical example**. Variation callouts highlight where PFRPG or Fate
Core diverge in shape.

### Top-level keys

```json
"entitybuilder": {
  "sheet": "default",
  "use_modifiers": "true",
  "show_core_blocks": "true",
  "menu": [ ... ],
  "core_skills": [ ... ],
  "character": { ... },
  "creature":  { ... }
}
```

| Key                  | Read by                                              | Effect                                                                 |
| -------------------- | ---------------------------------------------------- | ---------------------------------------------------------------------- |
| `sheet`              | `CoreRules::Entity.sheet_layout` (`entity.rb:4-8`)   | ERB layout selector. Views pick a sheet template by this string.       |
| `use_modifiers`      | `CoreRules::Entity.use_modifiers?` (`entity.rb:10-14`) | If `"true"`, sub-records expose a Modifiers panel. String, compared to `"true"`. |
| `show_core_blocks`   | `CoreRules::Entity.show_core_blocks?` (`entity.rb:16-20`) | If `"true"`, classic d20 sheet sections (ability scores etc.) render. String. |
| `menu`               | `CoreRules::Entity.menu` (`entity.rb:22-26`)         | Order and labels of sheet sections.                                    |
| `core_skills`        | `CoreRules::Entity.core_skills` (`entity.rb:32-36`)  | Skill catalogue used when seeding characters and offering "add core skill". |
| `character`          | `CoreRules::Entity.default_types` (`entity.rb:42-46`) | Default rows for character entities.                                  |
| `creature`           | same                                                 | Default rows for NPC and creature entities.                            |

> **Variation — Fate Core**: `sheet: "fate"`, `use_modifiers: "false"`,
> `show_core_blocks: "false"`. The Fate sheet uses a different template and
> hides the d20-style core blocks.

### `menu[]`

Drives the navigation on a character sheet. Each entry decides whether a
section appears, where it sits, and whether it offers a "Modifiers" affordance.

4th Edition example (`4th-edition.json:20-96`):

```json
"menu": [
  { "label": "Descriptors",     "link": "descriptors",                "add_modifiers": "true"  },
  { "label": "Base Values",     "link": "base_values",                "add_modifiers": "true"  },
  { "label": "Ability Scores",  "link": "ability_scores",             "add_modifiers": "true"  },
  { "label": "Class Levels",    "link": "class_levels",               "add_modifiers": "true"  },
  { "label": "Trackables",      "link": "trackables",                 "add_modifiers": "false" },
  { "label": "Attacks",         "link": "attacks",                    "add_modifiers": "true"  },
  { "label": "Movement",        "link": "movements",                  "add_modifiers": "true"  },
  { "label": "Defenses",        "link": "defenses",                   "add_modifiers": "true"  },
  { "label": "Powers",          "link": "known_spells",               "add_modifiers": "true"  },
  { "label": "Skills",          "link": "skills",                     "add_modifiers": "true"  },
  { "label": "Feats",           "link": "linked_rules?rule_type=feat", "add_modifiers": "true" },
  { "label": "Inventory Items", "link": "inventory_items",            "add_modifiers": "false" },
  { "label": "Currencies",      "link": "currencies",                 "add_modifiers": "false" },
  { "label": "Modifiers",       "link": "modifiers",                  "add_modifiers": "false" },
  { "label": "Options",         "link": "options",                    "add_modifiers": "false" }
]
```

| Field            | Notes                                                                                         |
| ---------------- | --------------------------------------------------------------------------------------------- |
| `label`          | Display text. Free choice. Use it to relabel — e.g. 4e shows "Powers" but the link is `known_spells`. |
| `link`           | The section name. Matches a `has_many` association name (e.g. `descriptors`, `attacks`). May include a query string to filter the index (see `linked_rules?rule_type=feat`). |
| `add_modifiers`  | If `"true"`, each row in this section gets a Modifiers panel and is exposed via `modifier_list` (`entity.rb:28-30`). |

> **Variation — Fate Core** (`fate-core.json:20-27`): the entire menu is six items —
> Descriptors, Trackables, Aspects (`linked_rules?rule_type=aspect`), Skills,
> Stunts (`linked_rules?rule_type=stunt`), Options. No ability scores, no
> defenses, no currencies, no modifiers menu (because `use_modifiers` is off).
>
> **Variation — PFRPG**: same menu shape as 4e but uses `saving_throws` instead
> of split-by-ability defenses, and includes a CMB attack default.

### `core_skills[]`

The system's official skill list. Used at create time when the `character`
block does not seed `skills` directly (`add_core_skills` only fires if
`entity.skills.size < 1` — `lib/core_rules/entity.rb:82`). Also powers the
"Add a missing core skill" affordance (`/skills/new/:skill_type` route, plus
`entity.missing_core_skills` — `entity.rb:162-166`).

4th Edition has 17 skills (`4th-edition.json:97-183`):

```json
"core_skills": [
  { "name": "Acrobatics", "ranks": "", "ability_score": "Dexterity"    },
  { "name": "Arcana",     "ranks": "", "ability_score": "Intelligence" },
  { "name": "Athletics",  "ranks": "", "ability_score": "Strength"     },
  ...
]
```

Each entry seeds an `entitybuilder_skills` row with `name`, `ranks`,
`ability_score` (a string — must match a row in `ability_scores` for skill
calculations to find an ability modifier).

> **Variation — PFRPG**: 35 skills including parenthesised knowledges
> (`"Knowledge (arcana)"`, `"Knowledge (dungeoneering)"`, …). Names are stored
> as-is and matched as strings.
>
> **Variation — Fate Core**: 18 skills, all with `ability_score: ""` (Fate
> skills aren't tied to an ability). The calculation logic in
> `skill.rb:23-49` simply finds no matching ability and skips that step.

### `character` and `creature` blocks

Each is a hash whose **keys are association names** on `Entitybuilder::Entity`
and whose **values are arrays of rows** to seed at entity creation.

The full set of keys 4e uses on `character`:

```json
"character": {
  "ability_scores": [ ... ],
  "base_values":    [ ... ],
  "currencies":     [ ... ],
  "defenses":       [ ... ],
  "descriptors":    [ ... ],
  "movements":      [ ... ],
  "trackables":     [ ... ]
}
```

`creature` adds `saving_throws` and `skills` (in 4e they're absent on
character, deferred to `core_skills`).

> **Variation — Fate Core**: the `character` block has only `descriptors`,
> `linked_rules`, `movements`, and `trackables`. The `creature` block is `{}`
> (empty) — `default_types` returns `[]` and `add_defaults` seeds nothing for
> Fate NPCs/creatures. The Fate sheet view fills in the rest.
>
> **Variation — PFRPG**: includes `saving_throws` on `character` (Fortitude /
> Reflex / Will) and an `attacks` entry for CMB.

#### `ability_scores[]`

Seeds rows into `entitybuilder_ability_scores` (`db/schema.rb:198-210`).

```json
{ "name": "Strength", "base": "10", "modifier": "0", "dice": "" }
```

| Column     | Type    | Notes                                                                 |
| ---------- | ------- | --------------------------------------------------------------------- |
| `name`     | string  | Referenced by string match from `skills[].ability_score`, `saving_throws[].ability_score`, `defenses[].ability_score`, and `movements[].ability_score`. Pick a stable canonical spelling. |
| `base`     | integer | The unmodified score.                                                 |
| `score`    | integer | Effective score (base + modifiers, stored if computed).               |
| `modifier` | integer | Cached ability modifier; refreshed at save.                           |
| `dice`     | string  | Optional dice expression — e.g. rolled stats. Validated by `VALID_DICE_MECHANIC` on sub-models that include `Dice`. |

> **Variation — Fate Core**: `"ability_scores"` is absent — Fate has no
> ability scores. The skill calculation in `skill.rb:31-32` silently does
> nothing when no matching score is found.

#### `base_values[]`

Named constants on the sheet. Seeds `entitybuilder_base_values`
(`db/schema.rb:244-254`).

```json
{ "name": "Half level", "value": "0", "dice": "" }
```

4e uses three: Half level, Combat Advantage (5), Trained (5).
PFRPG: Proficiency Bonus, Class Skill Bonus.

The skill calculation hard-codes lookups by name:

- `Proficiency Bonus` is added if `proficient?` (`skill.rb:34`).
- `Class Skill Bonus` is added if `class_skill?` and `ranks > 0` (`skill.rb:37`).

If a new system needs different proficiency-like mechanics, you'll likely
extend `Skill#calculated_bonus` rather than the JSON shape.

> **Variation — Fate Core**: omitted entirely. Fate Core characters have no
> base-value rows.

#### `currencies[]`

Seeds `entitybuilder_currencies` (`db/schema.rb:293-304`).

```json
{ "name": "Gold piece (gp)", "quantity": "0", "weight": "0.02", "carried": "true" }
```

`quantity` is a `bigint` column; `carried` is boolean. `weight` is decimal —
used by encumbrance calculations elsewhere.

> **Variation — Fate Core**: omitted (Fate doesn't model coinage).

#### `defenses[]`

Seeds `entitybuilder_defenses` (`db/schema.rb:306-319`).

```json
{ "name": "Armor Class", "base": "10", "ability_score": "Dexterity" }
```

| Column          | Type    | Notes                                            |
| --------------- | ------- | ------------------------------------------------ |
| `name`          | string  | Display name.                                    |
| `base`          | integer | Base value (e.g. 10 for AC).                     |
| `bonus`         | integer | Static bonus.                                    |
| `ability_score` | string  | Looked up by name on the entity's ability scores. |
| `misc_modifier` | integer | Free-form misc adjustment.                       |
| `dice`          | string  | Optional dice expression.                        |

4e splits Fortitude / Reflex / Will into seven defense rows (one per ability
that contributes) instead of using saving throws. That's a stylistic choice
the JSON expresses cleanly.

> **Variation — Fate Core**: omitted entirely.
>
> **Variation — PFRPG**: lists Armor Class, Touch, Flat-Footed, CMD here, and
> models Fortitude / Reflex / Will under `saving_throws` instead.

#### `descriptors[]`

Free-form name+description pairs — race, alignment, languages, age, anything.
Seeds `entitybuilder_descriptors` (`db/schema.rb:321-330`).

```json
{ "name": "Race", "description": "", "is_private": "false" }
```

`is_private` controls visibility on shared sheets.

> **Variation — Fate Core**: Age, Gender, Height, Weight (a much shorter list).
>
> **Variation — PFRPG**: Adds Class, Race, Size, Alignment, Languages,
> Deity, plus a few more.

#### `movements[]`

Seeds `entitybuilder_movements` (`db/schema.rb:433-446`).

```json
{ "name": "Initiative", "base": "0", "ability_score": "Dexterity", "dice": "", "description": "" }
```

`Initiative` is conventionally the first entry and is treated specially by
some sheet views.

> **Variation — Fate Core**: just `Initiative`, no Speed (Fate doesn't measure
> tactical movement in squares).

#### `saving_throws[]`

Seeds `entitybuilder_saving_throws`. Columns mirror `defenses` (`name`,
`base`, `bonus`, `ability_score`, `proficient`).

> **Variation — 4th Edition**: not present on `character`. (4e collapses saves
> into defenses.)
>
> **Variation — Fate Core**: not present.
>
> **Variation — PFRPG**: three rows — Fortitude (Constitution), Reflex
> (Dexterity), Will (Wisdom).

#### `skills[]`

Seeds `entitybuilder_skills` directly. If this key is missing or yields zero
rows, `add_core_skills` falls back to the `core_skills` catalogue
(`lib/core_rules/entity.rb:82`). 4e relies entirely on the fallback.

```json
{ "name": "Athletics", "ranks": "0", "ability_score": "Strength" }
```

Use this block instead of `core_skills` when characters should start with a
subset of the full skill list. Most systems leave it empty and use `core_skills`.

The `creature` block in 4e uses this directly to give creatures just two skills
(Perception, Insight) without inheriting the full character skill list.

#### `trackables[]`

Seeds `entitybuilder_trackables`. Each row has `name`, `minimum`, `maximum`,
`current`, `temporary` columns.

```json
{ "name": "Hit Points",      "maximum": "0", "current": "0" }
```

4e tracks Hit Points, Healing Surges, Action Points, Experience.
Fate Core: Fate Points, Physical Stress 1–2, Mental Stress 1–2.
PFRPG: Hit Points, Hit Dice, Experience.

#### `linked_rules[]`

The one block whose loader is **not** a 1:1 row creation. Reserved for systems
that want to seed placeholder rules (aspects, traits, etc.) on every new
character.

Fate Core uses it for the canonical aspects:

```json
"linked_rules": [
  { "detail": "", "rule": { "name": "High Concept", "rule_type": "Aspect" } },
  { "detail": "", "rule": { "name": "Trouble",      "rule_type": "Aspect" } },
  { "detail": "", "rule": { "name": "Aspect 1",     "rule_type": "Aspect" } },
  { "detail": "", "rule": { "name": "Aspect 2",     "rule_type": "Aspect" } },
  { "detail": "", "rule": { "name": "Aspect 3",     "rule_type": "Aspect" } }
]
```

`add_linked_rules` (`lib/core_rules/entity.rb:89-112`) does, per entry:

1. Creates a `Rulebuilder::Rule` row — Stock/Resident/Proprietary variant chosen
   by the entity's STI type — with `is_shared: false`, the entry's
   `rule.rule_type` and `rule.name`.
2. Creates an `Entitybuilder::LinkedRule` row tying the new rule to the entity,
   with `detail` from the JSON.

Because the rule is created with `is_shared: false`, it isn't visible in the
shared catalogue. When the linked-rule join is destroyed, the `after_destroy`
callback in `LinkedRule` (`linked_rule.rb:32-34`) also destroys the rule —
preventing orphaned per-character rules.

> **Variation — 4th Edition / PFRPG**: don't use `linked_rules` defaults. They
> rely on the user to pick feats from the shared catalogue.

#### `attacks[]`

Seeds `entitybuilder_attacks` (`db/schema.rb:212-242`).

```json
{ "name": "CMB", "attack_type": "Special", "attack_ability_score": "Strength" }
```

The attacks table has the widest column set — separate `attack_*`, `damage_*`,
`critical_damage_*`, and `special_damage_*` field groups for systems with
complex attack mechanics. Most defaults set only a handful; the rest are
filled in per-attack by the user.

> **Variation — 4th Edition**: doesn't seed attack defaults (uses Powers via
> `known_spells` instead). The Attacks menu entry is still there for ad-hoc
> use.
>
> **Variation — Fate Core**: omitted entirely.
>
> **Variation — PFRPG**: seeds CMB as shown above.

---

## Modifiers

`Modifier` is the polymorphic glue that lets any "modifierable" row carry
bonuses. Schema (`db/schema.rb:417-431`):

| Column              | Notes                                                                   |
| ------------------- | ----------------------------------------------------------------------- |
| `modifierable_id`   | FK to the host row (e.g. a Skill, a Defense, an InventoryItem).        |
| `modifierable_type` | Class name string, e.g. `"Entitybuilder::Skill"`.                      |
| `entity_id`         | FK back to the parent entity (denormalised for fast lookups).           |
| `category`          | Bucket — e.g. `"Skills"`, `"Defenses"`. Matches `Modifier` lookup logic. |
| `item`              | The name of the specific row the modifier targets (e.g. `"Acrobatics"`). |
| `value`             | Integer bonus.                                                          |
| `dice`              | Optional dice expression.                                               |
| `original_mod_type` | Tracks where the modifier came from for de-dup.                         |

A modifier attaches via two layers:

1. `belongs_to :modifierable, polymorphic: true` — points to the specific row.
2. `category` + `item` — used by calculation methods that need to find
   modifiers without traversing the polymorphic association (e.g.
   `Skill#calculated_bonus` filters `all_modifiers.select { |m| m.category == "Skills" and m.item == self.name }` — `skill.rb:41`).

The Modifiers panel on each row is enabled by the menu's
`"add_modifiers": "true"` flag, which `CoreRules::Entity.modifier_list`
(`entity.rb:28-30`) returns.

`use_modifiers: "false"` (Fate Core) hides the panel system-wide.

---

## Calculations

The engine doesn't model dice resolution — it stores dice expressions as
strings and lets the front end (or a roller) interpret them. What it **does**
calculate, on every render, are derived bonuses:

### `Skill#calculated_bonus` (`skill.rb:23-49`)

Adds, in order:

1. `ranks` if present.
2. `misc_modifier` if present.
3. The modifier of the matching ability score (lookup by `skill.ability_score == ability_score.name`).
4. `base_values["Proficiency Bonus"].value` if `proficient?`.
5. `base_values["Class Skill Bonus"].value` if `class_skill?` and `ranks > 0`.
6. Sum of all modifiers in `category == "Skills"` whose `item == self.name`.

If `skill.bonus` is set explicitly, all of that is skipped and `bonus` is
returned as-is (manual override).

### `AbilityScore` modifier

Either stored explicitly or derived via the d20 formula `(score - 10) / 2`
floored. Recomputed at save in most systems.

### Attack & damage

`Attack` has separate base/bonus/ability_score/dice fields for attack roll
and damage roll, plus a critical-damage triplet and an optional
special-damage triplet. The math is the same pattern as `Skill#calculated_bonus`,
just split across the two rolls.

If you add a new system with a fundamentally different attack mechanic
(e.g. Fate's Shifts), you likely won't seed attacks at all.

---

## Routing and controllers

`engines/entitybuilder/config/routes.rb` defines a single shared concern
`entity_core` that mounts every sub-model as a nested resource, and exposes:

- Per-row CRUD: `resources :descriptors`, `resources :skills`, …
- Bulk updates: `PATCH /<plural>` → `<plural>#update_list` (used for
  drag-and-drop reordering, batch privacy changes, etc.).
- Per-row modifiers: `resources :<plural>` `do resources :modifiers end`
  for each row type that supports modifiers.
- Sheet-only updates: e.g. `PATCH /trackables/:id/update_sheet` —
  in-place edits without leaving the sheet view.
- A `core_skill` re-add route: `GET /skills/new/:skill_type` → `skills#new_core_skill`,
  used to re-introduce a deleted core skill.

The three entity tiers (resident, stock, proprietary) each mount the concern
under their own scope:

```ruby
scope '/resident/' do
  resources :resident_characters, path: :characters, concerns: [:entity_core, :profile, :sheet, :card, :notes]
  resources :resident_creatures,  path: :creatures,  concerns: [...]
  resources :resident_npcs,       path: :npcs,       concerns: [...]
end

scope '/stock/'       do ... end
scope '/proprietary/' do ... end
```

The tiered concern set differs slightly — `:notes` is only mounted on the
resident scope, because notes are a private affordance for the owner.

Controllers follow the same `set_type` + `@type.constantize` pattern as the
rulebuilder engine — see the [`rulebuilder` README](../rulebuilder/README.md#routing-and-controllers).

---

## Adding default content for a new system

Walk through this in order when authoring the `entitybuilder` block for a new
system's JSON file:

1. **Decide on a sheet layout**.
   - Use `"sheet": "default"` if your system fits a d20-shaped sheet
     (ability scores, defenses, attacks, skills).
   - Use `"sheet": "fate"` if it's narrative / aspect-based.
   - Anything else requires a new ERB layout (see [Customising](#customising-per-system)).
2. **Pick a menu order**. List every section you want visible, in display
   order. Each `link` must match a sub-model association name. Set
   `add_modifiers: "true"` for sections whose rows should support per-row
   modifiers.
3. **Define your skill list** in `core_skills[]`. Reference ability-score names
   that you intend to define under `character.ability_scores` (or leave
   `ability_score: ""` if your system doesn't bind skills to attributes).
4. **Fill in `character`**. The keys you provide become the entity's seeded
   rows. Use the existing systems as templates. Remember:
   - Every key must match a `has_many` on `Entitybuilder::Entity`.
   - Every field inside a row must match a column on the corresponding sub-model.
   - String values are stored as strings even when the column is integer;
     ActiveRecord coerces on assign.
5. **Fill in `creature`** (or leave it `{}` for Fate-style systems). NPCs and
   creatures inherit this block. Often a stripped-down version of `character`.
6. **Restart the app** (JSON is loaded once at boot).
7. **Smoke-test** by creating a `ResidentCharacter` with the new
   `core_rules` name in `rails console`. Inspect the seeded children:

   ```ruby
   c = Entitybuilder::ResidentCharacter.create!(
     resident: Resident.first,
     core_rules: "MySystem",
     name: "Smoketest"
   )
   c.ability_scores.pluck(:name)   # should match your JSON
   c.skills.pluck(:name)           # core_skills (or character.skills if defined)
   c.trackables.pluck(:name)
   c.linked_rules.pluck(:detail)   # any seeded aspects/traits
   ```

---

## Customising per system

You can keep almost any system inside JSON. Reach for code only when:

| Need                                    | What to add                                                                 |
| --------------------------------------- | --------------------------------------------------------------------------- |
| A new sheet visual                      | New ERB layout file; reference it via `"sheet": "<name>"` in JSON.          |
| System-specific validation on a sheet (e.g. "Fate characters must have a High Concept aspect") | Subclass `ResidentCharacter` (or wrap the validation in a concern toggled on by `core_rules`). |
| A new sub-model type (e.g. "Tag")       | Migration + model + `has_many` on `Entity` + controller + routes concern entry + JSON support. |
| A new calculation                       | Method on the relevant sub-model. `Skill#calculated_bonus` is the model.    |
| Per-system menu items that don't map to a sub-model | Don't — the menu's `link` is fed straight into URL paths. Add the sub-model or extend the controller. |

When subclassing the STI tree (e.g. `MySystemCharacter < ResidentCharacter`),
remember:

- `add_defaults` keys off the entity's `core_rules` string, not the class.
  The same JSON drives every STI variant of `Resident*`.
- If you want different defaults per subclass, branch in the JSON via a
  different system name (e.g. ship `"Fate Core - Solo"` as a sibling system
  rather than as a subclass).

---

## Gotchas

- **The same string-not-FK constraint as rulebuilder.** `core_rules` on
  `entitybuilder_entities` is a plain string. Validation is application-side
  only. Bulk inserts that bypass validation will not be checked.

- **Defaults are seeded once, at create time.** Editing a system's JSON does
  not backfill into existing entities. If you add a new trackable to 4e
  tomorrow, only new 4e characters get it. Existing characters need a manual
  add or a data migration.

- **JSON keys are association names.** `character.foo` will crash at
  `entity.send(:foo).new` if there is no `has_many :foo` on `Entitybuilder::Entity`.
  Stick to the documented keys until you've extended the engine.

- **JSON field names are column names.** Misspelling a field name doesn't
  raise — the misspelled value lands on a non-existent attribute and is
  discarded silently when `save(:validate => false)` runs. Always smoke-test
  after editing JSON.

- **String fields stand in for foreign keys.** A skill's `ability_score`,
  a defense's `ability_score`, a saving throw's `ability_score`, and a
  movement's `ability_score` are all matched by **string equality** against
  ability-score names. Typos silently break the calculation
  (`skill.rb:31-32`: `unless ability_score.nil?`).

- **`saving_throws[]` and `skills[]` are optional but interact.** If
  `character.skills` is empty, `add_core_skills` falls back to `core_skills`
  (`lib/core_rules/entity.rb:82`). If both are present, the character block
  wins and core skills are not seeded — only available via the "add core skill"
  affordance later.

- **`linked_rules[]` is the only block that creates rules.** Defaults for
  abilities/feats normally do not live in the system JSON. If a system wants
  every character to start with specific abilities or feats, use
  `linked_rules` — the `add_linked_rules` loader (`lib/core_rules/entity.rb:89-112`)
  creates both the `Rulebuilder::Rule` row and the `Entitybuilder::LinkedRule`
  join.

- **`linked_rules`-created rules are private to the character.** They're
  saved with `is_shared: false` and `destroy_rule` on `LinkedRule` cleans them
  up when the link is destroyed. Don't try to share them — use the
  rulebuilder UI to create shared rules instead.

- **`use_modifiers: "false"` doesn't drop the modifiers table or column.** It
  just hides the per-row Modifiers panel. Modifiers can still be created
  programmatically; the UI just doesn't surface them.

- **Two more unused tables.** `entitybuilder_known_abilities` and
  `entitybuilder_known_feats` (`db/schema.rb:368-388`) exist but have no models
  in code (parallel to the unused `rulebuilder_abilities` / `rulebuilder_feats`).
  Abilities and feats are linked via `entitybuilder_linked_rules` to
  `rulebuilder_rules`. Do not start using these tables without a deliberate
  migration plan.

- **`creature: {}` is legal**. Fate Core sets it to empty. `default_types`
  returns `[]` and no defaults are seeded for NPCs/creatures. The sheet view
  handles the rest. This is the right move for systems where NPCs and creatures
  don't have a standard stat block.

- **Worlds (`worldbuilder_districts`) have no `core_rules`.** A world setting
  is reusable across systems. The system binding lives on the campaign, not
  the world.

- **Privacy defaults are hard-coded in `set_privacy`** (`entity.rb:184-187`):
  `privacy = 'Residents'`, `sheet_privacy = 'Private'` for new records. No way
  to override per system. If you want different defaults, change the model
  callback, not JSON.

---

## See also

- [`engines/rulebuilder/README.md`](../rulebuilder/README.md) — the
  catalogue half. Read it for the `core_rules` / `rule_type` validation
  contract and the JSON `rulebuilder` block.
- `lib/core_rules.rb` — the runtime registry that loads JSON at boot.
- `lib/core_rules/entity.rb` — the `add_defaults`, `add_linked_rules`,
  and `add_core_skills` loaders this engine relies on.
- `config/core_rules/4th-edition.json`, `pfrpg.json`, `fate-core.json` —
  read alongside this document for grounded examples of every block.
