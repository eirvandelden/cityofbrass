# Spec: Domain doc, glossary & i18n for Game

From `intent.md` (2026-10-05). Status: accepted.

## Flagged concerns

- `i18n-tasks health` currently reports "Every translation is in use". A "Game" key that no view uses yet counts as unused and fails that check. The intent says no view uses it until #93. Tradeoff: add an `ignore_unused` entry for the new key in `config/i18n-tasks.yml` (a config edit, not a linter disable comment), or add a view. This spec picks the config entry, because the intent forbids behaviour change. The entry is removed when #93 uses the key.
- The intent says issue edits need approval of each text. The spec lists the edit as a requirement, but the text stays a draft in chat until Etienne approves it. It is not part of the commit.

## Requirements

1. R1 — `docs/domain.md` exists and is the living domain document. It states that later milestone issues update it as they ship.
2. R2 — It defines each term exactly once: Game, Campaign, Adventure, Page, World, Module, Published, Catalog. The definitions come only from the bodies of #91–#106.
3. R3 — It describes the target model: authored content (Campaign, Adventure, World, Page, House Rules) versus live play (Game, content queue, players, player character queue, session log, ActivePlay sessions) versus sharing (Module, Published, Catalog). It records the "playlist" states `active`, `queued-future`, `retired`.
4. R4 — It holds the rename map: Stock Adventures → Adventure Modules; Stock NPCs/Creatures/Items/Spells → Published entities; browse surface → Catalog. It also maps the code names that differ from the terms (World is `District`; Scene and Encounter are not models).
5. R5 — It records the decision on Italian "Campaign": Italian keeps "Campagna". Dutch keeps "Campagne" as a loanword.
6. R6 — It lists the deferred items named in the issues (ActivePlay unlocks, date planning, "to be overcome" marker) so later issues do not build them early.
7. R7 — It says which terms are game-agnostic by rule: no City-of-Brass theming, no Foundation-specific UI.
8. R8 — `en.yml`, `nl.yml` and `it.yml` each hold a "Game" key: en "Game", nl "Spel", it "Gioco". The key has the same path in all three files, under a new top-level `domain` scope: `domain.game`.
9. R9 — `config/i18n-tasks.yml` lists `domain.game` under `ignore_unused`, with a comment naming #93.
10. R10 — `AGENTS.md` points to `docs/domain.md` in its Domain section, so agents find it.
11. R11 — A draft of the milestone 7 issue edit (#92–#106) points each issue to `docs/domain.md` instead of the missing spec. Drafts go to Etienne in chat. Nothing is posted without approval of that exact text (playbook rule 6). #91 gets the same edit.
12. R12 — No model, migration, view or behaviour changes.

## Design decisions

- File name `docs/domain.md`. The path is short, and the milestone issues link to one stable file.
- Key path `domain.game`. A neutral scope avoids guessing the future view that will use it. #93 may move the key; the domain doc notes this.
- The i18n check is `bundle exec i18n-tasks health`. It already covers missing, unused and normalized keys for en, nl and it. Add a test that runs `missing` and `unused` through the `i18n-tasks` API so `bin/rails test` enforces it. Tests: a Minitest file `test/i18n_test.rb`.
- The doc does not recreate the missing design spec. Where the issues are silent, the doc says "not decided" and links the issue.
- One line per paragraph and list item (playbook rule 26).

## Integration points

- `config/locales/en.yml`, `nl.yml`, `it.yml` (keys stay alphabetically sorted, so `i18n-tasks normalize` stays green).
- `config/i18n-tasks.yml` (`ignore_unused`).
- `AGENTS.md` (pointer line).
- `test/i18n_test.rb` (new).
- GitHub issues #91–#106 (edit drafts only, posted after approval).

## Acceptance criteria

- The domain document defines each of Game, Campaign, Adventure, Page, World, Module, Published and Catalog exactly once. (R2)
- The domain document tells a reader that Stock Adventures become Adventure Modules and Stock NPCs become Published NPCs. (R4)
- The domain document says Italian keeps "Campagna" and Dutch keeps "Campagne". (R5)
- The domain document says a Game references its content and never embeds it. (R3)
- The domain document lists "date planning" as deferred, so #98 does not build it. (R6)
- A developer who opens `AGENTS.md` finds the link to the domain document. (R10)
- The "Game" key reads "Game" in English, "Spel" in Dutch and "Gioco" in Italian. (R8)
- The i18n check passes with no missing, unused or unnormalized keys after the key is added. (R8, R9)
- Removing the Dutch "Game" key makes the i18n check fail. (R8)
- Etienne sees the draft issue edit for #92 and approves it before anything is posted. (R11)
- The app renders every existing page exactly as before; the full test suite stays green. (R12)

---
Domain skills applied: rails-ui (i18n strings), rails-testing, object-oriented-design (not applicable beyond the vocabulary).
