# Review: replace-yarn-with-npm

## Round 1 — 2026-10-19T11:42Z — ce76f3a (codex)

No findings.

## Round 2 — 2026-10-19T11:45Z — ce76f3a (claude)

- [ ] Nit: DATA_PATHS excludes `docs/changes/`, which plan.md does not list (only `db/seeds/`); it is needed only while the change folder exists and silently hides yarn mentions in any future change doc — `test/lib/javascript_package_manager_test.rb:4` → dismissed: the change folder names yarn until deliver removes it, and the other migrated repos exclude docs/changes the same way
