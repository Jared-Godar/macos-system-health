# Backward-facing audit of closed v1.0 work

**Date:** 2026-07-21 · **Tracking issue:** #59 · **Method:** `prompts/audit-closed-work.md`
**Auditor session:** executor, Opus 4.8 / high effort (Heavy tier — reconstruction + judgment).

## Why this document exists

Multiple v1.0 issues were closed while their bodies were one-line stubs, specced and accepted
under an underpowered PM model. "Done" was taken on trust, without spec-grade definitions-of-done
or independent verification, so actual coverage was unknown. This audit reconstructs the
definition-of-done each in-scope closed issue *should* have demanded, verifies the delivered work
against it **with a command + pasted output as the receipt**, and assigns a verdict of
**Satisfied / Partial / Unverifiable**. Every confirmed **Partial** becomes a new, forward-facing
issue linked back to the original.

**Integrity constraint honored:** no closed issue body was edited. Closed issues and their PRs are
read-only evidence; gaps are recorded here and in new issues, never by retouching history.

All receipts below were produced this session against the audited tree (branch
`audit/closed-work-59`, forked from `main` at `595eb7f`). Baseline: `tests/smoke.sh` reports
**41 passed; 0 failed** — but see finding **A1**: that green overstates enforcement, so the
behavioral verdicts below rest on **independent** experiments and code reading, not on the suite
passing.

## Verdict summary

| Issue | Closing PR | Reconstructed definition-of-done (core) | Verdict | Follow-up |
|---|---|---|---|---|
| **#7** log retention + maintenance dry-run | #33 | Age/count log retention **and** a dry-run that previews *and does not execute* maintenance mutations (`brew update/upgrade/cleanup`, `conda clean`), per ISSUES.md Phase 2 | **Partial** | **#60** |
| **#24** Brewfile/Conda backup retention | #33 | Prune backups by age/count; preserve current + unrelated files; report mode deletes nothing | **Satisfied** | — |
| **#11** per-tool opt-in + timeouts | #49 | Per-tool enable/disable **and** a bounded, correctly-reported command timeout with a distinct timed-out state | **Partial** | **#61** |
| **#10** stable JSON output | #50 | Versioned JSON: validity, `schema_version`, required fields, ISO-8601 timestamp, redaction, text unchanged | **Satisfied** | — |
| **#20** scheduled full-history secret scan | #21 | Weekly + on-demand scan, full history (`fetch-depth: 0`), invoking real gitleaks, least-privilege | **Satisfied** | — |
| **#29** permissions allowlist | #30 | `.claude/settings.json` conforming to the canonical categorical pattern | **Partial** | **#31** (existing — not refiled) |
| **#6** v1.0 acceptance criteria | #27 | Doc enumerating supported versions, compatibility boundaries, acceptance checklist | **Satisfied** | — |
| **#9** report/maintenance ADR | #39 | ADR enumerating permitted mutations and intentionally-manual exclusions | **Satisfied** | — |
| **#18** CONTRIBUTING + redaction guarantee | #19 | CONTRIBUTING.md documenting real workflow; redaction guarantee named in test + README | **Satisfied** | — |
| **#23** branch protection | #28 | Require PR + real `quality`/`checks` status check + branches up-to-date + no force-push | **Partial** | **#62** |

**Tier 3 (existence spot-check only):** #22, #34, #35, #36, #37, #40, #42, #44, #45 — all deliverables **present** (table at end). Recent closed governance issues #55 (PR #56) and #57 (PR #58) also present.

**Cross-cutting finding surfaced by the audit (not tied to one closed issue):**

| Finding | Verdict | Follow-up |
|---|---|---|
| **A1** — `tests/smoke.sh` intermediate assertions are non-enforcing: only each test's **last** statement gates pass/fail (errexit is suppressed under `if "$name"`), so many boundary/redaction assertions are decorative | **Defect confirmed** | **#64** |

---

## Hypotheses — explicitly confirmed or refuted (with receipts)

The PM scoping named specific hypotheses to test. Each is resolved below; refuting is a valid
outcome.

### H1 (#7): dry-run gates only cleanup deletions, not maintenance package mutations — **CONFIRMED (real gap)**

