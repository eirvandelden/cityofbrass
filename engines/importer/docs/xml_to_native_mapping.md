# FightClub5 XML → City of Brass Mapping

This document defines how every element of the FightClub5/GameMaster5 XML
format maps to a native City of Brass object. For the XML type definitions, see
`fightclub5_xml_format.md` and the XSD files in this directory.

**Implementation status legend:**

| Symbol | Meaning |
|--------|---------|
| ✅ | Implemented in the current importer |
| ⚠️ | Partially implemented or mapped with loss |
| ❌ | Not yet implemented |

---

## 1. Monster → Entitybuilder::Creature

A `<monster>` in a compendium maps to a `Entitybuilder::ResidentCreature` (resident
import) or `Entitybuilder::StockCreature` (admin stock import). All sub-records
belong to the same entity via `entity_id`.

### 1.1 Identity & classification

| XML field       | Native model       | Native field(s)                          | Notes | Status |
|-----------------|--------------------|------------------------------------------|-------|--------|
| `<name>`        | Entity             | `name`                                   | Truncated to 64 chars | ✅ |
| `<size>`        | Descriptor         | `name="Size"`, `description`             | Code decoded: T→Tiny, S→Small, M→Medium, L→Large, H→Huge, G→Gargantuan | ✅ |
| `<type>`        | Descriptor         | `name="Type"`, `description`             | Free text | ✅ |
| `<alignment>`   | Descriptor         | `name="Alignment"`, `description`        | Free text | ✅ |
| `<cr>`          | Descriptor + Entity | Descriptor `name="Challenge Rating"`; also Entity `short_description` | Stored as string | ✅ |
| `<source>`      | Entity             | `source`                                 | | ✅ |
| `<description>` | Entity             | `full_description`                       | | ✅ |
| `<environment>` | Descriptor         | `name="Environment"`, `description`      | Extracted and stored | ✅ |

### 1.2 Defences

| XML field          | Native model | Native field(s)                   | Notes | Status |
|--------------------|--------------|-----------------------------------|-------|--------|
| `<ac>`             | Defense      | `name="Armor Class"`, `base`, `description` | Leading integer → `base`; text in parentheses (e.g. `natural armor`) → `description` | ✅ |
| `<hp>`             | Trackable    | `name="Hit Points"`, `maximum`, `current`, `description` | Leading integer → `maximum`/`current`; dice formula in parentheses (e.g. `7d10+21`) → `description`. Falls back to `<hpMax>` | ✅ |
| `<resist>`         | Descriptor   | `name="Resistances"`, `description`| | ✅ |
| `<immune>`         | Descriptor   | `name="Immunities"`, `description`  | | ✅ |
| `<vulnerable>`     | Descriptor   | `name="Vulnerabilities"`, `description`| | ✅ |
| `<conditionImmune>`| Descriptor   | `name="Condition Immunities"`, `description`| | ✅ |

### 1.3 Speed

Each movement type parsed from the free-text `<speed>` value maps to a separate
`Movement` record.

| XML value example          | Movement `name`  | Movement `base` | Status |
|----------------------------|------------------|-----------------|--------|
| `"40 ft."`                 | `"Speed"`        | `40`            | ✅ |
| `"fly 80 ft."`             | `"Fly Speed"`    | `80`            | ✅ |
| `"swim 30 ft."`            | `"Swim Speed"`   | `30`            | ✅ |
| `"climb 30 ft."`           | `"Climb Speed"`  | `30`            | ✅ |
| `"burrow 30 ft."`          | `"Burrow Speed"` | `30`            | ✅ |

### 1.4 Ability scores

Both formats (`<str>` … `<cha>` individually, and `<abilities>` comma-separated)
are supported.

| XML field    | AbilityScore `name` | AbilityScore `base` | Status |
|--------------|---------------------|---------------------|--------|
| `<str>`      | `"Strength"`        | integer value       | ✅ |
| `<dex>`      | `"Dexterity"`       | integer value       | ✅ |
| `<con>`      | `"Constitution"`    | integer value       | ✅ |
| `<int>`      | `"Intelligence"`    | integer value       | ✅ |
| `<wis>`      | `"Wisdom"`          | integer value       | ✅ |
| `<cha>`      | `"Charisma"`        | integer value       | ✅ |

### 1.5 Skills & senses

