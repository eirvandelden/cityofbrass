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

Not affected: no request path changes. Push cost: the shared pre-push jobs plus one `bin/rails test` call over the pushed test files, the same test set `bin/pre_push_checks` ran.

### Invariants

- Every repo job that runs Ruby tooling runs `unset GIT_DIR` first. Enforced by review of `lefthook.yml`; proven by the worktree commit and push checks below.
- A repo job never shares a name with a shared job, because the remote config is merged after the repo config and overrides a same-name job.

### Alternatives

1. **Chosen: Starter remote plus one repo pre-push job `minitest-changed-tests`.** The shared `minitest` job only maps a changed `app/X.rb` to `test/X_test.rb`. It never runs a changed test file itself, and never anything under `engines/*/test`. The repo job runs exactly the files `bin/pre_push_checks` ran, so removing that script loses no push-time coverage.
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
- Lefthook 2.2.2, installed as a gem under rv Ruby 3.4.9; `.git/hooks/pre-commit` and `pre-push` already call it.
- rv: the shared jobs call bare `rubocop`, `bin/rails`, `brakeman` and `bundler-audit`, so they depend on rv putting Ruby 3.4.9 (`.ruby-version`) and its gem executables on `PATH`.
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
  commands:
    # The shared minitest job only maps app/X.rb to test/X_test.rb. This job runs the pushed
    # test files themselves, engine tests included. Not named minitest: the remote config
    # overrides a repo job of the same name.
    minitest-changed-tests:
      tags:
        - ruby
        - tests
        - minitest
      glob:
        - "test/**/*_test.rb"
        - "engines/*/test/**/*_test.rb"
      # GIT_DIR is unset for the reason given on the shared pre-commit rubocop job.
      run: |
        unset GIT_DIR
        files=""
        for file in {push_files}; do
          [ -f "$file" ] && files="$files $file"
        done
        [ -n "$files" ] || exit 0
        bin/rails test $files
      fail_text: |
        Tests failed for pushed test files.
        Fix the failing tests or use `--no-verify` to skip.
```

The glob list may need `test/*_test.rb` and `engines/*/test/*_test.rb` too, if lefthook's matcher does not let `**` match zero directories. Step 4 settles it.

## Order of work

No criterion needs an automated test: every change is configuration or a removal. Each criterion has a check instead.

1. Run `bi` in the worktree. Ruby 3.4.9's bundle is incomplete on this machine (`bundle check` reports missing gems; `rubocop` has no executable under Ruby 3.4.9), so the shared jobs cannot run until it is installed.
2. Replace `lefthook.yml` with the target above. Run `lefthook install` in the worktree. Run `lefthook dump` and confirm the merged config holds the shared jobs and `minitest-changed-tests`. Commit.
3. Delete `bin/pre_push_checks`, `lib/pre_push_checks.rb`, `test/lib/pre_push_checks_test.rb` and `test/lefthook_config_test.rb`; remove the three `.rubocop_todo.yml` lines and the `README.md` and `AGENTS.md` lines. Commit.
4. Check the glob: run the repo job on one top-level, one nested and one engine test file (for example `test/i18n_test.rb`, `test/models/affiliation_test.rb`, `engines/billing/test/billing_test.rb`). Check the flag names with `lefthook run --help` first (rule 22). Add the zero-directory globs if a file is skipped. Run it once more with a path that does not exist; it must exit 0.
5. Run the pre-commit check (Proof, criterion 2), then push the branch (criterion 3).
6. Run `bundle exec rubocop` and `bin/rails test` once in full; both must stay green after the removals.

## Risks

- The shared jobs call bare `rubocop`, not `bundle exec rubocop`. It runs the newest RuboCop installed for Ruby 3.4.9, which can differ from `Gemfile.lock`. A shell without rv's chpwd hook gets the wrong Ruby (seen in planning: Ruby 4.0.9 picked up `rubocop` 1.92.3 from the 4.0 gem dir). If the check in step 5 fails for that reason, the fix belongs in dotfiles: stop and ask.
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
- Invariant: every repo job that runs Ruby tooling unsets `GIT_DIR` first, enforced in `lefthook.yml` → check: the commit and push checks above run from a linked worktree, where git exports an absolute `GIT_DIR`.
- Nothing references the removed script → check: `grep -rn "pre_push_checks\|PrePushChecks" --exclude-dir=docs .` returns nothing.
- Suites stay green → check: `bundle exec rubocop` and `bin/rails test` pass.

Per changed file, the unit tests expected: none. `lefthook.yml` is configuration; the other files are deletions or doc lines.

Test setup: none.

Out of scope: changing the shared dotfiles `lefthook.yml`; adding `lefthook install` to `bin/setup` or the README; CI changes.

---
Domain skills applied: None (no Rails code changes). `new-repo-setup` supplied the Starter config.
