# Delivery account: upgrade-ruby-4-0-9

## Behaviour delivered

The app, its seven engines, the Docker image default and the RuboCop target move from Ruby 3.4.9 to 4.0.9. Puma moves from 7.2.1 to 7.2.3 to clear seven advisories that also fail on `main`. The importer lockfile records Ruby 4.0.9 too (Etienne put the engines in scope after delivery); its `BUNDLED WITH` stays 4.0.11. No app code changed.

## Evidence

- `rv run ruby -v` and `rv run bundle exec ruby -v`: ruby 4.0.9. All eight `.ruby-version` files read `4.0.9`.
- `bin/rails test`: 1480 runs, 5070 assertions, 0 failures, 0 errors, 0 skips, on the final puma 7.2.3 lock.
- RuboCop: 1112 files, no offenses. Brakeman: 0 warnings. `bundler-audit`: no vulnerabilities. `bin/i18n-tasks health`: green.
- Smoke test on 4.0.9 with `bin/rails server`: home 200 signed out and 302 signed in (`ScrollsController#home` redirects an active signed-in user), `/users/login` 200, sign-in 302, picture upload 302, image page 200, thumbnail `image/png` 200. Puma 7.2.3 boot (round 2 review): `/users/login` 200, `/` 200 signed out.
- Docker Hub tag `ruby:4.0.9-slim`: HTTP 200 on 2026-11-19. `docker build` did not run: no Docker runtime here.
- No Ruby 3.4.9 baseline run: the 3.4.9 gem set does not build here. Parity rests on green CI on `main` at `fb8e301`.
- System tests did not run: headless Chrome does not start in the sandbox. CI on the draft PR runs them.

## Check results

All local gates green as listed above. Round 2 saw one `bin/rails test` run with 11 failures (seed not kept) and two green runs on the same commit; my own runs on 7.2.3 were green. Watch the CI `Test` job on the draft PR.

## Review outcome

Round 2: two Nits. The puma evidence line is corrected. The 8.1.2 bump and its revert stay in history, because dropping them rewrites pushed history.

Round 1: one Important, two Nits. The puma major bump became the 7.2.3 patch update. The importer lockfile leftover is deferred (see below). The evidence nit is closed by this account.

## Left for separate changes

- Seed user has no `Resident`, so the gallery upload page returns 500 on a fresh database.
- Bundler 4, a real Docker build and the exception_notification fingerprint watch after deploy.
