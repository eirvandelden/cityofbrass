# Plan: Dependabot alerts describe only gems the app runs

From `intent.md` (2026-11-08). Status: accepted.

## Context

GitHub Dependabot reports 626 open alerts. 623 come from the eleven `engines/*/Gemfile.lock` files (checked 2026-11-08 with `gh api repos/eirvandelden/cityofbrass/dependabot/alerts`: 41–59 per engine lockfile, 3 for `package-lock.json`, none for any `Gemfile` or `*.gemspec`). The app never loads those lockfiles: the root `Gemfile` loads every engine as a `path:` gem, so the root `Gemfile.lock` decides every gem version. This change removes the engine lockfiles, points every engine `Gemfile` at the app's bundle, and stops Dependabot from watching the engine directories. After merge, only the 3 dompurify alerts stay open; PR #160 closes those.

Open question from `intent.md`, answered: six engines (billing, entitybuilder, gallery, report, rulebuilder, worldbuilder) have a `test/dummy` app, but no engine can run on its own today. Example: `engines/billing/Gemfile` pins `rails ~> 6.1` while `engines/billing/billing.gemspec` requires `rails >= 7.1`, so that bundle cannot resolve. No CI job or script runs an engine on its own. Removing the engine lockfiles takes nothing away.

## Design

### Domain terms

Not affected: tooling change, no domain words. The repository has no glossary file.

### Diagrams

Not affected: no Ruby objects change.

### Signatures

Not affected: no Ruby class or method changes.

### Complexity

Not affected: no request path changes.

### Invariants

- The root `Gemfile` and `Gemfile.lock` do not change. Enforced by the diff review; checked with `git diff --exit-code origin/main -- Gemfile Gemfile.lock`.
- Every engine `Gemfile` resolves to the app's bundle (`eval_gemfile "../../Gemfile"`). Enforced by `test/engine_gemfile_test.rb`, which evaluates each engine `Gemfile` and asserts `drb` and `sqlite3` with `force_ruby_platform`; it passes unchanged because the root `Gemfile` has both.
- Git tracks no engine lockfile. Enforced by `.gitignore` entry `/engines/*/Gemfile.lock`.

### Alternatives

1. Point engine Gemfiles at the root bundle (chosen). Reuses the existing `engines/importer/Gemfile` pattern. One bundle for everything, no stale version ranges left, every existing test keeps its meaning.
2. Delete only the lockfiles (rejected). The engine Gemfiles keep stale `rails ~> 6.1` ranges that cannot resolve, and GitHub may still parse those ranges.
3. Delete the engine Gemfiles too (rejected). The engines' `bin/rails` sets `BUNDLE_GEMFILE` to the engine `Gemfile` and would point at a missing file. The `drb` test in `test/engine_gemfile_test.rb` would become empty. More scope for no extra alert reduction.

Architects were not run: the change has no object model to design.

## Design decisions

- `.github/dependabot.yml` changes. `intent.md` says this needs explicit approval; Etienne's acceptance of this plan is that approval.
- `test/lib/no_devise_test.rb` changes: `LOCK_FILES` drops `engines/importer/Gemfile.lock`, because that file is deleted and the test would raise `Errno::ENOENT`. The assertion still covers the root `Gemfile.lock`, the only lockfile the app runs. This edits a test because its input file is gone, not to make a failing assertion pass.
- The engine `test/dummy` apps stay. Removing them is out of scope.
- `intent.md` has no `## Decisions` section, so there is nothing to check against.

## Integration points

- GitHub dependency graph and Dependabot alerts: alerts for the deleted lockfiles close after the change reaches main.
- Dependabot version updates: the 10 engine `bundler` entries go away; the root `bundler`, `npm` and `github-actions` entries stay.
- Bundler: `engines/*/Gemfile` evaluated through `eval_gemfile`; the root bundle reads only the engines' gemspecs through `path:` and does not change.

## Files that change

- `engines/{activeplay,billing,campaignmanager,entitybuilder,gallery,importer,report,rulebuilder,storybuilder,support,worldbuilder}/Gemfile.lock` — deleted (11 files).
- `engines/{activeplay,billing,campaignmanager,entitybuilder,gallery,report,rulebuilder,storybuilder,support,worldbuilder}/Gemfile` — replaced with the importer's two lines (10 files):
  ```ruby
  # Engine tests boot the host app, so use the host bundle.
  eval_gemfile "../../Gemfile"
  ```
- `engines/importer/Gemfile` — unchanged.
- `.gitignore` — add `/engines/*/Gemfile.lock`.
- `.github/dependabot.yml` — remove the 10 `bundler` entries with `directory: "/engines/..."`.
- `test/lib/no_devise_test.rb` — `LOCK_FILES = [ "Gemfile.lock" ].freeze`.

## Order of work

No criterion needs a new test; this is configuration. Each step is one commit.

1. Delete the 11 engine lockfiles, add `/engines/*/Gemfile.lock` to `.gitignore`, and drop `engines/importer/Gemfile.lock` from `test/lib/no_devise_test.rb`. Run `bin/rails test test/lib/no_devise_test.rb`.
2. Replace the 10 engine Gemfiles with the `eval_gemfile` form. Run `bin/rails test test/engine_gemfile_test.rb`.
3. Remove the 10 engine entries from `.github/dependabot.yml`.
4. Run the full checks listed under Proof.

## Risks

- A stray `bundle install` inside an engine directory writes a new engine lockfile. The `.gitignore` entry keeps it out of git.
- GitHub may follow `eval_gemfile` and list root dependencies under each engine `Gemfile`. Today no alert comes from any `Gemfile`, and the root has no open alerts, so this adds nothing now. Check after merge.
- The engines' `test/dummy` apps still cannot boot on their own. That is true today and stays out of scope.

## Proof

- Engine lockfiles no longer exist → check: `git ls-files 'engines/*/Gemfile.lock'` prints nothing.
- Engine lockfiles cannot come back → check: `git check-ignore engines/billing/Gemfile.lock` prints the path.
- Dependabot watches only the root directories → check: `ruby -ryaml -e 'puts YAML.load_file(".github/dependabot.yml")["updates"].map { |u| u["directory"] }.uniq'` prints only `/`.
- The app's gem versions do not change → check: `git diff --exit-code origin/main -- Gemfile Gemfile.lock`.
- The engines still load and pass their tests inside the app → check: `bin/rails test` and `bin/rails test:system` green.
- Only the dompurify alerts stay open → check after merge: `gh api 'repos/eirvandelden/cityofbrass/dependabot/alerts?state=open&per_page=100' --paginate -q '.[].dependency.manifest_path' | sort | uniq -c` lists only `package-lock.json`.
- Invariant: every engine `Gemfile` resolves to the app's bundle, enforced by `eval_gemfile "../../Gemfile"` → `test/engine_gemfile_test.rb` `test_ruby_34_engines_include_drb`, `test_sqlite_uses_ruby_platform`.

Per changed file, the unit tests expected:
- `test/lib/no_devise_test.rb`: existing `devise is gone` keeps passing with the root lockfile only.
- No new tests: configuration has no tests.

Also run: `bundle exec rubocop`, `bin/pre_push_checks`, `bin/brakeman`, `bin/bundle-audit`.

Test setup: none.

Out of scope: the dompurify alerts (PR #160), the engine `test/dummy` apps, the engine gemspecs, and any gem version change.

---
Domain skills applied: dependencies.
