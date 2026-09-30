# Review: rails-8-1-4

## Round 1 — 2026-09-29 UTC — a36c35a

Checked: `Gemfile.lock` changes only the Rails gems (8.1.3.1 -> 8.1.4, exact pins); `BUNDLED WITH` is unchanged and there is no CHECKSUMS section. The `gem "rails", "~> 8"` line is unchanged. RuboCop found no offenses. `bin/rails test -f` gave 1151 runs, 0 failures, 0 errors, 0 skips. CI on PR #148 is green (RuboCop, Test, i18n).

Compliance: acceptance "Gemfile.lock resolves rails 8.1.4" is proven by the `Gemfile.lock` diff, not by a test (acceptable for a version bump). "Test suite and linters green" is proven by the local run and CI. `plan.md` has no `## Proof` section, so there are no named tests to check. No existing test was weakened, skipped, or deleted.

- [x] Nit: The stated reason for the change (json 3.x compatibility) is not demonstrated. The lockfile still resolves json 2.21.2, and app/engine/lib code makes no direct `ActiveSupport::JSON` calls, so the PR body's claim that `ActiveSupport::JSON.decode` "keeps working" is untested here — `Gemfile.lock:313` → fixed (Remove json pin and update json to 3.0.2)
- [x] Nit: The PR body defers the bundler-audit advisories (bcrypt, devise medium x2, jwt high, msgpack; reproduced locally) to "a separate PR", but no such PR or issue exists. Playbook rule 25 says not to leave pre-existing failures untracked; open an issue or PR for them — `Gemfile.lock:1` → dismissed: user decision, separate change being planned via /intent; out of scope for this PR
- [x] Nit: Neither the CI workflows nor `bin/pre_push_checks` (`lib/pre_push_checks.rb`) run bundler-audit or Brakeman (playbook §4). Brakeman is already in the Gemfile, but bundler-audit is not. This belongs in a separate PR, and changing `.github/workflows/` needs approval — `lib/pre_push_checks.rb:1` → dismissed: user decision, separate change being planned via /intent; out of scope for this PR

## Round 2 — 2026-09-29 UTC — 149f089

Scope: `d31399c` (Plan json 3 update) and `149f089` (Remove json pin and update json to 3.0.2), with the full `main...HEAD` diff as context.

Checked: `Gemfile` drops only the `gem "json", ">= 2.0"` pin and its comment. Between `a36c35a` and `HEAD`, `Gemfile.lock` changes only `json (2.21.2)` -> `json (3.0.2)` and the removed `json (>= 2.0)` DEPENDENCIES entry; nothing else moved. json's dependents in the lockfile, `activesupport (8.1.4)` (`json`, no constraint) and `rubocop (1.90.0)` (`json (>= 2.3)`), both accept 3.0.2. `bundle check` passes. `JSON::VERSION` loads as 3.0.2 under Bundler, and `ActiveSupport::JSON.decode` and `to_json` work in `rails runner`. RuboCop: 1055 files, no offenses. `bin/rails test -f`: 1151 runs, 4121 assertions, 0 failures, 0 errors, 0 skips, on json 3.0.2. bundler-audit reports the same five advisories as round 1 (bcrypt, devise x2, jwt, msgpack) and none for json.

Plan: the json paragraph in `plan.md` was followed. The pin was removed, the update was conservative (only json moved), and the tests, RuboCop and bundler-audit were run on json 3.x.

Compliance: "Gemfile.lock resolves rails 8.1.4" is still proven by `Gemfile.lock` (`actioncable`..`railties` at 8.1.4). "Test suite and linters green" is proven by the runs above. `plan.md` has no `## Proof` section, so there are no named tests to check. No existing test was weakened, skipped, or deleted.

Round 1 items:

- [x] Round 1 Nit (json 3.x compatibility not demonstrated): fixed. The lockfile now resolves json 3.0.2, and the suite and RuboCop are green on it — `Gemfile.lock:313` → fixed (Remove json pin and update json to 3.0.2)
- [x] Round 1 Nit (bundler-audit advisories untracked): dismissed — `Gemfile.lock:1` → dismissed: user decision, separate change being planned via /intent; out of scope for this PR
- [x] Round 1 Nit (no bundler-audit/Brakeman in CI or pre-push checks): dismissed — `lib/pre_push_checks.rb:1` → dismissed: user decision, separate change being planned via /intent; out of scope for this PR

New findings:

- [x] Nit: `spec.md` acceptance still names only the Rails 8.1.4 lockfile and green suite. It says nothing about json 3.x, which `plan.md` and `149f089` now aim at — `docs/changes/rails-8-1-4/spec.md:1` → dismissed: only in docs/changes/, which /finish deletes

No new findings in code, `Gemfile` or `Gemfile.lock`.
