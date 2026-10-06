# Intent: Importer flow tests run the import job

Author: Etienne van Delden de la Haije. Status: accepted. Type: bugfix.

## Problem

Three tests in `engines/importer/test/integration/importer_import_flow_test.rb` fail on `main`: two find the import still `queued` instead of `succeeded`, and one cannot find the stock creature the import should have created. The tests wrap the request in `perform_enqueued_jobs`, but the import job never runs. The test environment inherits the `:solid_queue` adapter from `config/application.rb`, and since Rails 7.2 `ActiveJob::TestHelper` uses the configured adapter instead of swapping in its own.

Because of this, `bin/pre_push_checks` fails for any branch that touches an importer test, which blocks the push of `replace-devise`.

## Proposed outcome

The import flow tests run the import job and pass on `main`. `bin/pre_push_checks` passes again for branches that touch importer tests. No other test changes behaviour.

## Affected users and systems

- The test suite and `bin/pre_push_checks`; developers pushing branches.
- No production behaviour changes: production and development keep Solid Queue.

## Constraints

- Production and development job processing stays on Solid Queue.
- Fix the cause, not the tests' expectations (playbook rule 14).
- Lands as its own PR; `replace-devise` rebases on top of it (playbook rule 25).

## Open questions

None.