| XML field    | Native model | Native field(s)                         | Notes | Status |
|--------------|--------------|-----------------------------------------|-------|--------|
| `<save>`     | SavingThrow  | `name`, `base`                          | Parsed from `"Dex +5"`; a single comma-separated element (`"Dex +5, Con +15"`) is split into one record per entry | ✅ |
| `<skill>`    | Skill        | `name`, `bonus`                         | Parsed from `"Perception +14"`; comma-separated single element split per entry | ✅ |
| `<passive>`  | Descriptor   | `name="Passive Perception"`, `description` | Integer value e.g. `"14"` | ✅ |
| `<senses>`   | Descriptor   | `name="Senses"`, `description`          | | ✅ |
| `<languages>`| Descriptor   | `name="Languages"`, `description`       | | ✅ |

### 1.6 Spellcasting

| XML field       | Native model | Native field(s)                     | Notes | Status |
|-----------------|--------------|-------------------------------------|-------|--------|
| `<spellAbility>`| Descriptor   | `name="Spellcasting Ability"`, `description` | | ✅ |
| `<spells>`      | KnownSpell + Descriptor | `spell_id` (lookup by name); also a `name="Spells"` Descriptor holding the raw list | Spells not yet in the system are skipped for KnownSpell but still appear in the descriptor | ✅ |
| `<slots>`       | Trackable    | `name="Cantrips"` (level 0) / `"Spell Slots (Nth)"`, `maximum`, `current` | One Trackable per non-zero slot level | ✅ |

### 1.7 Traits

Each `<trait>` maps to a `Rulebuilder::ResidentRule` (or `StockRule`) with
`rule_type = "Ability"`, which is then linked to the creature via
`Entitybuilder::LinkedRule`.

| XML field        | Native model   | Native field(s)              | Notes | Status |
|------------------|----------------|------------------------------|-------|--------|
| `<trait><name>`  | Rule           | `name`                       | Blank names get a unique `No Name N` placeholder | ✅ |
| `<trait><text>`  | Rule           | `full_description`           | First `<text>` element | ✅ |
| `<trait><recharge>`| Rule         | `full_description` (appended)| Appended as a `Recharge: …` line | ✅ |
| `<trait><attack>`| Rule           | `full_description` (appended)| Appended as an `Attack: name\|+atk\|dmg` line | ✅ |

### 1.8 Actions, reactions, legendary actions

All three element types (`<action>`, `<reaction>`, `<legendary>`) share the same
mapping: **every entry with a name becomes an `Attack`** (there is no Rule
fallback). Attack notation, when present, populates the numeric fields; when
absent those fields are simply left blank.

| XML field          | Native model | Native field(s)          | Notes | Status |
|--------------------|--------------|--------------------------|-------|--------|
| `<name>`           | Attack       | `name`                   | Truncated to 64 chars; blank names get a `No Name N` placeholder | ✅ |
| `<text>`           | Attack       | `description`            | Stored in full (not truncated) | ✅ |
| attack `HitBonus`  | Attack       | `attack_bonus`           | Integer parsed from notation when present | ✅ |
| attack `DamageDice`| Attack       | `damage_dice`, `damage_bonus` | Regex parsed from notation when present | ✅ |
| `<text>` content   | Attack       | `attack_type`            | "melee"/"ranged" inferred from text, default "melee" | ✅ |

---

## 2. Item → Rulebuilder::Item

| XML field    | Native field        | Notes | Status |
|--------------|---------------------|-------|--------|
| `<name>`     | `name`              | Truncated to 64 chars | ✅ |
| `<type>`     | `category`          | Code decoded via mapping below | ✅ |
| `<text>`     | `full_description`  | Stats block prepended, then text | ✅ |
| `<source>`   | `source`            | | ✅ |
| `<weight>`   | `weight`            | Stored as decimal | ✅ |
| `<magic>`    | `full_description`  | Included in stats block | ✅ |
| `<dmg1>`     | `full_description`  | Included in stats block | ✅ |
| `<dmg2>`     | `full_description`  | Included in stats block | ✅ |
| `<dmgType>`  | `full_description`  | Included in stats block | ✅ |
| `<property>` | `full_description`  | Included in stats block | ✅ |
| `<range>`    | `full_description`  | Included in stats block | ✅ |
| `<ac>`       | `full_description`  | Included in stats block | ✅ |
| `<strength>` | `full_description`  | Included in stats block | ✅ |
| `<stealth>`  | `full_description`  | Included in stats block | ✅ |
| `<detail>`   | `full_description`  | Rarity/attunement, included in stats block as **Rarity** | ✅ |
| `<value>`    | `full_description`  | Cost, included in stats block as **Value** | ✅ |
| `<itemtemplate>` | (parsed as item) | Template items (e.g. `Silvered %name%`) imported as regular items | ✅ |
| `<modifier>` | —                   | No modifier association on items; not stored | ❌ |

