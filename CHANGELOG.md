# Changelog

All notable changes follow [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and releases use semantic versioning.

## [Unreleased]

### Added

- Governance: backward-facing audit of closed v1.0 work (`docs/audits/2026-07-21-closed-work-audit.md`)
  — reconstructs each in-scope closed issue's definition-of-done and verifies delivered work with
  pasted command receipts; verdicts (Satisfied/Partial) with follow-up issues #60 (#7 dry-run does
  not suppress brew/conda maintenance mutations), #61 (#11 timeout fires ~10x early and never reports
  the timed_out state), #62 (#23 branch protection strict flag), and #64 (smoke-test intermediate
  assertions are non-enforcing) for the confirmed gaps (#59).
- Governance: layered operating contract for agent sessions — a lean, authoritative
  `AGENTS.md` (standing commitments, roles and the four gated actions, canonical
  flow, model/effort sizing, definition of done, local environment) plus a thin
  auto-loaded root `CLAUDE.md` mirroring the three non-negotiables; the stale
  `docs/GOVERNANCE.md` was folded in and removed, `docs/PM-WORKFLOW.md` and
  `docs/README.md` now point to `AGENTS.md` as authoritative (#55).
- Docs: v1.0 acceptance criteria document with platform matrix and success metrics (#6).
- A recurring `full-history-scan.yml` CI workflow: runs the same
  `scripts/check --all` command (including the `gitleaks git` history scan)
  on a weekly schedule and via `workflow_dispatch`, independent of pushes or
  pull requests, so a newly published Gitleaks rule or a secret predating
  the current ruleset is caught on a recurring cadence rather than only on
  the next code change (#20).
- Log retention: configurable age/count-based cleanup via `SYSTEM_HEALTH_LOG_RETENTION_DAYS` and `SYSTEM_HEALTH_LOG_RETENTION_COUNT` environment variables in maintenance mode (#7).
- Backup snapshot retention: configurable age/count-based cleanup for `Brewfile-*` and `conda-base-*.yml` files via `SYSTEM_HEALTH_BACKUP_RETENTION_DAYS` and `SYSTEM_HEALTH_BACKUP_RETENTION_COUNT` in maintenance mode (#24).
- Dry-run mode for maintenance operations via `SYSTEM_HEALTH_DRY_RUN` environment variable; previews planned deletions without executing them (#7).
- Governance: GitHub Actions workflow to auto-add PRs to "macOS System Health Roadmap" project when they link tracked issues (#34).
- Docs: Project tracking workflow documentation in CONTRIBUTING.md (#35).
- Docs: Project tracking verification checklist in PR template (#36).
- Docs: Architecture Decision Record (ADR 0001) documenting report and maintenance boundaries (#9).
- Docs: PM workflow & governance documentation in `docs/PM-WORKFLOW.md` — artifact lifecycle, durable contracts, seed prompt pattern, and phase 1 lessons learned.
- Governance: Goldilocks label schema for GitHub Projects dashboarding and filtering — 28 labels across area, priority, type, effort, status, risk, confidence, and housekeeping categories; complete durable schema in `.github/labels.json` (#45).
- Per-tool enable/disable controls for Homebrew, Conda, and pip checks via configuration file at `~/.config/system-health/config.yaml` (#11).
- Configurable command timeout (default: 30 seconds) to prevent scheduled runs from hanging indefinitely; timed-out commands report clear state separate from other failures (#11).
- Four distinct command execution states: Skipped (tool disabled in config), Timed out (exceeded timeout), Warning (command succeeded with warnings), Failure (command failed) (#11).
- JSON output format via `--format json` flag in report mode; schema versioning (v1.0) enables future evolution; structured checks, warnings, and issues arrays with tool-level metadata; all private paths redacted; text output remains default and unchanged (#10).

### Changed

- Governance: Enable branch protection on main; require status checks before merge (#23).

### Fixed

- Governance: the "Auto-add PR to Project" workflow no longer reports a false
  green when a PR is not actually boarded. It now authenticates with a
  `PROJECT_METADATA_TOKEN` classic PAT to reach the user-owned "macOS System
  Health Roadmap" project (Project #3) — which the default `GITHUB_TOKEN` cannot
  see — adds the PR, reads membership back, and **fails the check (non-zero
  exit)** if the secret is missing, the project cannot be resolved, or
  membership cannot be confirmed. The previous workflow warned-and-skipped on
  those paths and exited 0, so PRs could merge unboarded. Requires the
  maintainer to add the `PROJECT_METADATA_TOKEN` repository secret; until then
  the check correctly fails rather than false-passing (#57).

## [0.1.0] - 2026-06-30

### Added

- Safe report and explicit maintenance modes.
- Homebrew, Conda, pip, disk, backup, locking, and optional email checks.
- LaunchAgent scheduling and operational runbook.
- Automated linting, smoke tests, and secret scanning for local commits and CI.
- A public privacy- and security-focused publication checklist.

### Security

- Removed embedded recipient addresses, workstation paths, hardware serial collection, and secret-bearing notes.
- Restricted generated log and backup permissions with `umask 077`.
- Redacted home-directory and Conda-base paths from logged and emailed command output.
