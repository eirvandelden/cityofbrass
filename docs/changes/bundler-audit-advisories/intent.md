# Intent: Clear the jwt, bcrypt and msgpack security advisories

Author: Etienne van Delden de la Haije. Status: accepted. Type: bugfix.

## Problem

City of Brass ships gem versions with published security advisories. On main (after PR #148, Rails 8.1.4), `bundle-audit check` reports five advisories:

- jwt 3.1.2 — high, CVE-2026-45363 (GHSA-c32j-vqhx-rx3x): a token signed with an empty HMAC key can be accepted as valid. Fixed in jwt >= 3.2.0. The app signs ActivePlay virtual table tokens with jwt (`engines/activeplay/app/controllers/activeplay/virtual_tables_controller.rb`).
- bcrypt 3.1.21 — CVE-2026-33306 (GHSA-f27w-vcwj-c954): at cost 31 on JRuby, password hashing does no key strengthening. Fixed in bcrypt >= 3.1.22. Devise uses bcrypt to hash every user password.
- msgpack 1.8.0 — CVE-2026-54522 (GHSA-4mrv-5p47-p938): use-after-free in `MessagePack::Buffer#clear` can disclose memory from another buffer. Fixed in msgpack >= 1.8.2. Pulled in by bootsnap.
- devise 4.9.4 — two medium advisories (CVE-2026-32700, CVE-2026-40295), fixed only in devise 5.

## Proposed outcome

jwt, bcrypt and msgpack are on versions with no known advisories. `bundle-audit check` reports only the two devise advisories. The devise advisories close when devise is removed from the app, which is separate work.

Signing in, password hashing, ActivePlay virtual table tokens and application boot behave as before.

## Affected users and systems

- Every user who signs in: bcrypt hashes and checks their password.
- ActivePlay virtual tables: jwt signs their tokens.
- Application boot: bootsnap loads its cache through msgpack.

## Constraints

- Builds on main; its pull request targets main. The Rails 8.1.4 work (PR #148) is already merged.
- Stay within each gem's current major version; no major upgrade in this change.
- Update only the three named gems (`bundle update <gem>`), never `bundle update` for all gems.
- Devise stays on 4.x in this change.

## Open questions

- Bugfix type requires a failing test before each fix. The jwt empty-key bypass can be shown in a test. The bcrypt flaw only occurs on JRuby at cost 31, and the msgpack flaw is a memory-safety bug; neither may be reproducible in this app's MRI test suite. Spec decides what counts as proof for those two (for example, a check that bundler-audit reports no advisory for them).
