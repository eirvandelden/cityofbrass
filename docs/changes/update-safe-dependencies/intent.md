# Intent: Update safe dependencies

Author: Etienne van Delden de la Haije. Status: accepted. Type: chore. Delivery: autonomous. Codex review: no.

## Problem

Every `rails` command, `rails db:migrate` included, aborts with `ArgumentError: unknown keyword: create_additions`. `json` 3.0.2 dropped that keyword, and `sprockets` 4.2.2 still passes it when Rails boots. Several other gems, Rails 8.1.4 included, are behind on patch and minor releases.

## Proposed outcome

The app boots again, and every gem that has a patch or minor update inside its current constraints is up to date.

## Affected users and systems

Developers running the app and the tests locally. `Gemfile.lock` only. Rails 8.1.4.1 is a security-patch release, so production gains the fix too.

## Constraints

- Update with `bundle update <gem> ...` for named gems. Never run a bare `bundle update` (playbook rule 11).
- No gem is added or removed.
- No major version bump. Gems pinned by a constraint in `Gemfile` stay inside it.
- `json` stays at 3.0.2: the break came from it, so it is not updated here.
- Git-sourced gems (`rubocop-eirvandelden`, `exception_notification-campfire-once`) are not updated.
- No migration, deploy file or config file changes.
- One branch, one pull request, one commit per step.

## In scope

- Commit 1: update `sprockets` to 4.4.1, which no longer passes `create_additions`.
- Commit 2: update `rails` and its sub-gems to 8.1.4.1.
- Commit 3: update the remaining runtime patch and minor gems.
- Commit 4: update the development and test tooling (`rubocop`, `rubocop-rails`, `rubocop-minitest`, `spring`, `meta_request`, `listen`).
- Fix offenses that new cops report in commit 4 only when they are mechanical and small. Otherwise leave them out and report them.

## Out of scope

- Major updates: `stripe` 20, `puma` 8, `marcel` 2, `prism` 2, `rouge` 5, `sass` 3.7, `terrapin` 1, `net-protocol` 0.4.
- Gems blocked by a constraint: `minitest` 6, `image_processing` 2, `foundation-rails` 6.
- `json` 3.1.0.
- The uncommitted changes to `db/cable_schema.rb`, `db/queue_schema.rb` and `bin/ci` in the main checkout.
- npm packages.

## Acceptance criteria

- `bin/rails runner 'puts 1'` prints `1` instead of aborting.
- `bin/rails db:migrate:status` lists the migrations instead of aborting.
- `Gemfile.lock` lists `sprockets 4.4.1` and `rails 8.1.4.1`, and `bundle outdated` lists no gem with a patch or minor update inside its constraint, apart from the exclusions above.
- `bin/rails test` and `bundle exec rubocop` pass.
- Brakeman and Bundler Audit report nothing new.
- The pull request holds the four commits, each touching only `Gemfile.lock` (plus mechanical cop fixes in commit 4).

## Decisions

- Bundle the sprockets fix and the safe updates in one pull request — the safe updates cannot be tested until sprockets is fixed.
- Deliver autonomously — no reason given.
- Skip the Codex review — the diff is lockfile-only.

## Open questions

None.
