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

- [x] Nit: The translation lines say "decided in #91", but the #91 body only proposes Game/Spel/Gioco ("confirm") and leaves the Italian question open. The decisions come from `intent.md`, as `## Sources` and `plan.md` state. Attribute them to the #91 intent, like the Stock Creatures line attributes the plan stage. — `docs/domain.md:78` → fixed (Correct domain doc sources and the Dutch Campaign word)
- [x] Nit: "It holds no live-play state (#94)" applies to all authored content. #94 states this only for Campaign. Either scope the sentence to Campaign or drop the #94 citation for the other types. — `docs/domain.md:24` → fixed (Correct domain doc sources and the Dutch Campaign word)
- [x] Nit: "Dutch keeps Campagne" contradicts three existing nl keys that read "Campaign details", "Campaign menu" and "Campaign pagina's". The plan's out-of-scope note ("Dutch 'campagne'") is therefore only partly true. Propose a separate follow-up for those keys; not for this branch. — `config/locales/nl.yml:26` → fixed (Correct domain doc sources and the Dutch Campaign word); Dutch uses "Campaign" (Etienne, 2026-10-06), and #152 aligns the old strings
- [x] Nit: The "references its content" test accepts "references the content" and does not check that the subject is a Game. Any sentence in `## Target model` with that phrase passes it. — `test/domain_doc_test.rb:40` → fixed (Correct domain doc sources and the Dutch Campaign word)

## Round 2 — 2026-10-06T19:17Z — 60b2186

State at review: `bin/rails test` green (1167 runs, 0 failures), `bin/rails test:system` green (3 runs, 0 failures), `bundle exec rubocop` clean (1057 files), `bin/i18n-tasks health` all five checks green. Working tree clean. No `REVIEW.md` in the repo; default passes used.

Round 1 verification:

- Nit 1 (translation attribution) — resolved. `docs/domain.md:78–79` attribute the decisions to the `intent.md` of #91; `## Sources` matches.
- Nit 2 (#94 scope) — resolved. `docs/domain.md:24` now limits the rule to Campaign; new test "says a Campaign holds no live-play state" pins it.
- Nit 3 (Dutch "Campagne") — resolved by Etienne's decision: Dutch uses "Campaign". `docs/domain.md:80` and `## Sources` record it; aligning the existing nl strings is out of scope.
- Nit 4 (loose regex) — resolved. `test/domain_doc_test.rb:41` now requires the literal subject "A Game".

Fix commit 60b2186: doc-only and test-only changes; no `app/`, `engines/`, `db/` or locale changes. Bugs and Security passes: nothing found.

Compliance: the round-1 criterion map still holds. R5 now reads "Campagna in Italian, Campaign in Dutch" → `test/domain_doc_test.rb` "keeps Campagna in Italian and Campaign in Dutch". The added `assert_no_match` strengthens that test; no existing test was weakened, skipped or deleted. Every test named in `plan.md` `## Proof` still exists (one renamed for the Dutch decision).

- [x] Nit: "a follow-up issue aligns them" names no issue, and none exists yet (`gh issue list --search campagne` finds only #91). Everywhere else the doc cites an issue number for future work. Open the issue and cite its number, or name the strings (`campaignmanager.campaigns.form.*`, `campaignmanager.menu_items.about.description`). — `docs/domain.md:80` → fixed (Link the Dutch Campaign follow-up issue in the domain doc)

## Round 3 — 2026-10-06T19:59Z — d50f35d

State at review: `bin/rails test test/domain_doc_test.rb test/i18n_test.rb` green (16 runs, 0 failures). Working tree clean; branch based on current `origin/main`. Full suite not re-run for a one-line doc change.

Round 2 verification:

- Nit (uncited follow-up issue) — resolved. `docs/domain.md:80` now cites #152, which exists and is open ("Use \"Campaign\" instead of \"campagne\" in the Dutch locale").

Fix commit d50f35d: one line changed in `docs/domain.md`; nothing else. Bugs, Security and Compliance passes: nothing found. The criterion map from rounds 1 and 2 still holds.

Nothing found.

## Round 4 — 2026-10-08T15:10Z — 28d0451

State at review: `bin/rails test test/domain_doc_test.rb test/i18n_test.rb` green (19 runs, 0 failures), `bundle exec rubocop` on both test files clean, `bin/i18n-tasks health` green. Working tree clean; branch based on current `origin/main`. Full suite not re-run: commit 28d0451 changes only `docs/domain.md` and `test/domain_doc_test.rb`. No `REVIEW.md` in the repo; default passes used.

Round 3 left no open finding. Commit 28d0451 adds Etienne's 2026-10-08 decisions: a user owns a Game, the doc never says Resident, and three old code names map to new names. Security pass: nothing found.

Compliance: the criterion map from rounds 1–3 still holds. Every test named in `plan.md` `## Proof` still exists. The commit adds three tests and weakens, skips or deletes none. The 2026-10-08 decisions go beyond `intent.md` (its rename map covers only Stock and the Catalog); see the last Nit.

- [x] Important: "`Resident` → User" maps onto a class name that already exists with another meaning. `User` is the Devise login record; `User has_one :resident` (`app/models/user.rb:15`), and all content belongs to `Resident` (for example `belongs_to :resident` in `engines/campaignmanager/app/models/campaignmanager/campaign.rb:16`). "A Game is owned by a user" (`docs/domain.md:31`) therefore does not tell #93 which record owns a Game: `belongs_to :user` would break the pattern of every other owned record. `## Code names` also has no line for the user concept. Add one (for example "user, as content owner → `Resident`; login → `User`") and say which record a Game belongs to, or list it under `## Not decided` with #93. — `docs/domain.md:58` → fixed (Record the Resident merge and City-name renames in the domain docs)
- [x] Nit: The three new rename-map lines cite no issue for the code rename, unlike the Stock lines (#103). `## Code names` keeps `Worldbuilder::District` and `Entitybuilder::ResidentCharacter` with no plan to change them. The doc's own rule (line 7) asks for "not decided" plus the issue that decides it. Say whether the classes get renamed and link the issue, or state that the map is vocabulary only. — `docs/domain.md:58-60` → fixed (Record the Resident merge and City-name renames in the domain docs)
- [x] Nit: `AGENTS.md` (and `CLAUDE.md`, its symlink) still defines **Resident** as the content owner and uses "residents" in five places, one line above the new pointer to `docs/domain.md`, which now says "never `Resident`". Agents read `AGENTS.md` first and get the opposite rule. Align the `## Domain` bullets with the doc, or propose that for a follow-up. — `AGENTS.md:12` → fixed (Record the Resident merge and City-name renames in the domain docs)
- [x] Nit: The test name says "Resident only inside code names", but the check strips every backtick span. Line 31 quotes `` `resident` `` as an issue word, not a code name, and any future backticked phrase passes. Rename the test to match what it checks ("says resident only inside backticks"), or narrow the strip to `Resident…` class names. — `test/domain_doc_test.rb:56` → dismissed: Etienne limited this session to documentation, so the test code stays as it is
- [x] Nit: The 2026-10-08 decisions live only in the doc's `## Sources` line. Unlike the 2026-10-06 Dutch decision (round 2), nothing in the change folder records them. Note them in this folder (for example in `plan.md` design decisions) so the trail from intent to doc stays complete. — `docs/domain.md:115` → fixed (Record the Resident merge and City-name renames in the domain docs)

## Round 5 — 2026-10-09T06:50Z — 5155fd9

State at review: `bin/rails test test/domain_doc_test.rb test/i18n_test.rb` green (19 runs, 81 assertions, 0 failures), `bundle exec rubocop` on both test files clean, `bin/i18n-tasks health` green. Working tree clean. Full suite not re-run: commit 5155fd9 changes only `AGENTS.md`, `docs/domain.md`, `plan.md` and `review.md`. No `REVIEW.md` in the repo; default passes used. The branch is behind `origin/main` by the #154 merge (`182565a`); `git merge-tree` shows no conflict. Rebase before the next push (playbook rule 20).

Round 4 verification:

- Important (which record owns a Game) — resolved. `docs/domain.md:31` and `:77` say a Game belongs to `Resident` until #155; `## Code names` has a user line (`:69`).
- Nit (rename lines cite no issue) — resolved. The three lines cite #155 and #156. Both issues exist and are open, and their bodies match the doc.
- Nit (`AGENTS.md` defines Resident) — partly resolved; see the first Nit below.
- Nit (test name) — dismissed by Etienne; not re-raised.
- Nit (decisions only in `## Sources`) — resolved. `plan.md` design decisions record the 2026-10-08 decisions.

Bugs and Security passes: nothing found. "Residents" as signed-in users matches the code (`app/models/concerns/keys_to_campaignmanager.rb:14`, after the `current_user.nil?` guard).

Compliance: the criterion map from rounds 1–4 still holds. Every test named in `plan.md` `## Proof` still exists; the commit changes no test. No file under `app/`, `engines/` or `db/` changed.

- [x] Nit: `## What this is` in `AGENTS.md` (and `CLAUDE.md`, its symlink) still says a user "creates a **Resident** — their identity in the world" and that `app/` "handles users, residents". The `## Domain` bullet four lines below now says Resident is only the content-owner record and to "say user". Agents read this paragraph first. Align it with the bullet. — `AGENTS.md:5` → fixed (Align AGENTS.md and the domain doc with the Resident and District renames)
- [x] Nit: The doc dates the `Resident` names (user line `:69` and Game line `:77` say "until #155") but not the #156 names. The glossary says World is "called "District" in code (#91)", and `World → Worldbuilder::District` and `Player Character → Entitybuilder::ResidentCharacter` have no end date. `## Rules` (`:89`) calls all three old code names. Add "until #156" to those three lines. — `docs/domain.md:15` → fixed (Align AGENTS.md and the domain doc with the Resident and District renames)
- [x] Nit: The first Live play bullet has a 34-word second sentence with a semicolon and a parenthesis. Playbook rule 1 asks for at most 20 words per sentence. Split it, for example: "Until #155 merges `Resident` into `User`, a Game belongs to the user's `Resident`, like all other owned content. #155 then moves it." — `docs/domain.md:31` → fixed (Align AGENTS.md and the domain doc with the Resident and District renames)
- [x] Nit: The edited visibility line says "Public / Residents / Private throughout", but Campaign also has `Friends` (`engines/campaignmanager/app/models/campaignmanager/campaign.rb:8`). This was wrong before this branch. Propose a separate fix; not for this branch. — `AGENTS.md:18` → fixed (Align AGENTS.md and the domain doc with the Resident and District renames)
