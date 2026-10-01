# Intent: Security checks block pushes and pull requests

Author: Etienne van Delden de la Haije. Status: accepted. Type: chore.

## Problem

Nothing stops a gem version with a known advisory, or code with a known security weakness, from reaching main. That is how the jwt, bcrypt, msgpack and devise advisories went unnoticed until the Rails 8.1.4 work (PR #148).

- CI (`.github/workflows/ci.yml`) runs RuboCop, the tests, the system tests and the i18n check. It runs neither bundler-audit nor Brakeman.
- `bin/pre_push_checks` (`lib/pre_push_checks.rb`) runs RuboCop and the changed test files only.
- Both tools are already in the Gemfile (brakeman 8.0.5, bundler-audit 0.9.3). `.bundler-audit.yml` only has a placeholder ignore entry, and there is no `config/brakeman.ignore`.
- Brakeman reports 9 warnings on main today:
  - Dynamic Render Path (high), `app/controllers/errors_controller.rb:5`.
  - Format Validation (high), six entitybuilder models: `saving_throw.rb`, `movement.rb`, `base_value.rb`, `attack.rb`, `ability_score.rb`, `skill.rb`.
  - Command Injection (medium), `lib/pre_push_checks.rb:10`.
  - Remote Code Execution (medium), `app/controllers/attachment_files_controller.rb:21`.

## Proposed outcome

A pull request and a push fail when bundler-audit finds an advisory or Brakeman finds a warning. The checks start clean: each of today's 9 Brakeman warnings is fixed, or confirmed as not a real risk and recorded as a reviewed exception with the reason. The two devise advisories are the only bundler-audit exceptions. Each carries a note that removing devise closes it.

## Affected users and systems

- The maintainer and any contributor who pushes or opens a pull request.
- CI (`.github/workflows/ci.yml`) and `bin/pre_push_checks`.
- The code behind the 9 Brakeman warnings: the errors controller, the attachment files controller, six entitybuilder models and `lib/pre_push_checks.rb`.

## Constraints

- Builds on main; its pull request targets main. The Rails 8.1.4 work (PR #148) is already merged.
- Changing `.github/workflows/` needs explicit approval.
- Can only pass once change `bundler-audit-advisories` has fixed jwt, bcrypt and msgpack, so that change merges first.
- The devise advisories are ignored only until devise is removed; the ignore entries must name that as the reason.
- Fixing a Brakeman warning must not change what users see or can do, unless the warning is a real vulnerability.

## Open questions

- Whether each of the 9 Brakeman warnings is a real vulnerability or a false positive. Spec triages them one by one.
- Whether the 9 Brakeman fixes are big enough to be a separate change that lands before the checks are switched on.
