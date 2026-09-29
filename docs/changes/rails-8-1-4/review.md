# Review: rails-8-1-4

## Round 1 — 2026-09-29 UTC — a36c35a

Checked: `Gemfile.lock` changes only the Rails gems (8.1.3.1 -> 8.1.4, exact pins); `BUNDLED WITH` is unchanged and there is no CHECKSUMS section. The `gem "rails", "~> 8"` line is unchanged. RuboCop found no offenses. `bin/rails test -f` gave 1151 runs, 0 failures, 0 errors, 0 skips. CI on PR #148 is green (RuboCop, Test, i18n).

Compliance: acceptance "Gemfile.lock resolves rails 8.1.4" is proven by the `Gemfile.lock` diff, not by a test (acceptable for a version bump). "Test suite and linters green" is proven by the local run and CI. `plan.md` has no `## Proof` section, so there are no named tests to check. No existing test was weakened, skipped, or deleted.

- [ ] Nit: The stated reason for the change (json 3.x compatibility) is not demonstrated. The lockfile still resolves json 2.21.2, and app/engine/lib code makes no direct `ActiveSupport::JSON` calls, so the PR body's claim that `ActiveSupport::JSON.decode` "keeps working" is untested here — `Gemfile.lock:313` →
- [ ] Nit: The PR body defers the bundler-audit advisories (bcrypt, devise medium x2, jwt high, msgpack; reproduced locally) to "a separate PR", but no such PR or issue exists. Playbook rule 25 says not to leave pre-existing failures untracked; open an issue or PR for them — `Gemfile.lock:1` →
- [ ] Nit: Neither the CI workflows nor `bin/pre_push_checks` (`lib/pre_push_checks.rb`) run bundler-audit or Brakeman (playbook §4). Brakeman is already in the Gemfile, but bundler-audit is not. This belongs in a separate PR, and changing `.github/workflows/` needs approval — `lib/pre_push_checks.rb:1` →
