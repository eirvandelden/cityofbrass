# Plan: Replace Devise with Rails 8 built-in authentication

From `intent.md` (2026-10-05) and `spec.md` (accepted). Status: accepted.

## Context

User and Admin login runs on Devise (`devise`, `devise-i18n`, Warden). The app is on Rails 8.1.4, which ships `has_secure_password` with signed reset tokens and the session-record pattern. This change replaces Devise with app-owned code, keeps every account and password working, keeps lockout and sign-in tracking, drops email confirmation, and drops the Devise-only columns. Every account signs in once after deploy.

Project scope: personal (Minitest, fixtures, `rv`, SQLite). Seed login stays `user@example.com` / `password1`.

## Design decisions

The spec's design decisions stand (polymorphic `sessions` table, `session_id` / `admin_session_id` cookies, one `SessionsController` and `PasswordsController` scoped by a `:scope` route default, lockout on the model, two migrations, `PasswordsMailer`, always-on remember-me, no `timeout_in`). Decisions the spec left open, or that this plan changes:

1. **Password length is 8 to 72 bytes, not 8 to 128.** Etienne chose this on 2026-10-06. Rails 8.1 `has_secure_password` validates a 72-byte maximum (the BCrypt limit); Devise silently truncated after 72. Keep the built-in validations and add `length: { minimum: 8 }, allow_nil: true` on `password`. Existing passwords of any length keep working, because `authenticate` does not apply the length validation. This amends spec requirement 10.
2. **Signed-out visitors get a locale from `Accept-Language`.** Etienne chose this on 2026-10-06. `ApplicationController#set_locale` becomes: `current_user&.locale`, else the `Accept-Language` entry with the highest `q` weight (default 1.0, ties keep header order) whose primary subtag (`nl-NL` → `nl`), converted with `to_sym`, is in `I18n.available_locales` (configured as symbols `%i[en nl it]`), else `I18n.default_locale`. Parse the header by hand in a private method; no new gem. This goes beyond the intent: the spec acceptance criterion "the sign-in page shows Dutch text when the User's locale is nl" cannot hold for a signed-out visitor otherwise.
3. **Sign-in and reset views use `t()`, with no Devise helpers.** The Devise views hardcode English headings and buttons and call `resource`, `resource_name`, `resource_class`, `devise_mapping`, `session_path(...)`, `password_path(...)` and `new_password_path(...)`; none of these exist after the change. The new views keep the same HTML structure and CSS classes but take `@account` (a new or found `User`/`Admin`), `@scope` (`"user"`/`"admin"`) and explicit URLs from the controller (`@form_url`, `@forgot_password_url`), and use `form_with model: @account, scope: @scope, url: @form_url`. The new `app/views/sessions/_links.html.erb` renders only the forgot-password link (`@forgot_password_url`). The admin heading prefix ("Admin Login") reads from `@scope`. Every visible string goes through `t()`. All nl and it strings are copied from the `devise-i18n` 1.15.0 gem locale files (`rails/locales/{nl,it}.yml`) and the en strings from `config/locales/devise.en.yml` or `devise-i18n`'s `en.yml`. No translation is written by hand. Where no source string exists (for example "invalid or expired reset link"), compose it from existing source strings (`activerecord.attributes.user.reset_password_token` + `errors.messages.expired`) per language, as Devise does today.
4. **Locale files.** New `config/locales/authentication.{en,nl,it}.yml` hold: `activerecord.attributes.{user,admin}.{email,password,password_confirmation,current_password}` (today supplied by `devise-i18n`, used by `ApplicationFormBuilder` labels on the sign-in and account pages), the view strings under `sessions.new.*` and `passwords.{new,edit}.*`, the flash strings under `sessions.*` / `passwords.*` / `authentication.*`, and the mail subject `passwords_mailer.reset.subject`. Add `admin` attributes in en/nl/it by reusing the user strings. `config/i18n-tasks.yml` drops `devise` from both ignore lists.
5. **Model concern `Authenticatable`** (`app/models/concerns/authenticatable.rb`), included in `User` and `Admin`:
   - `has_secure_password reset_token: { expires_in: 6.hours }` (supported in activemodel 8.1.4: `reset_token: { expires_in: }`). Gives `password_reset_token` and `find_by_password_reset_token`; a token dies once the password changes.
   - `has_many :sessions, as: :authenticatable, dependent: :destroy`.
   - `normalizes :email, with: ->(email) { email.strip.downcase }` (also applies to `find_by(email:)`).
   - `validates :password, length: { minimum: 8 }, allow_nil: true`.
   - Constants `MAXIMUM_ATTEMPTS = 20`, `UNLOCK_IN = 1.hour`.
   - Class method `authenticate_by_credentials(email:, password:)` → the account or `nil`. Finds by email, then tells the account `authenticate_unless_locked(password)`.
   - `authenticate_unless_locked(password)`: expire an old lock first (`unlock` when `locked_at <= UNLOCK_IN.ago`), raise `Authenticatable::Locked` when `locked?`, else `authenticate(password)` on success, or `register_failed_attempt` (increment `failed_attempts`; set `locked_at` when it reaches `MAXIMUM_ATTEMPTS`) and `nil`.
   - `locked?`, `unlock` (clears `failed_attempts` and `locked_at`).
   - `start_session(ip_address:, user_agent:)`: creates the `Session`, resets `failed_attempts` to 0, and records tracking (`sign_in_count + 1`, current → last, new current at/ip). One `transaction`. Returns the session.
   - `reset_password(password:, password_confirmation:)`: `update` + `unlock` on success. Returns the `update` result.
   - Methods stay at about 5 lines each; split helpers as needed.
