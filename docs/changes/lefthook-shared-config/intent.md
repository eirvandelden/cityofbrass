# Intent: Git hooks use the shared dotfiles lefthook config

Author: Etienne van Delden de la Haije. Status: accepted (2026-11-19). Type: chore.

## Problem

In a linked worktree, every commit that stages a Ruby file fails in the pre-commit hook. Git exports `GIT_DIR` to its hooks; `rv run bundle exec rubocop` inherits it, so Bundler looks for the git gem `exception_notification-campfire-once` at `8472c72` in the cityofbrass repository and stops with "that version can no longer be found in that source" (exit 7). Reproduced on 2026-11-18 with lefthook 2.2.2. The pre-push job `rv run bin/pre_push_checks` runs `bundle exec` the same way.

The other personal repositories already solved this through the shared lefthook config in the dotfiles repository (dotfiles PR #271): each repo's `lefthook.yml` names that config under `remotes:`, and the shared jobs unset `GIT_DIR` before they run Ruby tooling. cityofbrass still has its own standalone `lefthook.yml`.

## Proposed outcome

cityofbrass's `lefthook.yml` starts from the Starter config in the `new-repo-setup` skill (the dotfiles `lefthook.yml` as a remote, `ref: main`, `refetch_frequency: 24h`). Its own jobs stay below it, and each one that runs Ruby tooling unsets `GIT_DIR` first. A commit that stages a Ruby file and a push both succeed from a linked worktree with the hooks installed.

## Affected users and systems

- The maintainer and every agent that commits or pushes from a worktree under `.worktrees/`.
- `lefthook.yml` and `test/lefthook_config_test.rb`, which pins today's job commands.
- The `pre_push_checks` files, `.rubocop_todo.yml`, `README.md` and `AGENTS.md`.

## Constraints

- Builds on main; its pull request targets main.
- Copy the Starter config as the dotfiles repository documents it; do not invent a variant.
- `bin/pre_push_checks` is removed (decided 2026-11-19); the shared pre-push jobs replace it.

## Open questions

- Decided 2026-11-19: the repo drops its own `rubocop` pre-commit job and relies on the shared one of the same name. The shared job runs `rubocop -a` and re-stages the fixes.
- Decided 2026-11-19: the shared pre-push jobs make `bin/pre_push_checks` redundant. Remove `bin/pre_push_checks`, `lib/pre_push_checks.rb`, `test/lib/pre_push_checks_test.rb`, its `.rubocop_todo.yml` entries, and the references in `README.md` and `AGENTS.md`.
- Decided 2026-11-19: tests must run on push. The shared pre-push `minitest` job runs `bin/rails test` per file, so the removal loses nothing. The plan verifies that the job picks up the changed test files in this repo, including `engines/*/test`.