ISSUES.md Phase 2 → "Maintenance dry-run" required the interface `bin/system-health maintenance
--dry-run`, to "Print planned mutations", and to "Never execute `brew update`, `brew upgrade`,
`brew cleanup`, or `conda clean`". In the delivered code, dry-run (`SYSTEM_HEALTH_DRY_RUN`) is
wired only into `lib/cleanup.sh` (log/backup file deletions). `bin/system-health` runs the package
mutations unconditionally in maintenance mode (lines 440–444, 491) with no `DRY_RUN` guard, and
there is no `--dry-run` CLI flag (the arg parser accepts only `--format`).

Receipt — `maintenance` run with `SYSTEM_HEALTH_DRY_RUN=true`, brew/conda stubs logging every call:

```
### Did the dry-run print the planned-deletions banner? (cleanup path)
  matches: 1
### MUTATING package commands actually invoked during DRY-RUN maintenance:
brew update
brew upgrade
brew cleanup
conda clean --all --yes
```

The cleanup banner prints, yet all four package mutations still execute. No negative test asserts
their suppression. → filed as **#60**.

### H2a (#11): timeout enforcement lacks a regression test that forces a real timeout — **CONFIRMED (real gap)**, and enforcement is additionally buggy

There is no test in `tests/smoke.sh` that forces a timeout (no slow stub; the only `timed_out`
reference is a field-*presence* check, not a timed-out *assertion*):

```
=== any test that FORCES a timeout (slow stub / sleep / timed_out assertion)? ===
495:  for field in 'status' 'skipped' 'timed_out' 'duration_ms'; do   # presence only
```

Forcing a real timeout exposed two further defects. Receipt — config `command_timeout_seconds: 30`,
`brew doctor` stubbed to `sleep 5`:

```
### Wall-clock elapsed: 4s  (config said 30s timeout)
Command timed out after 30s.
### JSON homebrew object:
  {"status": "warning", "skipped": false, "timed_out": false, "duration_ms": 3942}
```

- The 5 s command was killed at ~4 s under a **30 s** configured timeout → the effective timeout is
  ~1/10th of configured (`capture_output_timed` loops `timeout_secs` × `sleep 0.1`).
- The killed command reports `"status":"warning"`, `"timed_out": false` — the distinct "Timed out"
  state the CHANGELOG advertises is unreachable (`record_check` only sets it on a `timeout` status
  that no check section ever passes). The JSON field's mere presence is **not** proof of
  enforcement. → filed as **#61**.

### H2b (#11): the timeout mechanism may depend on the absent macOS `timeout` binary — **REFUTED**

The live runtime path is `capture_output_timed`, which is pure Bash (kill/poll loop) and needs no
`timeout` binary. The only code using the external `timeout` binary is `execute_with_timeout`,
which is **defined but never called**:

```
=== is execute_with_timeout (the 'timeout' binary path) ever CALLED? ===
bin/system-health:256:execute_with_timeout() {          # definition only
--- calls to the 'timeout' binary anywhere in runtime code: ---
263:  if timeout "$timeout" "$@" > "$tmpfile" 2>&1; then # inside the never-called function
```

Portability is fine. The dead function is noted as cleanup within **#61** (it falsely implies a
non-portable dependency), not a portability gap in the shipping path.

### H3 (#10): JSON tests cover validity, schema_version, fields, timestamp, AND redaction — **CONFIRMED covered (Satisfied)**

`tests/smoke.sh` includes: `test_json_validity` (Python `json.tool`), `test_json_schema_version`
(`"schema_version":"1.0"`), `test_json_required_fields` (schema_version, timestamp, mode,
exit_status, checks, warnings, issues), `test_json_timestamp_format` (ISO-8601 regex),
`test_json_checks_structure`, `test_json_no_private_paths` (redaction: `$HOME|miniforge|anaconda|/private`),
`test_json_format_requires_report_mode`, `test_json_invalid_format_error`. All 8 pass in the 41/0
baseline. (Minor observation, not a gap: the JSON redaction test passes somewhat trivially because
few paths flow into JSON — but the assertion is present and correct.)

### H4 (#24): backups pruned by age/count; current + unrelated preserved; report mode deletes nothing — **CONFIRMED (Satisfied)**

`test_cleanup_backup_patterns` (count-based pruning of `Brewfile-*`/`conda-base-*.yml`, oldest
first, `other-backup.tar` preserved), `test_cleanup_report_mode_no_delete` (report mode deletes
nothing), plus age/count/boundary/dry-run log cases — all in the 41/0 baseline. Cleanup runs only
in maintenance mode after the current backup is written (newest), so the current snapshot survives
count pruning.

### H5 (#20): genuinely scheduled, full-history, real gitleaks — **CONFIRMED (Satisfied)**

