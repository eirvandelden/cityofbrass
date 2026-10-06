# Spec: Replace Devise with Rails 8 built-in authentication

From `intent.md` (2026-10-05). Status: accepted.

## Flagged concerns

- **Pepper.** Devise stores `bcrypt(password + DEVISE_PEPPER)`. If `DEVISE_PEPPER` is set in production, copying `encrypted_password` into `password_digest` locks every account out. Etienne does not know whether it is set. The migration therefore aborts when `DEVISE_PEPPER` is present, and the plan must confirm the production value before deploy.
- **Playbook rule 13.** Dropping the Devise initializer and routes touches no deployment file. No `deploy.yml`, Dockerfile or workflow file changes. `DEVISE_SECRET` and `DEVISE_PEPPER` stay in the deploy environment until a later change removes them.
- **Playbook rule 9.** The migration drops columns. The intent approves this explicitly.
- **Rule 11.** `bcrypt` becomes a direct dependency. The intent approves this. `devise` and `devise-i18n` are removed, also approved.

## Requirements

1. `User` and `Admin` authenticate with `has_secure_password`, stored in `password_digest`.
2. `password_digest` receives the value of `encrypted_password` for every existing User and Admin. Existing passwords keep working.
3. A polymorphic `sessions` table records each sign-in: authenticatable type and id, IP address, user agent. A signed, permanent cookie holds the session id. Sign-in is remembered, as today.
4. One `Authentication` concern in the core `ApplicationController` provides `current_user`, `current_admin`, `user_signed_in?`, `admin_signed_in?`, `authenticate_user!` and `authenticate_admin!`. Every engine inherits them with no per-engine code change beyond removing Devise-only calls.
5. Sign in at `/users/login` and `/admins/login`. Sign out at `/users/logout` and `/admins/logout` (DELETE). The paths stay as they are today. An unauthenticated request to a protected page redirects to the matching login page and returns to the page after sign-in.
6. Password reset by email for User and Admin. The reset token is a signed `password_reset_token` that expires after 6 hours. Requesting a reset for an unknown email gives the same response as a known email.
7. Lockout. After 20 consecutive failed attempts an account locks and refuses sign-in. It unlocks automatically 1 hour after `locked_at`. A successful sign-in resets `failed_attempts` to 0. A password reset also unlocks the account. No unlock email.
8. Sign-in tracking. Each successful sign-in increments `sign_in_count`, moves `current_sign_in_at/ip` to `last_sign_in_at/ip`, and sets `current_sign_in_at/ip`.
9. Email confirmation is removed. A User with `confirmed_at` of `NULL` signs in after the switch. No confirmation mail or view remains.
10. `User#update_account` keeps requiring the current password when the email or password changes. Password length stays 8 to 128.
11. Email is stripped and downcased before lookup, as today.
12. Existing Devise sessions and remember-me cookies stop working. Each account signs in once.
13. `SsoController#symposium` keeps working against the new `current_user`.
14. `/jobs` (Mission Control) stays behind admin sign-in.
15. Locale: the sign-in, reset and flash text keep their en, nl and it translations, now in app-owned locale files instead of `devise-i18n`.
16. Devise-only columns are dropped. `users`: `encrypted_password`, `confirmation_token`, `confirmation_sent_at`, `confirmed_at`, `unconfirmed_email`, `remember_created_at`, `reset_password_token`, `reset_password_sent_at`, `unlock_token`. `admins`: `encrypted_password`, `remember_created_at`, `reset_password_token`, `reset_password_sent_at`, `unlock_token`. The Devise indexes go with them. `failed_attempts`, `locked_at`, `sign_in_count` and the sign-in time and IP columns stay.
17. The `devise` and `devise-i18n` gems, `config/initializers/devise.rb`, `config/locales/devise.en.yml`, the Devise routes, `app/views/devise/` and the Devise mailer are gone. `bcrypt` is a direct `Gemfile` entry.
18. The test suite signs in without Devise helpers. Fixtures use `password_digest`. All tests, RuboCop, Brakeman and Bundler Audit pass.

## Design decisions

