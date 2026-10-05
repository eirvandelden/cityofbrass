# Intent: Domain doc, glossary & i18n for Game

Author: Etienne van Delden de la Haije. Status: accepted. Type: chore.

Issue: [#91](https://github.com/eirvandelden/cityofbrass/issues/91), the first issue of milestone 7, "Domain reframe: Game / Campaign / Adventure / World / Module".

## Problem

The domain reframe splits authored content (Campaign, Adventure, World) from live play (Game), and adds a sharing layer (Module, Published, Catalog). The repository has no shared record of that vocabulary or of the target model.

All 16 milestone issues cite a design spec at `docs/specs/2026-06-30-domain-reframe-design.md`. That file is not in the repository, and it never was in the git history. Each later issue therefore has no common reference for the meaning of its terms.

The app also has no translated word for "Game" in English, Dutch or Italian. The Italian word for "Campaign" is an open question in the issue.

## Proposed outcome

- A living domain document in the repository holds the canonical vocabulary and the target model. Later milestone issues update it as they ship.
- The document lists the rename map: Stock Adventures become Adventure Modules, Stock NPCs/Creatures/Items/Spells become Published entities, and the browse surface is the Catalog.
- The locale files have "Game" keys: en "Game", nl "Spel", it "Gioco".
- The Italian "Campaign" question is closed: Italian keeps "Campagna". The document records this decision. Dutch keeps "Campagne" as a loanword.
- The domain document replaces the missing spec as the milestone reference. The milestone 7 issues get updated to point at it. Etienne approves each issue edit before it is posted.
- The app behaviour does not change.

## Success

- Each term in the vocabulary of #91 has exactly one definition in the domain document.
- The "Game" key translates in en, nl and it, and an i18n check passes.
- #92 and #93 can link to the domain document for their terms.

## Affected users and systems

- Developers and agents who work on the milestone 7 issues: they read the domain document.
- `config/locales/en.yml`, `nl.yml` and `it.yml`.
- Users see no change yet. No view uses the new keys until a later issue (for example #93, "Introduce Game model").

## Constraints

- The only sources for the document are the issue bodies: #91 and the milestone 7 issues #92–#106. The missing design spec is not recreated from memory.
- No behaviour change, no models, no migrations.
- Issue edits on GitHub are posted only after explicit approval of each text (playbook rule 6).
- Prefer game-agnostic terms over City-of-Brass theming (cross-cutting rule of the milestone).

## Open questions

None.
