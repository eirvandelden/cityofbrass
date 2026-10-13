# Spec: Clear the jwt, bcrypt and msgpack security advisories

From `intent.md` (2026-10-01). Status: accepted.

## Flagged concerns

- jwt >= 3.2.0 rejects an empty HMAC key. `VirtualTablesController#set_token` signs with `ENV['ACTIVEPLAY_SECRET']`. If that variable is unset or empty in an environment, token creation fails after the update instead of silently signing with no key. This is the intended fix, but it is a visible behaviour change for any misconfigured environment. Etienne must confirm that production and CI set `ACTIVEPLAY_SECRET` before deploy.
- The bcrypt and msgpack flaws cannot be reproduced on MRI in this test suite (bcrypt: JRuby at cost 31 only; msgpack: memory-safety bug). Failing-first proof for those two is a lockfile version check, not a behaviour test. This is a deliberate weaker proof than the bugfix rule normally asks for.

## Requirements

1. `Gemfile.lock` resolves jwt to 3.2.0 or later, within major version 3.
2. `Gemfile.lock` resolves bcrypt to 3.1.22 or later, within 3.1.x.
3. `Gemfile.lock` resolves msgpack to 1.8.2 or later, within 1.x.
4. Only those three gems change in `Gemfile.lock`, plus transitive dependencies the update forces. Devise stays on 4.x. No other gem is updated.
5. `bundle-audit check` reports only the two devise advisories (CVE-2026-32700, CVE-2026-40295). The `.bundler-audit.yml` ignore list does not change.
6. ActivePlay virtual table tokens are still issued as HS256 JWTs with the same payload when `ACTIVEPLAY_SECRET` is set.
7. A JWT signed with an empty HMAC key is not accepted as valid.
8. Signing in with a correct password still works. A wrong password is still rejected.
9. The application boots (bootsnap loads its cache).

## Design decisions

- Proof for requirements 1–3 is a unit test that parses `Gemfile.lock` with `Bundler::LockfileParser` and compares versions with `Gem::Version`. It needs no network and no advisory database, so it is stable offline and in CI. It lives in `test/lib/`, next to `bundler_audit_config_test.rb`.
- Proof for requirement 5 is running `bundle-audit check` as a verification step in the plan, not as a test. The advisory database changes over time, so a test on it would fail for reasons unrelated to this change.
- Proof for requirement 7 is a direct test against the `jwt` gem: signing and decoding with an empty key must raise. This is the one advisory with a behaviour that MRI can show. It tests the dependency, not app code, because the app code does not change.
- Proof for requirement 6 is a request test of the virtual table token, since no test covers `set_token` today. It asserts the issued token decodes with `ACTIVEPLAY_SECRET` and carries the expected claims.
- Requirements 8 and 9 are covered by the existing sign-in tests and the full suite. No new test is added for them.
- No app code changes. The change is `Gemfile.lock` plus tests. `Gemfile` keeps its unconstrained `gem "jwt"`.
- Update with `bundle update jwt bcrypt msgpack` only, never a full `bundle update`.

## Integration points

- `Gemfile.lock` (jwt, bcrypt, msgpack and any forced transitive pins).
- `engines/activeplay/app/controllers/activeplay/virtual_tables_controller.rb` (`set_token`, reads `ACTIVEPLAY_SECRET`).
- Devise (depends on `bcrypt ~> 3.0`) and bootsnap (depends on `msgpack ~> 1.2`); both constraints allow the new versions.
- `bin/pre_push_checks` and `.bundler-audit.yml` (unchanged; the gate must pass).

## Acceptance criteria

- The lockfile pins jwt at 3.2.0 or later, below 4.
- The lockfile pins bcrypt at 3.1.22 or later, below 3.2.
- The lockfile pins msgpack at 1.8.2 or later, below 2.
- Signing a token with an empty key is refused instead of producing a token.
- Decoding a token with an empty key is refused instead of accepting it.
- Opening a virtual table with `ACTIVEPLAY_SECRET` set gives the player a token that decodes with that secret and names their resident and campaign.
- A resident signs in with the right password and is let in; with a wrong password they are turned away.
- `bundle-audit check` lists only the two devise advisories.
- The application boots and the full test suite passes.

---
Domain skills applied: dependencies, rails-testing.