- **One polymorphic `sessions` table.** `authenticatable_type` plus `authenticatable_id` as text, because User ids are UUID text and Admin ids are integers. One concern serves both. Etienne chose this over two tables.
- **Separate cookies per account type** (`session_id` for User, `admin_session_id` for Admin), so a User and an Admin can be signed in together, as Devise's `sign_out_all_scopes = false` allows today.
- **Own `SessionsController` and `PasswordsController`, one pair for both types**, scoped by a `:user` or `:admin` route default. Views move from `app/views/devise/` to `app/views/sessions/` and `app/views/passwords/`, with the existing markup.
- **Lockout lives on the model** (`lock_if_exhausted`, `locked?`, `register_failed_attempt`), per Tell Don't Ask. A concern shared by User and Admin holds it, with the tracking logic.
- **Password migration is data-preserving and two-step.** One migration adds `password_digest`, copies the hash with SQL, and aborts if `ENV["DEVISE_PEPPER"]` is present. A second migration drops the old columns. The drop is irreversible, so `down` raises `ActiveRecord::IrreversibleMigration`.
- **Mailer.** `PasswordsMailer` replaces `Devise::Mailer`, reusing the existing reset email copy. It delivers with `deliver_later`.
- **Remember-me is always on**, matching `SessionsController#create` today. The cookie lasts 1 year, refreshed on use.
- **`timeout_in` is not carried over.** Devise's `:timeoutable` is not enabled on either model, so the 3-day setting never took effect.
- **Primary database only.** Both migrations go under `db/migrate`.

## Integration points

- Core: `app/models/user.rb`, `app/models/admin.rb`, `app/controllers/application_controller.rb`, `sessions_controller.rb`, `account_controller.rb`, `sso_controller.rb`, `users_controller.rb`, `residents_controller.rb`, `messages_controller.rb`, `affiliations_controller.rb`, `scrolls_controller.rb`, `paperclip_files_controller.rb`, `attachment_files_controller.rb`.
- Views and helpers that call `user_signed_in?` or `current_user`: layouts (header, topbar, offcanvas, navigation), residents views, `application_helper.rb`.
- Engines: importer, rulebuilder, storybuilder, gallery, campaignmanager, and any others calling `authenticate_user!`, `current_user` or admin equivalents. Engines inherit from the core `ApplicationController`, so the helpers must be visible there.
- `config/routes.rb`: `devise_for` lines and the `authenticate :admin` constraint around `/jobs` (replaced by a routing constraint that reads the admin session).
- `db/schema.rb`, `test/fixtures/users.yml`, `test/fixtures/admins.yml`, `test/application_system_test_case.rb` (`sign_in_as`), about 70 test files using Devise helpers.
- Docs: `README.md` (env table, login notes), `AGENTS.md` and `CLAUDE.md` ("User — login/auth record (Devise)").
- Deploy environment: `DEVISE_SECRET` and `DEVISE_PEPPER`, left untouched (see Flagged concerns).

## Acceptance criteria

- A User with an existing password signs in at `/users/login` and reaches the app.
- An Admin with an existing password signs in at `/admins/login` and reaches the admin pages.
- A wrong password shows an "invalid email or password" message and does not sign the User in.
- Signing out ends the session, and the same protected page then redirects to the login page.
- A visitor who opens a protected page signs in and lands on that page.
- A User who never confirmed their email signs in.
- A User signed in at once stays signed in on later requests across a browser restart (the cookie is permanent).
- A cookie from a Devise-era session no longer signs anyone in.
- A User and an Admin can be signed in at the same time in one browser.
- After 20 failed attempts the 21st attempt with the correct password is refused.
- A locked account signs in again once one hour has passed.
- A successful sign-in clears the failed-attempt count.
- A password reset resets the password and unlocks a locked account.
- A User asks for a password reset and receives an email with a link that works within 6 hours.
- A reset link older than 6 hours is refused.
- A reset request for an unknown email gets the same response as for a known one.
- A User who types their email with capitals and spaces around it still signs in.
- Signing in records the session with the IP address and user agent.
- Signing in updates sign-in count, current and last sign-in time and IP.
- Changing email or password in account settings requires the current password.
- A User whose status is not active is still redirected away from pages guarded by `check_user_status`.
- Opening `/jobs` as a signed-out visitor redirects to the admin login. An Admin sees the dashboard.
- The Symposium SSO redirect carries the signed-in User's email and resident name.
- The sign-in page shows Dutch text when the User's locale is `nl`.
- The migration copies each `encrypted_password` into `password_digest` and keeps the user and admin row counts the same.
- The migration aborts with a clear message when `DEVISE_PEPPER` is set.
- After the drop migration, `users` and `admins` have none of the Devise-only columns listed above, and `failed_attempts`, `locked_at` and the sign-in columns remain.
- No `Devise` constant, `devise` gem or `devise_for` route remains.
- `bin/rails test`, `bundle exec rubocop`, Brakeman and Bundler Audit all pass.

---
Domain skills applied: rails-architecture, rails-testing, rails-ui, object-oriented-design, dependencies.
