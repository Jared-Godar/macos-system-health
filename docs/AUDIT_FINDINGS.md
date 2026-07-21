# Audit Findings: macos-system-health

**Issue:** #22
**Date:** 2026-07-20
**Scope:** Script architecture, update handling, scheduling, reporting, governance

## Summary

The repository is materially more mature than the audit brief assumed. It already has a
CHANGELOG (Keep a Changelog format), CI (`lint.yml` running ShellCheck/actionlint/smoke
tests/Gitleaks on every push and PR, plus a weekly `full-history-scan.yml`), issue/PR
templates, Dependabot, a `v1.0` milestone with 8 open enhancement issues (#6–#13) already
covering most of the categories this audit was scoped to find (JSON output, dry-run
controls, per-tool opt-in, notification providers, signed releases, an ADR, Intel
validation), a public roadmap, and a default label set. This audit therefore focused on
confirming the existing baseline and surfacing genuinely new gaps rather than re-deriving
work already tracked.

Two new issues were opened: #23 (no branch protection on `main` despite a working CI
gate) and #24 (backup snapshots — distinct from the log retention already tracked in #7 —
grow without bound). No other enhancement opportunities were found that aren't already
covered by an open issue.

## 1. Script Architecture & Code Quality

`bin/system-health` (169 lines) is a single-entry-point Bash script: `MODE` is `report` or
`maintenance`, validated with a `case` guard. It runs under `set -uo pipefail`, uses a lock
directory to prevent concurrent runs, redacts `$HOME` and the Conda base path from all
logged/emailed output, and separates read-only checks (always run) from mutating actions
(gated behind `maintenance`). Error handling is consistent: every external call goes
through `run_logged`/`capture_output` and increments `WARNINGS` or `ISSUES` rather than
aborting, so one missing tool (e.g., no Conda installed) doesn't kill the whole report.
Exit code reflects hard failures only (`ISSUES > 0` → exit 1). This is well-structured for
its size — no refactoring opportunity was found that isn't already covered by #11 (per-tool
opt-in and timeout configuration).

## 2. Update Handling

There is no `--minor`/`--major` flag distinction (the audit brief assumed one); instead
there's a binary `report`/`maintenance` mode. `maintenance` runs `brew update && brew
upgrade && brew cleanup` and `conda clean --all --yes` unconditionally — no per-package or
per-severity granularity. A Brewfile and Conda base export are captured as a backup
immediately before/regardless of maintenance actions, but there is no automated
reversion — rollback is manual (documented in `docs/operations/RUNBOOK.md`: "Homebrew
upgrades are not automatically rolled back; use package-specific pinning or reinstall a
known version when supported"). This gap — dry-run and finer-grained control — is already
tracked as #7 and #11; a scripted snapshot/reversion mechanism is implicit but not
automated, consistent with the "lean by design" directive rather than an oversight.

## 3. Scheduling Infrastructure

`bin/install-schedule` renders `config/io.github.system-health.report.plist.template` with
XML-escaped substitutions, validates it with `plutil -lint` before installing, and
bootstraps it via `launchctl`. Scheduling is LaunchAgent-only (no cron path — appropriate
for macOS-only tooling as documented). The RUNBOOK covers verification
(`launchctl print`), manual triggering (`launchctl kickstart -k`), and removal. This is
solid; no gap found beyond what #7/#8 already track.

## 4. Reporting & Notifications

Email delivery is optional (`msmtp`, configured via `bin/configure-email` using 1Password
CLI for the credential — no secrets touch the repo or plaintext config beyond a
`chmod 700` helper script). Report content is redacted before logging or emailing.
Log files are timestamped under `SYSTEM_HEALTH_LOG_DIR`; retention is currently unbounded
(tracked in #7). **New finding:** the separate backup directory (Brewfile/Conda snapshots)
has the same unbounded-growth problem and is not covered by #7's scope — filed as #24.

## 5. Governance & Maintenance

- **CHANGELOG:** present, Keep a Changelog format, actively maintained (`Unreleased`
  section current as of this audit).
- **Branch protection:** **not configured** on `main` — a genuine gap, since CI
  (`quality` workflow) already exists and works; it's just not enforced. Filed as #23.
- **Labels:** default GitHub set (`bug`, `documentation`, `enhancement`, etc.) plus
  `dependencies`, `github_actions`. This audit added a small `area:*`/`priority:*`
  layer (the taxonomy since grew into the schema in `.github/labels.json`; see
  `CONTRIBUTING.md` and `AGENTS.md`) rather than replacing the existing type-ish
  labels, keeping the taxonomy lean.
- **PR/issue metadata:** issue templates (bug/feature) and a PR template already exist.
- **Milestone/project tracking:** a `v1.0` milestone and a public roadmap project already
  track the 8 open enhancement issues.

## Overall Assessment

The script itself is small, well-tested (`tests/smoke.sh` covers the report/maintenance
boundary, redaction, error paths, and plist XML-escaping), and already reflects the
"report-only default, explicit maintenance" and privacy-by-default philosophy the audit
brief asked to confirm. The governance and CI baseline is further along than "lean by
design" strictly requires — this audit did not find over-engineering to trim. The two
concrete gaps (branch protection, backup retention) are both small, well-scoped, and now
tracked as #23 and #24 alongside the existing #6–#13 backlog.
