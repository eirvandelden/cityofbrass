# Review: importer-jobs-run-in-tests

## Round 1 — 2026-10-08T08:48Z — cc60576

Suite state on cc60576: `bin/rails test` 1151 runs, 0 failures; `bin/rails test engines/importer/test` 135 runs, 0 failures; `bin/rails test:system` 3 runs, 0 failures; rubocop clean on both changed files. The leak-check set (QueueStorageTest, ReprocessAttachmentJobTest, JobsDashboardTest, ApplicationSystemTestCaseTest, importer flow) passes for seeds 1, 2 and 3.

Compliance:

- "The import flow tests run the import job and pass" → `engines/importer/test/integration/importer_import_flow_test.rb` ("resident confirms a preview and imports content", "admin confirms a stock preview and imports shared content", "admin import results link to created stock records"). Present and green.
- "`bin/pre_push_checks` passes again for branches that touch importer tests" → no test; proven by a command run (`bin/pre_push_checks` exits 0, reported by the caller). Acceptable for a tooling criterion.
- "No other test changes behaviour" → missing as written. See the first Important finding.
- Proof tests named in `plan.md`: all exist (importer flow tests, QueueStorageTest x4, JobsDashboardTest x2, ReprocessAttachmentJobTest, ApplicationSystemTestCaseTest). No test deleted or skipped in the diff.

Bugs and security: the QueueStorageTest swap saves and restores the adapter object, and teardown runs on failure, so it restores state correctly. The suite runs single-process, so the global swap cannot race. Mission Control resolves the same `[ :solid_queue ]` list it derived before, so the dashboard behaves the same. No test in the repo uses `assert_emails`, `capture_emails` or `assert_enqueued_*`, and none asserts on `SolidQueue::Job` outside QueueStorageTest, so moving `deliver_later` (Devise, `UserMailer`, `SubscriptionMailer`) and Active Storage jobs into the in-memory adapter changes no test outcome. Nothing security-relevant changes: production and development config have no diff.

- [ ] Important: The intent's acceptance criterion "No other test changes behaviour" is not met as written. `Gallery::ReprocessAttachmentJobTest` now executes its job, `deliver_later` mail in every test now goes to an in-memory adapter instead of Solid Queue rows, and `ApplicationSystemTestCaseTest` loses its meaning (next finding). `plan.md` reinterprets the criterion as "every passing test still passes" and puts amending `intent.md` out of scope. The intent author must accept that reading, or `intent.md` must change, before this merges; the reviewer cannot close it. — `docs/changes/importer-jobs-run-in-tests/intent.md:13` →
- [ ] Important: Existing test weakened by side effect. "restores the configured queue adapter after each system test" now swaps `:test` to `:test` and compares `TestAdapter` with `TestAdapter`, so both assertions pass even if `restore_queue_adapter` is broken. It also leaves `ActiveJob::Base` holding a fresh `TestAdapter` instead of the configured instance, because `restore_queue_adapter` restores by name. The plan defers removal of the swap and this test to a follow-up; until then the test is vacuous. — `test/application_system_test_case_test.rb:23` →
- [ ] Nit: QueueStorageTest swaps only `ActiveJob::Base`. A job class that later sets its own `queue_adapter` (or gets one via a `queue_adapter_for_test` override elsewhere) would bypass the swap and silently stop writing Solid Queue rows in these tests. No job does this today. — `test/jobs/queue_storage_test.rb:4` →
- [ ] Nit: Plain `ActiveSupport::TestCase` tests that enqueue (for example `User` trial-warning mail via `deliver_later`) now accumulate jobs in the shared configured `TestAdapter` until the next `ActiveJob::TestHelper` test clears it. No assertion reads that list today, but a future `assert_enqueued_jobs` without a block in a plain test would see leftovers. — `config/environments/test.rb:45` →

## Round 2 — 2026-10-08T12:30Z — 486ed58

Suite state on 486ed58: `bin/rails test` 1151 runs, 0 failures; the set ApplicationSystemTestCaseTest, QueueStorageTest, JobsDashboardTest and the importer flow tests passes with seed 7; rubocop clean on the four changed code files. The caller reports importer engine 135/0, `test:system` 3/0, and the new adapter test failing without the `test.rb` line.

Round 1 Important findings:

- Intent criterion "No other test changes behaviour": resolved. Commit 6976f2b rewrites it as "Every test that passes today still passes", and names the tests that now run differently. The suite result matches that criterion.
- Vacuous "restores the configured queue adapter" test: resolved. Commit 486ed58 removes the swap/restore methods and the test. Its replacement fails when `test.rb` stops selecting `:test`, so it now guards something real.

