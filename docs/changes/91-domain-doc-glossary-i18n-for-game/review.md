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

## Round 2 — 2026-10-06T19:17Z — 60b2186

State at review: `bin/rails test` green (1167 runs, 0 failures), `bin/rails test:system` green (3 runs, 0 failures), `bundle exec rubocop` clean (1057 files), `bin/i18n-tasks health` all five checks green. Working tree clean. No `REVIEW.md` in the repo; default passes used.

Round 1 verification:

- Nit 1 (translation attribution) — resolved. `docs/domain.md:78–79` attribute the decisions to the `intent.md` of #91; `## Sources` matches.
- Nit 2 (#94 scope) — resolved. `docs/domain.md:24` now limits the rule to Campaign; new test "says a Campaign holds no live-play state" pins it.
- Nit 3 (Dutch "Campagne") — resolved by Etienne's decision: Dutch uses "Campaign". `docs/domain.md:80` and `## Sources` record it; aligning the existing nl strings is out of scope.
- Nit 4 (loose regex) — resolved. `test/domain_doc_test.rb:41` now requires the literal subject "A Game".

Fix commit 60b2186: doc-only and test-only changes; no `app/`, `engines/`, `db/` or locale changes. Bugs and Security passes: nothing found.

Compliance: the round-1 criterion map still holds. R5 now reads "Campagna in Italian, Campaign in Dutch" → `test/domain_doc_test.rb` "keeps Campagna in Italian and Campaign in Dutch". The added `assert_no_match` strengthens that test; no existing test was weakened, skipped or deleted. Every test named in `plan.md` `## Proof` still exists (one renamed for the Dutch decision).

- [ ] Nit: "a follow-up issue aligns them" names no issue, and none exists yet (`gh issue list --search campagne` finds only #91). Everywhere else the doc cites an issue number for future work. Open the issue and cite its number, or name the strings (`campaignmanager.campaigns.form.*`, `campaignmanager.menu_items.about.description`). — `docs/domain.md:80` →

## Round 3 — 2026-10-06T19:59Z — d50f35d

State at review: `bin/rails test test/domain_doc_test.rb test/i18n_test.rb` green (16 runs, 0 failures). Working tree clean; branch based on current `origin/main`. Full suite not re-run for a one-line doc change.

Round 2 verification:

- Nit (uncited follow-up issue) — resolved. `docs/domain.md:80` now cites #152, which exists and is open ("Use \"Campaign\" instead of \"campagne\" in the Dutch locale").

Fix commit d50f35d: one line changed in `docs/domain.md`; nothing else. Bugs, Security and Compliance passes: nothing found. The criterion map from rounds 1 and 2 still holds.

Nothing found.
