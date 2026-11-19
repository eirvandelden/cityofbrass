# Intent: Upgrade Ruby to 4.0.9

Author: Etienne van Delden. Status: accepted (2026-11-19). Type: chore. Delivery: autonomous. Codex review: no.

## Problem

The app runs on Ruby 3.4.9, one major version behind Ruby 4.0. Every `.ruby-version` pin, the lockfile, the Docker image and the linter target still name 3.4. The app cannot take Ruby 4 security and bug-fix releases until it moves.

## Proposed outcome

The app, its seven engines, its Docker image and CI all run Ruby 4.0.9. The full test suite, the linters and the security scans pass on it, with the same behaviour as today.

## Affected users and systems

- Developers who run the app and its tests locally through `rv`.
- CI, which installs Ruby through `spinel-coop/setup-rv`.
- The production Docker image, which builds from the `Dockerfile`.
- Every gem, including native extensions, that must install and load on Ruby 4.0.9.

## Constraints

- One major step only: Ruby 3.4 to 4.0. No skipped majors.
- Ruby 4.0.9 is already installed under `rv`. The change installs no Ruby and no version manager.
- Gems install with `bi`, never `bundle install`.
- If a gem blocks Ruby 4.0.9, bump only that gem with `bundle update <gem>`. Never run a bare `bundle update`. Stop and ask before removing or replacing a gem.
- Approved config edits: `ARG RUBY_VERSION` in the `Dockerfile` and `TargetRubyVersion` in `.rubocop.yml`, each one line. Nothing else in deployment config or `.github/workflows/` changes without a new approval.
- No skipped test, no linter disable comment and no Brakeman ignore to pass. Fix the production code.
- The security-fix change is already merged, so this change starts from `main`.

## In scope

- Set `.ruby-version` to 4.0.9 in the root and in the seven engines (`billing`, `entitybuilder`, `gallery`, `importer`, `report`, `rulebuilder`, `worldbuilder`).
- Record Ruby 4.0.9 in `Gemfile.lock`.
- Set `ARG RUBY_VERSION` in the `Dockerfile` to 4.0.9.
- Set `TargetRubyVersion` in `.rubocop.yml` to 4.0.
- Fix every code, gem or config break that Ruby 4.0.9 causes, including any stdlib or gem change.
- Check that CI picks up 4.0.9 from `.ruby-version`, and report it if it does not.

## Out of scope

- Ruby 4.1 and any Ruby version other than 4.0.9.
- Rails, gem and npm upgrades beyond what Ruby 4.0.9 forces.
- The `@rails/actiontext` 6.1 to 8.1 alignment.
- Changes to `config/deploy.yml`, `.github/workflows/` and other deployment config.
- Using new Ruby 4 language features or refactoring existing code.

## Acceptance criteria

- `ruby -v` in the repository reports 4.0.9, and `bundle exec ruby -v` agrees.
- `bin/rails test` passes with 0 failures and 0 errors on Ruby 4.0.9, locally and in CI.
- `bundle exec rubocop` reports no offenses with `TargetRubyVersion` 4.0.
- `bundle exec brakeman` reports 0 warnings, and `bundle exec bundler-audit check` reports no vulnerabilities.
- The Docker image builds with Ruby 4.0.9, or the build is checked as far as the environment allows, and the result is recorded.
- The app starts with `bin/dev`, and the home page, sign-in and a gallery picture load.
- All eight `.ruby-version` files read `4.0.9`, and the `Dockerfile` default reads `4.0.9`.

## Decisions

- Edit the `Dockerfile` and `.rubocop.yml` as part of this change — approved as the upgrade itself, not a way to pass a check.
- Deliver autonomously, with Claude review only — same flow that delivered the security fixes.
- Start from `main`, not stacked — the security PR is merged, so there is nothing to stack on.

## Open questions

None.
