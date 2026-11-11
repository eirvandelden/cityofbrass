# Intent: Fix security audit findings

Author: Etienne van Delden. Status: accepted (2026-11-10). Type: bugfix. Delivery: autonomous. Codex review: no.

## Problem

Brakeman 8.1.0 reports 8 warnings and `npm audit` reports 1 critical advisory. Bundler Audit reports none.

- `ErrorsController#show` renders a view and sets the HTTP status from `params[:code]`. A visitor controls both.
- The dice validation regex `VALID_DICE_MECHANIC` anchors only its first alternative. A value such as `"foo Standard bar"` passes validation on six models.
- `AttachmentFilesController` calls `constantize` on a class name it looks up by a path segment. The lookup uses a frozen allowlist, so the warning is a false positive, but the code still triggers the check.
- `dompurify` (`<=3.4.16`, pulled in by `trix`) has three bypass advisories. Trix sanitizes rich text that users write.

## Proposed outcome

- `/errors/<anything but a known code>` answers 404 and renders the 404 page.
- A dice or dice-mechanic field accepts only a dice expression, `Standard`, `Fate` or `Roll Under`, and nothing around them.
- `AttachmentFilesController` serves the same attachments as today without `constantize`.
- `npm audit` and `brakeman` both report no warnings. Bundler Audit stays clean.

## Affected users and systems

- Visitors who hit an error page.
- Users who edit dice fields on entitybuilder models.
- Users who load gallery images through `/attachments`.
- Users of the Trix rich-text editor.
- `package.json`, `package-lock.json`, `app/controllers/errors_controller.rb`, `app/controllers/attachment_files_controller.rb`, `app/models/concerns/dice.rb`.

## Constraints

- No linter disable comment, no skipped test and no `config/brakeman.ignore` entry. Fix the production code.
- Each bug fix has a regression test that fails before the fix.
- Approved permission: update `trix` to 2.1.19 and re-lock `dompurify` in `package-lock.json`. No package is added or removed.
- Existing dice values in the database are not migrated. Only new and changed values face the stricter rule.

## In scope

- The `ErrorsController` render and status handling.
- The `VALID_DICE_MECHANIC` regex, with anchors around every alternative.
- The `AttachmentFilesController` lookup, rewritten without `constantize`.
- The `trix` patch update and the `dompurify` re-lock.
- Tests for each of the above, including the commented-out `ErrorsController` tests.

## Out of scope

- The `@rails/actiontext` 6.1 → 8.1 alignment. It becomes its own change.
- The Ruby 4.0.9 upgrade. It follows as a stacked change.
- Migrating or cleaning existing dice data.
- Other Brakeman or audit findings that appear later.

## Acceptance criteria

- Requesting the error page for code `403` answers 403 and shows the 403 page.
- Requesting the error page for code `404` answers 404 and shows the 404 page.
- Requesting the error page for code `../secret` or `500` answers 404 and shows the 404 page.
- A skill with dice `1d20+2d6` is valid.
- A skill with dice `Fate`, `Standard` or `Roll Under` is valid.
- A skill with dice `foo Standard bar` is invalid.
- A skill with no dice value is still valid.
- A resident image, stock image, map image and FAQ image load at the same paths as today with the same access rules.
- A gallery path with an unknown collection name answers 404.
- `npm audit` reports 0 vulnerabilities.
- `bundle exec brakeman` reports 0 warnings.
- `bundle exec bundler-audit check` reports no vulnerabilities.

## Decisions

- Remove the `constantize` call by refactoring, not with a Brakeman ignore — the playbook forbids silencing checks.
- Deliver autonomously, with Claude review only — personal repo and a small change.
- Update `trix` to 2.1.19 and re-lock `dompurify` — approved now, so delivery does not stop to ask.
- Keep `@rails/actiontext` alignment out of this change — no reason given; it is a major bump and changes editor behaviour.

## Open questions

None.
