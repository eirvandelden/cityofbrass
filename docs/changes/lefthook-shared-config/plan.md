# Plan: Git hooks use the shared dotfiles lefthook config

From `intent.md` (2026-11-19). Status: accepted (2026-11-19).

## Design

### Domain terms

Not affected: a tooling chore; no domain term is introduced or reused. `GLOSSARY.md` holds no hook, lint or worktree terms.

### Diagrams

Not affected: no Ruby objects or records change. The hook flow after the change, for reference:

```mermaid
sequenceDiagram
  participant Git
  participant Lefthook
  participant Shared as dotfiles lefthook.yml (remote)
  participant Repo as cityofbrass lefthook.yml
  Git->>Lefthook: pre-commit / pre-push (GIT_DIR exported)
  Lefthook->>Shared: merge remote config (refetch every 24h)
  Lefthook->>Repo: merge repo jobs
  Lefthook->>Lefthook: run jobs; Ruby jobs `unset GIT_DIR` first
```

### Signatures

Not affected: no Ruby class or method is added or changed. `PrePushChecks` (`lib/pre_push_checks.rb`) is deleted with its binstub and test.

Not checked: no Ruby signatures change.

### Complexity

Not affected: no request path changes. Push cost: the shared pre-push jobs plus one `bin/rails test` call over the branch's changed test files and the tests mapped from its changed `app/X.rb` files. That is the test set `bin/pre_push_checks` ran, plus the mapped tests.

### Invariants

- Every repo job that runs Ruby tooling runs `unset GIT_DIR` first. Enforced by review of `lefthook.yml`; proven by the worktree commit and push checks below.
- A repo job never shares a name with a shared job, because the remote config is merged after the repo config and overrides a same-name job.
- One `bin/rails test` process runs per push. The shared pre-push hook runs jobs in parallel and the test database is one SQLite file. Enforced by the repo's hook-level `exclude_tags: [minitest]`, which turns the shared `minitest` job off; proven by the round 3 probe. It holds only while the shared pre-push hook sets no `exclude_tags` of its own: a hook-level list in a later config replaces the earlier one.

### Alternatives

1. **Chosen: Starter remote plus one repo pre-push job `minitest-changed-tests`.** The shared `minitest` job only maps a changed `app/X.rb` to `test/X_test.rb`. It never runs a changed test file itself, and never anything under `engines/*/test`. The repo job runs the files `bin/pre_push_checks` ran, plus the tests the shared job mapped, in one process, so removing that script loses no push-time coverage.
2. Rejected: Starter remote only, rely on CI. Changed test files and engine tests would run only on CI.
3. Rejected: change the shared dotfiles `minitest` job first. It is a separate repository and change; this one would wait on it.

## Design decisions

- Conflict with intent `## Open questions`, third decision ("the removal loses nothing"): the shared `minitest` job does not pick up changed test files or `engines/*/test`. Etienne chose on 2026-11-19 to close the gap with a repo pre-push job (Alternative 1).
- `test/lefthook_config_test.rb` is deleted, not rewritten. The playbook says configuration has no tests; the proof is the real commit and push from a linked worktree. Etienne chose this on 2026-11-19.
- The remote block copies the `new-repo-setup` Starter exactly, `configs: - lefthook.yml` included. Most other personal repos omit `configs:`; the intent says copy the Starter.
- The repo `rubocop` pre-commit job is dropped (intent decision 1). The shared job runs `rubocop -a --force-exclusion {staged_files} --parallel` with `stage_fixed: true`.
- `minitest-changed-tests` skips pushed paths that no longer exist. A push that deletes a test file (this change deletes two) must not hand a missing path to `bin/rails test`.
- `README.md` and `AGENTS.md` lose their `bin/pre_push_checks` line; no replacement line is added. `CLAUDE.md` is a symlink to `AGENTS.md` and needs no edit.

## Integration points

