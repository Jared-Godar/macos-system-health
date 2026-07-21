# Spec: Make tests/smoke.sh assertions enforcing (Issue #64)

**Closes:** #64 · **Type:** `type:bug`, `area:script`, `effort:small`
**Milestone:** Remediation - Back to Step 0
**Why first:** foundational — #60 and #61 remediation ship enforcing negative tests, which are only
trustworthy once this harness gap is closed. Fix this before touching the behavioral gaps.

---

## Intended outcome

`tests/smoke.sh` enforces **every** assertion: a failed intermediate assertion fails its test and
the tally. The suite's green then certifies exactly the behaviors it checks — no decorative
assertions.

## Current state and gap

`run_test` dispatches each test as `if "$name"; then pass; else fail; fi`. Bash suppresses `set -e`
for a function invoked in an `if` condition (across the whole body), so `assert_contains` /
`assert_not_contains` (which fail via `return 1`) only exit the helper — the test continues and its
result is whatever its **last** statement returns. Every non-final assertion is decorative;
concretely, the report-mode no-mutation and **redaction-guarantee** checks in
`test_report_boundary_and_redaction` (first six of seven) and most of `test_maintenance_boundary`
do not gate. See the audit A1 receipt in `docs/audits/2026-07-21-closed-work-audit.md`.

## Scope and deliverables

- Refactor the harness so any failed assertion deterministically fails its test. Acceptable
  approaches (executor's judgment): have `assert_*` record a per-test failure (counter/flag) checked
  at test end; and/or restructure `run_test` so the test body runs **without** errexit suppression
  and a failed assertion propagates. Keep test authoring ergonomic (bare `assert_*` calls should
  just work).
- Add a **self-test** proving the fix: a test with an intentionally-failing **intermediate**
  assertion must now report `not ok` and increment the failure tally (and be excluded from the real
  suite, or asserted in a meta-check).
- Re-run the full suite and **resolve honestly** anything the new enforcement surfaces: if a
  previously-decorative assertion now fails, it is either a real defect (fix it or file a new gap
  issue) or a wrong assertion (correct it). **Do NOT weaken or delete an assertion merely to keep
  the tally green** — that would re-introduce the exact defect this issue fixes.

## Non-goals

- Not fixing #60 (dry-run) or #61 (timeout) here — those are separate issues that will *depend* on
  this enforcing harness.
- No wholesale rewrite of the suite; preserve every existing test's intent.

## Acceptance criteria

- [ ] A failing **intermediate** assertion fails its test and the tally (self-test receipt shown)
- [ ] The report-boundary and **redaction** assertions in `test_report_boundary_and_redaction` are
      confirmed to gate (e.g. temporarily break one → suite goes red → restore)
- [ ] Full suite green under the enforcing harness; any newly-surfaced failure resolved honestly
      (fixed/corrected, or filed) — with a note in the PR of what, if anything, surfaced
- [ ] `scripts/check --all` green
- [ ] CHANGELOG `### Fixed` entry under `[Unreleased]`

## Dependencies and sequencing

- **First in the remediation march.** #60 and #61 are gated behind this (their negative tests need
  an enforcing harness).

## References

- Audit #59, `docs/audits/2026-07-21-closed-work-audit.md` (finding A1)
- `tests/smoke.sh` (`run_test`, `assert_contains`, `assert_not_contains`, `pass`, `fail`)
- `AGENTS.md` (definition of done; CHANGELOG-on-every-PR)
