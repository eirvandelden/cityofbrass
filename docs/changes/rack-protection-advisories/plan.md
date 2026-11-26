# Plan: Clear the rack-protection security advisories and bump Ruby to 4.0.10

Author: Etienne van Delden de la Haije. Status: accepted (2026-11-26). Type: chore. Delivery: step-by-step.

## Problem

`bin/bundle-audit check` on main reports three advisories on rack-protection 4.2.1: GHSA-pf75-2v58-7mxg, GHSA-r29j-38x9-qr26 and GHSA-vvhm-j6m8-64cw. The fix is `>= 4.2.2`. omniauth pulls in rack-protection (`rack-protection (>= 2.2.0)`); the Gemfile does not name it.

## Proposed outcome

rack-protection is at 4.2.2. `bin/bundle-audit check` reports no advisory. Sign-in through omniauth behaves as before.

## Affected users and systems

Every request through omniauth. rack-protection 4.2.2 is the latest on rubygems.org.

## Constraints

- Update only rack-protection: `bundle update rack-protection --conservative`. Never `bundle update` for all gems.
- `Gemfile` does not change.
- No new dependency.

## In scope

- `Gemfile.lock`: rack-protection 4.2.1 → 4.2.2 (committed).
- Ruby 4.0.9 → 4.0.10 (added at Etienne's request, 2026-11-26): `.ruby-version`, six `engines/*/.ruby-version` files, `Dockerfile` (`ARG RUBY_VERSION`), `Gemfile.lock` and `engines/importer/Gemfile.lock`. Ruby 4.0.10 is already installed under `rv`.

## Out of scope

- Any other gem.
- Deploying the image.
- The abandoned `bundler-audit-advisories` branch and the unused `puma-advisories` worktree. Puma is already at 7.2.3 on main.

## Acceptance criteria

- `bin/bundle-audit check` reports no vulnerabilities.
- `git diff Gemfile.lock` changes only the rack-protection line.

## Decisions

- Fold the Ruby 4.0.10 bump into this change, `Dockerfile` included — Etienne asked for it; the image must match dev and CI. No deploy runs.
- Plan the rack-protection update, not puma — puma was already fixed on main (7.2.3); the audit now shows rack-protection.

## Open questions

None.

## Order of work

1. `worktree-create --no-pane rack-protection-advisories`, then `bi`.
2. Write `plan.md` into `docs/changes/rack-protection-advisories/` and commit it with `commit-plan`.
3. `bundle update rack-protection --conservative`. Read `git diff Gemfile.lock`: only the rack-protection line may change. Otherwise stop and explain.
4. `bin/bundle-audit check --update`. Expect no vulnerabilities.
5. `bin/rails test` and `bundle exec rubocop`. Both green.
6. Commit `Gemfile.lock` alone: `Update rack-protection for security advisories`.

## Risks

- A minor bump of rack-protection could change omniauth's CSRF checks. The full suite and the omniauth sign-in tests guard it.
- A new advisory can appear in the database at any time. The audit result is a snapshot.

## Proof

- No pin of 4.0.9 remains → check: `git grep -E "4\.0\.9" -- . ':!docs'` prints nothing
- The app runs on 4.0.10 → check: `rv ruby run 4.0.10 -- -S bundle exec ruby -v` prints 4.0.10
- No advisory remains → check: `bin/bundle-audit check --update` exits 0
- Only rack-protection moved → check: `git diff Gemfile.lock` shows one changed version line
- Nothing regressed → check: `bin/rails test` green

A lockfile change is configuration. It has no test of its own.

---
Domain skills applied: dependencies.
