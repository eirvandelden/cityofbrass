# Delivery account: update-safe-dependencies

## Behaviour delivered

Every `rails` command boots again. `sprockets` moved from 4.2.2 to 4.4.1, which no longer passes `create_additions:` to `JSON.parse`, so `json` 3.0.2 accepts it. Rails and its sub-gems moved to 8.1.4.1, and the other patch and minor updates inside their constraints landed in two more commits. Only `Gemfile.lock` changed.

## Evidence

- Before commit 1, `bin/rails runner 'puts 1'` with a Sprockets manifest present aborted with `unknown keyword: create_additions`. After it, the command prints `1`. The coordinator reran it on the final commit.
- `db:migrate:status` lists the migrations instead of aborting.
- The lockfile holds `sprockets (4.4.1)` and `rails (8.1.4.1)`. `json (3.0.2)`, `net-protocol (0.2.2)` and both git gem revisions are unchanged.
- `bundle outdated --strict --filter-minor --filter-patch` lists only `json` and `net-protocol`, the two intended exclusions.

## Check results

- `bin/rails test`: 1274 runs, 4403 assertions, 0 failures, 0 errors, 0 skips. The coordinator reran the full suite.
- `bin/rails test:system`: 3 runs, 0 failures.
- `bundle exec rubocop`: 1081 files, no offenses.
- Bundler Audit: no vulnerabilities.
- Brakeman 8.1.0: 8 warnings on the commit before the updates and on the final commit, with identical fingerprints. No warning is new.

## Deviations from the plan

- Commit 2 also moved `rails-html-sanitizer`, `loofah` and `nokogiri`, because `actionview` 8.1.4.1 requires `rails-html-sanitizer >= 1.7.2`.
- Commit 4 removed the transitive `webrick`, because `ferrum` 0.20 no longer depends on it.
- `brakeman`, `cuprite`, `ferrum` and `stripe` 18.4.3 are in scope as minor or patch bumps, although the intent did not name them.
- The engine lockfiles under `engines/*/Gemfile.lock` already drift from the root lockfile on `main`. They stay out of scope.

## Review outcome

One Claude round, no findings, no Codex round (`Codex review: no`). The review is committed and pushed.