6. **Model `Session`** (`app/models/session.rb`): `belongs_to :authenticatable, polymorphic: true`. Text UUID primary key like every other table (`id: :text, default: -> { "uuid()" }`), assigned by `ApplicationRecord`'s UUID callback. `authenticatable_id` is text because `Admin#id` is an integer and `User#id` a UUID string.
7. **`Current`** (`app/models/current.rb`): `ActiveSupport::CurrentAttributes` with `user_session` and `admin_session`. Reset per request automatically.
8. **Controller concern `Authentication`** (`app/controllers/concerns/authentication.rb`), included in `ApplicationController`, all helpers exposed with `helper_method`:
   - `current_user`, `current_admin`, `user_signed_in?`, `admin_signed_in?` — resume lazily from `cookies.signed[:session_id]` / `cookies.signed[:admin_session_id]`, looking up `Session.find_by(id:, authenticatable_type: "User")` (or `"Admin"`). Lazy matters: `set_locale` runs first and calls `current_user`.
   - On resume, refresh the cookie expiry (1 year, `httponly: true`, `same_site: :lax`).
   - `authenticate_user!` / `authenticate_admin!`: when signed out, store `request.url` in `session[:return_to_after_authenticating]` for GET HTML requests and redirect to `main_app.new_user_session_path` / `main_app.new_admin_session_path` with the "unauthenticated" alert. Non-HTML formats (`js`, `json`) get `head :unauthorized`, as Devise's failure app does. Use `main_app.` because isolated engine controllers call these filters.
   - `start_new_session_for(account, cookie_name)` and `terminate_session(cookie_name)` for the sessions and passwords controllers.
   - The cookie names map by type in one frozen hash (`"User" => :session_id, "Admin" => :admin_session_id`). No `send` or `constantize`.
