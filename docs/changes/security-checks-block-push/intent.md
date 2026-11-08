# Intent: Security checks block pushes and pull requests

Author: Etienne van Delden de la Haije. Status: accepted. Type: chore.

## Problem

Nothing stops a gem version with a known advisory, or code with a known security weakness, from reaching main. That is how the jwt, bcrypt, msgpack and devise advisories went unnoticed until the Rails 8.1.4 work (PR #148). PR #163 and PR #159 have since closed them; nothing keeps new ones out.

- CI (`.github/workflows/ci.yml`) runs RuboCop, the tests, the system tests and the i18n check. It runs neither bundler-audit nor Brakeman.
- `bin/pre_push_checks` (`lib/pre_push_checks.rb`) runs RuboCop and the changed test files only.
- Both tools are already in the Gemfile (brakeman 8.1.0, bundler-audit 0.9.3). `.bundler-audit.yml` only has a placeholder ignore entry, and there is no `config/brakeman.ignore`.
- `bundle-audit check` reports no vulnerabilities on main today (2026-11-08).
- Brakeman reports 8 warnings on main today:
  - Dynamic Render Path, `app/controllers/errors_controller.rb:5`.
  - Remote Code Execution, `app/controllers/attachment_files_controller.rb:21`.
  - Format Validation, six entitybuilder models: `ability_score.rb`, `attack.rb`, `base_value.rb`, `movement.rb`, `saving_throw.rb`, `skill.rb`.

## Proposed outcome

A pull request and a push fail when bundler-audit finds an advisory or Brakeman finds a warning. The checks start clean: each of today's 8 Brakeman warnings is fixed, or confirmed as not a real risk and recorded as a reviewed exception with the reason. bundler-audit starts with no exceptions; the placeholder ignore entry goes.

## Affected users and systems

- The maintainer and any contributor who pushes or opens a pull request.
- CI (`.github/workflows/ci.yml`) and `bin/pre_push_checks`.
- The code behind the 8 Brakeman warnings: the errors controller, the attachment files controller and six entitybuilder models.

## Constraints

- Builds on main; its pull request targets main.
- Changing `.github/workflows/` needs explicit approval.
- Fixing a Brakeman warning must not change what users see or can do, unless the warning is a real vulnerability.

## Open questions

- Whether each of the 8 Brakeman warnings is a real vulnerability or a false positive. The plan triages them one by one.
- Whether the Brakeman fixes are big enough to be a separate change that lands before the checks are switched on.
