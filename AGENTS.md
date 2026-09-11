# City of Brass

## What this is

Tabletop RPG world-building and campaign-management platform (cityofbrass.io). A user
signs in and creates a **Resident** — their identity in the world — then builds worlds,
authors character/creature sheets, writes adventures, and runs campaigns. Content is
game-system aware (D&D 5e, Pathfinder 1e/2e, Fate Core, Draw Steel, and others defined
in `config/core_rules/`).

Rails modular monolith: core `app/` handles users, residents, auth, messaging, and
affiliations; each feature domain is its own mounted Rails engine under
`engines/` (activeplay, billing, campaignmanager, entitybuilder, gallery, importer,
report, rulebuilder, storybuilder, support, worldbuilder), routed at `/ap`, `/billing`,
`/cm`, `/eb`, `/gallery`, `/imports`, `/report`, `/rb`, `/sb`, `/wb`, `/support`.

## Domain

- **User** — login/auth record (Devise). Has a **status** (`free`, `trial`, `active`,
  `alpha`, `beta`, `vip`, `locked`, `canceled`) that gates features and quotas
  (`lib/quota.rb`).
- **Resident** — the user's in-world identity; owns the content built in each engine.
- **Affiliation** — an invite/accept relationship between residents to co-edit shared
  content or campaigns.
- **Message** — resident-to-resident inbox/sent messaging.
- Each engine owns its own models/controllers/views/migrations but shares the one
  database and one deploy.
- All primary keys are UUIDs.
- Content visibility is Public / Residents / Private throughout.

## Commands

```sh
bin/setup --skip-server    # install gems + JS packages, prepare the database (no server)
bin/dev                    # run the app, http://localhost:3000
bin/rails test              # unit, integration, and system tests
bundle exec rubocop         # linting
bin/pre_push_checks         # full pre-push gate (run before pushing)
```

Seed login: `user@example.com` / `password1`. Promote to `vip` via `/admins/login`
(same credentials) → User Admin → set status.

## Gotchas

- Three separate SQLite databases and schema files: `db/schema.rb` (primary),
  `db/queue_schema.rb` (Solid Queue), `db/cable_schema.rb` (Solid Cable) — each with its
  own `migrations_paths` in `config/database.yml`. A migration must go under the right
  path or it silently applies to the wrong database.
- System tests use Cuprite (headless Chrome) — a local Chrome/Chromium install is
  required to run `bin/rails test`.
- Records use UUID primary keys throughout; do not assume integer IDs.
- Background jobs run through Solid Queue (`bin/jobs`), not Sidekiq/Redis — there is no
  separate queue server.
