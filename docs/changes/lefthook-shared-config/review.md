# Review: lefthook-shared-config

## Round 1 — 2026-11-26T14:15Z — f121360

- [ ] Important: `minitest-changed-tests` reads `{push_files}`, so it does not run "exactly the files `bin/pre_push_checks` ran" (plan, Alternative 1). Lefthook 2.2.2 diffs HEAD against the remote branch, checked in a scratch repository. The first push of a new branch lists every test file in the repository: 265 files here, system tests included. The full suite takes about 10 minutes (622 s). After a rebase and a `--force-with-lease` push (rule 20), it lists the test files that main changed, and it skips the branch's own test files. A later push lists only the files in the new commits. `bin/pre_push_checks` used `origin/main...HEAD`. The merged config already provides that list as `{files}`: the shared hook-level `files:` diffs against the merge base with origin's default branch and leaves out deleted files. The shared jobs use `{files}` for this reason, as the comment on that `files:` key says. With `{files}`, the `[ -f "$file" ]` loop has nothing left to filter. — `lefthook.yml:27` → fixed (Run the branch's changed test files on push, not lefthook's push file list)
- [ ] Nit: Proof step 4 ran the job through `lefthook run`, which takes the file list from the command line. That check never covers how `{push_files}` gets its list during a real push. After the fix, prove it with a first push of a new branch that changes one test file, and with a push after a rebase. Check that only the branch's own test files run. — `docs/changes/lefthook-shared-config/plan.md:139` → fixed (Run the branch's changed test files on push, not lefthook's push file list)

Passes:

- Bugs: the finding above. No other defect found in the job script. A deleted test file is skipped, and an empty list exits 0.
- Security: nothing found. The remote is the owner's own dotfiles repository on `ref: main`, as the plan accepts under Risks.
- Compliance:
  - `lefthook.yml` starts with the Starter config → the `remotes:` block matches `new-repo-setup` item 3. `lefthook dump` shows the shared jobs, and `minitest-changed-tests` sits under `pre-push`.
  - A commit from a linked worktree succeeds → a manual check, outside the diff. The branch commits exist; the reviewer did not repeat the check.
  - A push from a linked worktree succeeds → `origin/lefthook-shared-config` holds HEAD.
  - The repo test job runs pushed test files, engine tests included → the glob is correct. The file list is wrong; see the Important finding.
  - Nothing references the removed script → `grep -rn "pre_push_checks\|PrePushChecks" --exclude-dir=docs` returns nothing.
  - Suites stay green → `bundle exec rubocop`: 1109 files, no offenses. `bin/rails test`: 1473 runs, 0 failures, 0 errors, 0 skips, in 622 s.
  - Deleted tests: `test/lefthook_config_test.rb` and `test/lib/pre_push_checks_test.rb` are deleted with the code and config they pinned, as the plan decided. No test that still applies was weakened or skipped.
- Design: no Ruby method is added. There is no Law of Demeter or N+1 concern. No glossary `Avoid:` word is used. The invariant holds: no repo job shares a name with a shared job.

## Round 2 — 2026-11-26T15:49Z — a799f7f

