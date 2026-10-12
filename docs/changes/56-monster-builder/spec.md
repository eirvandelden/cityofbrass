# Spec: 4e monster builder and monster versions

From `intent.md` (2026-10-05). Status: accepted.

## Flagged concerns

- Artillery HP is 21 + (6 * L), confirmed by Etienne. The card transcriptions disagreed (26 + (10 * L) in one).
- The card gives "+25-50% encounter" damage. Etienne confirmed +25%. Showing when a value falls outside the 25%-50% range is out of scope here, tracked as a separate issue.
- The DMG's Elite and Solo power adjustments are design choices, not derived numbers. This spec supports them as marks and options on the sheet, with the limits above. It does not automate extra actions. Confirm that scope.
- The DMG heading for Solo action points says "Add 1 Action Point", but its text says solos have 2. This spec uses 2.
- The card has no initiative formula, no Elite/Solo defense bonus, and no Leader role. Initiative follows the entity's existing ability-score calculation, with Etienne's role bonuses. For Elite and Solo, the DMG says to raise up to three defenses by 2, including AC. This spec makes AC +2 automatic and lets the GM pick up to two of Fortitude, Reflex and Will for +2 (default none). There is no Leader role (Etienne); only the six roles exist. Confirm the defense choice.
- The difficulty rules come from DMG (2008) chapter 4 "Building Encounters", as you pasted them. The DMG only defines Easy, Standard and Hard. This spec keeps those three names and adds Impossible as five or more levels above the party. Etienne confirmed the +5 cut-off.
- The XP values come from the Experience Points Reward table (glossary 385) and the Encounter XP Budget table (glossary 672), both pasted by Etienne. Minion XP in that table is rounded (level 2 is 31, level 3 is 38), not exactly one quarter. The spec uses the table values. The plan stage must save both tables in `docs/`.

## Requirements

