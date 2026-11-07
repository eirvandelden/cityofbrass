# Review: Update safe dependencies

## Round 1 — 2026-11-07T08:19:30Z — 594e52e

No findings. `REVIEW.md` does not exist, so the default Bugs, Security, Compliance and Design passes ran.

Compliance, per acceptance criterion in `intent.md`:

- `bin/rails runner 'puts 1'` prints `1` → verified after `bin/rails assets:precompile` wrote a `.sprockets-manifest-*.json`; then `bin/rails assets:clobber`.
- `bin/rails db:migrate:status` lists the migrations → verified with the manifest present against the test database (222 migrations `up`). The worktree's development database is empty, so in development the command reports "Schema migrations table does not exist yet", not the `create_additions` abort.
- `Gemfile.lock` lists `sprockets (4.4.1)`, `rails (8.1.4.1)` with all 12 sub-gems, and `stripe (18.4.3)`; `bundle outdated --strict --filter-minor --filter-patch` lists only `json` and `net-protocol` → verified.
- `bin/rails test` (1274 runs, 0 failures), `bin/rails test:system` (3 runs, 0 failures) and `bundle exec rubocop` (1081 files, no offenses) pass → verified.
- Brakeman and Bundler Audit report nothing new → verified. Bundler Audit finds no vulnerabilities. Brakeman 8.1.0 reports 8 warnings, all present under 8.0.5 on the same code by file and line; 8.0.5's `lib/pre_push_checks.rb` warning is gone. Format Validation fingerprints changed, but the repository has no `config/brakeman.ignore`.
- Four update commits, each touching only `Gemfile.lock` → verified with `git log --stat`.
- `plan.md`'s Proof names no new tests (lockfile change); no existing test was changed, skipped or deleted.

Invariants: `json (3.0.2)` and `net-protocol (0.2.2)` stay; no `revision:` line changes, so both git gems keep their revisions.

Allowlist deviations, both recorded in their commit messages and accepted as forced by in-scope updates:

- `a1befa4` also moves `rails-html-sanitizer`, `loofah` and `nokogiri`, because `actionview` 8.1.4.1 requires `rails-html-sanitizer >= 1.7.2`.
- `594e52e` removes the transitive `webrick`, because `ferrum` 0.20 no longer depends on it. No code in `app`, `lib`, `config`, `engines`, `test` or `bin` requires `webrick`; Capybara starts Puma.

Out of scope, not a finding: the engine lockfiles under `engines/*/Gemfile.lock` already drift from the root lockfile on `main` (`engines/importer` pins `rails 8.1.3.1`, `sprockets 4.2.2`, `json 2.19.5`), and the intent limits the change to the root `Gemfile.lock`.
