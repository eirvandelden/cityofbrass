# Plan: Importer flow tests run the import job

From `intent.md` (2026-10-06). Status: accepted.

## Context

Three tests in `engines/importer/test/integration/importer_import_flow_test.rb` fail on `main`:

- `resident confirms a preview and imports content` finds the import `queued`, not `succeeded`.
- `admin confirms a stock preview and imports shared content` finds the import `queued`, not `succeeded`.
- `admin import results link to created stock records` raises `ActiveRecord::RecordNotFound` on `StockCreature.find_by!(name: "Goblin")`.

Each wraps `post "/imports"` (or `post "/admin/imports"`) in `perform_enqueued_jobs`. The controllers call `Importer::ProcessImportJob.perform_later(import.id)`.

Cause, read in `activejob-8.1.4/lib/active_job/test_helper.rb`:

- `config/application.rb` sets `config.active_job.queue_adapter = :solid_queue`. `config/environments/test.rb` does not override it.
- `ActiveJob::TestHelper#before_setup` swaps in a `TestAdapter` only for job classes whose `_queue_adapter` is nil, or when `queue_adapter_for_test` returns an adapter. The explicit config makes `ActiveJob::Base._queue_adapter` non-nil, so no swap happens.
- `perform_enqueued_jobs` with a block "merely executes the block" when the adapter is not a `TestAdapter`. The job lands in the Solid Queue table and never runs.

`bin/pre_push_checks` runs every changed test file, so any branch that touches this file fails the gate. That blocks the push of `replace-devise`.

## Design decisions

- Set `config.active_job.queue_adapter = :test` in `config/environments/test.rb`. Every test class then gets the test adapter, so `perform_enqueued_jobs` and the `assert_enqueued_*` helpers work everywhere, not only in the importer tests. Etienne chose this over a per-class `queue_adapter_for_test` override on 2026-10-06.
- **Conflict with `intent.md`:** the intent says "No other test changes behaviour". The global setting changes how three other places work: `QueueStorageTest`, the `/jobs` dashboard in tests, and `Gallery::ReprocessAttachmentJobTest`. This plan reads the criterion as: every test that passes before the change still passes after it, and production and development job processing do not change. `intent.md` is not edited by this change.
- `test/jobs/queue_storage_test.rb` tests Solid Queue itself, so it selects Solid Queue explicitly. A `setup` block saves `ActiveJob::Base.queue_adapter` and sets it to `:solid_queue`. A `teardown` block restores the saved adapter object. `ApplicationSystemTestCase` used the same swap-and-restore shape until this change removed it (see below).
- The `/jobs` dashboard keeps reading Solid Queue. Mission Control 1.1.0 builds its adapter list from `config.active_job.queue_adapter` when `config.mission_control.jobs.adapters` is empty (`mission_control/jobs/engine.rb`). `TestAdapter` does not include `MissionControl::Jobs::Adapter`, so `get "/jobs"` would fail. Set `config.mission_control.jobs.adapters = [ :solid_queue ]` in `config/environments/test.rb`, next to the job adapter line.
- Both new lines go in `test.rb`, not `application.rb`. Production and development config files get no diff.
- Each new `test.rb` line gets a one-line comment that says why, matching the commented style of that file.
- No new test. The three failing importer tests are the acceptance tests. `QueueStorageTest` and `JobsDashboardTest` already prove the two side effects stay handled. A test that asserts an adapter class would be a meta-test of plumbing (rails-testing skill).

## Integration points