### 2.1 Item type code → category

| XML `<type>` | Item `category`   |
|--------------|-------------------|
| `LA`         | `"armor"`         |
| `MA`         | `"armor"`         |
| `HA`         | `"armor"`         |
| `S`          | `"armor"`         |
| `M`          | `"weapon"`        |
| `R`          | `"weapon"`        |
| `A`          | `"gear"`          |
| `P`          | `"potion"`        |
| `RD`         | `"wondrous"`      |
| `SC`         | `"wondrous"`      |
| `ST`         | `"wondrous"`      |
| `W`          | `"wondrous"`      |
| `WD`         | `"wondrous"`      |
| `RG`         | `"wondrous"`      |
| `G`          | `"gear"`          |
| `$`          | `"gear"`          |
| (absent)     | `nil`             |

---

## 3. Spell → Rulebuilder::Spell

| XML field       | Native field        | Notes | Status |
|-----------------|---------------------|-------|--------|
| `<name>`        | `name`              | Truncated to 64 chars | ✅ |
| `<level>` + `<classes>` | `levels`   | Combined into JSON array: `["Wizard 3", "Sorcerer 3"]` | ✅ |
| `<school>`      | `school`            | Code decoded: EV→Evocation, N→Necromancy, etc. | ✅ |
| `<time>`        | `casting_time`      | | ✅ |
| `<range>`       | `range`             | | ✅ |
| `<components>`  | `components`        | Stored verbatim from the `<components>` text (e.g. `V, S, M (a pinch of sulfur)`); falls back to assembling from `<v>`/`<s>`/`<m>` sub-elements. Column widened to `text` so long material lists are kept in full | ✅ |
| `<duration>`    | `duration`          | | ✅ |
| `<text>`        | `full_description`  | All `<text>` elements joined | ✅ |
| `<ritual>`      | `tags`              | `"ritual"` tag added when `YES` | ✅ |
| `<roll>`        | —                   | Not stored | ❌ |
| `<source>`      | `source`            | | ✅ |

---

## 4. Rules (Feat, Race, Class, Background, Subclass)

All five XML types map to `Rulebuilder::ResidentRule` (or `StockRule`), distinguished
by `rule_type`.

| XML element    | Rule `rule_type`  | Status |
|----------------|-------------------|--------|
| `<feat>`       | `"Feat"`          | ✅ |
| `<race>`       | `"Species"`       | ✅ |
| `<baseclass>` / `<class>` | `"Class"` | Both element spellings are parsed | ✅ |
| `<background>` | `"Backgrounds"`   | ✅ |
| `<subclass>`   | `"Subclass"`      | ✅ |

### 4.1 Shared field mapping (all rule types)

| XML field          | Native field        | Notes | Status |
|--------------------|---------------------|-------|--------|
| `<name>`           | `name`              | Truncated to 64 chars; blank names get a `No Name N` placeholder | ✅ |
| `<prerequisite>`   | `prerequisites`     | Feats only | ✅ |
| `<text>` / trait `<text>` | `full_description` | All text concatenated | ✅ |
| `<source>`         | `source`            | | ✅ |
| `<modifier>`       | —                   | Not stored | ❌ |
| `<ability>`        | `full_description`  | Race ability bonuses prepended to description | ✅ |
| `<proficiency>`    | `full_description`  | Race/background proficiencies prepended to description | ✅ |
| `<armor>` / `<weapons>` / `<tools>` | `full_description` | Class proficiencies appended to description | ✅ |
| `<hd>` / `<numSkills>` | —               | Class hit die and skill count not stored | ❌ |
| `<autolevel>`      | —                   | Not extracted or stored (see §4.2) | ❌ |

### 4.2 Class — autolevel detail

`<autolevel>` blocks are **not** parsed at all — only the class's top-level
`<text>`, `<proficiency>`, `<armor>`, `<weapons>`, and `<tools>` are read. Level
features, `<slots>`, `<counter>`, and `scoreImprovement` are not stored.

