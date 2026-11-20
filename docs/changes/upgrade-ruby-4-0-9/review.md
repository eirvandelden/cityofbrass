# Review: Upgrade Ruby to 4.0.9

## Round 1 — 2026-11-20 10:13 UTC — d8b976b

Checks on d8b976b: `rv run ruby -v` and `rv run bundle exec ruby -v` print 4.0.9; all eight `.ruby-version` files read 4.0.9; RuboCop 1112 files, no offenses; Brakeman no warnings; bundler-audit no vulnerabilities; `bin/rails test` 1480 runs, 5070 assertions, 0 failures, 0 errors, 0 skips. System tests not re-run in this round.

- [ ] Important: The puma 7.2.1 → 8.1.2 major bump is not forced by Ruby 4.0.9, so the intent puts it out of scope ("gem upgrades beyond what Ruby 4.0.9 forces"). All seven advisories in the commit message (GHSA-xw3h-pgr9-3vg7, -x646-wp7c-h9mg, -rf6g-xhmp-gm7v, -r885-m39c-939g, -m5xw-3hrw-qcmf, -jm4r-w4xx-qxw7, -86xc-wrr9-xmmq) list `~> 7.2.2` as a patched version, so `bundle update puma --patch` to 7.2.2 clears bundler-audit. The advisories also fail on `main` (puma 7.2.1 there), so the fix belongs in its own branch and PR first (playbook rules 21 and 25), with this branch rebased on it. Puma 8.0.0 also changes the default production bind from `0.0.0.0` to `::`, a behaviour change nothing in this branch verifies before deploy. — `Gemfile.lock:408` → fixed (Update puma to 7.2.3)
  - The patch update stays in this change on Etienne's instruction. It is not a separate branch first.
- [ ] Nit: `engines/importer/Gemfile.lock` still records `ruby 3.4.9` (and `BUNDLED WITH 4.0.11`) while its `.ruby-version` now reads 4.0.9. Plan step 6 says to record this leftover 3.4 pin for a separate change; the change folder does not record it. — `engines/importer/Gemfile.lock:858` → dismissed: plan.md records the importer lockfile as a deferred leftover and deliver.md lists it for a separate change
- [ ] Nit: The change folder records no evidence for the Baseline counts (step 1), the Docker Hub tag check (step 10) or the smoke-test HTTP statuses (step 11). §7a asks that evidence be recorded; it needs a home the PR body or this folder can cite. — `docs/changes/upgrade-ruby-4-0-9/plan.md:146` → fixed (docs: delivery account for upgrade-ruby-4-0-9)

## Round 2 — 2026-11-20 10:46 UTC — 3eb65ac

Base: `origin/main` at `fb8e301`, fetched; the branch sits on it. No REVIEW.md or REVIEW.local.md at the root, so the passes follow the playbook, intent.md and plan.md. Round 1 findings hold as closed.

Checks on 3eb65ac: `rv run ruby -v` and `rv run bundle exec ruby -v` print 4.0.9; all eight `.ruby-version` files and the `Dockerfile` default read 4.0.9; puma loads as 7.2.3; RuboCop 1112 files, no offenses; Brakeman 0 warnings; bundler-audit (updated 2026-11-19) no vulnerabilities. `rv run bin/rails server` boots on Puma 7.2.3 with Ruby 4.0.9: `/users/login` 200, `/` 200 signed out. `bin/rails test` ran three times: two runs (seeds 59483 and 25905) gave 1480 runs, 5070 assertions, 0 failures, 0 errors, 0 skips; the first run gave 1480 runs, 5061 assertions, 11 failures. Its seed and failure output were not kept, so the cause is not known. It may be an order-dependent flake. Watch the CI `Test` job on the draft PR; a red run there needs its seed and failures before anyone blames Ruby 4. System tests not run in this round.

Bugs: none. Security: none; puma 7.2.3 clears the seven advisories. Design: none; the diff is pins plus one patch bump.

- [ ] Nit: The puma 8.1.2 bump (`d8b976b`) and its revert (`abaf2fa`) stay in the branch history. This repository allows merge commits only, so both land on `main` as a no-op pair. Playbook rule 18 asks for one logical change per commit. Drop both with `git rebase --onto c37931a abaf2fa`, then push with `--force-with-lease`. — `Gemfile.lock:408` → dismissed: dropping the pair rewrites pushed history and orphans d8b976b, a sha another agent was given; the pair is a harmless no-op on main
- [ ] Nit: The delivery account's Puma evidence names 7.2.3 but comes from 8.1.2 ("Puma 7.2.3 boot: `/users/login` 200 (checked on 8.1.2 …)"). This round booted 7.2.3 and saw `/users/login` 200 and `/` 200 signed out, where the account says home 302. Replace the line with the 7.2.3 result. — `docs/changes/upgrade-ruby-4-0-9/deliver.md:12` → fixed (docs: correct puma evidence in delivery account)

## Round 3 — 2026-11-20 11:01 UTC — c7cb81c

Base: `origin/main` at `fb8e301`, fetched; the branch sits on it. No REVIEW.md or REVIEW.local.md at the root, so the passes follow the playbook, intent.md and plan.md. Round 1 and round 2 findings hold as closed. The only new commit is `c7cb81c`, a two-line edit to `deliver.md`.