`.github/workflows/full-history-scan.yml`: `schedule: cron "0 6 * * 1"` (weekly) +
`workflow_dispatch`; `fetch-depth: 0` (echoed via `git rev-list --all --count`); runs
`scripts/check --all`, whose scan step is `gitleaks git --redact --verbose` over full history;
`permissions: contents: read`; bounded retry on the brew install.

### H6 (#29): permissions non-conformance — **CONFIRMED, already tracked by #31 (not refiled)**

`.claude/settings.json` uses per-command enumerations (`Bash(git *)`, `Bash(gh *)`, …) rather than
the canonical categorical `Bash` rule + `defaultMode: auto` + path globs. #31 is **OPEN** and
tracks exactly this. Per the spec, referenced — not refiled.

### A1 (cross-cutting): smoke-test assertions are non-enforcing — **CONFIRMED (defect)** → #64

`run_test` dispatches each test as `if "$name"; then pass; else fail; fi`. Bash suppresses
`set -e` for a function called in an `if` condition, and that suppression covers the whole body, so
`assert_contains`/`assert_not_contains` (which fail via `return 1`) only exit the *helper* — the
test continues and its result is whatever its **last** statement returns. Every assertion that is
not the final statement is decorative. Minimal receipt (same pattern as the suite):

```
demo_intermediate_assert_fails() {
  assert_contains "$f" 'THIS_STRING_IS_ABSENT'   # FAILS (prints Expected …), not the last stmt
  [[ -f "$f" ]]                                    # last stmt, true -> test "passes"
}
```
```
Expected /tmp/tmp.iPBMBWGoh0 to contain: THIS_STRING_IS_ABSENT
ok - demo_intermediate_assert_fails
1 passed; 0 failed          (exit 0)
```

This fires in the real suite: `test_cleanup_dry_run_no_delete`'s `assert_contains … '[DRY-RUN]'`
prints its `Expected … [DRY-RUN]` line during `scripts/check --all` yet the test reports `ok` and
the tally stays 41/0 (only its trailing file-existence check gates). Consequently the first six of
`test_report_boundary_and_redaction`'s seven assertions — the report-mode no-mutation checks **and
the redaction-guarantee checks** — are non-enforcing, as is all but the last assertion of
`test_maintenance_boundary`. The audited behaviors are correct (verified independently above), but
the tests meant to guard them only partially enforce. This is exactly the "trust-based done"
failure #59 exists to surface: a green suite that certifies less than it appears to. → filed as
**#64**.

---

## Tier-1 detail (behavioral / safety)

### #7 — log retention + maintenance dry-run → **Partial** (follow-up #60)

- **Delivered & Satisfied:** age/count **log** retention (`SYSTEM_HEALTH_LOG_RETENTION_DAYS/COUNT`)
  with `cleanup_logs`; tested by `test_cleanup_maintenance_mode_deletes`, `test_cleanup_count_limit`,
  `test_cleanup_boundary_no_delete_at_limit`, `test_cleanup_preserves_non_matching_logs`,
  `test_cleanup_dry_run_no_delete`, `test_cleanup_report_mode_no_delete`.
- **Gap:** the dry-run half fails its ISSUES.md Phase 2 DoD — no `--dry-run` flag; maintenance
  package mutations are neither printed as planned nor suppressed (H1 receipt). Even #7's own issue
  text ("dry-run mode for maintenance actions so users can preview mutations before execution")
  and the ADR's enumerated mutations point to the broader behavior. The CHANGELOG narrowed it to
  "previews planned deletions."

### #24 — backup retention → **Satisfied**

Age/count pruning of `Brewfile-*`/`conda-base-*.yml` in `cleanup_backups`; unrelated + current
files preserved; report mode deletes nothing (H4).

### #11 — per-tool opt-in + timeouts → **Partial** (follow-up #61)

- **Delivered & Satisfied:** per-tool enable/disable via `~/.config/system-health/config.yaml`
  (`test_config_disabled_tool_not_executed`, `test_config_invalid_yaml_fails_early`,
  `test_config_default_behavior_all_enabled`).
- **Gaps (H2a):** effective timeout ~1/10th of configured; timed-out state never reported;
  misleading "after Ns" message; dead `execute_with_timeout`; no timeout-forcing regression test.

### #10 — stable JSON output → **Satisfied**

Full JSON test coverage (H3); text output remains default and unchanged.

### #29 — permissions allowlist → **Partial**, tracked by existing **#31** (not refiled) (H6).