Removed system-test setup/teardown: nothing is lost. The swap was `:test` to `:test`. The teardown's `clear_enqueued_jobs` and `clear_performed_jobs` move to the next test's start: `ActiveJob::TestHelper#before_setup` (activejob 8.1.4) clears both before every test that includes it, and `ApplicationSystemTestCase` still includes it. The only gap is a plain `ActiveSupport::TestCase` that runs right after a system test in the same process: it now sees that test's leftover jobs. That is the same gap as round 1's second nit, and no test reads the list. Removing the by-name restore also fixes round 1's side issue, where `ActiveJob::Base` got a fresh `TestAdapter` instead of the configured one.

Compliance:

- "The import flow tests run the import job and pass" → `engines/importer/test/integration/importer_import_flow_test.rb` (three named tests). Present and green.
- "`bin/pre_push_checks` passes again for branches that touch importer tests" → command run, not a test (unchanged from round 1).
- "Every test that passes today still passes" → full-suite run, 1151/0, and the Proof list in `plan.md`. Met.
- "Tests that exercise Solid Queue itself select it explicitly" → `test/jobs/queue_storage_test.rb` setup/teardown; "work handed off for later waits in the queue" sees a `SolidQueue::Job` row. Met.
- Proof tests named in `plan.md`: all exist. The one deleted test (the vacuous adapter-restore test) was removed together with the code it covered, by Etienne's decision, and has a stronger replacement. Not a weakening.

Bugs and security: none found. The diff since round 1 removes test helpers and changes one assertion. No production or development config changes.

- [ ] Nit: `plan.md` still describes the pre-round-1 scope. "Files that change" lists two files and says "Nothing else", but the branch also changes `test/application_system_test_case.rb` and `test/application_system_test_case_test.rb`. Design decisions still say "`intent.md` is not edited by this change" and quote the old criterion. "Out of scope" lists "Amending `intent.md`", and the round 1 amendment sits under "Out of scope" although it is now in scope. — `docs/changes/importer-jobs-run-in-tests/plan.md:48` →
- [ ] Nit: `plan.md` design decision "No new test … A test that asserts an adapter class would be a meta-test of plumbing" contradicts the new test, which asserts the configured adapter. Record why that test is now accepted, or reword the decision. — `docs/changes/importer-jobs-run-in-tests/plan.md:31` →
- [ ] Nit: The new test is named "system tests run jobs on the test adapter" but reads `Rails.application.config.active_job.queue_adapter`, not the adapter a system test sees at run time. It proves the `test.rb` line, not the system-test behaviour. A name that says what it checks ("test environment selects the test job adapter") would be accurate. — `test/application_system_test_case_test.rb:23` →

## Round 3 — 2026-10-08T12:45Z — 6213098

Suite state on 6213098: ApplicationSystemTestCaseTest, QueueStorageTest, JobsDashboardTest and the importer flow tests run together: 19 runs, 0 failures. Rubocop is clean on the four changed code files. The caller reports the renamed config test green for 5 runs.

Round 2 nits:

- Stale "Files that change" and out-of-scope intent note: resolved. `plan.md` lists all four changed files, records the round 1 intent amendment, and no longer lists "Amending `intent.md`" as out of scope.
- "No new test" decision contradicting the config test: resolved. The decision now says one config test replaces the vacuous adapter-restore test, and why.
- Misleading test name: resolved. The test is "test environment selects the test queue adapter" and checks exactly that.

Plan against diff: "Files that change" matches the diff (four code files plus the change folder). Production and development config have no diff. Every Proof test exists and passes.

Bugs and security: none. The commit since round 2 changes plan prose and one test name.

- [ ] Nit: The "Per changed file, the unit tests expected" list still names only `test.rb` and `queue_storage_test.rb`, and says `test.rb` gets "no new tests". The new config test in `test/application_system_test_case_test.rb` now covers `test.rb`, and the two system-test files are not listed there. — `docs/changes/importer-jobs-run-in-tests/plan.md:93` →

## Dismissals — 2026-10-08 — Etienne

- Round 1 nit, `test/jobs/queue_storage_test.rb:4` (swap covers only `ActiveJob::Base`): dismissed. No job class sets its own adapter today.
- Round 1 nit, `config/environments/test.rb:45` (plain tests accumulate jobs in the shared `TestAdapter`): dismissed. No test reads that list outside `ActiveJob::TestHelper`, which clears it before each test.
- Round 3 nit, `plan.md:93` (stale per-file unit test list): dismissed. `finish` removes the change folder; the PR body carries the file list.
