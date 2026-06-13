# 🏛️ City of Brass

<https://cityofbrass.io>

**City of Brass** is a tabletop RPG world-building and campaign-management platform.
Each user signs in and creates a **Resident** — their identity in the world — and from
there builds and runs games: design worlds, author character and creature sheets,
write adventures, manage campaigns, and collaborate with other residents. Content is
**game-system aware**, so sheets and rules adapt to the system you're playing (D&D 5e,
Pathfinder, Fate Core, and more).

It is a Rails modular monolith made up of ~10 mounted Rails engines, one per
feature domain.

## ✨ Features

City of Brass is organized into feature engines, each mounted under its own path:

- 🗺️ **World Builder** (`/wb`) — build districts (worlds) with pages, sections, features,
  menus, and collaborating contributors.
- 🧙 **Entity Builder** (`/eb`) — game-system-aware character, NPC, and creature sheets:
  ability scores, skills, defenses, attacks, movements, and trackable resources.
- 📖 **Story Builder** (`/sb`) — author adventures and scenarios with pages, sections,
  and notable elements.
- ⚔️ **Campaign Manager** (`/cm`) — run campaigns: campaign pages, players, and features
  that tie the other tools together.
- 📜 **Rule Builder** (`/rb`) — a shared catalogue of rules, spells, items, abilities, and
  feats, scoped per game system.
- 🎲 **Active Play** (`/ap`) — live-play features and virtual tables.
- 🖼️ **Gallery** (`/gallery`) — image management and attachment to any content (Paperclip).
- 💳 **Billing** (`/billing`) — Stripe-backed subscriptions, plans, and billing events.
- 🆘 **Support** (`/support`) — FAQ and help content, including system-specific FAQs.
- 📊 **Report** (`/report`) — reporting and analytics.

Cross-cutting capabilities in the core app:

- 🔐 **Authentication** via Devise (email confirmation, account lockout) plus a custom
  single sign-on layer (`lib/single_sign_on.rb`).
- 🤝 **Collaboration** — residents send/accept **affiliations** to co-edit shared content
  and campaigns.
- 💬 **Messaging** — resident-to-resident inbox/sent messaging.
- 🛠️ **Admin panel** — user administration and status management.
- 🎚️ **Account tiers & quotas** — user statuses (`free`, `trial`, `active`, `alpha`,
  `beta`, `vip`, `locked`, `canceled`) gate features and enforce content quotas
  (`lib/quota.rb`).
- 🔒 **Privacy controls** — content visibility of Public / Residents / Private.

## 🎯 Supported game systems

Game systems are defined in `config/core_rules/`:

- 🐉 3.5 Edition
- 🐉 4th Edition
- 🐉 5th Edition
- 🔫 d20 Modern
- 🚀 d20 Future
- ⚔️ Pathfinder 1e
- ⚔️ Pathfinder 2e
- 🎴 Fate Core
- 🛡️ Draw Steel
- 🌌 W.O.I.N
- 🎲 Generic

## 🧰 Tech stack

- **Language / framework:** Ruby, Rails
- **Web server:** Puma
- **Database:** SQLite (with a custom UUID function; UUID primary keys)
- **Background jobs / cache:** Sidekiq + Redis
- **Auth:** Devise + OmniAuth
- **Payments:** Stripe
- **File uploads:** Paperclip (disk-backed, optional AWS S3)
- **Frontend:** server-rendered ERB, Turbolinks, jQuery, Foundation, Sprockets asset
  pipeline; CKEditor for rich text
- **Testing:** Minitest, Capybara + Cuprite (headless Chrome), RuboCop
- **Deployment:** Docker image, deployed with Kamal

## 💻 Supported platforms

- **Production / Docker / Kamal:** Linux on **amd64** (the image is built for
  `x86_64-linux`).
- **Development:** macOS and Linux. Requires the Ruby version pinned in `.ruby-version`,
  Redis, and a POSIX filesystem for the `storage/` directory (SQLite database and
  uploaded files live there).
- **Windows** is not supported.

## 🚀 Installation

All paths below assume the application root. Copy the example config first in every
case:

```sh
cp config/application.example.yml config/application.yml
# edit config/application.yml and fill in the values you need
```