Checks on c7cb81c: `rv run ruby -v` and `rv run bundle exec ruby -v` print 4.0.9; all eight `.ruby-version` files and the `Dockerfile` default read 4.0.9; RuboCop 1112 files, no offenses; Brakeman 0 warnings; bundler-audit no vulnerabilities. `bin/rails test` ran twice, seeds 9414 and 3065: each gave 1480 runs, 5070 assertions, 0 failures, 0 errors, 0 skips. The round 2 failure did not come back in four green runs since; the CI `Test` job on the draft PR stays the check. System tests not run in this round.

Bugs: none. Security: none. Compliance: the code diff holds only the approved pins and the puma 7.2.3 patch Etienne kept in scope. Design: none; no Ruby code changed.

- [ ] Nit: The smoke-test line still says "home 302 signed out". `ScrollsController#home` redirects only a signed-in user, and the round 2 boot saw `/` 200 signed out, which the same bullet now also states. The two claims contradict each other in one line of evidence the PR body cites. Correct it to 200, or name the state that gave 302 (for example signed in). — `docs/changes/upgrade-ruby-4-0-9/deliver.md:12` → fixed (docs: state the signed-in and signed-out home results)
- [ ] Nit: "Review outcome" names round 1 only. Round 2 closed one Nit as fixed (the puma evidence line) and one as dismissed (the 8.1.2 bump and revert pair stay in history). Add a round 2 line so the account matches review.md. — `docs/changes/upgrade-ruby-4-0-9/deliver.md:23` → fixed (docs: align delivery account with review rounds)

## Round 4 — 2026-11-20 11:03 UTC — f93c45f

Base: `origin/main` at `fb8e301`, fetched; the branch sits on it. No REVIEW.md or REVIEW.local.md at the root, so the passes follow the playbook, intent.md and plan.md. Round 1 and round 2 findings hold as closed. The only new commit is `f93c45f`, a three-line edit to `deliver.md`. No code, lockfile or config changed since `c7cb81c`, so the round 3 checks (RuboCop, Brakeman, bundler-audit, two green `bin/rails test` runs) still apply. They did not run again.

Round 3 Nit 2 (round 2 line in "Review outcome") is fixed by `f93c45f`; its line still needs the closing arrow. Round 3 Nit 1 (home 302) changed, but the new cause is wrong. It carries over as the Nit below; close round 3 Nit 1 against it.

Bugs: none. Security: none. Compliance: the code diff holds only the approved pins and the puma 7.2.3 patch. Design: none; no Ruby code changed.

- [ ] Nit: The smoke-test line now puts the home 302 down to the dev database ("302 on the implementer's dev database, 200 on the reviewer's"). The code does not support that. `ScrollsController#home` redirects only when `user_signed_in?` and `current_user.active?` (`app/controllers/scrolls_controller.rb:3`). No `before_action` in `ApplicationController` or `Authentication` redirects a signed-out request. A signed-out `/` is 200 on any database; the 302 came from a signed-in active user. Write the state instead, for example "home 200 signed out, 302 signed in (redirect to the resident page)". — `docs/changes/upgrade-ruby-4-0-9/deliver.md:12` → fixed (docs: state the signed-in and signed-out home results)

## Round 5 — 2026-11-20 12:25 UTC — eba2629

Base: `origin/main` at `fb8e301`, fetched; the branch sits on it. No REVIEW.md or REVIEW.local.md at the root, so the passes follow the playbook, intent.md and plan.md. Round 4 Nit holds as fixed by `6babdee`. `deliver`'s `restore` dropped the removal commit `d75d55a` by rebase, so the local branch diverges from `origin/upgrade-ruby-4-0-9` (ahead 3, behind 1). PR #168 points at `d75d55a`; only `git push --force-with-lease -u origin HEAD` updates it, as `restore` prints.

New since round 4: `12398c9` sets `engines/importer/Gemfile.lock` `RUBY VERSION` to `ruby 4.0.9` and nothing else (`BUNDLED WITH` stays 4.0.11); `4712f2f` and `eba2629` record it in plan.md and deliver.md. Round 1 Nit 2 (importer leftover, dismissed) is now resolved by `12398c9` rather than deferred.

Checks on eba2629: `rv run ruby -v` prints 4.0.9; all eight `.ruby-version` files and the `Dockerfile` default read 4.0.9; root `Gemfile.lock` records `ruby 4.0.9p0`; `test/engine_gemfile_test.rb` 2 runs, 4 assertions, 0 failures. No Ruby, gem set or config changed for the root app since round 3, so its RuboCop, Brakeman, bundler-audit and `bin/rails test` results still apply. They did not run again.

Bugs: none. Security: none. Compliance: the importer lockfile change is one `RUBY VERSION` line, as plan step 6 allows, and plan.md records Etienne's scope decision. Design: none; no Ruby code changed.

- [ ] Nit: "Review outcome" round 1 still says "The importer lockfile leftover is deferred (see below)". `12398c9` resolved it, and "Left for separate changes" no longer lists it, so the line contradicts the account's own "Behaviour delivered". Replace it with the resolution, for example "The importer lockfile now records Ruby 4.0.9 (`12398c9`)". — `docs/changes/upgrade-ruby-4-0-9/deliver.md:25` → fixed (docs: bring the delivery account up to date with the reviews)
- [ ] Nit: "Review outcome" stops at round 2, while review.md now holds rounds 3 to 5, each closed by a `deliver.md` fix. "Check results" also still says "the draft PR", but PR #168 is marked ready. Add one line for rounds 3 to 5 and drop "draft", so the account matches review.md and the PR. — `docs/changes/upgrade-ruby-4-0-9/deliver.md:23` → fixed (docs: bring the delivery account up to date with the reviews)
