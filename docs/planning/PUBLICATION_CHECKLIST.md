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
- [x] Add Dependabot version-update configuration for GitHub Actions dependencies.
- [x] Pin CI to macOS 15, move checkout to Node 24-based `actions/checkout@v6`, and remove the unused runner tap warning.

## First publication

- [x] Stage and review the intended public files.
- [x] Confirm ignored and private files do not appear in `git ls-files`.
- [x] Create the initial commit and confirm the pre-commit quality suite passes.
- [x] Create the public `Jared-Godar/macos-system-health` repository with fresh history and push `main`.
- [x] Confirm the first GitHub Actions quality run passes.

## GitHub repository settings

- [x] Enable secret scanning and push protection.
- [x] Enable private vulnerability reporting.
- [x] Enable Dependabot alerts and security updates.
- [x] Enable CodeQL default setup for GitHub Actions workflow analysis.
- [x] Add a repository description and the topics `macos`, `bash`, `homebrew`, `conda`, `system-health`, and `automation`.
- [x] Confirm GitHub recognizes the MIT license.
- [x] Enable release immutability and streamline repository collaboration settings.
- [x] Protect `main` with pull requests, linear history, force-push and deletion blocking, and the required `checks` status.
- [ ] Add a privacy-reviewed social preview image.

## Follow-up publication checks

- [x] Commit and push the reviewed CI and Dependabot improvements.
- [x] Confirm the follow-up quality workflow passes without the original runner annotations.
- [x] Review and merge the first Dependabot update through a passing pull request.

## Release readiness

- [x] Run report mode on a backed-up macOS account and inspect the generated and emailed reports for private data.
- [x] Run maintenance mode on a backed-up macOS account and verify the documented mutation boundary.
- [x] Verify LaunchAgent installation, immediate triggering, scheduled logs, removal, and reinstallation using the runbook.
- [ ] Import or recreate the starter backlog from `docs/planning/trello-import.csv` if it strengthens the portfolio presentation.
- [ ] Publish release notes and tag `v0.1.0` after all required checks pass.
