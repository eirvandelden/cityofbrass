# Intent: Replace Devise with Rails 8 built-in authentication

Author: Etienne van Delden de la Haije. Status: accepted. Type: refactor.

## Problem

User and Admin login depends on Devise, a large third-party gem with its own controllers, views, mailer, routes and Warden middleware. The app runs on Rails 8, which ships its own authentication (has_secure_password, a Session record, an Authentication concern). Devise adds an upgrade burden and an abstraction layer that the app no longer needs.

## Proposed outcome

User and Admin both sign in, sign out and reset their password through plain Rails 8 authentication. The `devise` and `devise-i18n` gems are gone. Every existing User and Admin keeps their account and logs in with their current password. Account lockout after repeated failed attempts still works. Sign-in tracking (sign-in count, current and last sign-in time and IP) still works.

Email confirmation goes away. Users who never confirmed their email can log in after the switch.

The Devise-only columns (confirmation fields, `encrypted_password` after its value moves, and any other column the new setup does not use) are dropped in this change.

## Affected users and systems

- Every User and Admin: one forced re-login, because existing Devise sessions and remember-me cookies stop working.
- Core `app/`: User and Admin models, sessions controller, Devise views, mailer, routes.
- Every engine that calls Devise helpers (`authenticate_user!`, `current_user`, `user_signed_in?`, and the admin equivalents).
- The primary database (`db/schema.rb`): a migration moves password hashes and drops columns.
- The test suite, which signs in through Devise test helpers.

## Constraints

- No user or admin record is lost, and no existing password stops working.
- The migration targets the primary database only, not the queue or cable databases.
- One re-login for every account is acceptable.
- Dropping columns is explicitly approved for this change.
- Removing `devise` and `devise-i18n` is approved.
- `bcrypt` stays: it becomes a direct `Gemfile` dependency, because it currently arrives only through Devise. Approved.
- Any other new dependency needs separate approval.

## Open questions

None.