- [ ] Nit: The branch is 10 commits behind `origin/main`. Main moves `.ruby-version` to 4.0.9 (#168). The plan's Integration points, Risks and the worktree commit and push checks all use Ruby 3.4.9. Under Ruby 4.0.9, the shared jobs' bare `rubocop` resolves to 1.92.3, and `Gemfile.lock` on main pins 1.92.2. That is the case the plan's first Risk names. Rebase onto main (rule 20). Then repeat the Proof commit and push checks under 4.0.9 before `deliver`, and update the Integration points line. — `docs/changes/lefthook-shared-config/plan.md:61` → fixed (docs: plan names Ruby 4.0.9 after the rebase onto main)

Passes:

- Bugs: the round 1 Important finding holds as fixed. `lefthook dump` (lefthook 2.2.3) shows `minitest-changed-tests` under `pre-push`, below the shared hook-level `files:` script: the diff against the merge base with origin's default branch, deleted files left out. A probe ran in a scratch clone with a stub `bin/rails`. A branch commit changed `test/models/affiliation_test.rb` and `engines/billing/test/billing_test.rb`. `lefthook run pre-push --command minitest-changed-tests` with no `--file` ran `bin/rails test` on exactly those two files. The `.git` path that the `files:` script also echoes does not match the job's globs. On this branch itself, only deleted test files changed, so the job has no files and skips.
- Security: nothing found. No change since round 1 beyond the file list source.
- Compliance:
  - `lefthook.yml` starts with the Starter config → unchanged since round 1; `lefthook dump` shows the `remotes:` block and the shared jobs.
  - A commit from a linked worktree succeeds → manual check outside the diff; not repeated. See the Nit for Ruby 4.0.9.
  - A push from a linked worktree succeeds → `origin/lefthook-shared-config` held HEAD before this round.
  - The repo test job runs pushed test files, engine tests included → the globs cover top-level, nested and engine test files; the probe above ran a nested and an engine file.
  - The repo test job runs only the branch's own changed test files → the probe above.
  - Nothing references the removed script → `grep -rn "pre_push_checks\|PrePushChecks" --exclude-dir=docs` returns nothing.
  - Suites stay green → only `lefthook.yml` and `plan.md` changed since round 1's green `bundle exec rubocop` and `bin/rails test` runs; no Ruby changed. `yamllint lefthook.yml` exits 0 (one `document-start` warning).
  - Deleted tests: unchanged since round 1, deleted with the code and config they pinned, as the plan decided.
  - Round 1 Nit: the new Proof line uses `lefthook run` without `--file`, which runs the same hook-level `files:` script as a real push. The probe confirms it.
- Design: no Ruby method is added. There is no Law of Demeter or N+1 concern. No glossary `Avoid:` word is used. The invariant holds: no repo job shares a name with a shared job, and the job unsets `GIT_DIR` first.

## Round 3 — 2026-11-26T16:39Z — f368860

- [ ] Important: A push can fail with `database is locked` when the branch changes a mapped `app/` file and a test file. The merged pre-push hook has `parallel: true`, set by the shared config. In that case the shared `minitest` job and the repo `minitest-changed-tests` job each start `bin/rails test` at the same time on the same `db/test.sqlite3`. The removed `bin/pre_push_checks` ran one test process, so this is new with this change. Probe: `lefthook run pre-push --no-tty --command minitest --command minitest-changed-tests` with `--file` set to `app/models/user.rb`, `app/models/affiliation.rb`, `test/models/user_test.rb`, `test/models/affiliation_test.rb` and `engines/billing/test/billing_test.rb`. It failed 3 times out of 3: 6 to 11 errors per job, all `ActiveRecord::StatementTimeout: SQLite3::BusyException: database is locked`. Each job alone passes with the same files (23 runs and 25 runs, 0 errors). Most feature branches change both kinds of file, so most pushes would fail. This branch changes no `app/` file, so its own push never showed it. Proof has no check that runs both jobs on one push. — `lefthook.yml:14` → fixed (Run one test process on push: the repo job replaces the shared minitest job)
- [ ] Nit: Round 2's Nit asked for the Risks line to name Ruby 4.0.9 too. `plan.md:124` still says bare `rubocop` runs "the newest RuboCop installed for Ruby 3.4.9", and calls `rubocop` 1.92.3 under Ruby 4.0.9 the wrong-Ruby case. Under the `.ruby-version` Ruby, 4.0.9, bare `rubocop` is now 1.92.3, and `Gemfile.lock` pins 1.92.2. Both versions report no offenses on 1109 files today, so nothing fails yet. `plan.md:60` still names Lefthook 2.2.2 under Ruby 3.4.9; `rv run -- lefthook version` reports 2.2.3 under 4.0.9. — `docs/changes/lefthook-shared-config/plan.md:124` → fixed (docs: plan names Ruby 4.0.9 in the Risks and Integration points)

Passes:

- Bugs: the Important finding above. The branch now sits on `origin/main` (0 commits behind), `.ruby-version` 4.0.9. `lefthook dump` (2.2.3) shows the shared jobs, the shared hook-level `files:` script, and `minitest-changed-tests` under `pre-push`, as in round 2.
- Security: nothing found. No change since round 2 beyond the rebase and plan text.
- Compliance:
  - `lefthook.yml` starts with the Starter config → unchanged; `lefthook dump` shows the `remotes:` block and the shared jobs.
  - A commit from a linked worktree succeeds → manual check outside the diff; the plan records that it passed under 4.0.9 through rv. Not repeated.
  - A push from a linked worktree succeeds → `origin/lefthook-shared-config` holds HEAD. That push changed no `app/` file, so it does not cover the Important finding.
  - The repo test job runs pushed test files, engine tests included → the control run above ran a nested and an engine test file, 25 runs, 0 errors.
  - The repo test job runs only the branch's own changed test files → round 2's probe; `lefthook.yml` is unchanged since.
  - Nothing references the removed script → the round 2 grep, repeated, returns nothing outside `docs`.
  - Suites stay green under Ruby 4.0.9 after the rebase → `bundle exec rubocop` (1.92.2) and bare `rubocop` (1.92.3): 1109 files, no offenses each. `bin/rails test`: 1473 runs, 5055 assertions, 0 failures, 0 errors, 0 skips, in 853 s.
  - Deleted tests: unchanged since round 1, deleted with the code and config they pinned, as the plan decided.
- Design: no Ruby method is added. There is no Law of Demeter or N+1 concern. No glossary `Avoid:` word is used. The invariants hold: no repo job shares a name with a shared job, and the job unsets `GIT_DIR` first. A missing invariant: two jobs in one hook must not share the test database while the hook runs jobs in parallel.

## Round 4 — 2026-11-26T19:45Z — 4b2dfa0

- [ ] Nit: The new protection against `database is locked` is not an invariant in the plan, and it can break without a cityofbrass commit. Under `### Invariants`, the plan lists only `unset GIT_DIR` and the job names. It does not say that one pre-push test process must run while the hook runs jobs in parallel. Round 3 called this the missing invariant. The repo's hook-level `exclude_tags: [minitest]` holds only while the shared pre-push hook sets no `exclude_tags` of its own. A hook-level list in a later config replaces the earlier list. It is not merged. Probe: a scratch repository with `exclude_tags: [minitest]` that `extends` a file with `exclude_tags: [other]`. `lefthook dump` shows `other` only. The remote config is merged after the repo config, so a shared `exclude_tags` would turn the shared `minitest` job back on. Within 24 hours, pushes would fail with `database is locked` again. Add the invariant, and record that dependency on the shared config under Risks. — `docs/changes/lefthook-shared-config/plan.md:37` → fixed (docs: plan matches the final lefthook.yml and records the exclude_tags dependency)
- [ ] Nit: The plan's `lefthook.yml` target block is still the pre-round-3 job. It has the `minitest` tag, no `app/**/*.rb` glob, no hook-level `exclude_tags`, and the run line `bin/rails test {files}`. The committed file differs on all four. `### Complexity` (line 35) and Alternative 1 (line 44) still say the job runs "the same test set" or "exactly the files" that `bin/pre_push_checks` ran. The job now also runs the `test/X_test.rb` files mapped from changed `app/X.rb` files. Update the target block and both lines to match `lefthook.yml`. — `docs/changes/lefthook-shared-config/plan.md:86` → fixed (docs: plan matches the final lefthook.yml and records the exclude_tags dependency)

Passes:

- Bugs: the round 3 Important finding holds as fixed. Probe: `lefthook run pre-push --no-tty --command minitest --command minitest-changed-tests` with `--file` set to `app/models/user.rb`, `app/models/affiliation.rb`, `test/models/user_test.rb`, `test/models/affiliation_test.rb` and `engines/billing/test/billing_test.rb`. Output: `minitest (skip) tags`. `minitest-changed-tests` ran one `bin/rails test`: 25 runs, 0 failures, 0 errors, in 4.7 s. `lefthook dump` (2.2.3) shows `exclude_tags: [minitest]` under the merged `pre-push`. The repo job's `app/*.rb` mapping is the same as the shared `minitest` job's. No other parallel pre-push job (brakeman, bundle-audit, rubocop, erb_lint, yamllint and others) touches the test database. The shared `rspec` job finds no `spec/` file here. No `.rb` file sits directly under `app/`, so the `app/**/*.rb` glob misses nothing.
- Security: nothing found. No change since round 3 beyond the job script and plan text.
- Compliance:
  - `lefthook.yml` starts with the Starter config → `lefthook dump` shows the `remotes:` block and the shared jobs; the block is unchanged since round 1.
  - A commit from a linked worktree succeeds → manual check outside the diff. The plan records that it passed under 4.0.9 through rv. The reviewer did not repeat it.
  - A push from a linked worktree succeeds → `origin/lefthook-shared-config` holds an earlier HEAD. This round does not push, because findings are open.
  - The repo test job runs pushed test files, engine tests included → the probe above ran a nested and an engine test file.
  - The repo test job runs only the branch's own changed test files → round 2's probe. The hook-level `files:` script is unchanged since then.
  - Nothing references the removed script → `grep -rn "pre_push_checks\|PrePushChecks"` outside `docs`, `node_modules`, `tmp` and `log` returns nothing.
  - Suites stay green → since round 3's green `bundle exec rubocop` and `bin/rails test` runs, only `lefthook.yml` and `plan.md` changed. No Ruby changed. `yamllint lefthook.yml` exits 0, with one `document-start` warning.
  - Deleted tests: unchanged since round 1. They are deleted with the code and config they pinned, as the plan decided.
  - The branch is 11 commits behind `origin/main` (#170). `git merge-tree` shows a clean merge. Main changes no lefthook or Ruby version file. Rebase before `deliver` (rule 20).
- Design: no Ruby method is added. There is no Law of Demeter or N+1 concern. No glossary `Avoid:` word is used. The invariants hold: no repo job shares a name with a shared job, and the job unsets `GIT_DIR` first. The test-database invariant is missing; see the first Nit.