Business card source: Monster Manual 3 "on a business card" (https://www.blogofholding.com/?p=512). The transcription lives in `docs/4e-business-card.md`.

### Versions (every rule set)

1. A creature or NPC can have versions. A version is a separate entity linked to a parent entity, with a short version label (for example "Level 5").
2. The parent shows its versions. Each version shows its parent.
3. A GM creates a version from an existing monster. The new version copies the parent's stat block.
4. Versions work in every rule set. Rule sets other than 4e get no builder UI.
5. A version belongs to the same resident as its parent and starts with the parent's privacy.

### Builder (4e only)

6. A 4e creature or NPC can opt in to the builder. Existing monsters stay unchanged until the GM opts in.
7. The GM chooses level, role (Artillery, Brute, Controller, Lurker, Skirmisher, Soldier) and group (Minion, Standard, Elite, Solo).
8. Derived numbers, with L as the level:
   - AC: 14 + (1 * L), plus 2 for Soldier, minus 2 for Brute or Artillery, plus 2 for Elite or Solo (the DMG's "increase up to three defenses, including AC, by 2", with AC always one of the three).
   - Fortitude, Reflex, Will: 12 + (1 * L). An Elite or Solo gains +2 on up to two of these, chosen by the GM, and none by default.
   - Attack bonus: 5 + (1 * L).
   - Average damage: 8 + (1 * L).
   - HP by role: Skirmisher, Controller, Soldier 24 + (8 * L); Brute 26 + (10 * L); Artillery, Lurker 21 + (6 * L).
   - Elite HP is 2 * role HP. Solo HP is 4 * role HP. Minion HP is 1.
   - Saving throw bonus: Elite +2, Solo +5, Standard and Minion none.
   - Action points: Elite 1, Solo 2, Standard and Minion none.
   - Initiative: the 4e Initiative value already defined for the entity (Dexterity modifier plus half level), plus 2 for Skirmisher or Soldier, plus 3 for Lurker.
9. Power damage:
   - Minion damage is half of average damage.
   - Brute damage is +25%.
   - Encounter powers are +25%.
   - A multi-target power is -25%.
   - Adjustments combine as multipliers on the average damage and round down.
10. Adding an at-will or encounter power prefills its attack bonus and damage from the monster's level, role and group. The GM can edit both.
11. Hand edits: when the GM edits a derived value, the builder stops overwriting it. The value carries a "needs manual revision" mark that clears when the GM resets it to the calculated value.

### Elite and Solo power adjustments (4e builder monsters)

12. A power has an action type: Standard, Minor, Immediate interrupt or Immediate reaction. The default is Standard.
13. An Elite can mark one encounter power "recharges when first bloodied". The monster shows it gains another use when first bloodied. A Standard, Minion or Solo monster cannot set it. A second mark on an Elite is refused.
14. A Solo can mark one encounter power "usable at will". That power prefills as an at-will power. A non-Solo cannot set it. A second mark on a Solo is refused.
15. An Elite shows an "additional attack" option, off by default. A Solo shows an "additional standard action" option, on by default. Both show as text on the sheet. Other groups do not have the option.

### Version recalculation (4e builder monsters)

16. Creating a version at another level recalculates every derived value that the GM has not edited.
17. An edited value keeps its edited number and shows "needs manual revision" in the new version.

### Difficulty (4e only)

18. The GM chooses a campaign on the monster. The monster shows Easy, Standard, Hard or Impossible.
19. The party is all characters joined to the campaign. Party size is the number of characters. Party level is their average level, rounded.
20. Monster XP is the Experience Points Reward table value for its level and group (Standard, Minion, Elite, Solo), levels 1 to 40.
21. The monster's encounter level is the highest level whose Encounter XP Budget value times party size does not exceed the monster's XP. Below level 1, it is level 0.
22. The difference is encounter level minus party level. Easy is -1 or lower. Standard is 0 or +1. Hard is +2 to +4. Impossible is +5 or higher.
23. A campaign with no joined characters shows no difficulty and a short hint.

## Design decisions

- Versions use a nullable `parent_id` on `entitybuilder_entities` (self-reference) plus a `version_label`. The existing sheet, sharing and campaign-join code keeps working. The migration goes under the primary database path.
- Power adjustments are stored as attributes on the existing attack (power) record: an action type, and two flags. The "additional attack" and "additional standard action" options are attributes on the entity.
- Saving throw bonus and action points use the entity's existing saving throws and trackables. Check the model names in the plan stage.
- A builder monster stores `level`, `role` and `group` on the entity, and the list of hand-edited values. The calculator is a model concern on the 4e entity types, not a service object.
- The 4e rule set definition (`config/core_rules/4th-edition.json`) gates the builder. Other rule sets never render it.
- Calculation tables live in one place (a constants-only value object), so a test can check each card number.
- The version a GM views is a normal entity page. No stat-block switching UI is needed.

## Integration points

- Entitybuilder (`/eb`): entity model, creature and NPC forms, powers (attacks), new versions action.
- Campaign Manager (`/cm`): `Campaign#characters` and `class_levels`, read-only.
- `config/core_rules/4th-edition.json`: gates the builder.
- `docs/4e-business-card.md` and the XP table source: new reference documents.

## Acceptance criteria

- A GM of a 4e creature picks level 5, Soldier, Standard, with Dexterity 10, and sees AC 21, Fortitude 17, Reflex 17, Will 17, HP 64, initiative 4 (0 + 2 + 2), attack +10.
- A level 4 Lurker with Dexterity 14 shows initiative 7 (2 + 2 + 3).
- A level 4 Brute with Dexterity 10 shows initiative 2.
- A level 3 Soldier Elite shows AC 19 (14 + 3 + 2 + 2).
- A GM picks Reflex and Will for a level 3 Elite, and sees Reflex 17 and Will 17, with Fortitude still 15.
- A level 3 Elite shows a +2 saving throw bonus and 1 action point.
- A level 3 Solo shows a +5 saving throw bonus and 2 action points.
- A level 3 Standard monster shows no saving throw bonus and no action points.
- A GM marks one encounter power of an Elite "recharges when first bloodied", and the sheet says it gains another use when first bloodied.
- A GM cannot mark a second power "recharges when first bloodied" on an Elite.
- A GM cannot mark a power "recharges when first bloodied" on a Standard monster.
- A GM marks one encounter power of a Solo "usable at will", and its damage prefills as an at-will power.
- A GM cannot mark a second power "usable at will" on a Solo.
- A Solo shows "additional standard action" on, and an Elite shows "additional attack" off.
- A GM sets a power's action type to Immediate interrupt, and the sheet shows it.
- A GM cannot pick a third defense for an Elite or Solo.
- A level 3 Brute Solo shows AC 17 (14 + 3 - 2 + 2).
- A GM picks level 3, Brute, Standard, and sees AC 15 and HP 56.
- A GM picks level 3, Lurker, Elite, and sees HP 78 (2 x (21 + 18)).
- A GM picks Solo at level 2 with role Controller, and sees HP 160.
- A Minion has 1 HP.
- Adding an at-will power to a level 4 Brute prefills attack +9 and damage 15 (12 + 25%).
- Adding an encounter power to a level 4 Skirmisher prefills damage 15 (12 + 25%).
- A Minion's at-will power at level 4 prefills damage 6.
- A multi-target power at level 4 Skirmisher prefills damage 9.
- A GM who edits AC from 21 to 23 keeps 23 after changing the level, and sees "needs manual revision" next to it.
- A GM who resets an edited value sees the calculated number again and the mark disappears.
- A GM creates a version "Level 10" of a level 5 Orc Warrior, and the version shows the level 10 numbers.
- A version at another level keeps an edited AC and marks it as needing manual revision.
- A GM opens a Pathfinder 2e creature and creates a version of it, without seeing level, role or group.
- A Pathfinder 2e creature shows no difficulty and no power prefill.
- A new version of a Private monster is owned by the same resident and starts Private.
- A parent monster lists all its versions, and each version links back to the parent.
- An existing 4e creature with no builder data opens with all its old numbers unchanged.
- A level 5 Standard monster against five level 5 characters shows Easy (200 XP is below the level 1 budget of 500).
- A level 5 Solo monster against five level 5 characters shows Standard (1000 XP equals 5 x 200).
- A level 3 Minion (38 XP) against four level 3 characters shows Easy.
- A level 9 Solo monster against five level 5 characters shows Hard (2000 XP is encounter level 9, four above).
- A level 10 Solo monster against five level 5 characters shows Impossible (2500 XP is encounter level 10, five above).
- A campaign with no joined characters shows no difficulty and a hint to join characters.

---
Domain skills applied: rails-architecture, object-oriented-design, rails-testing.
