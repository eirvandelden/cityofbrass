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
| `<cr>`          | Descriptor         | `name="Challenge Rating"`, `description` | Stored as string | ✅ |
| `<source>`      | Entity             | `source`                                 | | ✅ |
| `<description>` | Entity             | `full_description`                       | | ⚠️ |
| `<environment>` | Descriptor         | `name="Environment"`, `description`      | Extracted and stored | ✅ |

### 1.2 Defences

| XML field          | Native model | Native field(s)                   | Notes | Status |
|--------------------|--------------|-----------------------------------|-------|--------|
| `<ac>`             | Defense      | `name="Armor Class"`, `base`      | Integer part; source in parentheses stored in `description` | ✅ |
| `<hp>`             | Trackable    | `name="Hit Points"`, `maximum`    | Integer part; formula in parentheses stored in `description` | ✅ |
| `<resist>`         | Descriptor   | `name="Resistance"`, `description`| | ✅ |
| `<immune>`         | Descriptor   | `name="Immunity"`, `description`  | | ✅ |
| `<vulnerable>`     | Descriptor   | `name="Vulnerability"`, `description`| | ✅ |
| `<conditionImmune>`| Descriptor   | `name="Condition Immunity"`, `description`| | ✅ |

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
| `<save>`     | SavingThrow  | `name`, `bonus`, `proficient=true`      | Parsed from `"Dex +5, Con +15"` | ✅ |
| `<skill>`    | Skill        | `name`, `bonus`                         | Parsed from `"Perception +14"` | ✅ |
| `<passive>`  | Descriptor   | `name="Passive Perception"`, `description` | Stored as descriptor on character | ✅ |
| `<senses>`   | Descriptor   | `name="Senses"`, `description`          | | ✅ |
| `<languages>`| Descriptor   | `name="Languages"`, `description`       | | ✅ |

### 1.6 Spellcasting

| XML field       | Native model | Native field(s)                     | Notes | Status |
|-----------------|--------------|-------------------------------------|-------|--------|
| `<spellAbility>`| CasterLevel  | `ability_score`                     | | ⚠️ |
| `<spells>`      | KnownSpell   | `spell_id` (lookup by name)         | Comma-separated; lookup may fail if spell not in system | ⚠️ |
| `<slots>`       | CasterLevel  | `per_day` per level                 | SlotString parsed per level | ⚠️ |

### 1.7 Traits

Each `<trait>` maps to a `Rulebuilder::ResidentRule` (or `StockRule`) with
`rule_type = "Ability"`, which is then linked to the creature via
`Entitybuilder::LinkedRule`.

| XML field        | Native model   | Native field(s)              | Notes | Status |
|------------------|----------------|------------------------------|-------|--------|
| `<trait><name>`  | Rule           | `name`                       | | ✅ |
| `<trait><text>`  | Rule           | `full_description`           | All `<text>` elements joined | ✅ |
| `<trait><recharge>`| Rule         | `full_description` (appended)| Cosmetic; not parsed as a mechanic | ⚠️ |
| `<trait><attack>`| Attack         | see §1.8                     | Optional | ✅ |

### 1.8 Actions, reactions, legendary actions

All three element types (`<action>`, `<reaction>`, `<legendary>`) share the same
mapping. Whether a `<name>` + `<text>` entry produces an Attack, a Rule, or both
depends on whether attack notation is present.

#### With attack notation

| XML field          | Native model | Native field(s)          | Notes | Status |
|--------------------|--------------|--------------------------|-------|--------|
| `<name>`           | Attack       | `name`                   | Truncated to 64 chars | ✅ |
| `<text>`           | Attack       | `description`            | Truncated to 6,000 chars | ✅ |
| attack `HitBonus`  | Attack       | `attack_bonus`           | Integer parsed from notation | ✅ |
| attack `DamageDice`| Attack       | `damage_dice`, `damage_bonus` | Regex parsed from notation | ✅ |
| `<text>` content   | Attack       | `attack_type`            | "melee"/"ranged" inferred from text | ✅ |

#### Without attack notation

| XML field  | Native model | Native field(s)   | Notes | Status |
|------------|--------------|-------------------|-------|--------|
| `<name>`   | Rule         | `name`            | `rule_type = "Ability"` | ✅ |
| `<text>`   | Rule         | `full_description`| | ✅ |

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
| `<modifier>` | —                   | No modifier association on items; not stored | ❌ |

### 2.1 Item type code → category

| XML `<type>` | Item `category`   |
|--------------|-------------------|
| `LA`         | `"light armor"`   |
| `MA`         | `"medium armor"`  |
| `HA`         | `"heavy armor"`   |
| `S`          | `"weapon"`        |
| `M`          | `"weapon"`        |
| `R`          | `"weapon"`        |
| `A`          | `"gear"`          |
| `P`          | `"potion"`        |
| `RD`         | `"wondrous"`      |
| `SC`         | `"scroll"`        |
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
| `<components>`  | `components`        | V/S/M assembled with materials | ✅ |
| `<duration>`    | `duration`          | | ✅ |
| `<text>`        | `full_description`  | All `<text>` elements joined | ✅ |
| `<ritual>`      | `tags`              | `"ritual"` tag added when `YES` | ✅ |
| `<roll>`        | —                   | Not stored | ❌ |
| `<source>`      | `source`            | | ✅ |

