# Plan: Update safe dependencies

From `intent.md` (2026-11-06). Status: accepted.

## Context

Every `rails` command aborts with `ArgumentError: unknown keyword: create_additions` from `json-3.0.2/lib/json/common.rb:302`. `sprockets` 4.2.2 passes `create_additions: false` to `JSON.parse` in `lib/sprockets/manifest.rb:318`, `npm.rb:40` and `bower.rb:49`, and `json` 3.0.2 dropped that keyword.

The failure only appears when `public/assets` holds a `.sprockets-manifest-*.json`. The main checkout has one; a fresh worktree does not, so `bin/rails runner 'puts 1'` prints `1` there today. Every boot check in this plan therefore runs `bin/rails assets:precompile` first. `public/assets` is git-ignored (global ignore), and `bin/rails assets:clobber` removes it afterwards.

Versions today (checked with `bundle outdated --strict --filter-minor --filter-patch`, Bundler 2.7.2, Ruby 3.4.9): `sprockets` 4.2.2 (4.4.1 available), `rails` 8.1.4 (8.1.4.1 available), and the gems listed per commit below.

## Design

### Domain terms

Not affected: the change touches `Gemfile.lock` only and introduces no domain term.

### Diagrams

Not affected: no class, table or flow changes.

### Signatures

Not affected: no Ruby method changes, apart from possible mechanical cop fixes in commit 4, which keep their signatures.

Not checked: the change has no new or changed method signatures.

### Complexity

Not affected: no request path changes. The work is four resolver runs, one per commit.

### Invariants

- `json` stays at 3.0.2 in `Gemfile.lock`. `--conservative` keeps unnamed shared dependencies at their locked version, and `json` is never named. `--conservative` is not a hard guarantee: the resolver can still relax an unnamed gem to solve a conflict. The exact-version check and the per-commit allowlist (see Order of work) enforce it.
- The git-sourced gems `rubocop-eirvandelden` and `exception_notification-campfire-once` keep their `revision:` lines. Enforced by never naming them and never using `--group`.
- No gem changes major version, and `net-protocol` stays at 0.2.2. Enforced by `--strict` with `--minor` or `--patch`, and by never naming `net-protocol`.
- Each commit touches only `Gemfile.lock` (commit 4 may add mechanical cop fixes), and the lockfile diff changes only the gems named in that commit's command. Checked with `git diff --stat` and the allowlist check before each commit.

### Alternatives

1. Chosen: name every gem explicitly per commit, with `--conservative --strict` and `--minor` (or `--patch` for Rails). Bundler moves the named gems and keeps the others locked unless a conflict forces it; the allowlist check catches any such extra move, so each commit holds exactly the gems it claims.
2. Rejected: short commands without `--conservative` (`bundle update rails --patch --strict` and similar), which unlock each named gem's whole dependency tree. Fewer hand-typed names, but a patch pass unlocks `json` through `activesupport` and `rubocop`. It stays at 3.0.2 only because no 3.0.3 exists today. Transitive gems also land in whichever commit unlocks them first, which blurs the commit split.
3. Rejected: `bundle update --group development test` for commit 4. It names every gem in the group, `rubocop-eirvandelden` included, so that git gem would move to a new revision against the intent.

## Design decisions

- `brakeman`, `cuprite` and `ferrum` go in commit 4. They are development and test tooling, and the acceptance criterion on `bundle outdated` needs them updated. The intent's commit-4 list does not name them, and commit 3 is for runtime gems. `cuprite` 0.17 pins `ferrum ~> 0.17.0`, so the two move together.
- Transitive gems used only by tooling (`parser`, `regexp_parser`, `parallel`, `unicode-display_width`, `unicode-emoji`, `addressable`) go in commit 4. All other transitive gems go in commit 3.
- `cuprite` 0.17 → 0.20 and `ferrum` 0.17 → 0.20 are 0.x minor bumps. The intent excludes only `net-protocol` 0.4 among 0.x bumps, so they are in scope. If system tests break on them, commit 4 leaves them out and the report names them.
- If `--conservative` makes a resolution fail because a named gem needs a newer unnamed dependency, add only that dependency to the same command. Never drop `--conservative`, and never name `json` or `net-protocol`.
- `stripe` 18.4.0 → 18.4.3 is a patch inside the current major, so it is in scope. The intent excludes only `stripe` 20.
- No conflict with `intent.md`'s `## Decisions`: one pull request, autonomous delivery, no Codex review.

## Integration points

- Bundler resolution against `https://gem.coop`.
- Sprockets asset pipeline (`sprockets-rails` 3.5.2 accepts `sprockets >= 3.0.0`).
- Cuprite and Ferrum drive headless Chrome for system tests.
- RuboCop config inherits `rubocop-eirvandelden`, which sets `NewCops: enable`, so new cops in the RuboCop updates are active at once.

## Files that change

