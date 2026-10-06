# Plan: Domain doc, glossary & i18n for Game

From `intent.md` (2026-10-05) and `spec.md` (accepted). Status: accepted.

## Context

Milestone 7 ("Domain reframe: Game / Campaign / Adventure / World / Module") has 16 issues, #91–#106. Every issue cites `docs/specs/2026-06-30-domain-reframe-design.md`. That file was never committed. This change adds a living domain document, `docs/domain.md`, as the milestone reference instead. It also adds a "Game" locale key in en, nl and it, and records the Italian "Campaign" decision. App behaviour does not change: no model, migration, view or controller changes.

The spec (`docs/changes/91-domain-doc-glossary-i18n-for-game/spec.md`) holds requirements R1–R12 and the acceptance criteria. This plan implements that spec.

## Design decisions

- **Sources.** `docs/domain.md` has exactly three sources, and its `## Sources` section names each one:
  - The bodies of issues #91–#106, for every definition, rule and deferral. Read them with `gh issue view <n> --json body -q .body` for each `n` from 91 to 106.
  - The accepted `intent.md`, for the decisions that #91 leaves as proposals: Game is "Game" / "Spel" / "Gioco"; Italian keeps "Campagna"; Dutch keeps "Campagne" as a loanword.
  - Etienne's plan-stage decision (2026-10-06): Stock Creatures become Published Monsters.
  - The intent's constraint ("the only sources are the issue bodies") forbids recreating the missing spec from memory. It does not forbid recording a decision that Etienne makes and that the doc attributes. The doc marks each decision with its source.
  - The code-name map may also cite class names verified in the repository. Where all sources are silent, the doc says "not decided" and links the issue that will decide.
