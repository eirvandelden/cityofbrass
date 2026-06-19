# FightClub5 / GameMaster5 XML Format Reference

This document specifies the XML format used by the FightClub5 and GameMaster5
applications (iOS and Android) for D&D 5e content. It is derived from direct
examination of files in the wild and from community-maintained resources, and
serves as the authoritative reference for the City of Brass importer.

---

## Documentation status

There is **no official documentation** from Lion's Den (the app developer). The
developer has not published a specification, schema, or API. All format knowledge
is community-derived from template files, real XML examples, and
community-maintained repositories; contributor groups explicitly disclaim
developer affiliation.

The only community-produced formal schema is the XSD maintained by the
`kinkofer/FightClub5eXML` project at `Utilities/compendium.xsd`
([GitHub](https://github.com/kinkofer/FightClub5eXML)). It covers the
*compendium* format only (`<monster>`, `<item>`, `<spell>`, `<feat>`,
`<background>`, `<race>`, `<class>`). The `<campaign>`, `<data>`,
`<adventure>`, `<encounter>`, and `<note>` elements used by GameMaster5 are
not covered by any formal schema and must be inferred from real XML files.

Other useful community resources:
- `ceryliae/DnDAppFiles` — template examples; explicitly not affiliated with Lion's Den
- `donfarland.com` — style and convention guide for compendium contributors (last updated August 2023, CC BY-NC-SA 4.0)

---

## Cardinality notation

The field tables use the following cardinality column:

| Notation   | Meaning                              |
|------------|--------------------------------------|
| `required` | Exactly one; element must be present |
| `optional` | Zero or one (0..1)                   |
| `0..*`     | Zero or more; element may repeat     |

---

## 1. Document Types

A document is identified by its root element. Every root element accepts the
following optional attributes:

| Attribute     | Type    | Values       | Notes                              |
|---------------|---------|--------------|-------------------------------------|
| `version`     | Integer | `5`          | Always 5 for D&D 5e                 |
| `auto_indent` | Enum    | `YES` · `NO` | Text formatting hint; safe to ignore |
| `HB`          | String  | `"HB"`       | Marks homebrew content              |
| `UA`          | String  | free text    | Marks Unearthed Arcana content      |
| `source`      | String  | e.g. `"PHB"` | 3-letter source code                |

### Root element vocabulary

| Root element   | Contains                                      |
|----------------|-----------------------------------------------|
| `<compendium>` | monsters, items, spells, races, classes, etc. |
| `<collection>` | XInclude references to other compendium files |
| `<campaign>`   | notes, encounters, adventures (simple format) |
| `<data>`       | full campaign state: PCs, NPCs, adventures    |
| `<characters>` | one or more `<character>` blocks              |
| `<pc>`         | single player character                       |
| `<notes>`      | standalone note collections                   |

`<collection>` documents are aggregators and are not directly importable:

```xml
<collection xmlns:xi="http://www.w3.org/2001/XInclude">
  <xi:include href="../Sources/CoreRules/Players Handbook.xml"
              xpointer="xpointer(/collection/doc)" />
</collection>
```

---

## 2. Types

### 2.1 Compendium

`Compendium` is an unordered set of zero or more entities drawn from the union:

    Compendium ::= (Monster | Item | Spell | Feat | Race | Class | Subclass | Background)*

### 2.2 Monster

`Monster` represents a creature stat block. It may appear in a `<compendium>`,
or inline inside a `<combatant>` within a `<data>` campaign file.

#### Fields

| Field              | Cardinality | Type        | Notes |
|--------------------|-------------|-------------|-------|
| `<name>`           | required    | String      | |
| `<size>`           | optional    | Enum        | `T`=Tiny · `S`=Small · `M`=Medium · `L`=Large · `H`=Huge · `G`=Gargantuan. Some `<data>` files use numeric IDs instead. |
| `<type>`           | optional    | String      | free text: beast, humanoid, undead, monstrosity, … |
| `<alignment>`      | optional    | String      | free text |
| `<cr>`             | optional    | String      | Integer or fraction: `"0.125"` `"0.5"` `"24"` |
| `<ac>`             | optional    | String      | Integer, or `"Integer (source)"` e.g. `"17 (chain shirt)"` |
| `<hp>`             | optional    | String      | Integer, or `"Integer (formula)"` e.g. `"52 (8d8+16)"` |
| `<speed>`          | optional    | String      | free text: `"40 ft., fly 80 ft."` |
| `<str>`            | optional    | Integer     | mutually exclusive with `<abilities>` |
| `<dex>`            | optional    | Integer     | mutually exclusive with `<abilities>` |
| `<con>`            | optional    | Integer     | mutually exclusive with `<abilities>` |
| `<int>`            | optional    | Integer     | mutually exclusive with `<abilities>` |
| `<wis>`            | optional    | Integer     | mutually exclusive with `<abilities>` |
| `<cha>`            | optional    | Integer     | mutually exclusive with `<abilities>` |
| `<abilities>`      | optional    | String      | `"STR,DEX,CON,INT,WIS,CHA"` — alternative to six separate elements |
| `<save>`           | optional    | String      | `"Dex +5, Con +15"` |
| `<skill>`          | optional    | String      | `"Perception +14, Stealth +5"` |
| `<resist>`         | optional    | String      | damage type list |
| `<immune>`         | optional    | String      | damage type list |
| `<vulnerable>`     | optional    | String      | damage type list |
| `<conditionImmune>`| optional    | String      | condition list |
| `<senses>`         | optional    | String      | free text |
| `<passive>`        | optional    | Integer     | passive Perception |
| `<languages>`      | optional    | String      | comma-separated |
| `<spellAbility>`   | optional    | String      | `"Charisma"` · `"Wisdom"` · `"Intelligence"` |
| `<spells>`         | optional    | String      | comma-separated spell names |
| `<slots>`          | optional    | SlotString  | see §4.1 |
| `<trait>`          | 0..*        | Trait       | see §2.2.1 |
| `<action>`         | 0..*        | Action      | see §2.2.2 |
| `<reaction>`       | 0..*        | Action      | same structure as Action |
| `<legendary>`      | 0..*        | Action      | same structure as Action |
| `<description>`    | optional    | String      | source or lore note |
| `<source>`         | optional    | String      | e.g. `"MM"` `"MM p. 123"` |

#### 2.2.1 Trait

| Field       | Cardinality | Type   | Notes |
|-------------|-------------|--------|-------|
| `<name>`    | required    | String | |
| `<text>`    | 0..*        | String | concatenated with newlines |
| `<recharge>`| optional    | String | e.g. `"3/day"` `"5-6"` — cosmetic only |
| `<attack>`  | 0..*        | Attack | see §2.2.3 |

#### 2.2.2 Action

`Action` is the shared structure for `<action>`, `<reaction>`, and `<legendary>`.

| Field     | Cardinality | Type   | Notes |
|-----------|-------------|--------|-------|
| `<name>`  | required    | String | |
| `<text>`  | 0..*        | String | concatenated with newlines |
| `<attack>`| 0..*        | Attack | see §2.2.3 |
| `<atk>`   | optional    | String | direct hit bonus without an `<attack>` wrapper |
| `<dmg>`   | optional    | String | direct damage dice without an `<attack>` wrapper |

When `<atk>` or `<dmg>` appear directly on an `Action` (without an `<attack>`
wrapper), they are semantically equivalent to
`<attack><atk>…</atk><dmg>…</dmg></attack>`.

#### 2.2.3 Attack

`Attack` encodes a roll-able attack expression. Three syntactic forms are found
in the wild; all are semantically equivalent.

**Form 1 — pipe-separated string (most common in compendium files):**

    <attack>Name|HitBonus|DamageDice</attack>

- `HitBonus` is a bare integer (`17`, not `+17`).
- An empty `HitBonus` indicates a saving-throw ability with no hit roll: `||16d6`.
- Multiple damage expressions may be concatenated: `2d10+10+2d10`.

**Form 2 — structured sub-elements (common in campaign/data files):**

    <attack>
      <name>Claw</name>    <!-- optional -->
      <atk>17</atk>
      <dmg>2d8+10</dmg>
    </attack>

**Form 3 — multiple `<attack>` elements per action (rare):**

    <action>
      <name>Longsword</name>
      <attack><name>One Handed</name><atk>9</atk><dmg>1d8+3</dmg></attack>
      <attack><name>Two Handed</name><atk>9</atk><dmg>1d10+3</dmg></attack>
    </action>

#### Example

```xml
<monster>
  <name>Ancient Red Dragon</name>
  <size>G</size>
  <type>dragon</type>
  <alignment>chaotic evil</alignment>
  <cr>24</cr>
  <ac>22 (natural armor)</ac>
  <hp>546 (28d20+280)</hp>
  <speed>40 ft., fly 80 ft.</speed>
  <str>30</str> <dex>10</dex> <con>29</con>
  <int>18</int> <wis>15</wis> <cha>23</cha>
  <save>Dex +7, Con +16, Wis +9, Cha +13</save>
  <skill>Perception +16, Stealth +7</skill>
  <immune>fire</immune>
  <senses>blindsight 60 ft., darkvision 120 ft.</senses>
  <passive>26</passive>
  <languages>Common, Draconic</languages>

  <trait>
    <name>Legendary Resistance (3/Day)</name>
    <text>If the dragon fails a saving throw, it can choose to succeed instead.</text>
  </trait>

  <action>
    <name>Multiattack</name>
    <text>The dragon makes three attacks: one bite and two claws.</text>
  </action>

  <action>
    <name>Bite</name>
    <text>Melee Weapon Attack: +17 to hit, reach 15 ft. Hit: 21 (2d10+10) piercing plus 11 (2d10) fire.</text>
    <attack>Bite|17|2d10+10+2d10</attack>
  </action>

  <action>
    <name>Fire Breath (Recharge 5-6)</name>
    <text>DC 24 Dex save, 91 (26d6) fire damage on fail, half on success.</text>
    <attack>Fire Breath||26d6</attack>
  </action>

  <legendary>
    <name>Wing Attack (Costs 2 Actions)</name>
    <text>DC 25 Dex save or 17 (2d8+10) bludgeoning and knocked prone.</text>
    <attack>Wing Attack||2d8+10</attack>
  </legendary>
</monster>
```

---

### 2.3 Item

`Item` represents a weapon, armor, gear, magic item, container, or currency.

| Field        | Cardinality | Type   | Notes |
|--------------|-------------|--------|-------|
| `<name>`     | required    | String | |
| `<type>`     | optional    | Enum   | see §2.3.1 |
| `<magic>`    | optional    | Integer| `0` = non-magical; `1` = magical |
| `<weight>`   | optional    | Number | pounds |
| `<dmg1>`     | optional    | String | one-handed weapon damage, e.g. `"1d8"` |
| `<dmg2>`     | optional    | String | two-handed / alternate damage |
| `<dmgType>`  | optional    | Enum   | `B`=Bludgeoning · `P`=Piercing · `S`=Slashing |
| `<property>` | optional    | String | comma-separated property codes; see §2.3.2 |
| `<range>`    | optional    | String | `"normal/long"` e.g. `"20/60"` |
| `<ac>`       | optional    | Integer| for armor |
| `<strength>` | optional    | Integer| minimum Strength requirement |
| `<stealth>`  | optional    | String | `"YES"` if disadvantage on Stealth |
| `<modifier>` | 0..*        | Modifier | see §4.2 |
| `<roll>`     | 0..*        | Roll   | see §4.3 |
| `<text>`     | 0..*        | String | concatenated with newlines |
| `<source>`   | optional    | String | |

#### 2.3.1 Item Type Codes

| Code | Category           |
|------|--------------------|
| LA   | Light Armor        |
| MA   | Medium Armor       |
| HA   | Heavy Armor        |
| S    | Simple Melee       |
| M    | Martial Melee      |
| R    | Ranged             |
| A    | Ammunition         |
| P    | Potion             |
| RD   | Rod                |
| SC   | Scroll             |
| ST   | Staff              |
| W    | Wondrous Item      |
| WD   | Wand               |
| RG   | Ring               |
| G    | Gear / Adventuring |
| $    | Currency           |

#### 2.3.2 Weapon Property Codes

| Code | Property    |
|------|-------------|
| A    | Ammunition  |
| F    | Finesse     |
| H    | Heavy       |
| L    | Light       |
| LD   | Loading     |
| R    | Reach       |
| S    | Special     |
| T    | Thrown      |
| 2H   | Two-Handed  |
| V    | Versatile   |

#### Example

```xml
<item>
  <name>Longsword +1</name>
  <type>M</type>
  <magic>1</magic>
  <weight>3</weight>
  <dmg1>1d8</dmg1>
  <dmg2>1d10</dmg2>
  <dmgType>S</dmgType>
  <property>V</property>
  <modifier category="bonus">attack roll +1</modifier>
  <modifier category="bonus">damage roll +1</modifier>
  <text>This sword is magically enhanced.</text>
</item>
```

---

### 2.4 Spell

| Field         | Cardinality | Type   | Notes |
|---------------|-------------|--------|-------|
| `<name>`      | required    | String | |
| `<level>`     | optional    | Integer| `0` = cantrip; `1`–`9` = spell level |
| `<school>`    | optional    | Enum   | see §2.4.1 |
| `<ritual>`    | optional    | Enum   | `"YES"` if ritual-castable |
| `<time>`      | optional    | String | e.g. `"1 action"` `"1 minute"` |
| `<range>`     | optional    | String | e.g. `"150 feet"` `"Self (20-foot cone)"` |
| `<components>`| optional    | String | e.g. `"V, S, M (bat guano)"` |
| `<duration>`  | optional    | String | e.g. `"Instantaneous"` `"Concentration, up to 1 hour"` |
| `<classes>`   | optional    | String | comma-separated class names |
| `<text>`      | 0..*        | String | concatenated with newlines; empty element = blank line |
| `<roll>`      | 0..*        | Roll   | see §4.3 |
| `<source>`    | optional    | String | |

#### 2.4.1 School Codes

| Code | School        |
|------|---------------|
| A    | Abjuration    |
| C    | Conjuration   |
| D    | Divination    |
| EN   | Enchantment   |
| EV   | Evocation     |
| I    | Illusion      |
| N    | Necromancy    |
| T    | Transmutation |

#### Example

```xml
<spell>
  <name>Fireball</name>
  <level>3</level>
  <school>EV</school>
  <time>1 action</time>
  <range>150 feet</range>
  <components>V, S, M (a tiny ball of bat guano and sulfur)</components>
  <duration>Instantaneous</duration>
  <classes>Sorcerer, Wizard</classes>
  <text>A bright streak flashes from your pointing finger to a point you choose within range, then blossoms with a low roar into an explosion of flame.</text>
  <text></text>
  <text>At Higher Levels: The damage increases by 1d6 for each slot level above 3rd.</text>
  <roll description="Damage">8d6</roll>
</spell>
```

---

### 2.5 Feat

| Field           | Cardinality | Type     | Notes |
|-----------------|-------------|----------|-------|
| `<name>`        | required    | String   | |
| `<prerequisite>`| optional    | String   | free text |
| `<text>`        | 0..*        | String   | concatenated with newlines |
| `<modifier>`    | 0..*        | Modifier | see §4.2 |

#### Example

```xml
<feat>
  <name>Great Weapon Master</name>
  <text>You've learned to put the weight of a weapon to your advantage.</text>
  <modifier category="bonus">attack roll -5</modifier>
  <modifier category="bonus">damage roll +10</modifier>
</feat>
```

---

### 2.6 Race

| Field          | Cardinality | Type     | Notes |
|----------------|-------------|----------|-------|
| `<name>`       | required    | String   | |
| `<size>`       | optional    | Enum     | same codes as Monster `<size>` |
| `<speed>`      | optional    | Integer  | base walking speed in feet |
| `<ability>`    | optional    | String   | e.g. `"Str +2, Cha +1"` |
| `<languages>`  | optional    | String   | comma-separated |
| `<proficiency>`| optional    | String   | comma-separated skill names |
| `<trait>`      | 0..*        | Trait    | `category` attribute optional: `"description"` · `"species"` |
| `<modifier>`   | 0..*        | Modifier | see §4.2 |

#### Example

```xml
<race>
  <name>Dragonborn</name>
  <size>M</size>
  <speed>30</speed>
  <ability>Str +2, Cha +1</ability>
  <languages>Common, Draconic</languages>
  <trait category="species">
    <name>Draconic Ancestry</name>
    <text>You have draconic ancestry. Choose one type of dragon from the table.</text>
  </trait>
  <trait>
    <name>Breath Weapon</name>
    <text>You can use your action to exhale destructive energy.</text>
  </trait>
</race>
```

---

### 2.7 Class

`<autolevel>` is the mechanism by which the class definition encodes what a
character gains at each level. It groups, under a single `level` attribute, the
spell slot progression, resource counters (e.g. Channel Divinity uses), and
named features for that level. The app reads these blocks in ascending level
order to know what to grant when a character levels up. Each class has one
`<autolevel>` per level from 1 to 20.

`<autolevel>` is also the injection point for subclasses: a subclass definition
adds its own `<autolevel>` blocks, and the app merges them into the matching
class by level number. Subclass features that are not always taken (e.g. domain
spells that vary by domain choice) carry `optional="YES"` on the `<feature>`.

This is verified against the `kinkofer/FightClub5eXML` XSD (`autolevelType`):
`level` is `xs:integer` `use="required"`; `scoreImprovement` is a custom boolean
`use="optional"`; children are an `xs:choice` of `feature`, `slots`, `counter`.

| Field           | Cardinality | Type      | Notes |
|-----------------|-------------|-----------|-------|
| `<name>`        | required    | String    | |
| `<hd>`          | optional    | Integer   | Hit Dice; the integer `8` denotes a d8 |
| `<proficiency>` | optional    | String    | saving throw abilities, comma-separated |
| `<numSkills>`   | optional    | Integer   | number of skill choices at character creation |
| `<armor>`       | optional    | String    | armor proficiencies |
| `<weapons>`     | optional    | String    | weapon proficiencies |
| `<tools>`       | optional    | String    | tool proficiencies |
| `<wealth>`      | optional    | String    | starting gold expression, e.g. `"5d4x10"` |
| `<spellAbility>`| optional    | String    | primary spellcasting ability |
| `<slotsReset>`  | optional    | Enum      | `"L"` = long rest · `"S"` = short rest |
| `<autolevel>`   | 0..*        | AutoLevel | one per class level; `level` attribute required (Integer, 1–20) |

**AutoLevel attributes:**

| Attribute          | Required | Type    | Notes |
|--------------------|----------|---------|-------|
| `level`            | yes      | Integer | 1–20 |
| `scoreImprovement` | no       | Boolean | marks ability score improvement levels |

**AutoLevel child fields:**

| Field       | Cardinality | Type       | Notes |
|-------------|-------------|------------|-------|
| `<slots>`   | optional    | SlotString | spell slots at this level; see §4.1 |
| `<counter>` | 0..*        | Counter    | a named limited-use resource: `<name>` + `<value>` |
| `<feature>` | 0..*        | Feature    | `<name>` + `<text>` (0..*) + optional nested `<feature>` for subclass entries; `optional="YES"` attribute marks optional subclass features |

#### Example

```xml
<class>
  <name>Cleric</name>
  <hd>8</hd>
  <proficiency>Strength, Wisdom</proficiency>
  <numSkills>2</numSkills>
  <spellAbility>Wisdom</spellAbility>
  <slotsReset>L</slotsReset>
  <autolevel level="1">
    <slots>0,2,0,0,0,0,0,0,0,0</slots>
    <feature>
      <name>Spellcasting</name>
      <text>As a conduit for divine power, you can cast cleric spells.</text>
    </feature>
  </autolevel>
  <autolevel level="2">
    <slots>0,3,0,0,0,0,0,0,0,0</slots>
    <counter>
      <name>Channel Divinity</name>
      <value>1</value>
    </counter>
    <feature>
      <name>Channel Divinity: Turn Undead</name>
      <text>As an action, you present your holy symbol.</text>
    </feature>
  </autolevel>
</class>
```

---

### 2.8 Subclass

| Field        | Cardinality | Type      | Notes |
|--------------|-------------|-----------|-------|
| `<name>`     | required    | String    | |
| `<baseclass>`| required    | String    | name of the parent class |
| `<hd>`       | optional    | Integer   | Hit Dice; inherited from the base class |
| `<autolevel>`| 0..*        | AutoLevel | same structure as in Class |

#### Example

```xml
<subclass>
  <name>Champion</name>
  <baseclass>Fighter</baseclass>
  <autolevel level="3">
    <feature>
      <name>Improved Critical</name>
      <text>Your weapon attacks score a critical hit on a roll of 19 or 20.</text>
    </feature>
  </autolevel>
</subclass>
```

---

### 2.9 Background

| Field          | Cardinality | Type   | Notes |
|----------------|-------------|--------|-------|
| `<name>`       | required    | String | |
| `<proficiency>`| optional    | String | comma-separated skill names |
| `<languages>`  | optional    | String | |
| `<tools>`      | optional    | String | |
| `<trait>`      | 0..*        | Trait  | |

#### Example

```xml
<background>
  <name>Acolyte</name>
  <proficiency>Insight, Religion</proficiency>
  <trait>
    <name>Feature: Shelter of the Faithful</name>
    <text>As an acolyte, you command the respect of those who share your faith.</text>
  </trait>
</background>
```

---

## 3. Campaign Documents

### 3.1 Campaign (simple format)

`Campaign` is the simple export format produced by GameMaster5. It contains an
ordered sequence of `Note`, `Encounter`, and `Adventure` values, along with
references to PCs and NPCs. The ordering of child elements is significant: it
reflects the intended reading order of the campaign.

    Campaign ::= name, (Note | Encounter | Adventure | Pc | Npc)*

| Field        | Cardinality | Type      | Notes |
|--------------|-------------|-----------|-------|
| `<name>`     | required    | String    | |
| `<note>`     | 0..*        | Note      | see §3.1.1 |
| `<encounter>`| 0..*        | Encounter | see §3.1.2 |
| `<adventure>`| 0..*        | Adventure | see §3.1.3 |
| `<pc>`       | 0..*        | PcRef     | `<label>` only |
| `<npc>`      | 0..*        | NpcRef    | `<name>` + `<label>` |

#### 3.1.1 Note

A `Note` is a free-form text section, analogous to a page of GM notes. It
contains one or more `<text>` elements; an empty `<text>` produces a blank line.

Notes use `<title>` — not `<name>` — for their heading. This is confirmed by
direct examination of real campaign files and adversarially verified in the deep
research phase (the claim that notes use `<name>` was voted 0-3 refuted). This
contrasts with `<encounter>`, which uses `<name>`. The distinction is specific
to element type, not to export version. Both are present in the same file.

| Field     | Cardinality | Type   | Notes |
|-----------|-------------|--------|-------|
| `<title>` | optional    | String | heading of the note |
| `<text>`  | 0..*        | String | concatenated with newlines |

#### 3.1.2 Encounter

An `Encounter` represents a scene — a combat, a social interaction, or a
descriptive set piece. Encounters use `<name>` for their heading (contrast with
notes, which use `<title>`).

The text content of an encounter is not flat: the exporting app uses nested
`<note>` elements to organise content into labelled sections (e.g. "Read Aloud",
"DM Notes", "Tactics"). Each `<note>` may itself contain further `<note>`
children, so the text depth is unbounded in principle.

To collect all encounter text regardless of where it sits in this hierarchy,
an importer must traverse the entire subtree of the `<encounter>` element.
Concretely:

- Direct `<text>` children of `<encounter>` are top-level descriptive text.
- `<note>` children group related text under a label; their `<text>` children
  are one level deep.
- `<note>` children of `<note>` children represent sub-sections; their `<text>`
  elements are two or more levels deep.

All three depths have been observed in real campaign exports.

| Field        | Cardinality | Type      | Notes |
|--------------|-------------|-----------|-------|
| `<name>`     | optional    | String    | also seen as `<title>` |
| `<text>`     | 0..*        | String    | direct text children |
| `<note>`     | 0..*        | Note      | may contain further `<note>` children |
| `<combatant>`| 0..*        | Combatant | `<monster>` child: either a name reference or an inline stat block |

#### 3.1.3 Adventure

An `Adventure` is a named sub-section of a campaign. Its children follow the
same grammar as the top-level `Campaign`, enabling arbitrary nesting.

    Adventure ::= name, (Note | Encounter | Adventure | Npc)*

| Field        | Cardinality | Type      | Notes |
|--------------|-------------|-----------|-------|
| `<name>`     | required    | String    | |
| `<text>`     | 0..*        | String    | overview text |
| `<note>`     | 0..*        | Note      | |
| `<encounter>`| 0..*        | Encounter | |
| `<npc>`      | 0..*        | NpcRef    | |

#### Example

```xml
<campaign version="5">
  <name>Red Hand of Doom</name>

  <note>
    <name>Session One</name>
    <text>The party met in Brindol and were hired by the town council.</text>
  </note>

  <encounter>
    <name>Council Meeting</name>
    <text>The adventurers are summoned before the council.</text>
    <note>
      <name>Read Aloud</name>
      <text>Lord Jarmaath rises from his seat and extends a hand in greeting.</text>
    </note>
    <note>
      <name>DM Notes</name>
      <note>
        <name>Tactics</name>
        <text>If the party is hostile, the guards intervene on round 2.</text>
      </note>
    </note>
  </encounter>

  <adventure>
    <name>Part 1: Invasion</name>
    <text>The Red Hand army marches on Elsir Vale.</text>
    <encounter>
      <name>Hobgoblin Raid</name>
      <text>A squad of hobgoblins attacks the south gate.</text>
      <combatant><monster>Hobgoblin</monster></combatant>
      <combatant><monster>Hobgoblin Captain</monster></combatant>
    </encounter>
    <note>
      <name>DM Notes</name>
      <text>If the players go to the inn first, the raid escalates.</text>
    </note>
  </adventure>

  <npc>
    <name>Captain Soranna</name>
    <label>Soranna</label>
  </npc>
  <pc>
    <label>Little Crow</label>
  </pc>
</campaign>
```

---

### 3.2 Data (full campaign state)

`Data` is a superset of `Campaign`. It records the complete runtime state of an
active campaign: current HP, spell slots, initiative order, and inline monster
stat blocks. Its root element is `<data>`, which wraps a single `<campaign>`.

Additional fields relative to simple `Campaign`:

| Field inside `<campaign>` | Cardinality | Type     | Notes |
|---------------------------|-------------|----------|-------|
| `<version>`               | optional    | Integer  | internal campaign version |
| `<uid>`                   | optional    | Integer  | internal ID |
| `<pc>`                    | 0..*        | PcState  | abbreviated PC stat block with current HP and slots |
| `<npc>`                   | 0..*        | NpcState | abbreviated NPC stat block |

Additional fields on `<encounter>` within `<data>`:

| Field     | Cardinality | Type    | Notes |
|-----------|-------------|---------|-------|
| `<state>` | optional    | Integer | `0` not started · `1` in progress · `2` complete |
| `<round>` | optional    | Integer | current round |

Within `<data>`, a `<combatant>` wraps a full inline `<monster>` stat block
(including current HP and actions) rather than a bare monster name reference.

#### Example

```xml
<data version="5">
  <campaign>
    <name>Red Hand of Doom</name>
    <uid>1769</uid>

    <pc>
      <uid>100</uid>
      <label>Aragorn</label>
      <hpMax>72</hpMax>
      <hpCurrent>50</hpCurrent>
      <abilities>16,14,15,10,16,10</abilities>
    </pc>

    <npc>
      <label>King Markos</label>
      <hpCurrent>100</hpCurrent>
      <enemy>1</enemy>
    </npc>

    <adventure>
      <name>Part 1: Invasion</name>
      <encounter>
        <name>Hobgoblin Ambush</name>
        <state>2</state>
        <round>5</round>
        <combatant>
          <monster>
            <name>Hobgoblin Captain</name>
            <ac>17</ac>
            <hpMax>39</hpMax>
            <hpCurrent>25</hpCurrent>
            <action>
              <name>Longsword</name>
              <text>Melee Weapon Attack: +4 to hit. Hit: 9 (2d6+2) slashing.</text>
              <attack><atk>4</atk><dmg>2d6+2</dmg></attack>
            </action>
          </monster>
        </combatant>
      </encounter>
    </adventure>
  </campaign>
</data>
```

---

### 3.3 Player Character

`Pc` may appear as a standalone document (`<pc>`) or as a `<character>` inside a
`<characters>` party file.

| Field             | Cardinality | Type      | Notes |
|-------------------|-------------|-----------|-------|
| `<name>`          | required    | String    | |
| `<uid>`           | optional    | Integer   | internal ID |
| `<race>`          | optional    | PcRace    | `<name>` + biographical fields |
| `<class>`         | 0..*        | PcClass   | `<name>` + `<level>` + slot tracking |
| `<str>` … `<cha>` | optional    | Integer   | mutually exclusive with `<abilities>` |
| `<abilities>`     | optional    | String    | `"STR,DEX,CON,INT,WIS,CHA"` |
| `<ac>`            | optional    | Integer   | |
| `<armor>`         | optional    | String    | equipped armor name |
| `<speed>`         | optional    | String    | |
| `<hpMax>`         | optional    | Integer   | |
| `<hpCurrent>`     | optional    | Integer   | |
| `<passive>`       | optional    | Integer   | passive Perception |
| `<spellAbility>`  | optional    | String    | |
| `<spells>`        | optional    | String    | comma-separated spell names |
| `<action>`        | 0..*        | Action    | same structure as Monster Action |

**PcClass** additionally tracks:

| Field            | Cardinality | Type       | Notes |
|------------------|-------------|------------|-------|
| `<level>`        | required    | Integer    | |
| `<hd>`           | optional    | String     | Hit Dice type, e.g. `"1d10"` |
| `<hdCurrent>`    | optional    | Integer    | remaining hit dice |
| `<slots>`        | optional    | SlotString | maximum slots |
| `<slotsCurrent>` | optional    | SlotString | current remaining slots |

#### Example

```xml
<pc version="5">
  <character>
    <name>Aragorn, Ranger</name>
    <race><name>Human</name></race>
    <class>
      <name>Ranger</name>
      <level>9</level>
      <slots>4,4,3,3,3,1,0,0,0,0</slots>
      <slotsCurrent>3,2,0,0,0,0,0,0,0,0</slotsCurrent>
    </class>
    <str>16</str> <dex>14</dex> <con>15</con>
    <int>10</int> <wis>16</wis> <cha>10</cha>
    <ac>16</ac>
    <hpMax>72</hpMax>
    <hpCurrent>72</hpCurrent>
    <action>
      <name>Longbow</name>
      <text>Ranged Weapon Attack: +6 to hit, range 150/600 ft. Hit: 1d8+4 piercing.</text>
      <attack><atk>6</atk><dmg>1d8+4</dmg></attack>
    </action>
  </character>
</pc>
```

---

## 4. Shared Scalar Types

### 4.1 SlotString

A `SlotString` is a comma-separated sequence of non-negative integers representing
spell slot counts at each level. The first position is cantrips; positions 2–10 are
spell levels 1–9. Both 9-element and 10-element strings are observed:

    "4,4,3,3,2,1,0,0,0"      -- 9 elements
    "0,2,0,0,0,0,0,0,0,0"    -- 10 elements

Treat missing trailing elements as zero.

### 4.2 Modifier

`Modifier` encodes a mechanical bonus. Two syntactic forms coexist:

**String form (most common):**

```xml
<modifier category="ability score">strength +1</modifier>
<modifier category="bonus">attack roll +1</modifier>
<modifier category="saving throw">constitution +2</modifier>
<modifier category="skill">perception +5</modifier>
<modifier category="initiative">+2</modifier>
```

**Numeric form (older files):**

```xml
<modifier>
  <category>0</category>   <!-- 0=STR 1=DEX 2=CON 3=INT 4=WIS 5=CHA -->
  <type>5</type>
  <value>2</value>
</modifier>
```

### 4.3 Roll

`Roll` exposes a dice expression to the application's dice roller. The
`description` and `level` attributes are optional.

```xml
<roll>8d6</roll>
<roll description="Damage">8d6</roll>
<roll description="Damage (4th level)">9d6</roll>
<roll description="Personality Trait" level="1">1d8</roll>
```

### 4.4 Source

`<source>` appears on individual records or as an attribute on `<compendium>`.
When present on the root element it applies to all children.

```xml
<source>PHB</source>
<source>MM p. 123</source>
```

---

## 5. Known Inconsistencies

| Issue                          | Detail |
|--------------------------------|--------|
| Note title vs encounter name   | `<note>` uses `<title>` for its heading; `<encounter>` uses `<name>`. These are distinct by element type, not by export version. Both may appear in the same file. |
| Ability scores                 | Either six separate elements or a single `<abilities>` element. |
| Attack notation                | Three syntactic forms; all must be handled (see §2.2.3). |
| AC and HP                      | Either a bare integer or `"integer (qualifier)"`. |
| Monster size in `<data>` files | Letter codes in compendiums; numeric IDs in some `<data>` files. |
| SlotString length              | 9- or 10-element strings both observed. |
| `<campaign>` vs `<data>`       | Same content model; `<data>` adds runtime state and inline monsters. |
| Empty elements                 | Any field may be an empty element; treat as absent. |
| Encounter text depth           | Text may be a direct `<text>` child, inside one `<note>`, or inside arbitrarily nested `<note>` elements. Collect all with `.//note/text`. |
| Multiple `<attack>` per action | Rare but observed; each yields a distinct attack record. |
