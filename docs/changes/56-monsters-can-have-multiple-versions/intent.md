# Intent: 4e monster builder and monster versions

Author: Etienne van Delden de la Haije. Status: accepted. Type: feature.

Issue: #56 "Monsters can have multiple versions". Prior attempt: PR #143 (stale Toolbox scaffold, no calculations). Reference app: `~/Developer/DnD-MonsterCalculator-4E`.

## Problem

A GM who builds a D&D 4e creature or NPC today fills in every number by hand: initiative, hit points, AC, Fortitude, Reflex, Will, attack bonuses and damage. That is tedious table arithmetic from the "Monster on a business card" rules.

The GM cannot see whether a monster is an easy, medium, hard or impossible fight for the party in one of their campaigns.

Powers get no help either. The GM looks up the attack bonus and damage for every at-will and encounter power.

A monster cannot exist in several versions. A GM who wants an "Orc Warrior" for every 5 levels makes separate, unrelated monsters and redoes all the maths for each level.

## Proposed outcome

For a 4e creature or NPC, the GM chooses a level, a role (Artillery, Brute, Controller, Lurker, Skirmisher, Soldier) and a group (Minion, Standard, Elite, Solo). The derived numbers fill in from those choices.

The GM chooses a campaign and sees whether the monster is an easy, medium, hard or impossible fight for that campaign's party.

When the GM adds an at-will or encounter power, its attack bonus and damage are prefilled from the monster's level, role and group.

One monster can have several versions under one name, each with its own stat block. This works in every rule set.

For a 4e monster, a new version at a different level recalculates its derived numbers. A value the GM edited by hand keeps its edited value and is marked as needing manual revision.

## Affected users and systems

- GMs who author 4e creatures and NPCs in Entitybuilder (`/eb`).
- GMs of every rule set who want several versions of one monster.
- Campaign Manager (`/cm`), as the source of the party for the difficulty.
- The 4e rule set definition in `config/core_rules/4th-edition.json`.

## Constraints

- The builder, the difficulty and the power prefill exist only for the 4e rule set. Other rule sets see no new builder UI and no change in behaviour.
- Monster versions work in every rule set.
- Existing 4e creatures and NPCs keep working unchanged. They can opt in to the builder.
- The numbers follow the "Monster on a business card" rules. Where the macOS app differs (for example its deliberately higher damage), the business card wins. The app is a reference only.

## Success criteria

- A GM builds a playable 4e monster from level, role and group in under a minute.
- The monster shows easy, medium, hard or impossible for a chosen campaign.
- Choosing at-will or encounter for a power prefills its attack bonus and damage.
- A GM makes a new version of a monster at another level, and all derived numbers update. Hand-edited values stay and carry a "needs manual revision" mark.

## Open questions

- Is Leader a selectable secondary role? The business card mentions it; the macOS app does not.
- Which 4e rule sets the difficulty bands (easy/medium/hard/impossible), for example XP budget against party level and size? The macOS app has no difficulty.
- What makes up "the party" of a campaign: all characters joined to it, or a subset the GM chooses?
- Is a version a separate creature linked to a parent, or one creature with several stat blocks? (spec)
- Where does the source text of the "Monster on a business card" rules come from? A link or a copy is needed so the numbers can be verified.