---

## 5. Campaign → Campaignmanager::Campaign

| XML field   | Native field   | Notes | Status |
|-------------|----------------|-------|--------|
| `<name>`    | `name`         | | ✅ |
| (privacy)   | `privacy`      | Always `"Private"` on import | ✅ |
| (core_rules)| `core_rules`   | Always `"dnd5e"` on import | ✅ |

---

## 6. Adventure → Storybuilder::ResidentAdventure

Each `<adventure>` element within a campaign maps to one `ResidentAdventure`.
The adventure is linked to the campaign via `CampaignAdventureJoin`.

| XML field     | Native field        | Notes | Status |
|---------------|---------------------|-------|--------|
| `<name>`      | `name`              | | ✅ |
| `<text>`      | `full_description`  | Overview text | ✅ |
| (privacy)     | `privacy`           | Always `"Private"` | ✅ |
| (core_rules)  | `core_rules`        | Always `"dnd5e"` | ✅ |
| `<npc>`       | Notable             | NPCs linked to the adventure via `Storybuilder::Notable` | ✅ |

---

## 7. Encounter → Storybuilder::Page

Each `<encounter>` within an adventure (or at campaign level) maps to one
`Storybuilder::Page` belonging to the parent adventure.

| XML field              | Native field        | Notes | Status |
|------------------------|---------------------|-------|--------|
| `<name>`               | Page `name`         | | ✅ |
| `<text>` (all depths)  | Page `full_description` | Direct `<text>` + `.//note/text` joined | ✅ |
| `<combatant><monster>` | Notable             | Creature looked up by name, linked via `Storybuilder::Notable` | ✅ |
| (privacy)              | Page `privacy`      | Always `"Private"` | ✅ |

---

## 8. Note → Storybuilder::Page

Each `<note>` within an adventure (or at campaign level) maps to one
`Storybuilder::Page`. Each `<text>` block within the note becomes a separate
`Section` on the page (preserving paragraph structure).

| XML field    | Native field             | Notes | Status |
|--------------|--------------------------|-------|--------|
| `<title>`    | Page `name`              | | ✅ |
| `<text>` (each) | Section `content`     | One Section per non-blank `<text>` element; `section_type="text"`, `section_style="paragraph"` | ✅ |
| (privacy)    | Page `privacy`           | Always `"Private"` | ✅ |

---

## 9. PC → Entitybuilder::ResidentCharacter

Player characters come in two shapes:

1. **FightClub flat `<pc>`** — fields directly on the `<pc>` node (also used for
   `<pc>` children of a `<characters>` file and embedded `<pc>` in a campaign).
2. **GM5-native `<pc><character>`** — the stat block is wrapped in a
   `<character>` element, with abilities as a CSV and class/race nested. The
   parser unwraps `<character>` transparently, so both shapes map identically.

| XML field          | Native field / model    | Notes | Status |
|--------------------|-------------------------|-------|--------|
| `<name>` / `<label>` | Entity `name`         | label used as fallback | ✅ |
| `<str>` … `<cha>`  | AbilityScore records    | | ✅ |
| `<abilities>`      | AbilityScore records    | Comma-separated alternative (`"10,15,12,…"`); used by GM5 `<character>` files | ✅ |
| `<class><name>`    | ClassLevel `name`       | Falls back to the class parsed from the `<name>` string | ✅ |
| `<class><level>`   | ClassLevel `level`      | | ✅ |
| `<action>`         | Attack                  | Same mapping as monster action (§1.8) | ✅ |
| `<hpMax>`          | Trackable `maximum`     | `name="Hit Points"` — also tries `<hp>` | ✅ |
| `<ac>`             | Defense `base`          | `name="Armor Class"` | ✅ |
| `<spells>`         | KnownSpell              | Lookup by name; unknown spells skipped | ✅ |
| `<race><name>`     | Descriptor              | `name="Race"`; falls back to the race parsed from the `<name>` string (e.g. `"Elf (Wood)"`) | ✅ |
| `<senses>`         | Descriptor              | `name="Senses"` | ✅ |
| `<languages>`      | Descriptor              | `name="Languages"` | ✅ |
| `<save>` / `<skill>` | SavingThrow / Skill   | Parsed `"Name +N"`; comma-separated single element split per entry | ✅ |
| `<class><hd>` + `<class><hdCurrent>` | Trackable | `name="Hit Dice (1d10)"`, max=level, current=hdCurrent | ✅ |
| `<slots>`          | Trackable               | One Trackable per non-zero slot level | ✅ |
| `<passive>`        | Descriptor              | `name="Passive Perception"` | ✅ |
| `<armor>`          | InventoryItem / Descriptor | Item looked up by name, `equipped: true`; falls back to Descriptor | ✅ |
| GM5 `<race><feat>` / `<class>` feature text | — | Nested racial/class feature & feat text not imported | ❌ |
| GM5 inventory `<item>` list | — | Item lists inside a `<character>` are not added to inventory | ❌ |