### #20 — scheduled full-history secret scan → **Satisfied** (H5).

---

## Tier-2 detail (contracts that gate behavior)

### #6 — v1.0 acceptance criteria → **Satisfied**

`docs/v1.0-acceptance.md` enumerates: Acceptance Checklist, Platform Support Matrix, Known
Limitations (Current / Known Issues), Success Metrics, Deferral Rationale.

### #9 — report/maintenance ADR → **Satisfied**

`docs/ADRs/0001-report-and-maintenance-boundaries.md` enumerates permitted maintenance mutations
(`brew update/upgrade/cleanup`; `conda clean --all`) and "Intentionally NOT Automatic" exclusions
(conda/pip upgrades, system updates) with rationale. (This ADR is also the corroborating source for
the #7 dry-run gap: it names exactly the mutations dry-run should preview.)

### #18 — CONTRIBUTING + redaction guarantee → **Satisfied**

`CONTRIBUTING.md` documents the real workflow and names "the **redaction guarantee**"; `README.md`
names redaction and points to `test_report_boundary_and_redaction`; the test case name carries
"redaction". Receipt: `README.md:128` — "Private paths are redacted from all report output … The
redaction case in `tests/smoke.sh` (`test_report_boundary_and_redaction`) asserts they never
appear."

### #23 — branch protection → **Partial** (follow-up #62)

- **Correct:** PR required; the required status-check context `checks` is the real
  `.github/workflows/lint.yml` job key (`scripts/check --all`) — not a phantom; force-pushes
  disallowed; 0 required reviews (correct for a solo maintainer).
- **Gap:** `required_status_checks.strict = false` — "require branches up to date", named in both
  issue #23 and `AGENTS.md`, is not enforced. Receipt:

```
$ gh api repos/:owner/:repo/branches/main/protection --jq '{strict_up_to_date:.required_status_checks.strict, contexts:[.required_status_checks.checks[].context]}'
{"strict_up_to_date": false, "contexts": ["GitGuardian Security Checks", "checks"]}
```

Remediation is a recorded decision (enable `strict`, or amend the baseline for the solo-maintainer
exemption) — see #62.

---

## Tier-3 existence spot-check

| Issue | Deliverable | Present |
|---|---|---|
| #22 | `docs/AUDIT_FINDINGS.md` | ✅ |
| #34 | `.github/workflows/add-pr-to-project.yml` | ✅ |
| #35 | CONTRIBUTING.md "Project Tracking" section | ✅ |
| #36 | `.github/pull_request_template.md` (project checklist) | ✅ |
| #37 | `prompts/EXECUTOR-SEED-PROMPT-TEMPLATE.md` (+ prompts/) | ✅ |
| #40 | `prompts/2026-07-21-issue-40-commit-pm-artifacts.md` | ✅ |
| #42 | `docs/PM-WORKFLOW.md` | ✅ |
| #44 | `docs/PM-WORKFLOW.md` (PM workflow & governance) | ✅ |
| #45 | `.github/labels.json` (Goldilocks schema) | ✅ |
| #55 | AGENTS.md + auto-loaded CLAUDE.md (PR #56) | ✅ |
| #57 | add-pr-to-project fix (PR #58) | ✅ |

---

## Follow-up issues filed by this audit

| # | Title | For | Labels |
|---|---|---|---|
| **#60** | maintenance --dry-run does not suppress brew/conda package mutations | #7 (PR #33) | area:script, type:bug, priority:high, effort:medium, status:ready, risk:high |
| **#61** | Command-timeout enforcement fires ~10x early and never reports the timed_out state | #11 (PR #49) | area:script, type:bug, priority:high, effort:medium, status:ready, risk:medium |
| **#62** | main branch protection does not require branches up to date (strict:false) | #23 (PR #28) | area:governance, type:bug, priority:low, effort:small, status:ready, risk:medium |
| **#64** | tests/smoke.sh intermediate assertions are non-enforcing (only the last statement gates) | cross-cutting (A1) | area:script, type:bug, priority:high, effort:small, status:ready, risk:medium |

`#29` is **not** refiled — its gap is tracked by existing open issue **#31**.

All four follow-ups are on milestone v1.0 and boarded to the "macOS System Health Roadmap"
project. Per #59, remediation begins after the PM independently re-verifies these findings by
reading back the receipts above. Suggested order: **#64** first (an enforcing suite is the
foundation for re-verifying the rest), then the behavioral safety gaps **#60** and **#61**, then
**#62**.
