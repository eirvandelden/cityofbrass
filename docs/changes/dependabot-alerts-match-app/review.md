# Review: dependabot-alerts-match-app

## Round 1 — 2026-11-10T21:00:49Z — af45e3f

No `REVIEW.md` or `REVIEW.local.md` at the repository root; default passes used. Checks run: `bin/rails test` (1274 runs, 0 failures, 0 errors, 0 skips), `bin/rails test test/engine_gemfile_test.rb test/lib/no_devise_test.rb` green, `bundle exec rubocop` on the changed files clean. `bin/rails test:system` not run in this round.

Bugs: none. Every engine `Gemfile` evaluates through `eval_gemfile "../../Gemfile"`, and its path gems resolve against the repository root (checked: `engines/worldbuilder/Gemfile` resolves `rulebuilder` to `<root>/engines/rulebuilder`). The Dockerfile bundles from the root `Gemfile` only.

Security: none. No gem version changes; `git diff --exit-code origin/main -- Gemfile Gemfile.lock` exits 0.

Compliance: outcome "the engine lockfiles no longer produce alerts" → `git ls-files 'engines/*/Gemfile.lock'` prints nothing, `git check-ignore engines/billing/Gemfile.lock` prints the path. "Dependabot watches only the root directories" → `.github/dependabot.yml` lists only `/`. "Gem versions do not change" → root `Gemfile` and `Gemfile.lock` unchanged. "Engines still load and pass their tests inside the app" → `bin/rails test` green. "Only dompurify alerts stay open" → post-merge check, not verifiable before merge. Proof tests `test_ruby_34_engines_include_drb` and `test_sqlite_uses_ruby_platform` exist and pass. `test/lib/no_devise_test.rb` drops the deleted importer lockfile from its input; `plan.md` records why, and the assertion keeps its meaning for the root lockfile. No test weakened, skipped or deleted.

Design: no public methods, no queries, no glossary file. Nothing to report.

- [ ] Nit: `.rubocop_todo.yml` still excludes `engines/activeplay/Gemfile` from `Layout/TrailingEmptyLines`; the new file has no trailing blank line, so the exclusion is a leftover of this change — `.rubocop_todo.yml:841` → fixed (Drop stale Gemfile exclusion from rubocop todo)

## Round 2 — 2026-11-20T00:00:00Z — c176967

Base: `origin/upgrade-ruby-4-0-9` (d8b976b). `git fetch origin` failed (no network access), so the local ref was used. No `REVIEW.md` or `REVIEW.local.md`; default passes used. Checks run under Ruby 4.0.9: `bin/rails test test/engine_gemfile_test.rb test/lib/no_devise_test.rb` (4 runs, 0 failures), `bundle exec rubocop` (1112 files, no offenses). The full suite (1480 runs), brakeman and bundle-audit were taken from the caller's report, not re-run.

Round 1 nit: closed by c176967; `engines/activeplay/Gemfile` is gone from `.rubocop_todo.yml` and no engine Gemfile entry remains there.

Bugs: none. Ten engine Gemfiles are identical (`eval_gemfile "../../Gemfile"`); `engines/importer/Gemfile` was already that form.

Security: none. `git diff --exit-code origin/upgrade-ruby-4-0-9 -- Gemfile Gemfile.lock` exits 0.

Compliance: no tracked engine lockfile (`git ls-files 'engines/*/Gemfile.lock'` empty); `git check-ignore engines/billing/Gemfile.lock` prints the path; `.github/dependabot.yml` has only `/` directories; the rebase did not change root gem versions; the `engine_gemfile_test.rb` proof tests exist and pass; `no_devise_test.rb` edit matches `plan.md`. The post-merge alert check cannot be verified before merge. No test weakened, skipped or deleted.

Design: no public methods, queries or glossary terms. Nothing to report.

Nothing found.