- `ActiveJob::TestHelper` (`before_setup`, `after_teardown`, `perform_enqueued_jobs`) in activejob 8.1.4. It is included in every `ActionDispatch::IntegrationTest` by the Active Job railtie, and in `ActiveJob::TestCase`.
- `Importer::ImportsController#create` and `Importer::Admin::ImportsController#create` enqueue `Importer::ProcessImportJob`. Neither changes. Import files use Paperclip, not Active Storage, so running jobs inline adds no `ActiveStorage::AnalyzeJob` work.
- Mission Control Jobs 1.1.0 (`/jobs`, `test/integration/jobs_dashboard_test.rb`). It prepends `SolidQueueExt` onto `SolidQueueAdapter` only when its adapter list includes `:solid_queue`.
- `test/jobs/queue_storage_test.rb` — enqueues and reads `SolidQueue::Job` rows in the queue database.
- `test/jobs/gallery/reprocess_attachment_job_test.rb` — its `perform_enqueued_jobs` block starts running the job.
- `ApplicationSystemTestCase` — its adapter swap (`swap_queue_adapter_for_system_tests`, `restore_queue_adapter`) and its setup/teardown are removed; `ActiveJob::TestHelper` clears jobs on its own.
- Mailers sent with `deliver_later` (Devise notifications, `UserMailer`, `SubscriptionMailer`) — in tests they now wait in the test adapter instead of Solid Queue rows. Neither performs them, so no outcome changes.

## Files that change

- `config/environments/test.rb` — add `config.active_job.queue_adapter = :test` and `config.mission_control.jobs.adapters = [ :solid_queue ]`, each with a why-comment.
- `test/jobs/queue_storage_test.rb` — add `setup` and `teardown` blocks that run these tests on Solid Queue and restore the previous adapter afterwards.

Nothing else. `engines/importer/test/integration/importer_import_flow_test.rb`, `config/application.rb`, `config/environments/development.rb` and `config/environments/production.rb` do not change.

## Order of work

1. Run `bin/rails test engines/importer/test/integration/importer_import_flow_test.rb`. Watch the three named tests fail: two on `"succeeded"` vs `"queued"`, one on `RecordNotFound` for `Goblin`. Any other failure reason means the cause is different: stop and report.
2. Before any code change, record the baseline. Run `bin/rails test`, `bin/rails test engines/importer/test` and `bin/rails test:system`. Write down every failing test.
3. Add `config.active_job.queue_adapter = :test` to `config/environments/test.rb`. Run the importer flow test file again. All eight tests pass.
4. Run `bin/rails test test/jobs/queue_storage_test.rb test/integration/jobs_dashboard_test.rb`. Expect red: the two `QueueStorageTest` tests that enqueue ("work handed off for later waits in the queue", "the queue remembers which work is waiting and where") and `JobsDashboardTest` "admin can open the jobs dashboard". Write down the actual failures.
5. Add the `setup`/`teardown` swap to `QueueStorageTest`. Rerun it. All four tests pass.
6. Add `config.mission_control.jobs.adapters = [ :solid_queue ]` to `config/environments/test.rb`. Rerun `JobsDashboardTest`. Both tests pass. If the dashboard test was already green in step 4, still add the line and confirm it stays green: without it, the dashboard in tests points at the test adapter.
7. Leak check: run `bin/rails test test/jobs/queue_storage_test.rb test/jobs/gallery/reprocess_attachment_job_test.rb test/integration/jobs_dashboard_test.rb engines/importer/test/integration/importer_import_flow_test.rb` in one process, with three different `--seed` values. All pass for every seed.
8. Rerun the three commands from step 2. Compare with the baseline. The only difference is the three importer tests now passing.
9. Run `bundle exec rubocop config/environments/test.rb test/jobs/queue_storage_test.rb`. Fix any offence. Both files are clean on `main`.
10. Commit both files as one change: switching test-environment jobs to the test adapter while the Solid Queue tests and dashboard keep Solid Queue.
11. Run `bin/pre_push_checks`. It exits 0. Then run the command it issues for a changed importer test: `DISABLE_SPRING=1 bundle exec rails test engines/importer/test/integration/importer_import_flow_test.rb`. It exits 0.

## Risks

