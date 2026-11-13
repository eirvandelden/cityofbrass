# Delivery account: fix security audit findings

## Behaviour delivered

- The dice-mechanic validation anchors every alternative, so `foo Standard bar` is refused. Six entitybuilder models validate the format only when the field changes, so stored legacy values still save.
- `Gallery::Image.find_in_collection` finds a gallery image without `constantize`. An unknown collection segment runs no query and answers 404.
- The unreachable `ErrorsController` and its commented-out test are deleted. The error views stay in use.
- `trix` moves to 2.1.19 and `dompurify` to 3.4.17 in `package-lock.json`, which closes the critical advisory.

## Evidence

- Brakeman went from 8 warnings to 0, Bundler Audit reports no vulnerabilities, and `npm audit` went from 1 critical to 0. I re-ran all three myself.
- Rubocop reports no offenses on the 15 touched Ruby files.
- The reviewer ran the narrow set for the new and changed code: 72 runs, 423 assertions, 0 failures, 0 errors.
- The implement worker reported a full local suite of 1296 runs with 0 failures and a clean `bin/pre_push_checks`.
- Red-before-green was seen for the regex, legacy-save and `find_in_collection` tests.

## Open points

- My own full local run reported 1296 runs with 157 errors. The reviewer was running tests against the same SQLite database at the time, which is the likely cause, but I did not read the messages. I stopped the re-run at Etienne's request, so CI is the deciding full-suite run.
- Nobody ran the browser hand check. Etienne still needs to open a gallery picture of each type and type in a Trix editor in `bin/dev`.
- The plan's `#:` signature on `find_in_collection` is a plain doc comment instead, because `Layout/LeadingCommentSpace` flags `#:` and the repository has no Steep or RBS setup.

## Review outcome

- Round 1 had one Important finding, fixed in `4cb28a8`. Round 2 found nothing. No finding is open.