9. **`SessionsController` and `PasswordsController`** (core `app/controllers/`), inherit `ApplicationController`. Each resolves its model from `params[:scope]` through a frozen hash `{ "user" => User, "admin" => Admin }.fetch(params[:scope])`.
   - `SessionsController#new` renders the form; `#create` calls `authenticate_by_credentials`, then `start_new_session_for` and redirects to the stored return URL or `main_app.root_path` with the "signed in" notice; on `nil` re-renders `new` with `status: :unprocessable_entity` and the "invalid email or password" alert; `rescue Authenticatable::Locked` re-renders with the "your account is locked" alert, as Devise does today; `#destroy` terminates the session of that scope only and redirects to root with the "signed out" notice.
   - Flash after sign-in uses the account's locale for a User (`I18n.with_locale(account.locale)`); Admin has no locale column and uses the request locale.
   - `PasswordsController#new` / `#create` (always the same notice, known or unknown email; `PasswordsMailer.reset(account, edit_url).deliver_later` only when found) / `#edit` / `#update` (finds by `find_by_password_reset_token`; invalid or expired → redirect to `new` with the expired alert; success → `reset_password`, then start a new session and redirect to root with "password changed, you are now signed in", matching Devise's `sign_in_after_reset_password` default today).
   - `#update` with an invalid new password (shorter than 8, over 72 bytes, or confirmation mismatch) re-renders `edit` with `status: :unprocessable_entity`, keeping the token in the form URL and showing the model errors; the account stays locked or unlocked as it was.
   - URLs per scope come from private controller methods that branch once on the scope with literal helper calls: user → `user_session_path`, `new_user_password_path`, `user_passwords_path`, `edit_user_password_url(token)`, `user_password_path(token)`; admin → the `_admin_` equivalents. No `send`, no string-built helper names. Do not rely on `url_for` with the `scope` default: with these routes Rails generates the `/users/...` path for an admin (verified by the second-model critique). A test asserts the mailed Admin link points at `/admins/passwords/<token>/edit`.
10. **Routes** (`config/routes.rb`), replacing both `devise_for` lines. Route names match Devise's where views or tests use them:
    ```ruby
    scope "/users", defaults: { scope: "user" } do
      get    "login",  to: "sessions#new",     as: :new_user_session
      post   "login",  to: "sessions#create",  as: :user_session
      delete "logout", to: "sessions#destroy", as: :destroy_user_session
      resources :passwords, param: :token, only: [ :new, :create, :edit, :update ], as: :user_passwords
    end
    # same block for "/admins", scope "admin", names *_admin_*
    ```
    Password paths move from `/users/password/...` to `/users/passwords/...`; Devise-era reset links die anyway. Unlock and confirmation routes are gone. Check the `/users/edit` and `/users` account routes still resolve (they are declared after and do not collide).
11. **`/jobs` (Mission Control).** Replace `authenticate :admin do ... end` with a plain `mount`, and set `config.mission_control.jobs.base_controller_class = "MissionControlController"` in `config/application.rb` (next to the existing `http_basic_auth_enabled = false`). New `app/controllers/mission_control_controller.rb`: `ActionController::Base`, `include Authentication`, `before_action :authenticate_admin!`. Not `ApplicationController`, to keep the app's helpers and engine helper registrations out of Mission Control's views. A signed-out visitor or a plain User gets redirected to the admin login, as today.
12. **`responders` goes with Devise.** `ScrollsController` calls the class-level `respond_to :html, :json, :js`, which comes from the `responders` gem, a Devise dependency. No `respond_with` exists anywhere, so the line is dead. Remove it.
13. **`PasswordsMailer`** (`app/mailers/passwords_mailer.rb`) inherits `ApplicationMailer`. `reset(account, edit_url)`; view `app/views/passwords_mailer/reset.html.erb` copies the Devise reset email markup and copy, with `@edit_url` for the link. Subject from `passwords_mailer.reset.subject` (Devise's "Reset password instructions" in en/nl/it). Delivered with `deliver_later`.
14. **Migrations, primary database only (`db/migrate`)**, generated with `bin/rails g migration` for real timestamps:
    - `CreateSessions`: `sessions` (text UUID id), `authenticatable_type` text null false, `authenticatable_id` text null false, `ip_address` text, `user_agent` text, timestamps; index on `[authenticatable_type, authenticatable_id]`.
    - `CopyDevisePasswordsToPasswordDigest`: `up` raises with a clear message ("DEVISE_PEPPER is set; Devise hashes include the pepper and would not verify with has_secure_password. Remove the pepper only after confirming it is unused in production.") when `ENV["DEVISE_PEPPER"].present?`; adds `password_digest` (text) to `users` and `admins`; runs `UPDATE users SET password_digest = encrypted_password` and the same for `admins`. Rows with an empty `encrypted_password` get an empty digest; `authenticate` returns false for them, which equals today. `down` removes `password_digest`.
    - `RemoveDeviseColumns`: removes the indexes and then the columns listed in spec requirement 16. `down` raises `ActiveRecord::IrreversibleMigration`.
    - Run `bin/rails db:migrate` and commit the regenerated `db/schema.rb`. Do not touch `db/queue_schema.rb` or `db/cable_schema.rb`.
    - **Deploy with a short downtime, one release.** Etienne chose this on 2026-10-06 over an expand/cutover/contract split. Old Devise code fails once `encrypted_password` is gone, and new code fails before `password_digest` and `sessions` exist; `config/deploy.yml` runs migrations through the `kamal migrate` alias (`app exec --reuse "bin/rails db:migrate"`), which runs in the current container. Runbook, written into the PR description (no deploy file changes): (1) confirm `DEVISE_PEPPER` is empty in production; (2) back up the production primary SQLite database; (3) stop the app; (4) run `db:migrate` in the new image; (5) boot the new image. The implementer writes the exact Kamal commands after checking the Kamal docs for the version in `Gemfile.lock`, and states the expected downtime. Only Etienne runs them (playbook rule 13).
15. **Test sign-in helper.** New `test/test_helpers/session_test_helper.rb`, included in `ActionDispatch::IntegrationTest` and `ActionController::TestCase` from `test/test_helper.rb`. It provides `sign_in(account)` and `sign_out(account_or_scope)` with the same call shape as Devise's helpers, so the ~70 test files only lose their `include Devise::Test::...` line. Integration tests set the signed cookie the Rails 8 way (`ActionDispatch::TestRequest.create.cookie_jar` → copy into `cookies`); controller tests write `cookies.signed[...]` directly. Fixtures use `password_digest: <%= BCrypt::Password.create("password", cost: BCrypt::Engine::MIN_COST) %>` and drop `confirmed_at`.
16. **No rate limiting added.** The Rails 8 generator adds `rate_limit` on `sessions#create`; lockout covers the spec. Out of scope.

## Integration points

- Every engine controller calling `authenticate_user!`, `authenticate_admin!`, `skip_before_action :authenticate_user!`, `current_user`, `user_signed_in?`, `admin_signed_in?`. All inherit `::ApplicationController`, so the concern's methods and helper methods reach them unchanged. No engine file changes, except none found calling Devise-only APIs.
- `Importer::Admin::ApplicationController` uses `admin_signed_in?` — unchanged.
- Mission Control Jobs 1.1.0 via `base_controller_class`.
- `SsoController#symposium` reads `current_user` — unchanged code; gets a test.
- `UsersController` (admin user management) calls `skip_confirmation!`, `skip_confirmation_notification!`, `confirm` — removed.
- `app/views/users/_details.html.erb` shows "Confirmed At" from `confirmed_at` — row removed.
- `db/seeds.rb` calls `user.skip_confirmation!` — removed.
- `Resident` scope and `Report::UserSnapshotsController` read `current_sign_in_at` — column stays.
- `ActionMailer` + Solid Queue for `deliver_later`.
- Deploy environment: `DEVISE_SECRET` and `DEVISE_PEPPER` stay set and unused. No deploy file changes (playbook rule 13).

## Files that change

Core app:
- `Gemfile`, `Gemfile.lock` — remove `devise`, `devise-i18n`; add `gem "bcrypt"` (unpinned, per the dependencies skill). `bundle install` drops `warden`, `orm_adapter`, `responders`.
- `config/application.rb` — remove the `Devise.secret_key` `before_initialize` block; add `base_controller_class`.
- `config/initializers/devise.rb`, `config/locales/devise.en.yml` — delete.
- `config/locales/authentication.{en,nl,it}.yml` — new (decision 4).
- `config/i18n-tasks.yml` — drop `devise` from the ignore lists.
- `config/routes.rb` — decision 10 and 11.
- `app/models/concerns/authenticatable.rb`, `app/models/session.rb`, `app/models/current.rb` — new.
- `app/models/user.rb` — drop `devise`, `send_devise_notification`; include `Authenticatable`; `update_account` uses `current_password` check: `authenticate(attributes[:current_password])` then `update(attributes.except(:current_password))`, else add an error on `:current_password` ("is invalid", Rails' built-in `errors.messages.invalid`) and return false. Remove the now-duplicated `password`/`password_confirmation` create validations only if `has_secure_password` covers them (it validates password presence on create and confirmation when given; keep `password_confirmation` presence on create to preserve behaviour).
- `app/models/admin.rb` — drop `devise`, `send_devise_notification`; include `Authenticatable`.
- `app/controllers/concerns/authentication.rb`, `app/controllers/sessions_controller.rb` (rewritten), `app/controllers/passwords_controller.rb`, `app/controllers/mission_control_controller.rb` — new or rewritten.
- `app/controllers/application_controller.rb` — `include Authentication`; `set_locale` with the `Accept-Language` fallback.
- `app/controllers/users_controller.rb` — remove confirmation calls.
- `app/controllers/scrolls_controller.rb` — remove `respond_to :html, :json, :js`.
- `app/controllers/sso_controller.rb` — drop the stale "from devise" comments only.
- `app/mailers/passwords_mailer.rb`, `app/views/passwords_mailer/reset.html.erb` — new.
- `app/views/sessions/new.html.erb`, `app/views/passwords/{new,edit}.html.erb`, `app/views/sessions/_links.html.erb` (forgot-password link only), `app/views/sessions/_poweredby.html.erb` — moved from `app/views/devise/`, markup kept, strings through `t()`.
- `app/views/devise/` — delete the whole directory (confirmations, unlocks, registrations, mailer, shared included).
- `app/views/users/_details.html.erb` — remove the "Confirmed At" row.
- `db/migrate/*_create_sessions.rb`, `*_copy_devise_passwords_to_password_digest.rb`, `*_remove_devise_columns.rb`, `db/schema.rb` — new / regenerated.
- `db/seeds.rb` — remove `skip_confirmation!`.

Tests:
- `test/test_helper.rb`, `test/test_helpers/session_test_helper.rb` — new helper (decision 15).
- `test/fixtures/users.yml`, `test/fixtures/admins.yml` — `password_digest`, no `confirmed_at`.
- `test/application_system_test_case.rb` — `sign_in_as` keeps working via the unchanged route names; check the "Login" button text still matches the en translation.
- ~66 test files — remove `include Devise::Test::IntegrationHelpers` / `ControllerHelpers`. Pattern only; no other change to them.
- `test/integration/locale_settings_test.rb` — drop `assert_nil user.unconfirmed_email`; `valid_password?` → `authenticate`.
- `test/initializers/rails_8_1_deprecation_configuration_test.rb` — remove the test "configures Devise secret key without Rails secrets fallback" (line 12): it asserts `Devise.secret_key`, a setting this change removes on purpose. Keep the file's other tests.
- `test/db/seeds_test.rb` — drop the `skip_confirmation!` call (line ~42) to match `db/seeds.rb`.
- `engines/importer/Gemfile.lock` — re-lock (`BUNDLE_GEMFILE=engines/importer/Gemfile bundle lock`); the engine Gemfile evaluates the host `Gemfile`, so Devise and devise-i18n drop out of it too. `test/lib/no_devise_test.rb` checks both lock files.
- `test/integration/user_unlocks_test.rb` — delete. It tests the unlock-by-email form, which the spec removes (requirement 7: no unlock email). This is removing a feature, not skipping a failing test.
- New test files listed under Proof.

Docs:
- `README.md` (lines 37, 70, 218, 271), `AGENTS.md` and `CLAUDE.md` ("User — login/auth record (Devise)") — describe Rails built-in authentication; mark `DEVISE_SECRET`/`DEVISE_PEPPER` as unused, kept until a later change. `agents.md` (lowercase) — check whether it duplicates `AGENTS.md`; update the same line if so.

## Order of work

Each step: write the test, run it, watch it fail for the right reason, make it pass, run `bundle exec rubocop` on touched files, commit (one logical change per commit).

1. Walking skeleton. Write `test/integration/authentication_test.rb` "user with an existing password signs in" (fixture password via `password_digest`, POST `/users/login`, follow redirect, see the app). Run it, watch it fail (no `password_digest` column).
2. `CreateSessions` and `CopyDevisePasswordsToPasswordDigest` migrations with their migration tests (pepper abort, copy, row counts). `db:migrate`, commit schema.
3. `Session`, `Current`, `Authenticatable` (secure password, normalization, sessions association) with model tests. Fixtures switch to `password_digest`. `User`/`Admin` still `devise` at this point is not possible together with `has_secure_password` (both define `password=`), so this step also removes the `devise` macro from both models and `send_devise_notification`.
4. `Authentication` concern, `SessionsController`, new routes for sessions, views moved to `app/views/sessions/`. Steps 3 and 4 may land as one commit if the suite cannot stay green between them. `SessionTestHelper`; remove the Devise test includes across the suite in the same commit so the suite stays runnable. Step 1's test passes.
5. Remaining sign-in acceptance tests: wrong password, sign-out, return-to, unconfirmed user, permanent cookie, Devise-era cookie ignored, User + Admin together, email normalization, session record, tracking, `check_user_status`.
6. Lockout (`authenticate_unless_locked`, `register_failed_attempt`, auto-unlock) with model and acceptance tests.
7. `PasswordsController`, `PasswordsMailer`, password routes and views; reset acceptance and mailer tests. Delete `user_unlocks_test.rb`.
8. `User#update_account` on `authenticate`; update `locale_settings_test.rb`.
9. `/jobs`: `MissionControlController`, `base_controller_class`, plain `mount`; update `jobs_dashboard_test.rb`.
10. `SsoController` test.
11. Locale: `authentication.{en,nl,it}.yml`, views through `t()`, `Accept-Language` fallback in `set_locale`; visitor-locale and nl-flash tests.
12. `RemoveDeviseColumns` migration + test; `db:migrate`; schema. Remove confirmation calls in `UsersController`, `_details` row, `db/seeds.rb`.
13. Remove `devise`, `devise-i18n` from the `Gemfile`, add `bcrypt`; `bundle install`; re-lock `engines/importer/Gemfile.lock`; update `rails_8_1_deprecation_configuration_test.rb` and `seeds_test.rb`; delete `config/initializers/devise.rb`, `config/locales/devise.en.yml`, `app/views/devise/`, the `config/application.rb` Devise block, `ScrollsController`'s `respond_to`; update `config/i18n-tasks.yml`. Add the "no Devise remains" test.
14. Docs: `README.md`, `AGENTS.md`, `CLAUDE.md`. Write the downtime runbook for the PR description (decision 14).
15. Full verification (below), then re-read the whole diff.

## Risks

- **Deploy window.** Between stopping the old app and the migration finishing, the site is down. Chosen deliberately (decision 14). A failed migration leaves the database half-migrated: the copy migration runs in one transaction on SQLite; the drop migration runs after it. The pre-deploy backup is the rollback path, since the drop is irreversible.
- **`DEVISE_PEPPER` in production.** If it is set, copied hashes do not verify and every account is locked out. The copy migration aborts on a set pepper, but that only protects an environment where the variable is present at migrate time. Checked on 2026-10-06 in the production console: `Devise.pepper.present?` and `ENV["DEVISE_PEPPER"].present?` are both `false`, and `config/deploy.yml` does not pass `DEVISE_PEPPER` to the container. Still open: whether a pepper went into hashes on an earlier host. Before deploy, Etienne checks one known account per type with `BCrypt::Password.new(<record>.encrypted_password) == "<password>"` in the production console; `true` confirms that hash has no pepper.
- **Every session dies on deploy.** Expected (spec requirement 12). Warden session keys and `remember_user_token` / `remember_admin_token` cookies are ignored; they expire on their own.
- **Locked-account message.** Devise today shows "Your account is locked." for a locked account (`paranoid` is off), which tells an attacker the email exists. Etienne decided on 2026-10-06 to keep this message, accepting that it reveals the email exists. The model raises `Authenticatable::Locked`, the controller rescues it (playbook §3: raise freely, rescue higher).
- **Polymorphic id type.** `Admin#id` is integer, `sessions.authenticatable_id` is text. SQLite text affinity makes `'1' = 1` compare equal and Active Record casts by column type. A model test covers `admin.sessions` and `session.authenticatable` for an Admin.
- **Mission Control `base_controller_class`.** If Mission Control 1.1.0 needs helpers from the base class, its pages break. `jobs_dashboard_test.rb` renders the dashboard as an Admin and catches this.
- **Removed transitive gems.** `responders`, `warden`, `orm_adapter` disappear. Only `ScrollsController#respond_to` uses `responders`. A full `bin/rails test` run after step 13 is the check; also boot `bin/rails runner 'Rails.application.eager_load!'`.
- **Route generation by default.** Rejected: `url_for(..., scope: "admin")` generates the user path with these routes. The explicit per-scope URL map replaces it.
- **`normalizes :email`** applies on save. Devise already stored emails stripped and downcased, so existing rows match.
- **Empty `encrypted_password`.** Copied as `""`; `authenticate` returns false; same as today.
- **Rejected:** two `sessions` tables (spec chose polymorphic); a routing constraint for `/jobs` (returns 404 instead of redirecting to the admin login); `http_accept_language` gem (new dependency; a hand parser is a few lines); keeping 8..128 with silent truncation (Etienne chose 72).

## Out of scope

- Removing `DEVISE_SECRET` / `DEVISE_PEPPER` from the deploy environment or `README` env table beyond marking them unused.
- The `omniauth` gem (not wired to Devise's omniauthable; untouched).
- Rate limiting on sign-in.
- Redirecting an already signed-in account away from the login page (Devise did; the new page simply renders).
- Unlock-by-email, email confirmation, registrations.
- Translating any page other than sign-in, password reset and their flashes.

## Proof

Acceptance criteria → tests:

- A User with an existing password signs in at `/users/login` and reaches the app → `test/integration/authentication_test.rb` `test "user with an existing password signs in"`; `test/system/sign_in_test.rb` `test "user signs in"`
- An Admin with an existing password signs in at `/admins/login` and reaches the admin pages → `test/integration/authentication_test.rb` `test "admin signs in and reaches the admin pages"`; `test/system/sign_in_test.rb` `test "admin signs in"`
- A wrong password shows "invalid email or password" and does not sign in → `authentication_test.rb` `test "wrong password shows invalid email or password"`
- Signing out ends the session; the protected page then redirects to login → `authentication_test.rb` `test "signing out ends the session"`
- A visitor who opens a protected page signs in and lands on that page → `authentication_test.rb` `test "sign in returns to the requested page"`
- A User who never confirmed their email signs in → `authentication_test.rb` `test "user without confirmation signs in"`
- Signed-in User stays signed in across a browser restart (permanent cookie) → `authentication_test.rb` `test "session cookie is persistent for a year"`
- A Devise-era cookie no longer signs anyone in → `authentication_test.rb` `test "devise remember cookie does not sign in"`
- A User and an Admin signed in at once in one browser → `authentication_test.rb` `test "user and admin are signed in together"`
- After 20 failed attempts the 21st correct attempt is refused → `test/integration/lockout_test.rb` `test "twentieth failure locks the account"` (asserts the "account is locked" alert)
- A locked account signs in again after one hour → `lockout_test.rb` `test "lock expires after one hour"`
- A successful sign-in clears the failed-attempt count → `lockout_test.rb` `test "successful sign in clears failed attempts"`
- A password reset resets the password and unlocks a locked account → `test/integration/password_resets_test.rb` `test "reset changes the password and unlocks the account"`
- A User asks for a reset and gets an email with a link that works within 6 hours → `password_resets_test.rb` `test "reset email link works within six hours"`
- A reset link older than 6 hours is refused → `password_resets_test.rb` `test "reset link older than six hours is refused"`
- Unknown email gets the same response as a known one → `password_resets_test.rb` `test "unknown email gets the same response"`
- Email with capitals and spaces still signs in → `authentication_test.rb` `test "email is stripped and downcased"`
- Sign-in records the session with IP and user agent → `authentication_test.rb` `test "sign in records ip and user agent"`
- Sign-in updates count and current/last time and IP → `authentication_test.rb` `test "sign in updates tracking columns"`
- Changing email or password requires the current password → `test/integration/locale_settings_test.rb` `test "email changes require the signed in user's current password"`, `"password changes require the signed in user's current password"`, `"password changes with the signed in user's current password"`
- Inactive User still redirected by `check_user_status` → `authentication_test.rb` `test "inactive user is redirected by check_user_status"`
- `/jobs` signed out redirects to admin login; Admin sees the dashboard → `test/integration/jobs_dashboard_test.rb` `test "signed out visitor is redirected to the admin login"`, `"admin can open the jobs dashboard"`, `"user cannot open the jobs dashboard"`
- Symposium SSO redirect carries email and resident name → `test/controllers/sso_controller_test.rb` `test "redirect carries the user's email and resident name"`
- Sign-in page shows Dutch text for locale nl → `test/integration/authentication_locale_test.rb` `test "visitor with dutch accept-language sees dutch sign in page"`, `test "dutch user sees dutch signed in notice"`
- Migration copies each hash and keeps row counts → `test/migrations/copy_devise_passwords_to_password_digest_test.rb` `test "copies encrypted_password into password_digest"`, `test "keeps user and admin row counts"`
- A migrated legacy Devise hash still signs in (spec requirement 2) → `test/integration/legacy_password_test.rb` `test "user with a copied devise hash signs in"`, `test "admin with a copied devise hash signs in"`: a fixed, literal Devise BCrypt hash (cost 10, no pepper, generated once with `BCrypt::Password.create("legacy-password", cost: 10)` and pasted as a constant) goes into a recreated `encrypted_password` column, the copy migration's `up` runs, then `POST /users/login` (or `/admins/login`) with `legacy-password` succeeds. Same setup technique as the migration tests.
- Migration aborts when `DEVISE_PEPPER` is set → same file, `test "aborts when DEVISE_PEPPER is set"`
- After the drop migration, Devise columns are gone and lockout/tracking columns remain → `test/migrations/remove_devise_columns_test.rb` `test "drops devise only columns and keeps tracking columns"`
- No `Devise` constant, gem, or `devise_for` route remains → `test/lib/no_devise_test.rb` `test "devise is gone"` (asserts `!defined?(Devise)`, no `devise` in `Gemfile.lock`, no `devise_for` in `config/routes.rb`)
- Tests, RuboCop, Brakeman, Bundler Audit pass → verification commands below, not a test

Unit tests per changed file:
- `app/models/concerns/authenticatable.rb` (via `test/models/user_test.rb` and `test/models/admin_test.rb`): `authenticate_by_credentials returns the account for the right password`, `returns nil for a wrong password`, `returns nil for an unknown email`, `refuses a locked account with the right password`, `register_failed_attempt locks at twenty`, `expired lock is cleared before authenticating`, `start_session creates a session and records tracking`, `start_session resets failed attempts`, `reset_password updates and unlocks`, `password_reset_token expires after six hours`, `password shorter than eight is invalid`, `password over 72 bytes is invalid`, `normalizes email`.
- `app/models/user.rb`: `update_account requires current password for an email change`, `update_account changes locale without current password`.
- `app/models/session.rb` (`test/models/session_test.rb`): `belongs to a user`, `belongs to an admin with an integer id`.
- `app/controllers/application_controller.rb` (`test/integration/authentication_locale_test.rb`): `accept-language picks the highest weighted available locale`, `accept-language region tag maps to its language`, `falls back to default for an unknown language`, `signed-in user's locale wins over accept-language`.
- `app/controllers/concerns/authentication.rb`: `authenticate_user! answers 401 for a js request` (in `authentication_test.rb`).
- `app/controllers/passwords_controller.rb` (`test/integration/password_resets_test.rb`): `admin reset mail links to the admin edit path`, `too short new password re-renders with errors and keeps the token`, `mismatched confirmation re-renders with errors`.
- `app/mailers/passwords_mailer.rb` (`test/mailers/passwords_mailer_test.rb`): `reset mail goes to the account with the edit link`, `subject is translated`.

Test setup: fixtures `users(:dan)` (active), `users(:brittany)` (suspended), `admins(:dan)` with `password_digest` for `"password"`. `SessionTestHelper#sign_in` for tests that need a signed-in account; acceptance tests sign in through `POST /users/login` so they exercise the real path. Time travel via `travel` for lockout and token expiry. `ActionMailer::Base.deliveries` with `perform_enqueued_jobs` for the reset mail. Migration tests run the migration class against the test database inside the test transaction (SQLite DDL is transactional): recreate the pre-migration columns, insert rows with raw SQL, `migrate(:up)`, assert with raw SQL, and `reset_column_information` on `User`/`Admin` in teardown. `ENV["DEVISE_PEPPER"]` set and restored in an `ensure`. SSO test sets `SYMPOSIUM_SSO_SECRET`/`SYMPOSIUM_SSO_URL` and signs the payload with `SingleSignOn#sign`.

## Verification

```sh
bin/rails test test/integration/authentication_test.rb   # narrowest first
bin/rails test                                            # full suite incl. system tests (needs Chrome)
bundle exec rubocop
bundle exec brakeman --no-pager
bundle exec bundle-audit check --update
bin/rails runner 'Rails.application.eager_load!'
bin/pre_push_checks
```

Manual: `bin/dev`, sign in as `user@example.com` / `password1` (after re-seeding, or with a copy of the dev database migrated: confirm a pre-existing dev account signs in with its old password), sign out, request a reset and open the mail from the log, sign in at `/admins/login`, open `/jobs`.

---
Domain skills applied: rails-architecture, rails-testing, rails-ui, object-oriented-design, dependencies, rails-guides (has_secure_password, CurrentAttributes).
Second-model critique: `codex -p terra`, 2026-10-06. All seven findings adopted; finding 3 (rollout) resolved by Etienne as one release with downtime.
