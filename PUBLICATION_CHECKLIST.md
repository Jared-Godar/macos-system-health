# Publication checklist

This checklist records the privacy, security, reliability, and release concerns reviewed while preparing the project for publication.

## Completed locally

- [x] Revoke the exposed Google app password and store its replacement outside the repository.
- [x] Create a standalone Git repository with fresh history; do not reuse the parent `mini-projects` history.
- [x] Remove private Fish and 1Password notes from the public changelog and ignore their private holding directory.
- [x] Set the README clone URL to the intended GitHub account and repository.
- [x] Expand `.gitignore` for private notes, local environments, editor metadata, credentials, logs, backups, and test artifacts.
- [x] Harden scheduled PATH discovery, configuration validation, command-failure reporting, Conda path redaction, email summaries, and LaunchAgent XML handling.
- [x] Add isolated smoke tests for report and maintenance boundaries, failed checks, invalid configuration, privacy redaction, and XML-sensitive paths.
- [x] Add automatic Bash, ShellCheck, Actionlint, plist, whitespace, smoke-test, and Gitleaks checks.
- [x] Activate the repository-owned pre-commit hook through `core.hooksPath`.
- [x] Add the same quality suite to GitHub Actions.
- [x] Run the complete local quality suite successfully with five passing smoke tests and no detected secrets.
- [x] Confirm `.DS_Store`, private notes, and the local VS Code workspace are ignored.
- [x] Separate workstation-specific notes from public project documentation.
- [x] Configure optional email delivery through a read-only 1Password service account without storing credentials in the repository.

## Before the first push

- [ ] Stage the intended public files with `git add .`.
- [ ] Review `git diff --cached`, `git diff --cached --check`, and `git ls-files` before the first commit.
- [ ] Confirm ignored and private files do not appear in `git ls-files`.
- [ ] Create the initial commit and confirm the pre-commit quality suite passes against the staged snapshot.
- [ ] Create the public `jaredgodar/macos-system-health` repository with fresh history and push `main`.
- [ ] Confirm the first GitHub Actions quality run passes.

## GitHub repository settings

- [ ] Enable secret scanning and push protection.
- [ ] Enable private vulnerability reporting.
- [ ] Enable Dependabot alerts and security updates.
- [ ] Add a repository description and the topics `macos`, `bash`, `homebrew`, `conda`, `system-health`, and `automation`.
- [ ] Confirm GitHub recognizes the MIT license.
- [ ] Add a privacy-reviewed social preview image.

## Release readiness

- [ ] Run report mode on a disposable or backed-up macOS account and inspect the generated report for private data.
- [ ] Run maintenance mode only on a disposable or backed-up macOS account and verify the documented mutation boundary.
- [ ] Verify LaunchAgent installation, immediate triggering, scheduled logs, and removal using the runbook.
- [ ] Import or recreate the starter backlog from `docs/trello-import.csv` if it strengthens the portfolio presentation.
- [ ] Publish release notes and tag `v0.1.0` after all required checks pass.
