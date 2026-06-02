# Comment App

A Rails 8 application for tree-structured comments with live updates,
multi-channel notifications, and full-text search.

## Stack

- **Rails 8** (Propshaft) + **Hotwire** (Turbo + Stimulus) + **Tailwind CSS**
- **esbuild** — bundles Stimulus controllers and Action Cable client code
- **PostgreSQL** — primary datastore
- **Redis** — Action Cable pub/sub, Sidekiq queues, Rails cache
- **Sidekiq** — background workers (notifications, search indexing, bulk generation)
- **Meilisearch** — full-text comment search
- **Devise** — email/password authentication
- **noticed** — multi-channel notifications (in-app, email, mobile-push seam)
- **ancestry** — materialized-path comment trees (comment-on-comment)

## Frontend (Turbo + Stimulus)

The UI is server-rendered ERB with Hotwire — no React SPA.

- **Turbo** — page navigation, lazy-loaded comment/search pages (`turbo_frame`), form submissions
- **Stimulus** — live comment feed, thread expand/collapse, search debounce, notification badge, presence
- **Action Cable** — pushes new comments and unread notification counts to connected browsers

Key controllers live under `app/javascript/controllers/` (for example `comments_live_controller`,
`thread_controller`, `notifications_live_controller`).

## Run everything with one command

```bash
docker compose up --build
```

This starts PostgreSQL, Redis, Meilisearch, the Rails web server (port 3000),
two Sidekiq workers (interactive + generation), and an `assets` service that builds JS/CSS once then watches
for changes (no manual `yarn build` needed). The web service creates and
migrates the database automatically on boot.

App: http://localhost:3000 · Sidekiq dashboard: http://localhost:3000/sidekiq
(HTTP Basic Auth via env vars) · Meilisearch: http://localhost:7700

## Local (non-Docker) development

Requires Ruby 3.3.7, Node 25, PostgreSQL, Redis, and (optionally) Meilisearch.

```bash
bundle install
yarn install
bin/rails db:prepare
bin/dev            # web + asset watchers + interactive & generation Sidekiq (Procfile.dev)
```

## Architecture

- `app/services/` — write logic (`Comments::CreateService`, `Comments::NotifyService`, `Comments::BroadcastService`)
- `app/queries/` — read/query objects (`Comments::IndexQuery`, `Comments::RepliesQuery`, `Comments::SearchQuery`, `Users::DirectoryQuery`, `Notifications::RecentQuery`)
- `app/notifiers/` — `NewCommentNotifier` and delivery methods (`InAppCableDelivery`, `PushDeliveryMethod`)
- `app/workers/` — Sidekiq jobs (`FakeCommentsGenerationWorker`, `ReindexCommentsWorker`)
- `app/channels/` — `CommentsChannel`, `NotificationsChannel`, `PresenceChannel`
- `app/jobs/` — Active Job wrappers (for example `Comments::PostCreateJob` on the `notifications` queue)

## Generating fake data (millions of tree comments)

```bash
# Enqueue generation of 1,000,000 fake nested comments (batched insert_all):
bin/rails 'fake:comments[1000000]'

# Populate Meilisearch afterwards (insert_all bypasses indexing callbacks):
bin/rails fake:reindex
```

Both run on the dedicated low-priority `generation` queue (separate Sidekiq process), so they
do not block notifications or other interactive work. The generator self-re-enqueues in 100k chunks.

## Configuration

Copy `.env.example` to `.env` and adjust. Key variables: `DATABASE_*`,
`REDIS_URL`, `MEILISEARCH_URL`, `MEILISEARCH_API_KEY`, `SIDEKIQ_CONCURRENCY`,
`SIDEKIQ_DASHBOARD_USERNAME`, `SIDEKIQ_DASHBOARD_PASSWORD`.

## Production

```bash
RAILS_MASTER_KEY=$(cat config/master.key) \
  docker compose -f docker-compose.prod.yml up --build -d
```

Uses the optimized production image (`Dockerfile`) with Thruster + Puma for web
and separate Sidekiq workers for interactive and generation queues. Provide `SECRET_KEY_BASE`, strong
`POSTGRES_PASSWORD` / `MEILI_MASTER_KEY`, and `APP_HOST` via the environment.

## Sidekiq dashboard auth

Protect `/sidekiq` with HTTP Basic Auth by setting:

- `SIDEKIQ_DASHBOARD_USERNAME`
- `SIDEKIQ_DASHBOARD_PASSWORD`

You can set them in `.env` for Docker/local development, or as environment
variables in your deployment.

## Quality

```bash
bundle exec rubocop      # omakase styling
bundle exec brakeman     # security scan
yarn lint:js             # ESLint for Stimulus/JS
```