See [Configuration](#configuration) for the full list of variables.

### 🖥️ Local machine (production-style)

1. Install **Ruby** (the version pinned in `.ruby-version`) and a running **Redis**.
2. Install dependencies and prepare the database:
   ```sh
   bin/setup            # bundle install + bin/rails db:prepare
   ```
3. Export the required production environment variables:
   ```sh
   export RAILS_ENV=production
   export SECRET_KEY_BASE="$(bin/rails secret)"
   export REDIS_URL=redis://localhost:6379/0
   export DEFAULT_BASE_URL=your.domain
   export SMTP_URL=smtp://user:pass@host:587
   export RAILS_SERVE_STATIC_FILES=1
   export RAILS_LOG_TO_STDOUT=1
   ```
4. Precompile assets and prepare the production database:
   ```sh
   bin/rails assets:precompile
   bin/rails db:prepare
   ```
5. Start the processes defined in the `Procfile`:
   ```sh
   bundle exec puma -C config/puma.rb                                   # web
   bundle exec sidekiq -c 8 -q default -q mailers -q paperclip          # worker
   ```

The SQLite production database is created at `storage/db/production.sqlite3`, and
uploads are stored under `storage/`. Back up the whole `storage/` directory.

### 🐳 Docker

The `Dockerfile` builds a self-contained **production** image (Puma on port **3000**).
The container entrypoint creates `storage/db` on boot; run database migrations
yourself after the first start.

1. Build the image:
   ```sh
   docker build -t cityofbrass .
   ```
2. Run Redis and the app on a shared network, with a volume for `storage/`:
   ```sh
   docker network create cob-net

   docker run -d --name cob-redis --network cob-net redis:7-alpine

   docker run -d --name cityofbrass --network cob-net \
     -p 80:3000 \
     -v cob-storage:/rails/storage \
     -e SECRET_KEY_BASE="$(openssl rand -hex 64)" \
     -e REDIS_URL=redis://cob-redis:6379/0 \
     -e DEFAULT_BASE_URL=your.domain \
     -e SMTP_URL=smtp://user:pass@host:587 \
     -e RAILS_SERVE_STATIC_FILES=1 \
     -e RAILS_LOG_TO_STDOUT=1 \
     cityofbrass
   ```
3. Prepare the database (first run only):
   ```sh
   docker exec cityofbrass bin/rails db:prepare
   ```

You'll also want a worker container for background jobs, started from the same image
with the Sidekiq command:

```sh
docker run -d --name cob-worker --network cob-net \
  -v cob-storage:/rails/storage \
  -e SECRET_KEY_BASE=... -e REDIS_URL=redis://cob-redis:6379/0 \
  cityofbrass bundle exec sidekiq -c 8 -q default -q mailers -q paperclip
```

### ⛵ Kamal

Production is deployed with [Kamal](https://kamal-deploy.org); see `config/deploy.yml`.
It builds the image on a remote builder, pushes to a private registry, and runs two
roles on the host: a **web** role (Puma) and a **job** role (Sidekiq), plus a **Redis**
accessory. The `storage/` directory is mounted from a persistent host volume and the
proxy health-checks `/up`.

Secrets are pulled at deploy time from `.kamal/secrets` (backed by 1Password). Provide:

- `KAMAL_REGISTRY_PASSWORD`
- `SECRET_KEY_BASE`
- `SMTP_URL`
- `ACTIVEPLAY_SECRET`

Common commands:

```sh
kamal setup        # first-time provisioning + deploy
kamal deploy       # build, push, and roll out a new release
kamal app logs     # tail application logs

# aliases defined in config/deploy.yml
kamal console      # bin/rails console on the server
kamal shell        # bash shell in the running container
kamal dbconsole    # bin/rails dbconsole
kamal migrate      # bin/rails db:migrate
```

## ⚙️ Configuration

Configuration is read from environment variables (and `config/application.yml` in
development — see `config/application.example.yml`).

| Variable | Purpose |
| --- | --- |
| `SECRET_KEY_BASE` | Rails secret; **required** in production |
| `RAILS_ENV` | Environment (`production`) |
| `DEFAULT_BASE_URL` | Public host used for URL generation and mailers |
| `REDIS_URL` | Redis connection (Sidekiq + cache) |
| `SMTP_URL` | SMTP connection string for outbound mail |
| `DEFAULT_FROM_EMAIL` | Default "from" address |
| `RAILS_SERVE_STATIC_FILES` | Serve precompiled assets from the app (`1`) |
| `RAILS_LOG_TO_STDOUT` | Log to STDOUT (`1`) |
| `WEB_CONCURRENCY` / `MAX_THREADS` | Puma workers / threads |
| `ACTIVEPLAY_URL` / `ACTIVEPLAY_SECRET` | Active Play integration |
| `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` / `AWS_REGION` | S3 image storage (optional) |
| `STRIPE_SECRET_KEY` / `STRIPE_PUBLISHABLE_KEY` / `STRIPE_WEBHOOK_TOKEN` | Stripe billing (optional) |
| `DEVISE_SECRET` / `DEVISE_PEPPER` | Devise auth secrets |

## 🧪 Development & testing

```sh
bin/setup              # install gems, prepare the database
bin/rails db:setup     # load schema and seed data
bin/rails server       # http://localhost:3000
```

The seed data creates a login you can use immediately:

- **Email:** `user@example.com`
- **Password:** `password1`

After signing in, set up your resident. To unlock paid features, promote the user to
`vip`: sign in to the admin panel at `/admins/login` with the same credentials, then
**Admin menu → User Admin → cog icon for the user → set status to `vip`**.

Running checks:

```sh
bin/rails test         # unit, integration, and system tests (Capybara/Cuprite)
bundle exec rubocop    # linting
bin/pre_push_checks    # the full pre-push gate
```

System tests use Cuprite (headless Chrome), so a local Chrome/Chromium is required.

## 🏗️ Architecture

City of Brass is a **Rails modular monolith**. The core `app/` directory handles
users, residents, authentication, messaging, and affiliations, while each major feature
domain lives in its own namespaced **Rails engine** mounted under a sub-path in
`config/routes.rb` (e.g. `/wb`, `/eb`, `/cm`). This keeps domains isolated — each engine
owns its own models, controllers, views, and migrations — while sharing one deployable
app and database.

The frontend is **server-rendered** ERB with Turbolinks for fast page transitions,
jQuery for interactivity, and Foundation for styling, served through the Sprockets
asset pipeline (no SPA or Hotwire). **Sidekiq + Redis** handle background work
(asynchronous mail, Paperclip image processing) and caching. Authentication is built on
**Devise** with a custom single-sign-on layer, and authorization is enforced through a
status-tier and **quota** system (`lib/quota.rb`) that gates features per account level.
Records use **UUID primary keys**. Persistence is **SQLite** (database and Paperclip
uploads both stored under `storage/`), payments run through **Stripe**, and the whole
thing ships as a single Docker image deployed with Kamal.