---

## 4. Rules (Feat, Race, Class, Background, Subclass)

All four XML types map to `Rulebuilder::ResidentRule` (or `StockRule`), distinguished
by `rule_type`.

| XML element    | Rule `rule_type`  | Status |
|----------------|-------------------|--------|
| `<feat>`       | `"Feat"`          | ✅ |
| `<race>`       | `"Species"`       | ✅ |
| `<class>`      | `"Class"`         | ✅ |
| `<background>` | `"Background"`    | ✅ |
| `<subclass>`   | `"Subclass"`      | ✅ |

### 4.1 Shared field mapping (all rule types)

| XML field          | Native field        | Notes | Status |
|--------------------|---------------------|-------|--------|
| `<name>`           | `name`              | Truncated to 64 chars | ✅ |
| `<prerequisite>`   | `prerequisites`     | Feats only | ✅ |
| `<text>` / trait `<text>` | `full_description` | All text concatenated | ✅ |
| `<source>`         | `source`            | | ✅ |
| `<modifier>`       | —                   | Not stored | ❌ |
| `<ability>`        | `full_description`  | Race ability bonuses prepended to description | ✅ |
| `<proficiency>`    | `full_description`  | Race/background proficiencies prepended to description | ✅ |
| `<autolevel>`      | —                   | Class level features not individually stored | ⚠️ |

### 4.2 Class — autolevel detail

`<autolevel>` blocks are serialised into the rule's `full_description` (formatted
as text). Individual `<feature>` entries are not stored as distinct records.
`<slots>`, `<counter>`, and `scoreImprovement` are not stored.

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
| `<text>`      | `full_description`  | Overview text | ⚠️ |
| (privacy)     | `privacy`           | Always `"Private"` | ✅ |
| (core_rules)  | `core_rules`        | Always `"dnd5e"` | ✅ |
| `<npc>`       | Notable             | NPCs linked to campaign, not adventure | ⚠️ |

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

Player characters from `<pc>` / `<characters>` files or embedded `<pc>` elements
within a campaign.

| XML field          | Native field / model    | Notes | Status |
|--------------------|-------------------------|-------|--------|
| `<name>` / `<label>` | Entity `name`         | label used as fallback | ✅ |
| `<str>` … `<cha>`  | AbilityScore records    | | ✅ |
| `<abilities>`      | AbilityScore records    | Comma-separated alternative | ✅ |
| `<class><name>`    | ClassLevel `name`       | | ✅ |
| `<class><level>`   | ClassLevel `level`      | | ✅ |
| `<action>`         | Attack                  | Same mapping as monster action (§1.8) | ✅ |
| `<hpMax>`          | Trackable `maximum`     | `name="Hit Points"` | ⚠️ |
| `<ac>`             | Defense `base`          | `name="Armor Class"` | ⚠️ |
| `<spells>`         | KnownSpell              | Lookup by name | ⚠️ |
| `<race><name>`     | Descriptor              | `name="Race"` | ⚠️ |
| `<class><hd>`      | ClassLevel `hit_dice`   | | ⚠️ |
| `<slots>`          | CasterLevel             | | ⚠️ |
| `<passive>`        | —                       | Not stored | ❌ |
| `<armor>`          | —                       | Equipped armor name not stored | ❌ |

---

## 10. NPC → Entitybuilder::ResidentNpc

NPCs declared at campaign or adventure level.

| XML field  | Native field  | Notes | Status |
|------------|---------------|-------|--------|
| `<name>` / `<label>` | Entity `name` | label used as fallback | ✅ |

NPC stat blocks (when inline in `<data>` files) are not currently imported —
only the name is used to create a minimal NPC record.

---

## 11. Remaining gaps

Fields present in the XML format with no complete native mapping. All other
gaps from the original list have been resolved.

| XML element / field       | Reason |
|---------------------------|--------|
| `<item><modifier>`        | No modifier association on items; would require a join table |
| `<spell><roll>`           | Dice roll expressions not stored; no native field |
| `<class><autolevel>`      | Level features serialised to text only; not stored as discrete records |
| `<class><slots>`          | Class slot progression not stored |
| `<class><counter>`        | Resource counters not stored |
| `<monster><spells>`       | Spell lookup by name; fragile if spell not yet in system |
| `<monster><slots>`        | Caster level slot tracking incomplete |
| `<npc>` inline stat block | Only name/size/type/alignment/AC/HP imported from inline `<data>` NPCs |
| `<pc><armor>`             | Equipped armor name not stored; no inventory lookup |