- **Doc layout.** `docs/domain.md` has these sections, in order:
  - Intro: a living document; each milestone 7 issue updates it when it ships (R1); it replaces the never-committed design spec.
  - `## Glossary`: the eight terms.
  - `## Target model`: Authored content (Campaign, Adventure, World, Page, House Rules; an Adventure has an optional default World, #92). Live play (Game: content queue of references, players, per-player character queues, session log, ActivePlay sessions 1:many, GM Notes; #93–#98). Sharing (a Module owns a full self-contained copy and never depends on its source, #100; an optional, severable source link only powers "Update Module", #101; import gives an owned copy, #102; Catalog, #104). The playlist states `active`, `queued-future`, `retired` (#93, #95). The divergence rule: "Create duplicate for game NAME" is the only way a Game diverges from its content, via the deep-copy engine that Module release and import reuse (#97).
  - `## Rename map`, `## Code names`, `## Translations`.
  - `## Rules` (R7 and invariants): game-agnostic terms, no City-of-Brass theming, no new Foundation-specific UI, vertical slice; a Game references content and never embeds it; GM Notes are never exported in a Module; a Module owns its copy, so editing or deleting the source never changes the Module or any import (#100); the only link back is the optional, severable source link for "Update Module" (#101); imports are independent copies that updates do not touch (#101, #102).
  - `## Deferred`, `## Not decided`, `## Sources`.
- **Prose format.** One line per paragraph and per list item in `docs/domain.md` (playbook rule 26). Each rule, decision and deferred item names its issue number.
- **Glossary format.** One list item per term: `- **Term** — definition (#issue).` Exactly eight terms: Game, Campaign, Adventure, Page, World, Module, Published, Catalog. The doc test counts these lines, so later issues cannot add a second definition by accident.
- **Stock Creatures.** #91 names Stock "NPCs/Creatures/Items/Spells" but the Published forms "NPC/Item/Monster/Spell". Etienne decided at the plan stage (2026-10-06): Stock Creatures become **Published Monsters**. The rename map records this as a #91 decision. The full map: Stock Adventures → Adventure Modules; Stock NPCs → Published NPCs; Stock Creatures → Published Monsters; Stock Items → Published Items; Stock Spells → Published Spells; browse surface → Catalog.
- **Code names.** The map, each verified in `engines/`: World → `Worldbuilder::District`; Campaign → `Campaignmanager::Campaign` (authored and live play fused until #94); Adventure → `Storybuilder::Adventure`; Page → `Campaignmanager::Page`, `Storybuilder::Page`, `Worldbuilder::Page`; Player → `Campaignmanager::Player`; Player Character → `Entitybuilder::ResidentCharacter`; ActivePlay session → `Activeplay::VirtualTable`; combatant → `Activeplay::Notable`; session log → `Campaignmanager::AdventureLog` (Page STI until #98); House Rules → `Campaignmanager::HouseRule`; GM Notes → `Campaignmanager::GameMasterNote`; Stock → `Storybuilder::StockAdventure`, `Entitybuilder::StockNpc`, `Entitybuilder::StockCreature`, `Rulebuilder::StockItem`, `Rulebuilder::StockSpell`. Game has no model yet (#93). Scene and Encounter are not models: a Page plays the Scene role, and launching ActivePlay from a Page realises an encounter (#105).
- **Not decided.** The doc lists, each with its deciding issue: GM Notes storage, Page-like STI on the Game or a private flag (#94, implementer's choice; never exported either way); the final key path for Game (#93 may move `domain.game`); `Rulebuilder::StockRule` and `Gallery::StockImage`, which exist in code but no issue maps.
- **Deferred items.** ActivePlay unlocks (pre-prepared sessions, pause/resume, session history — #96). Date planning and scheduling for the session log (#98). The "to be overcome" marker is not part of #105; #106 builds it.
- **Key path `domain.game`.** Neutral top-level scope, as the spec decides. It sorts between `campaignmanager` and `errors` in all three files, so `i18n-tasks normalize` stays clean.
- **Unused key.** `config/i18n-tasks.yml` gets `- 'domain.game'` under `ignore_unused`, with a comment: the key has no view until #93, and #93 removes this entry.
- **I18n test.** `test/i18n_test.rb` starts with `require "test_helper"` and `require "i18n/tasks"`, as the gem's template does (`templates/minitest/i18n_test.rb` in i18n-tasks 1.1.2). It uses the `I18n::Tasks::BaseTask` API for missing, unused and normalized keys, plus one test for the three Game translations. The gem's interpolation test is left out; the CI `i18n_check` job (`bin/i18n-tasks health`) still covers it.
- **Gem group.** `i18n-tasks` stays in the Gemfile `:development` group. This is the pattern in the gem's README: `group: :development` (line 27), then copy the Minitest template into `test/` (line 45). `config/boot.rb` runs `require "bundler/setup"`, which puts every group on the load path but loads nothing; the explicit `require "i18n/tasks"` loads the gem. Verified: under `RAILS_ENV=test`, `require "i18n/tasks"` loads 1.1.2. No Gemfile change.
- **Pinned and unpinned prose.** `DomainDocTest` pins every invariant that a later issue must not silently break: one definition per term, the living-document rule, the rename map, the World code name, the translations, the playlist states, "references, never embeds", the Module ownership rule, game-agnostic terms, and the deferrals. `## Not decided` and `## Sources` stay unpinned on purpose: they change most as issues ship, and a test there would only record churn. The `#93` comment in `config/i18n-tasks.yml` is checked in the diff review, not by a test.
- **Test style.** `test "behaviour" do` blocks, as in `test/deployment_test.rb` and `test/views/footer_test.rb`. Both new test files sit in `test/` root next to `deployment_test.rb`.
- **Issue edits.** Each body of #91–#106 has exactly one line `**Design spec (committed):** \`docs/specs/2026-06-30-domain-reframe-design.md\`` (verified 2026-10-06). The edit replaces only that line with `**Domain reference:** [\`docs/domain.md\`](https://github.com/eirvandelden/cityofbrass/blob/main/docs/domain.md)`. Nothing else in the body changes.
- **Issue edit timing.** The edits are posted only after this branch merges, so the link never returns a 404. The implement stage drafts the text and puts it in its report; it posts nothing. After the merge, Etienne approves each issue by number, and only then does a session run the post command (see `## After merge`).

## Integration points

- `config/locales/en.yml`, `nl.yml`, `it.yml` — read by Rails I18n and by `i18n-tasks`.
- `config/i18n-tasks.yml` — read by `bin/i18n-tasks health` (CI job `i18n_check`) and by the new `I18nTest`.
- `AGENTS.md` — `CLAUDE.md` is a symlink to it, so one edit covers both.
- GitHub issues #91–#106 on `eirvandelden/cityofbrass` — body edits via `gh issue edit`, only after merge and only after approval of each issue.

## Files that change

- `docs/domain.md` (new) — the living domain document.
- `test/domain_doc_test.rb` (new) — pins the doc's acceptance criteria and the AGENTS.md link.
- `test/i18n_test.rb` (new) — i18n-tasks checks plus the Game translations.
- `config/locales/en.yml` — add `domain:` → `game: Game`.
- `config/locales/nl.yml` — add `domain:` → `game: Spel`.
- `config/locales/it.yml` — add `domain:` → `game: Gioco`.
- `config/i18n-tasks.yml` — add `domain.game` under `ignore_unused`, with a #93 comment.
- `AGENTS.md` — one bullet in `## Domain`: the milestone 7 vocabulary and target model live in `docs/domain.md`.

Out of scope: models, migrations, views, controllers, routes; the Gemfile; CI workflows; existing Campaign translations (Italian already reads "Campagna", Dutch "campagne"); renaming Stock in code (#103); recreating the missing design spec.

## Order of work

Each doc step: add one test to `test/domain_doc_test.rb`, run `bin/rails test test/domain_doc_test.rb`, watch the new test fail, write the section, run again, green.

1. Test "defines each milestone term exactly once". Watch it fail: `docs/domain.md` does not exist. Write `## Glossary` with the eight terms. Green.
2. Test "says milestone issues update it as they ship" (R1). Red. Write the intro. Green.
3. Test "maps Stock content to Adventure Modules and Published entities" (Adventures → Adventure Modules, NPCs → Published NPCs, Creatures → Published Monsters, browse surface → Catalog). Red. Write `## Rename map`. Green.
4. Test "names District as the code name for World" (R4). Red. Write `## Code names`. Green.
5. Test "keeps Campagna in Italian and Campagne in Dutch" (R5). Red. Write `## Translations`. Green.
6. Test "says a Game references its content and never embeds it" (R3). Red. Write the Live play part of `## Target model`. Green.
7. Test "names the playlist states active, queued-future and retired" (R3). Red. Add the playlist paragraph to `## Target model`. Green.
8. Test "says a Module owns its copy and keeps only a severable source link" (R3, #100, #101). Red. Write the Authored content and Sharing parts of `## Target model`. Green.
9. Test "requires game-agnostic terms" (R7). Red. Write `## Rules`. Green.
10. Test "defers date planning, ActivePlay unlocks and the to-be-overcome marker" (R6). Red. Write `## Deferred`. Green.
11. Write `## Not decided` and `## Sources` (unpinned; see Design decisions). Re-run the file; still green.
12. Test "is linked from AGENTS.md" (R10). Red. Add the pointer bullet to `AGENTS.md`. Green.
13. Write `test/i18n_test.rb` with "Game reads Game, Spel and Gioco". Red: no key in any locale.
14. Add `domain.game: Game` to `en.yml` only. Run `test/i18n_test.rb`. Watch "no locale is missing a key" fail for nl and it. This proves that a removed Dutch key fails the check.
15. Add the key to `nl.yml` and `it.yml`. Missing-key and translation tests go green. Watch "every key is used" fail on `domain.game`.
16. Add the `ignore_unused` entry with its #93 comment. All of `test/i18n_test.rb` green, including "every locale file is normalized".
17. Run `bin/i18n-tasks health`. Expect all five checks green.
18. Run `bundle exec rubocop test/domain_doc_test.rb test/i18n_test.rb`. Fix every offence without disable comments.
19. Run the full suite: `bin/rails test`, then `bin/rails test:system`. Both green.
20. Re-read the full diff. Confirm no file under `app/`, `engines/` or `db/` changed, and the `ignore_unused` comment names #93.
21. Draft the issue edit: the old line, the new line, the list #91–#106, and the post command from `## After merge`. Put the draft in the implement report and the PR description. Post nothing.

## After merge

Not part of the implement stage. After the PR merges to `main`, show Etienne the draft. Post only to the issues Etienne approves by number, one command per issue:

```sh
gh issue view <n> --json body -q .body \
  | sed 's#^\*\*Design spec (committed):\*\* `docs/specs/2026-06-30-domain-reframe-design.md`$#**Domain reference:** [`docs/domain.md`](https://github.com/eirvandelden/cityofbrass/blob/main/docs/domain.md)#' \
  | gh issue edit <n> --body-file -
```

Check each with `gh issue view <n>`: the new line is present, the old line is gone, and nothing else changed.

## Risks

- **Doc tests pin prose.** A later issue that rewrites a definition may break a test. Intended: a change to a canonical term should be visible. The tests match short phrases, not whole sentences, to limit churn.
- **Duplicate i18n check.** `I18nTest` overlaps the CI `i18n_check` job. Accepted in the spec for local enforcement under `bin/rails test`. Cost: the unused-key scan of `app/` and `engines/` adds a few seconds.
- **Dev-group gem in tests.** If CI ever sets `BUNDLE_WITHOUT=development`, `require "i18n/tasks"` raises `LoadError`. Today it does not. Moving the gem to `:development, :test` was rejected: the gem's README pattern keeps it in `:development`, and a Gemfile change is outside this scope.
- **Doc contradicts an issue.** The Module rule must hold both #100 (no dependency on the source) and #101 (an optional, severable source link). The test "says a Module owns its copy and keeps only a severable source link" pins both halves.
- **Forgotten ignore entry.** If #93 forgets to drop `domain.game` from `ignore_unused`, a later unused key goes unnoticed. The config comment and `## Not decided` in the doc both name #93.
- **Dead link.** The issue links point at `main`. Posting waits until the merge, so the links resolve. If `docs/domain.md` moves later, the 16 issue links break.
- **Rejected:** a view that uses the key now (the intent forbids behaviour change); recreating the design spec from memory (the intent forbids it).

## Proof

- Each of Game, Campaign, Adventure, Page, World, Module, Published, Catalog is defined exactly once (R2) → `test/domain_doc_test.rb` "defines each milestone term exactly once"
- Stock Adventures become Adventure Modules; Stock NPCs become Published NPCs; Stock Creatures become Published Monsters (R4) → `test/domain_doc_test.rb` "maps Stock content to Adventure Modules and Published entities"
- Italian keeps "Campagna"; Dutch keeps "Campagne" (R5) → `test/domain_doc_test.rb` "keeps Campagna in Italian and Campagne in Dutch"
- A Game references its content and never embeds it (R3) → `test/domain_doc_test.rb` "says a Game references its content and never embeds it"
- Date planning is deferred (R6) → `test/domain_doc_test.rb` "defers date planning, ActivePlay unlocks and the to-be-overcome marker"
- `AGENTS.md` links the domain document (R10) → `test/domain_doc_test.rb` "is linked from AGENTS.md"
- "Game" reads Game / Spel / Gioco (R8) → `test/i18n_test.rb` "Game reads Game, Spel and Gioco"
- No missing, unused or unnormalized keys (R8, R9) → `test/i18n_test.rb` "no locale is missing a key", "every key is used", "every locale file is normalized"; plus `bin/i18n-tasks health`
- Removing the Dutch key fails the check (R8) → `test/i18n_test.rb` "no locale is missing a key", shown red in step 14
- Etienne approves the #92 edit before posting (R11) → manual gate: draft in step 21, posting in `## After merge`
- Every page renders as before; suite green (R12) → `bin/rails test` and `bin/rails test:system` green; diff has no file under `app/`, `engines/`, `db/`

Requirements beyond the acceptance criteria:
- Living document (R1) → `test/domain_doc_test.rb` "says milestone issues update it as they ship"
- Target model (R3) → `test/domain_doc_test.rb` "names the playlist states active, queued-future and retired", "says a Module owns its copy and keeps only a severable source link"
- Code names (R4) → `test/domain_doc_test.rb` "names District as the code name for World"
- Game-agnostic rule (R7) → `test/domain_doc_test.rb` "requires game-agnostic terms"
- Ignore entry names #93 (R9) → diff review, step 20

Per changed file, the unit tests expected:
- `docs/domain.md`: covered by `DomainDocTest` — one definition per term, living-document rule, rename map (including Creatures → Published Monsters), World code name, Campaign translations, Game references content, playlist states, Module ownership, game-agnostic terms, deferrals.
- `AGENTS.md`: `DomainDocTest` "is linked from AGENTS.md".
- `config/locales/{en,nl,it}.yml`: `I18nTest` "Game reads Game, Spel and Gioco", "no locale is missing a key", "every locale file is normalized".
- `config/i18n-tasks.yml`: `I18nTest` "every key is used".

Test setup: no fixtures or data. `DomainDocTest` reads `docs/domain.md` and `AGENTS.md` from `Rails.root`; private helpers `domain_doc`, `section(heading)` (text from `## heading` to the next `## `) and `definitions_of(term)` (count of `- **term** — ` lines). `I18nTest` requires `i18n/tasks`, builds `I18n::Tasks::BaseTask.new` in `setup`, and uses `I18n.t("domain.game", locale:)` for each locale.

---
Domain skills applied: rails-ui (i18n strings), rails-testing (Minitest, `test "..."` style), dependencies (no Gemfile change; dev-group gem is on the test load path via `bundler/setup` and loaded by an explicit `require`). Critiqued by Codex (`codex exec -p terra`, 2026-10-06); its findings are folded in.
