# Review: rack-protection-advisories

## Round 1 — 2026-11-27T07:25:09Z — d8f708b

No `REVIEW.md` or `REVIEW.local.md` at the repository root: default passes (Bugs, Security, Compliance, Design).

Checks run on Ruby 4.0.10 (`rv run`): `bin/rails test` 1480 runs, 0 failures, 0 errors, 0 skips; `bundle exec rubocop` no offenses; `brakeman` no warnings; `bin/bundle-audit check --update` no vulnerabilities (advisory DB 2026-11-22).

Bugs: none. `ruby:4.0.10-slim` exists on Docker Hub, so the `Dockerfile` build base resolves. CI uses `setup-rv` with `ruby-version: current`, which reads `.ruby-version`. No `4.0.9` pin remains outside `docs/`.

Security: none. rack-protection 4.2.2 clears GHSA-pf75-2v58-7mxg, GHSA-r29j-38x9-qr26 and GHSA-vvhm-j6m8-64cw.

Compliance:
- `bin/bundle-audit check` reports no vulnerabilities → verified, exit 0.
- `git diff Gemfile.lock` changes only the rack-protection line → holds for commit c85a79b alone; on the branch the `RUBY VERSION` line also moves, as the in-scope Ruby bump requires.
- No `4.0.9` pin remains → `git grep` prints nothing.
- The app runs on 4.0.10 → verified with `rv run bundle exec ruby -v`; the plan's command fails (see below).
- Nothing regressed → full suite green.
- No test was weakened, skipped or deleted.

Design: no Ruby code changed; no signatures, Demeter, N+1 or glossary concerns apply.

- [ ] Nit: The Proof command `rv ruby run 4.0.10 -- -S bundle exec ruby -v` fails on rv 0.7.2 with `unrecognized subcommand 'run'`; the working form is `rv run bundle exec ruby -v` (or `rv run --ruby 4.0.10 bundle exec ruby -v`) — `docs/changes/rack-protection-advisories/plan.md:65` → fixed (Correct the rv command in the Ruby version check)
- [ ] Nit: Untracked `bin/ci` sits in the worktree, outside the plan's scope, and requires `config/ci.rb`, which does not exist, so it fails on run; keep it out of this branch and remove it or move it to its own change — `bin/ci:6` → dismissed: bin/ci was an untracked file outside the change, deleted at Etienne's request; it is not in any commit

## Round 2 — 2026-11-27T07:54:14Z — 019422e

No `REVIEW.md` or `REVIEW.local.md` at the repository root: default passes (Bugs, Security, Compliance, Design).

Since round 1 only `plan.md` changed (019422e). Round 1's test, rubocop and brakeman results still apply to the code.

Checks re-run: `rv run bundle exec ruby -v` prints 4.0.10; `bin/bundle-audit check --update` no vulnerabilities (advisory DB 2026-11-22); `git grep -E "4\.0\.9" -- . ':!docs'` prints nothing.

Bugs: none.

Security: none.

Compliance: the corrected Proof command at `plan.md:65` runs and prints 4.0.10. Both round 1 nits are closed.

Design: none. No Ruby code changed.

No findings.