---

## 10. NPC → Entitybuilder::ResidentNpc

NPCs declared at campaign or adventure level (`<npc>` elements).

| XML field            | Native field / model | Notes | Status |
|----------------------|----------------------|-------|--------|
| `<name>` / `<label>` | Entity `name`        | label used as fallback; blank gets a `No Name N` placeholder | ✅ |
| `<description>`      | Entity `full_description` | | ✅ |
| `<source>`           | Entity `source`      | | ✅ |
| `<size>`             | Descriptor `name="Size"` | Raw code, **not** decoded to a word | ⚠️ |
| `<type>`             | Descriptor `name="Type"` | | ✅ |
| `<alignment>`        | Descriptor `name="Alignment"` | | ✅ |
| `<ac>`               | Defense `name="Armor Class"`, `base`, `description` | Leading integer; parenthetical note → `description` | ✅ |
| `<hp>`               | Trackable `name="Hit Points"`, `maximum`, `current`, `description` | Leading integer; formula note → `description` | ✅ |
| `<cr>`               | —                    | Not stored for NPCs | ❌ |

NPC `<action>`, `<trait>`, and ability scores are not imported. Full inline
monster stat blocks inside `<combatant>` elements of `<data>` campaign files are
imported separately as **creatures** (see §11.8), not as NPCs.

---

## 11. Remaining gaps

The gaps below are either unimplemented or only partially stored. Each entry
describes what full support would require and what alternatives exist short of
a model migration.

---

### 11.1 `<item><modifier>` — magical item bonuses

**What it is:** `<modifier category="bonus">attack roll +1</modifier>` — a
mechanical bonus granted by a magic item (attack rolls, damage, AC, ability
scores, etc.).

**To import fully:** `Entitybuilder::Modifier` exists but is scoped to entities,
not to `Rulebuilder::Item`. Proper support would require either (a) a new
polymorphic join so `Modifier` can belong to an `Item`, or (b) a new
`rulebuilder_item_modifiers` table. Migration + model change required.