- Shared config: `https://github.com/eirvandelden/dotfiles.git`, `lefthook.yml` on `main`. Lefthook clones it into `<git common dir>/info/lefthook-remotes/` (a `dotfiles` clone already exists there).
- Lefthook (2.2.3 under Ruby 4.0.9 via rv), installed as a gem; `.git/hooks/pre-commit` and `pre-push` already call it.
- rv: the shared jobs call bare `rubocop`, `bin/rails`, `brakeman` and `bundler-audit`, so they depend on rv putting the `.ruby-version` Ruby (4.0.9 after the rebase onto main, #168) and its gem executables on `PATH`. The commit check passed under 4.0.9 with `rv run git commit`.
- CI (`.github/workflows/ci.yml`) still runs full RuboCop and `bin/rails test`; unchanged.

## Files that change

- `lefthook.yml` — replace the whole file: the Starter `remotes:` block, then a `pre-push` section with the `minitest-changed-tests` job.
- `test/lefthook_config_test.rb` — delete; it pins the old job commands.
- `bin/pre_push_checks` — delete (intent decision 2).
- `lib/pre_push_checks.rb` — delete.
- `test/lib/pre_push_checks_test.rb` — delete.
- `.rubocop_todo.yml` — remove the three `pre_push_checks` exclude lines (535, 764, 766).
- `README.md` — remove the `bin/pre_push_checks` line from "Running checks".
- `AGENTS.md` — remove the `bin/pre_push_checks` line from "Commands".

Target `lefthook.yml`:

```yaml
remotes:
  - git_url: https://github.com/eirvandelden/dotfiles.git
    ref: main
    refetch_frequency: 24h
    configs:
      - lefthook.yml

pre-push:
  # The shared minitest job runs bin/rails test too. Two test processes in parallel lock the one
  # SQLite test database, so the repo job below replaces it. Its tag is excluded here.
  exclude_tags:
    - minitest
  commands:
    # Runs the branch's changed test files, engine tests included, and the tests that the shared
    # minitest job maps from changed app/X.rb files (test/X_test.rb), in one bin/rails test run.
    # The list comes from the shared hook-level `files:` (not {push_files}, which lists every
    # file on a first push). Not named minitest: the remote config overrides a repo job of the
    # same name.
    minitest-changed-tests:
      tags:
        - ruby
        - tests
      glob:
        - "app/**/*.rb"
        - "test/*_test.rb"
        - "test/**/*_test.rb"
        - "engines/*/test/*_test.rb"
        - "engines/*/test/**/*_test.rb"
      # GIT_DIR is unset for the reason given on the shared pre-commit rubocop job.
      run: |
        unset GIT_DIR
        tests=""
        for file in {files}; do
          case "$file" in
            test/*_test.rb | engines/*/test/*_test.rb) tests="$tests $file" ;;
            app/*.rb)
              mapped="test/${file#app/}"
              mapped="${mapped%.rb}_test.rb"
              [ -f "$mapped" ] && tests="$tests $mapped"
              ;;
          esac
        done
        [ -n "$tests" ] || exit 0
        bin/rails test $(printf '%s\n' $tests | sort -u)
      fail_text: |
        Tests failed for the pushed files.
        Fix the failing tests or use `--no-verify` to skip.
```

The zero-directory globs (`test/*_test.rb`, `engines/*/test/*_test.rb`) are needed: lefthook's matcher does not let `**` match zero directories (step 4 showed it). The job reads `{files}`, the shared hook-level pre-push list (the branch's changes against the merge base with origin's default branch, deleted files left out), not `{push_files}`, which lists every file on a first push (review round 1).

## Order of work

No criterion needs an automated test: every change is configuration or a removal. Each criterion has a check instead.

1. Run `bi` in the worktree. Ruby 3.4.9's bundle is incomplete on this machine (`bundle check` reports missing gems; `rubocop` has no executable under Ruby 3.4.9), so the shared jobs cannot run until it is installed.
2. Replace `lefthook.yml` with the target above. Run `lefthook install` in the worktree. Run `lefthook dump` and confirm the merged config holds the shared jobs and `minitest-changed-tests`. Commit.
3. Delete `bin/pre_push_checks`, `lib/pre_push_checks.rb`, `test/lib/pre_push_checks_test.rb` and `test/lefthook_config_test.rb`; remove the three `.rubocop_todo.yml` lines and the `README.md` and `AGENTS.md` lines. Commit.
4. Check the glob: run the repo job on one top-level, one nested and one engine test file (for example `test/i18n_test.rb`, `test/models/affiliation_test.rb`, `engines/billing/test/billing_test.rb`). Check the flag names with `lefthook run --help` first (rule 22). Add the zero-directory globs if a file is skipped. Run it once more with a path that does not exist; it must exit 0.
5. Run the pre-commit check (Proof, criterion 2), then push the branch (criterion 3).
6. Run `bundle exec rubocop` and `bin/rails test` once in full; both must stay green after the removals.

## Risks

- The `exclude_tags: [minitest]` fix depends on the shared config: if the shared pre-push hook ever sets its own `exclude_tags`, that list replaces the repo's, the shared `minitest` job runs again, and pushes fail with `database is locked`. A refetch picks it up within 24 hours without a cityofbrass commit. Accepted; the fix then belongs in dotfiles or in a repo `lefthook-local.yml`.
- The shared pre-push hook runs jobs in parallel (`parallel: true`). Two `bin/rails test` processes lock the one SQLite test database (`database is locked`; review round 3). The repo job therefore also runs the shared job's `app/X.rb` to `test/X_test.rb` mapping, and the hook-level `exclude_tags: [minitest]` turns the shared `minitest` job off. Proof: a probe with two changed `app/` files and three changed test files ran one process, 25 runs, 0 errors.

- The shared jobs call bare `rubocop`, not `bundle exec rubocop`. It runs the newest RuboCop installed for the `.ruby-version` Ruby (4.0.9: 1.92.3, while `Gemfile.lock` pins 1.92.2); both report no offenses today. A shell without rv's chpwd hook gets the wrong Ruby. If the check in step 5 fails for that reason, the fix belongs in dotfiles: stop and ask.
- The shared `rubocop` glob is `*.{rb}`: `.rake` files are no longer linted on commit or push. CI still lints them.
- Engine tests run from the root with the root `test_helper` load path. That is how `bin/pre_push_checks` ran them, so behaviour is unchanged; an engine test that only passes under its own helper would now block a push it blocked before too.
- The shared config changes on `main` of dotfiles without a cityofbrass commit, and a refetch picks it up within 24 hours. Accepted: that is the point of the remote.
- The shared pre-push `review-report-fresh` job blocks a push once a pull request is open and `review.md` is stale. Expected workflow.
- Rejected: keeping a repo `rubocop` job (intent decision 1); keeping `bin/pre_push_checks` (intent decision 2); rewriting `test/lefthook_config_test.rb` (playbook: config has no tests).

## Proof

- `lefthook.yml` starts with the Starter config → check: the `remotes:` block equals the one in `~/.claude/skills/new-repo-setup/SKILL.md` item 3, byte for byte; `lefthook dump` shows the shared jobs.
- A commit that stages a Ruby file succeeds from a linked worktree with the hooks installed → check: in `.worktrees/lefthook-shared-config`, add a comment line to `app/models/user.rb`, stage it, `git commit`. The hook output shows the shared `rubocop` job ran (not skipped) and the commit exits 0. Then `git reset --soft HEAD~1` and `git restore --staged --worktree app/models/user.rb`.
- A push succeeds from a linked worktree with the hooks installed → check: `git push -u origin HEAD` from the worktree exits 0 and the hook output lists the shared pre-push jobs.
- The repo test job runs pushed test files, engine tests included → check: step 4's `lefthook run` calls run `bin/rails test` on all three files and exit 0.
- The repo test job runs only the branch's own changed test files → check: a temporary commit that changes one engine test and one nested test, then `lefthook run pre-push --command minitest-changed-tests` with no `--file`, runs those two files only; reset the commit afterwards.
- Invariant: every repo job that runs Ruby tooling unsets `GIT_DIR` first, enforced in `lefthook.yml` → check: the commit and push checks above run from a linked worktree, where git exports an absolute `GIT_DIR`.
- Nothing references the removed script → check: `grep -rn "pre_push_checks\|PrePushChecks" --exclude-dir=docs .` returns nothing.
- Suites stay green → check: `bundle exec rubocop` and `bin/rails test` pass.

Per changed file, the unit tests expected: none. `lefthook.yml` is configuration; the other files are deletions or doc lines.

Test setup: none.

Out of scope: changing the shared dotfiles `lefthook.yml`; adding `lefthook install` to `bin/setup` or the README; CI changes.

---
Domain skills applied: None (no Rails code changes). `new-repo-setup` supplied the Starter config.
