# Plan: Clear the jwt, bcrypt and msgpack security advisories

From `intent.md` (2026-10-01) and `spec.md` (accepted). Status: accepted.

## Context

`bundle-audit check` on main reports five advisories. Three of them close with an in-major update: jwt 3.1.2 → >= 3.2.0 (CVE-2026-45363, empty HMAC key accepted), bcrypt 3.1.21 → >= 3.1.22 (CVE-2026-33306), msgpack 1.8.0 → >= 1.8.2 (CVE-2026-54522). The two devise advisories stay; devise removal is separate work. The change is `Gemfile.lock` plus tests. No app code changes.

## Design decisions

- Update command: `bundle update jwt bcrypt msgpack --conservative`. `--conservative` stops Bundler from moving shared dependencies, so spec requirement 4 (only the three gems change) holds by construction. The expected result is jwt 3.3.0, bcrypt 3.1.22, msgpack 1.8.5 (latest in each line on rubygems.org on 2026-10-13). Any of these satisfies the spec floors.
- `Gemfile` does not change. `gem "jwt"` stays unconstrained, as the spec decides.
- jwt 3.2.0 behaviour, verified against the fix commit (`db560b7`): `JWA::Hmac#sign` and `#verify` both call `ensure_valid_key!`. A nil or empty key raises `JWT::DecodeError` ("HMAC key expected to be a String" / "HMAC key cannot be empty"). This applies to `JWT.encode` as well as `JWT.decode`. On jwt 3.1.2 today, `JWT.encode(payload, nil, "HS256")` and `JWT.encode(payload, "", "HS256")` both succeed (checked locally).
- The decode test needs a token signed with an empty key. After the update `JWT.encode` refuses to make one, so the test forges it by hand: base64url header and payload, signed with `OpenSSL::HMAC.digest("SHA256", "", signing_input)`. This mirrors the attack from the advisory.
- Sign-in proof deviates from the spec. The spec says existing sign-in tests cover requirement 8. They cover only the right password (`test/system/sign_in_test.rb`). No test rejects a wrong password. This plan adds a request-level test with both cases: a POST to the Devise session path, not a system test, so it runs without Chrome and stays fast.
- The virtual table token test is a request test that hits `new_token` with `xhr: true` (the route renders `new_token.js.erb`, and Rails refuses a non-XHR cross-origin JS GET). It extracts the token from `token = '<jwt>'` in the body.
- `ACTIVEPLAY_SECRET` is not set in test or CI. The token test sets it itself and restores the old value in `teardown`, the same save/restore pattern as `test/deployment_test.rb`.
- There are no activeplay fixtures. The token test creates its `Activeplay::VirtualTable` in `setup` from `campaignmanager_campaigns(:resident_one)` (owned by `residents(:razune)`, user `users(:dan)`, status `active`). Dan is the game master, so `can_show?` passes and the payload name is `"GM"`. No new fixture file is added for one test.

## Integration points

- `Gemfile.lock`: jwt, bcrypt, msgpack.
- `engines/activeplay/app/controllers/activeplay/virtual_tables_controller.rb` `#set_token`: signs with `ENV['ACTIVEPLAY_SECRET']`, HS256. Unchanged, but now raises when the variable is unset or empty.
- Devise (`bcrypt ~> 3.0`) and bootsnap (`msgpack ~> 1.2`): both constraints allow the new versions.
- `.bundler-audit.yml`: unchanged. `test/lib/bundler_audit_config_test.rb` keeps passing.
- Production sets `ACTIVEPLAY_SECRET` from 1Password via `.kamal/secrets` and `config/deploy.yml`.

## Files that change

- `Gemfile.lock` — the three gem versions move up.
- `test/lib/gemfile_lock_advisories_test.rb` (new) — parses `Gemfile.lock` with `Bundler::LockfileParser`, compares with `Gem::Version`. One test per gem: at or above the patched floor, below the next major (jwt < 4, bcrypt < 3.2, msgpack < 2).
- `test/lib/jwt_empty_key_test.rb` (new) — signing with `""` raises; signing with `nil` raises; decoding a hand-forged empty-key token with `""` raises.
- `test/integration/activeplay_virtual_table_token_test.rb` (new) — the game master opens a virtual table and gets an HS256 token that decodes with `ACTIVEPLAY_SECRET` and carries `residentId`, `campaignId`, `name: "GM"` and an `exp` in the future.
- `test/integration/user_sign_in_test.rb` (new) — `users(:dan)` with `"password"` is signed in and redirected; with a wrong password the response re-renders the form and the user is not signed in.

## Order of work

