# Changelog

All notable changes follow [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and releases use semantic versioning.

## [Unreleased]

### Added

- Docs: v1.0 acceptance criteria document with platform matrix and success metrics (#6).
- A recurring `full-history-scan.yml` CI workflow: runs the same
  `scripts/check --all` command (including the `gitleaks git` history scan)
  on a weekly schedule and via `workflow_dispatch`, independent of pushes or
  pull requests, so a newly published Gitleaks rule or a secret predating
  the current ruleset is caught on a recurring cadence rather than only on
  the next code change (#20).

### Changed

- Governance: Enable branch protection on main; require status checks before merge (#23).

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