**Alternatives:**
- Parse modifier text and include it in `full_description` (e.g. "+1 to attack
  rolls") — visible in the UI, not machine-readable.
- Store as a `tags` entry (e.g. `["bonus:attack_roll:+1"]`) for rough
  searchability without a schema change.

---

### 11.2 `<spell><roll>` — dice expressions for the dice roller

**What it is:** `<roll description="Damage">8d6</roll>` — one or more labelled
dice expressions the app exposes as tappable dice rolls.

**To import fully:** `Rulebuilder::Spell` has no `rolls` column. A JSON column
(e.g. `rolls: [{label: "Damage", expression: "8d6"}]`) would be enough — no
join table needed. Requires a migration adding the column, then extracting
`<roll>` nodes in `spell_record` and storing them in `import_spell`.

**Alternatives:**
- Parse roll expressions out of the description text and include them inline
  (e.g. append "Damage: 8d6" lines to `full_description`). Already partially
  true since the description text usually mentions the dice; this just makes the
  linkage explicit.

---

### 11.3 `<class><autolevel>` — level features as discrete records

**What it is:** Individual class features granted at each level (e.g.
`<autolevel level="5"><feature><name>Extra Attack</name>…</feature></autolevel>`).

**Current state:** All features are concatenated into `full_description` as
formatted text. No individual `Feature` records are created.

**To import fully:** A `class_features` table linked to `Rulebuilder::Rule`
with `level`, `name`, `description` columns would be needed. This is significant
work — effectively a new sub-entity model for class progression.

**Alternatives:**
- Keep serialising to `full_description` but improve formatting (e.g. use
  Markdown headers per level). The content is readable; it is just not
  machine-queryable.
- Store as `Storybuilder::Section` records on the rule's page if the class rule
  has an associated page — this reuses an existing polymorphic content model.

---

### 11.4 `<class><slots>` — spell slot progression table

**What it is:** `<autolevel level="5"><slots>0,4,3,2,0,0,0,0,0,0</slots></autolevel>`
— the number of spell slots a class has at each level across all nine spell levels.

**To import fully:** No native model stores class-level slot progression.
A JSON column on `Rulebuilder::Rule` (e.g. `slot_progression: {1 => [2], 2 =>
[3], …}`) would be the minimal change. Alternatively a `class_slot_levels` join
table with `level`, `slot_counts` (SlotString) columns.

**Alternatives:**
- Format the slot table as Markdown and append to `full_description`. Readable
  but not parseable.
- Store only the maximum slot string (from the highest `autolevel`) as a
  descriptor on the rule.

---

### 11.5 `<class><counter>` — limited-use resource counters

**What it is:** `<autolevel level="2"><counter><name>Channel Divinity</name>
<value>1</value></counter></autolevel>` — a named resource that resets per rest.

**To import fully:** No model for class-level counters. Would need a
`class_counters` table (level, name, value, reset) or a JSON column on the rule.
Entitybuilder has `Trackable` for tracking resources on a character, but that is
instance-level, not class-definition-level.

**Alternatives:**
- Include counter names and values in `full_description` formatted text.
- The `scoreImprovement` boolean attribute on `<autolevel>` could be stored
  as a simple annotation in the description (e.g. "Level 4: Ability Score
  Improvement") without a dedicated column.

---

### 11.6 `<monster><spells>` — spellcasting creature spell lists ✅ Implemented

`<spells>` is imported: a `name="Spells"` Descriptor holds the raw list and each
spell already in the system is linked via `KnownSpell`. `<spellAbility>` becomes
a `name="Spellcasting Ability"` Descriptor. See §1.6.

---

### 11.7 `<monster><slots>` — spell slot counts on creatures ✅ Implemented

One `Trackable` per non-zero slot level (`name="Cantrips"` for level 0,
`"Spell Slots (Nth)"` otherwise). See §1.6.

---

### 11.8 `<combatant>` inline monster stat block from `<data>` files ✅ Implemented

Inline `<monster>` blocks inside `<combatant>` elements are parsed through
`monster_record` / `import_monster`, so they import as full creatures (ability
scores, attacks, traits, descriptors, etc.) and are linked to the encounter page
via `Storybuilder::Notable`. (`<npc>` *elements* still import basic stats only —
see §10.)

---

### 11.9 `<pc><armor>` — equipped armor name ✅ Implemented

The armor name is looked up in the name index; if the item exists it becomes an
equipped `InventoryItem`, otherwise it is stored as a `name="Equipped Armor"`
Descriptor.

---

### 11.10 PC `<race>`, `<hd>`, `<slots>` ✅ Implemented

`<race><name>` (or the race parsed from the `<name>` string) →
`name="Race"` Descriptor; `<class><hd>` → `name="Hit Dice (…)"` Trackable;
`<slots>` → one `Trackable` per non-zero slot level; `<hpMax>` / `<ac>` via
`build_basic_stats`.

---

### Summary

| Gap | Effort | Schema change? |
|-----|--------|----------------|
| §11.1 `<item><modifier>` | High | Yes — new join table |
| §11.2 `<spell><roll>` | Low | Yes — add `rolls` JSON column to spells |
| §11.3 `<class>` features as records | High | Yes — new `class_features` table |
| §11.4 `<class><slots>` progression | Medium | Yes — JSON column or new table |
| §11.5 `<class><counter>` | Medium | Yes — JSON column or new table |
| ~~§11.6 `<monster><spells>`~~ | — | ✅ Fixed |
| ~~§11.7 `<monster><slots>`~~ | — | ✅ Fixed |
| ~~§11.8 `<combatant>` inline monster stat block~~ | — | ✅ Fixed |
| ~~§11.9 `<pc><armor>`~~ | — | ✅ Fixed |
| ~~§11.10 PC `<race>`, `<hd>`, `<slots>`~~ | — | ✅ Fixed |

---

## 12. Corpus verification (June 2026)

The importer was verified against **3,352 real-world XML files** from the
`DnDAppFiles`, `DnD-CampaignsAndAdventures`, and `FightClub5eXML` corpora. Every
supported file imports without crashes. The pass surfaced and fixed the
following beyond the §11 gaps:

### 12.1 Newly supported formats

| Format | What it is | Fix |
|--------|------------|-----|
| `<compendium><class>` | Modern FightClub/SRD-5.5e classes use a bare `<class>` element (older files used `<baseclass>`) | Parser now reads both `./baseclass` and `./class` (~429 files were importing zero records) |
| `<pc><character>` | GM5-native player-character export — stats wrapped in a `<character>` element, abilities as a CSV (`10,15,12,…`), class/race nested | Parser unwraps `<character>`; imports name, ability scores (CSV fallback), class+level, race, HP (~241 files were importing zero records) |
| `<compendium><itemtemplate>` | Template items such as `Silvered %name%` | Imported as regular items (~48 files were importing zero records) |

### 12.2 Newly fixed field drops

| Field | Was | Now |
|-------|-----|-----|
| `<monster><description>` | Never extracted → `full_description` always nil | Extracted and stored |
| `<monster><save>` / `<skill>` | Never built for creatures (only for PCs) | Built as SavingThrow / Skill records |
| `<monster><speed>` (fly/swim/climb/burrow) | Only the base speed was stored | One Movement per mode |
| `<pc><languages>` / `<senses>` | Extracted but never stored | Stored as Descriptors |
| `<pc>` race from name string | `"Elf (Wood) Monk 2"` race lost when no `<race>` element | Race descriptor created from the parsed name |
| `<feat><prerequisite>` | Extracted but never stored | Stored in `prerequisites` |
| `<class><armor>/<weapons>/<tools>` | Dropped | Appended to `full_description` |
| comma-separated `<save>`/`<skill>` | Mis-parsed into one garbled record | Split into one record per entry |

### 12.3 Import robustness (no data loss)

A single malformed entity used to abort the entire file. The importer now:

- **imports blank-name entities** (monsters, items, spells, rules, traits, PCs)
  under a unique `No Name N` placeholder — each nameless entry becomes its own
  record rather than being skipped or merged into one;
- **never truncates content.** The `length: { maximum: ... }` validations on every
  content field (`full_description`, `content`, `notes`, and the `description` on
  `Defense` / `Trackable` / `Attack`) were removed across the engines, and the
  importer's own hard truncations (attack descriptions to 6,000 chars) were
  dropped, so imported text is stored in full. The columns are already `text`
  (effectively unlimited), so no migration was required.
- **preserves AC source / HP formula:** the text in parentheses on `<ac>` and
  `<hp>` (e.g. `(natural armor)`, `(7d10+21)`) is stored in the Defense/Trackable
  `description` instead of being discarded; `<trait><recharge>` and
  `<trait><attack>` are appended to the trait rule description.
- **preserves spell components in full:** the `<components>` string is read
  verbatim (it was previously dropped because only `<v>`/`<s>`/`<m>` sub-elements
  were parsed), its 255-char validation was removed, and the `components` column
  was migrated from `string` to `text` so long material lists are not truncated.
- **dedupes pages by slug** (not just by name) so near-duplicate encounter
  titles that parameterize identically no longer collide;
- isolates each compendium/character record so one bad record never aborts the
  rest of the file.

### 12.4 Files that intentionally import nothing

| Root element | Count | Reason |
|--------------|------:|--------|
| `<source>` | ~420 | Manifest files: metadata + a `<collection>` of `<doc href>` references to other compendium files (no inline content) |
| `<collection>` | ~84 | XInclude aggregators referencing other files |
| `<notes>` | ~27 | Character/reference note documents — not a supported import format |
| empty `<compendium/>` | ~9 | Deprecated stubs with no child entities |

### 12.5 Remaining known gaps (unchanged scope)

- GM5 `<character>` nested racial/class **feature & feat text** is not imported
  (only name, abilities, class+level, race, HP). Equipped/inventory `<item>`
  lists inside GM5 characters are not added to inventory.
- Campaign-embedded `<pc>` records import name + backstory only; full stat
  blocks come from the standalone PC file via merge-by-label.
- Class `<autolevel>` features / slot progression / counters (§11.3–11.5),
  `<item><modifier>` (§11.1) and `<spell><roll>` (§11.2) remain as documented —
  each needs a schema change.