- `Gemfile.lock` — new versions, in four commits.
- Any Ruby file with a new, mechanical, small cop offense after commit 4 — the fix, in commit 4 only.
- No change to `Gemfile`, `.rubocop.yml`, `.rubocop_todo.yml`, migrations, schema files, deploy files or config files.

## Order of work

Run every command from the worktree root. `bundle update` installs the gems it resolves; if a later command reports a missing gem, run `bi` (never `bundle install`).

1. Reproduce the failure (the regression check, red): `bin/rails assets:precompile && bin/rails runner 'puts 1'`. Expect `ArgumentError: unknown keyword: create_additions` from either command. Then `bin/rails assets:clobber`. If it does not fail, stop and report.
2. Commit 1, `sprockets`:
   - `bundle update --conservative --minor --strict sprockets`
   - Expect `sprockets (4.4.1)` in `Gemfile.lock`.
   - Green check: `bin/rails assets:precompile && bin/rails runner 'puts 1' && bin/rails db:migrate:status`, then `bin/rails assets:clobber`.
   - Run the invariant checks (below), then commit: `Update sprockets to 4.4.1 for json 3 compatibility`.
3. Commit 2, Rails:
   - `bundle update --conservative --patch --strict rails actioncable actionmailbox actionmailer actionpack actiontext actionview activejob activemodel activerecord activestorage activesupport railties`
   - All 13 names are required: `rails` pins `= 8.1.4` on each sub-gem, so it cannot move alone under `--conservative`.
   - Expect `rails (8.1.4.1)` and every sub-gem at 8.1.4.1. `bundle outdated --filter-patch` compares only three version segments, so it does not show 8.1.4 → 8.1.4.1. Check exactly instead: for each of the 13 names, `grep -qx "    $gem (8.1.4.1)" Gemfile.lock`.
   - Run the boot check, then `bin/rails test`. Run the invariant checks, then commit: `Update rails to 8.1.4.1`.
4. Commit 3, runtime gems:
   - `bundle update --conservative --minor --strict bcrypt bigdecimal bootsnap msgpack jbuilder jwt kaminari kaminari-actionview kaminari-activerecord kaminari-core kt-paperclip aws-eventstream mini_magick mime-types-data mission_control-jobs omniauth hashie solid_cable solid_queue fugit et-orbi sqlite3 stripe terser execjs nokogiri loofah crass rails-html-sanitizer rack rack-test net-imap net-smtp date uri ffi io-console prettyprint rdoc rbs tilt`
   - `stripe` moves 18.4.0 → 18.4.3 (patch, inside major 18). `bundle outdated --strict --filter-minor --filter-patch` did not list it, so check it exactly: `grep -qx '    stripe (18.4.3)' Gemfile.lock`.
   - Run the boot check, then `bin/rails test`. Run the invariant checks, then commit: `Update runtime gems within their constraints`.
5. Commit 4, development and test tooling:
   - `bundle update --conservative --minor --strict rubocop rubocop-rails rubocop-minitest parser regexp_parser parallel unicode-display_width unicode-emoji spring listen meta_request brakeman cuprite ferrum addressable`
   - Run `bundle exec rubocop`. Fix new offenses only when they are mechanical and small (`bundle exec rubocop -a` on the named files, then read each hunk). Never add a disable comment or edit `.rubocop.yml` or `.rubocop_todo.yml`. Leave larger offenses unfixed and list them in the report.
   - Run `bin/rails test && bin/rails test:system`. `bin/rails test` excludes `test/system`, and CI runs `bin/rails test:system` separately. If system tests fail on Cuprite or Ferrum, revert those two gems to 0.17 with `git checkout Gemfile.lock` and re-run the command without `cuprite ferrum`, and report it.
   - Run the invariant checks, then commit: `Update development and test tooling`.
6. Final checks:
   - `bundle outdated --strict --filter-minor --filter-patch` lists only `json` and `net-protocol`. The per-commit check below catches a missed gem before its commit is made, so this final run only confirms.
   - `bundle outdated` shows the remaining majors and constrained gems only: `stripe`, `puma`, `marcel`, `prism`, `rouge`, `sass`, `terrapin`, `net-protocol`, `minitest`, `image_processing`, `foundation-rails`, `json`, plus transitive majors held by their parents (`aws-sdk*`, `climate_control`) and the two git gems.
   - `bundle exec rubocop`, `bin/rails test`, `bin/rails test:system`, `bundle exec brakeman --no-pager`, `bundle exec bundle-audit check --update`.
   - `git log --oneline main..HEAD` shows the docs commit and the four update commits; `git diff --stat main..HEAD -- . ':!docs'` shows only `Gemfile.lock` plus any commit-4 cop fixes.

Invariant checks, run before each commit:

- `git diff --stat` shows only `Gemfile.lock` (commit 4: plus cop-fixed files).
- `grep -qx '    json (3.0.2)' Gemfile.lock` exits 0.
- `grep -qx '    net-protocol (0.2.2)' Gemfile.lock` exits 0.
- `! git diff Gemfile.lock | grep -q 'revision:'` exits 0.
- Allowlist: `git diff -U0 Gemfile.lock | grep -E '^[-+]    [a-z0-9_.-]+ \(' | sed -E 's/^[-+] +([^ ]+) .*/\1/' | sort -u` prints only names from this commit's `bundle update` command. Any other name is an unplanned move: stop, find which named gem forced it, and either add it to the command on purpose (never `json` or `net-protocol`) or report it.
- `bundle outdated --strict --filter-minor --filter-patch` no longer lists any gem this commit's group owns (commit 3: runtime gems; commit 4: everything except `json` and `net-protocol`). A gem still listed goes into this commit's command before committing.

## Risks

- `cuprite`/`ferrum` 0.17 → 0.20 can break system tests. Mitigation in step 5.
- New RuboCop cops (`NewCops: enable`) can report many offenses. Only mechanical, small ones are fixed; the rest are reported.
- `nokogiri` and `ffi` have several platform entries in `Gemfile.lock`; every platform must resolve. `sqlite3` builds from source (`force_ruby_platform`), so its update compiles a native extension.
- `sprockets` 4.4 may need newer `rack` or `concurrent-ruby`. If `--conservative` fails to resolve, add only that gem to commit 1's command.
- The boot check needs `public/assets` populated; without `assets:precompile` the check passes even on the broken lockfile.
- Rejected: updating `json` to 3.1.0 instead of `sprockets` (out of scope per intent), and the short-command design (see Alternatives).

## Out of scope

- Major updates: `stripe` 20, `puma` 8, `marcel` 2, `prism` 2, `rouge` 5, `sass` 3.7, `terrapin` 1, `net-protocol` 0.4.
- Gems blocked by a `Gemfile` constraint: `minitest` 6, `image_processing` 2, `foundation-rails` 6.
- `json` 3.1.0, the git-sourced gems, npm packages, and any `Gemfile` change.
- The uncommitted changes to `db/cable_schema.rb`, `db/queue_schema.rb` and `bin/ci` in the main checkout.

## Proof

No criterion needs a new test: the change is a lockfile (configuration) change. Each criterion names its check.

- `bin/rails runner 'puts 1'` prints `1` → check: `bin/rails assets:precompile && bin/rails runner 'puts 1'`, red before commit 1 (step 1), green after it; then `bin/rails assets:clobber`.
- `bin/rails db:migrate:status` lists the migrations → check: `bin/rails assets:precompile && bin/rails db:migrate:status` after commit 1; then `bin/rails assets:clobber`.
- `Gemfile.lock` lists `sprockets 4.4.1` and `rails 8.1.4.1`, and nothing else in scope is outdated → check: `grep -qx '    sprockets (4.4.1)' Gemfile.lock`, the 13 exact Rails checks from step 3, `grep -qx '    stripe (18.4.3)' Gemfile.lock`, and `bundle outdated --strict --filter-minor --filter-patch` lists only `json` and `net-protocol`.
- `bin/rails test` and `bundle exec rubocop` pass → check: `bin/rails test`, `bin/rails test:system` and `bundle exec rubocop` exit 0 after commit 4.
- Brakeman and Bundler Audit report nothing new → check: `bundle exec brakeman --no-pager` and `bundle exec bundle-audit check --update` report no warning that `main` lacks.
- The pull request holds four commits touching only `Gemfile.lock` (plus commit-4 cop fixes) → check: `git log --stat main..HEAD`.
- Invariant: `json` stays at 3.0.2, enforced by never naming it and by the per-commit allowlist check → check: `grep -qx '    json (3.0.2)' Gemfile.lock` before each commit.
- Invariant: git gems keep their revisions, enforced by never naming them → check: `! git diff main -- Gemfile.lock | grep -q 'revision:'` exits 0.

Per changed file, the unit tests expected:

- `Gemfile.lock`: none (configuration).
- Commit-4 cop fixes: none new; the existing suite covers the touched code and must stay green.

Test setup: the existing suite; Chrome or Chromium for the Cuprite system tests.

---
Domain skills applied: dependencies, rails-upgrade (patch-level Rails bump only).

## Critique

### Round 1 (codex terra)

- Commit 3 omits `stripe`, which has the safe patch 18.4.3; the intent excludes only `stripe` 20 → fixed (added `stripe` to commit 3's command, an exact check for version 18.4.3, and a design decision)
- `bundle outdated --filter-minor --filter-patch` compares three segments and cannot show Rails 8.1.4 → 8.1.4.1 → fixed (step 3 and Proof check all 13 Rails gems with exact `grep -qx` lines)
- The invariants overstate `--conservative`, the greps only prove the gems exist, and the revision grep exits non-zero on success → fixed (invariant text now says the resolver can relax unnamed gems; checks use `grep -qx` and a negated revision grep; a per-commit allowlist check on the lockfile diff was added)
- `bin/rails test` excludes `test/system`, so the Cuprite and Ferrum bump is not exercised → fixed (step 5, final checks and Proof run `bin/rails test:system` as well, matching CI)
