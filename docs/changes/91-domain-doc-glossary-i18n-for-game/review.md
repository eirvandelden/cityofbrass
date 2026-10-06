# Review: 91-domain-doc-glossary-i18n-for-game

## Round 1 — 2026-10-06T19:03Z — dc9595d

State at review: `bin/rails test` green (1166 runs, 0 failures), `bundle exec rubocop` clean, `bin/i18n-tasks health` all five checks green. No `REVIEW.md` in the repo; default passes used. No file under `app/`, `engines/` or `db/` changed.

Traceability: every class in `## Code names` and `## Not decided` exists under `engines/` with the stated name. Every glossary definition matches #91. Every rule and deferral traces to #91–#106, `intent.md` or the attributed Stock Creatures decision, except the points below. Playbook rule 26: no hard-wrapped prose in `docs/domain.md`, `AGENTS.md` or the change folder.

Compliance (acceptance criterion → proof):

- Each of the eight terms is defined once (R2) → `test/domain_doc_test.rb` "defines each milestone term exactly once"
- Stock Adventures → Adventure Modules, Stock NPCs → Published NPCs (R4) → "maps Stock content to Adventure Modules and Published entities"
- Italian "Campagna", Dutch "Campagne" (R5) → "keeps Campagna in Italian and Campagne in Dutch"
- A Game references content and never embeds it (R3) → "says a Game references its content and never embeds it"
- Date planning deferred (R6) → "defers date planning, ActivePlay unlocks and the to-be-overcome marker"
- `AGENTS.md` links the doc (R10) → "is linked from AGENTS.md"
- Game / Spel / Gioco (R8) → `test/i18n_test.rb` "Game reads Game, Spel and Gioco"
- No missing, unused or unnormalized keys (R8, R9) → "no locale is missing a key", "every key is used", "every locale file is normalized"
- Removing the Dutch key fails the check (R8) → "no locale is missing a key"
- Etienne approves the #92 edit before posting (R11) → manual gate after merge; nothing in the diff, as planned
- Existing pages unchanged, suite green (R12) → full suite green; no `app/`, `engines/`, `db/` changes

Every test named in `plan.md` `## Proof` exists. No existing test was weakened, skipped or deleted.

- [ ] Nit: The translation lines say "decided in #91", but the #91 body only proposes Game/Spel/Gioco ("confirm") and leaves the Italian question open. The decisions come from `intent.md`, as `## Sources` and `plan.md` state. Attribute them to the #91 intent, like the Stock Creatures line attributes the plan stage. — `docs/domain.md:78` →
- [ ] Nit: "It holds no live-play state (#94)" applies to all authored content. #94 states this only for Campaign. Either scope the sentence to Campaign or drop the #94 citation for the other types. — `docs/domain.md:24` →
- [ ] Nit: "Dutch keeps Campagne" contradicts three existing nl keys that read "Campaign details", "Campaign menu" and "Campaign pagina's". The plan's out-of-scope note ("Dutch 'campagne'") is therefore only partly true. Propose a separate follow-up for those keys; not for this branch. — `config/locales/nl.yml:26` →
- [ ] Nit: The "references its content" test accepts "references the content" and does not check that the subject is a Game. Any sentence in `## Target model` with that phrase passes it. — `test/domain_doc_test.rb:40` →