1. Write `test/lib/gemfile_lock_advisories_test.rb`. Run it. Watch all three tests fail on jwt 3.1.2, bcrypt 3.1.21, msgpack 1.8.0.
2. Write `test/lib/jwt_empty_key_test.rb`. Run it. Watch the three tests fail (jwt 3.1.2 encodes and decodes with an empty key).
3. Write `test/integration/activeplay_virtual_table_token_test.rb`. Run it. It passes on jwt 3.1.2: it is a characterization test that pins today's behaviour before the update.
4. Write `test/integration/user_sign_in_test.rb`. Run it. It passes on bcrypt 3.1.21: also a characterization test.
5. Commit the tests (one commit per test file, or one for the characterization pair).
6. Run `bundle update jwt bcrypt msgpack --conservative`. Read `git diff Gemfile.lock`: only the jwt, bcrypt and msgpack lines may change. If any other gem moves, stop and explain why.
7. Run the four new test files. All green.
8. Run `bin/bundle-audit check --update`. Expect exactly CVE-2026-32700 and CVE-2026-40295 (devise). Record the output in the PR body.
9. Boot check: `bin/rails runner 'puts Rails.application.initialized?'` with bootsnap active (proves msgpack loads the cache). Then `bin/dev`, sign in as `user@example.com` / `password1`, and confirm the dashboard loads.
10. Run the full suite (`bin/rails test`, including system tests), `bundle exec rubocop` on the new files, `bin/brakeman`, `bin/pre_push_checks`.
11. Commit `Gemfile.lock` alone: `Update jwt, bcrypt and msgpack for security advisories`.

## Risks

- **`ACTIVEPLAY_SECRET` unset becomes a 500.** jwt >= 3.2.0 raises `JWT::DecodeError` on a nil or empty key in `JWT.encode`. Any environment without the variable now fails to open a virtual table, where before it silently issued an unsigned-in-practice token. Production sets it (`.kamal/secrets`, `config/deploy.yml`). Development and CI do not by default (`config/application.example.yml` has it blank). No existing test opens a virtual table, so the suite does not catch this. Handling the missing secret in the controller (a friendly error page) is out of scope; the spec accepts the raise as the intended fix. Etienne confirmed this on 2026-10-13: accept the dev/CI breakage, handle it as follow-up work. Etienne confirms production has the secret before deploy.
- **The bcrypt and msgpack proof is weak.** Their flaws do not reproduce on MRI. The lockfile test proves the version, not the behaviour. The sign-in test and the boot check prove nothing regressed. The spec accepts this.
- **jwt 3.3.0, not 3.2.0.** Bundler picks the newest 3.x. 3.3.0 may carry other behaviour changes. The characterization test of the token payload is the guard. Etienne accepted 3.3.0 on 2026-10-13. Rejected: pinning `~> 3.2.0` in `Gemfile`, because the spec keeps `Gemfile` unchanged.
- **Lockfile test ages.** It asserts floors and major ceilings, not exact versions, so future patch updates keep it green. A future major upgrade will fail it on purpose; that test then needs its ceiling moved.
- Rejected: a test that runs `bundle-audit`. The advisory database changes over time; such a test fails for unrelated reasons (spec decision).

## Out of scope

- Devise upgrade or removal, and its two advisories.
- Any change to `VirtualTablesController`, including handling a missing `ACTIVEPLAY_SECRET`.
- Any other gem update, `Gemfile` edits, `.bundler-audit.yml` edits.
- Setting `ACTIVEPLAY_SECRET` in CI or development config.

## Proof

- The lockfile pins jwt at 3.2.0 or later, below 4 → `test/lib/gemfile_lock_advisories_test.rb` `test "jwt is at or above 3.2.0 and below 4"`
- The lockfile pins bcrypt at 3.1.22 or later, below 3.2 → `test/lib/gemfile_lock_advisories_test.rb` `test "bcrypt is at or above 3.1.22 and below 3.2"`
- The lockfile pins msgpack at 1.8.2 or later, below 2 → `test/lib/gemfile_lock_advisories_test.rb` `test "msgpack is at or above 1.8.2 and below 2"`
- Signing a token with an empty key is refused → `test/lib/jwt_empty_key_test.rb` `test "signing with an empty key is refused"`, `test "signing with a nil key is refused"`
- Decoding a token with an empty key is refused → `test/lib/jwt_empty_key_test.rb` `test "decoding a token forged with an empty key is refused"`
- Opening a virtual table with `ACTIVEPLAY_SECRET` set gives a token that decodes with that secret and names the resident and campaign → `test/integration/activeplay_virtual_table_token_test.rb` `test "game master receives an HS256 token signed with the activeplay secret"`
- A resident signs in with the right password; a wrong password is turned away → `test/integration/user_sign_in_test.rb` `test "user signs in with the right password"`, `test "user with a wrong password is turned away"`
- `bundle-audit check` lists only the two devise advisories → check: `bin/bundle-audit check --update` shows exactly CVE-2026-32700 and CVE-2026-40295
- The application boots and the full suite passes → check: `bin/rails runner 'puts Rails.application.initialized?'` prints `true`; `bin/rails test` green

Per changed file, the unit tests expected:
- `Gemfile.lock`: covered by `gemfile_lock_advisories_test.rb` above; no app code changes, so no further unit tests.

Test setup: `users(:dan)` with password `"password"`; `campaignmanager_campaigns(:resident_one)` (owned by `residents(:razune)`, Dan's resident); one `Activeplay::VirtualTable` created in `setup`. `ACTIVEPLAY_SECRET` set to a fixed test value in `setup` and restored in `teardown`. `Devise::Test::IntegrationHelpers` for the token test. No network, no advisory database in tests.

---
Domain skills applied: dependencies, rails-testing.
