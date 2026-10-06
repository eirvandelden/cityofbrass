# Domain

This is a living document: the shared vocabulary and target model of the domain reframe (milestone 7, "Domain reframe: Game / Campaign / Adventure / World / Module").

Each milestone 7 issue updates it when it ships. It replaces the design spec that the issues cite (`docs/specs/2026-06-30-domain-reframe-design.md`), which was never committed.

Where no source decides a point, the document says "not decided" and links the issue that will decide it.

## Glossary

- **Game** — the live play layer: an ordered queue of referenced Campaigns and Adventures (several active, others queued), per-player character queues, a session log, and ActivePlay sessions (#91, #93).
- **Campaign** — authored content: an ongoing series of connected Adventures, a World and continuity, with its own Pages and House Rules (#91, #94).
- **Adventure** — authored content: one complete playable unit, built from Pages (#91).
- **Page** — a flexible building block inside an Adventure; it plays the "Scene" role, so there are no Scene or Encounter models (#91, #105).
- **World** — setting and reference material, called "District" in code (#91).
- **Module** — the delivery format: the released form of a runnable container, named "Adventure Module", "Campaign Module" or "World Module" (#91, #100).
- **Published** — the released form of a single entity, named "Published NPC", "Published Item", "Published Monster" or "Published Spell" (#91, #100).
- **Catalog** — the browse surface that holds both Modules and Published content (#91, #104).

## Target model

### Authored content

Authored content is Campaign, Adventure, World, Page and House Rules. It holds no live-play state (#94).

- A Campaign has its own Pages, its House Rules, a World and connected Adventures (#94).
- An Adventure has an optional default World. A Game can later run the same Adventure in another World by duplicating content (#92).

### Live play

- A Game is owned by a resident. It holds a content queue of references to Campaigns and Adventures. Several may be active; the others are queued for the future (#93).
- A Game references its content and never embeds it (#93, #97).
- Players belong to the Game. Each Player has an ordered queue of Player Characters; a retired character stays as history and stays referenceable (#93, #95).
- The playlist pattern is ordered items with the states `active`, `queued-future` and `retired`; the content queue and the per-player character queue share it (#93, #95).
- ActivePlay sessions belong to the Game, one Game to many sessions (#96).
- The session log is a first-class model on the Game, with a session date (#98).
- GM Notes belong to the Game side. They are private and never exported in a Module (#94).
- The only way a Game diverges from its content is "Create duplicate for game NAME". It deep-copies the content and re-points the Game's reference to the copy; the original is untouched. Module release and Module import reuse the same deep-copy engine (#97, #100, #102).

### Sharing

- Release as Module: a Module owns a full self-contained copy of the content, the object and all its sub-children. It never depends on its source (#100).
- Any user can publish, not only admins. Publishable units are Campaigns, Adventures and Worlds (as Modules), individual entities (as Published), and collections (#100).
- An optional, severable source link from a Module back to its source content powers "Update Module", which re-copies a new version. An admin can reassign the source (#101).
- If the source is deleted, the Module keeps its last full copy and can no longer be updated (#101).
- Import deep-copies a Module or Published item into the importer's library as an owned, independent copy (#102).
- The Catalog lists Modules and Published content, filterable by content type, with browse, discover, publish and share/import flows (#104).
- Modules and Published content replace the admin-only Stock mechanism (#103).

## Rename map

- Stock Adventures → Adventure Modules (#91, #103)
- Stock NPCs → Published NPCs (#91, #103)
- Stock Creatures → Published Monsters (decided at the plan stage of #91, 2026-10-06; the issue names "Creatures" and "Monster" separately)
- Stock Items → Published Items (#91, #103)
- Stock Spells → Published Spells (#91, #103)
- browse surface → Catalog (#91, #104)

## Code names

- World → `Worldbuilder::District`
- Campaign → `Campaignmanager::Campaign`; it fuses authored content and live play until #94
- Adventure → `Storybuilder::Adventure`
- Page → `Campaignmanager::Page`, `Storybuilder::Page`, `Worldbuilder::Page`
- Player → `Campaignmanager::Player`
- Player Character → `Entitybuilder::ResidentCharacter`
- ActivePlay session → `Activeplay::VirtualTable`
- combatant → `Activeplay::Notable`
- session log → `Campaignmanager::AdventureLog`, a Page STI until #98
- House Rules → `Campaignmanager::HouseRule`
- GM Notes → `Campaignmanager::GameMasterNote`
- Stock → `Storybuilder::StockAdventure`, `Entitybuilder::StockNpc`, `Entitybuilder::StockCreature`, `Rulebuilder::StockItem`, `Rulebuilder::StockSpell`
- Game → no model yet (#93)
- Scene and Encounter are not models: a Page plays the Scene role, and launching ActivePlay from a Page realises an encounter (#105)

## Translations

- The locale key for Game is `domain.game`: en "Game", nl "Spel", it "Gioco" (decided in #91; #93 may move the key).
- Italian keeps "Campagna" for Campaign (decided in #91).
- Dutch keeps "Campagne" as a loanword (#91).

## Rules

- Use game-agnostic terms; no City-of-Brass theming (#91).
- No new Foundation-specific UI; use framework-agnostic HTML and CSS (#91).
- Ship vertically: model, UI and i18n together (#91).
- A Game references content and never embeds it (#93).
- GM Notes are never exported in a Module (#94).
- A Module owns its copy. Editing or deleting the source never changes the Module or any import (#100).
- The only link back to the source is the optional, severable source link for "Update Module" (#101).
- Imports are independent copies that updates do not touch (#101, #102).

## Deferred

- ActivePlay unlocks: pre-prepared sessions, pause/resume and session history. Do not build them in #96.
- Date planning and scheduling for the session log. Do not build them in #98; the session date is the foundation.
- The "to be overcome" marker is not part of #105. #106 builds it.

## Not decided

- GM Notes storage: a Page-like STI on the Game, or a private flag. The implementer of #94 chooses; GM Notes are never exported either way.
- The final key path for Game. #93 may move `domain.game`, and removes its `ignore_unused` entry in `config/i18n-tasks.yml`.
- `Rulebuilder::StockRule` and `Gallery::StockImage` exist in code, but no issue maps them (#103).

## Sources

- The bodies of issues #91–#106 on `eirvandelden/cityofbrass`.
- The accepted `intent.md` of #91 (`docs/changes/91-domain-doc-glossary-i18n-for-game/`): the Game translations, "Campagna" and "Campagne".
- Etienne's plan-stage decision of 2026-10-06: Stock Creatures become Published Monsters.
- Class names verified in `engines/`.
