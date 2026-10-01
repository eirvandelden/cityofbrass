# Intent: Dependabot alerts describe only gems the app runs

Author: Etienne van Delden de la Haije. Status: accepted. Type: chore.

## Problem

GitHub Dependabot reports 567 open alerts on cityofbrass (20 critical, 78 high, 268 medium, 201 low). Real risk cannot be told apart from noise:

- 562 alerts come from the eleven engines' own `Gemfile.lock` files (`engines/*/Gemfile.lock`), about 52 per engine. Ten of those lockfiles still pin Rails 6.1.7.10; the importer one pins Rails 8.1.3.1.
- The app never loads those lockfiles. The root `Gemfile` loads every engine as a path gem, so the root `Gemfile.lock` decides every gem version the app runs.
- `.github/dependabot.yml` still watches each engine directory, so the stale lockfiles keep producing alerts and would keep producing update pull requests.
- Only 5 alerts come from the root `Gemfile.lock`: jwt, bcrypt, msgpack and two for devise. Change `bundler-audit-advisories` handles those.

## Proposed outcome

Every open Dependabot alert refers to a gem version the app actually runs. The engine lockfiles no longer produce alerts. After this change and `bundler-audit-advisories`, only the two devise alerts remain open, and they close when devise is removed.

## Affected users and systems

- The maintainer, who triages Dependabot alerts and update pull requests.
- GitHub Dependabot configuration (`.github/dependabot.yml`).
- The eleven engines under `engines/` and their `Gemfile` / `Gemfile.lock`.

## Constraints

- Builds on main; its pull request targets main. The Rails 8.1.4 work (PR #148) is already merged.
- The gem versions the app runs must not change: the root `Gemfile.lock` stays as it is.
- Changing `.github/dependabot.yml` needs explicit approval, because it is under `.github/`.
- The engines must still load and pass their tests inside the app.

## Open questions

- Whether any engine is ever run or tested on its own, outside the app, which would need its own lockfile. None has a `test/dummy` app, and no CI job or script uses an engine's Gemfile.