- Mission Control reads `config.mission_control.jobs.adapters` during its own initializers. `test.rb` is loaded before those run, so the setting takes effect. Step 6 proves it by loading `/jobs` in a test.
- Test classes that do not include `ActiveJob::TestHelper` (plain `ActiveSupport::TestCase`) now enqueue into the one shared `TestAdapter` from config. Their jobs stay in memory until a `TestHelper` test clears the list. No test asserts on that list today.
- `perform_enqueued_jobs` performs every job enqueued inside its block. Today the importer creates no other jobs. If import processing later enqueues more work, it runs inline in these tests. That matches what the tests mean.
- `Gallery::ReprocessAttachmentJobTest` "job is discarded when model class name does not exist" now runs its job. `constantize` raises `NameError`, and `discard_on NameError` discards the job, so the test still passes, and now proves what its name says. This replaces the separate Gallery follow-up Etienne asked for: the global setting fixes that test as a side effect.
- Rejected: a per-class `queue_adapter_for_test` override in `ImporterImportFlowTest`. It touches one file, but every future test that uses `perform_enqueued_jobs` hits the same trap. Etienne chose the global setting.
- Rejected: `config.mission_control.jobs.adapters` in `config/application.rb`. It would describe the dashboard for every environment, but it edits shared app config for a test-only need.
- Rejected: `QueueStorageTest` overriding `queue_adapter_for_test` with a `SolidQueueAdapter`. Rails documents that hook for adapters with the `TestAdapter` interface, which `SolidQueueAdapter` does not have.

## Out of scope

- Amended after review round 1 (Etienne, 2026-10-08): `ApplicationSystemTestCase#swap_queue_adapter_for_system_tests` and `#restore_queue_adapter` became a swap from `:test` to `:test`, and their test in `test/application_system_test_case_test.rb` passed no matter what. Both are removed in this branch instead of a follow-up. The test becomes "system tests run jobs on the test adapter", which fails if `test.rb` stops selecting `:test`.
- The redundant `include ActiveJob::TestHelper` in `ImporterImportFlowTest`. Rails already includes it into `ActionDispatch::IntegrationTest`.
- Any change to production or development job processing.
- Amending `intent.md` for the reading of "No other test changes behaviour" given above.
- Rebasing `replace-devise` on top of this fix. That happens after merge, in that branch's own work.

## Proof

- The import flow tests run the import job and pass → `engines/importer/test/integration/importer_import_flow_test.rb`:
  - `test_resident_confirms_a_preview_and_imports_content`
  - `test_admin_confirms_a_stock_preview_and_imports_shared_content`
  - `test_admin_import_results_link_to_created_stock_records`
- `bin/pre_push_checks` passes for branches that touch importer tests → `DISABLE_SPRING=1 bundle exec rails test engines/importer/test/integration/importer_import_flow_test.rb` (the command `PrePushChecks.run!` issues for that file) exits 0; `bin/pre_push_checks` on this branch exits 0.
- No other test changes its outcome → `test/jobs/queue_storage_test.rb` (all four tests), `test/integration/jobs_dashboard_test.rb` (both tests), `test/jobs/gallery/reprocess_attachment_job_test.rb` and `test/application_system_test_case_test.rb` pass; the failure lists of `bin/rails test`, `bin/rails test engines/importer/test` and `bin/rails test:system` equal the step 2 baseline minus the three importer tests.
- Production and development stay on Solid Queue → `config/application.rb`, `config/environments/development.rb` and `config/environments/production.rb` have no diff; `QueueStorageTest` "work handed off for later waits in the queue" still sees a `SolidQueue::Job` row appear.

Per changed file, the unit tests expected:

- `config/environments/test.rb`: no new tests. Covered by the three importer tests (red → green) and `JobsDashboardTest` "admin can open the jobs dashboard" (stays green).
- `test/jobs/queue_storage_test.rb`: no new tests. Its four existing tests stay green on Solid Queue.

Test setup: existing fixtures (`users(:dan)`, `admins(:dan)`, `residents(:razune)`) and `engines/importer/test/fixtures/files/importer/sample_compendium.xml`. No new fixtures. No faked boundaries.

---
Domain skills applied: rails-testing.
