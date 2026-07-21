# Contributing to macOS System Health

Thanks for helping improve this project. It is a conservative Bash utility, so
the bar for changes is deliberately high: every contribution must preserve the
read-only report default, the explicit maintenance boundary, and the privacy
model described in [README.md](README.md) and [SECURITY.md](SECURITY.md).

This document describes the workflow the repository actually runs. If anything
here drifts from the tooling in `scripts/`, `.githooks/`, `.github/`, and
`tests/`, treat the tooling as authoritative and open an issue.

## Prerequisites

- macOS and Bash 3.2 or newer (the scripts target the system Bash).
- The quality tools used by the checks and CI:

  ```fish
  brew install actionlint shellcheck gitleaks
  ```

- `plutil` (included with macOS) is used to lint the LaunchAgent template when
  present.

## One-time setup

Install the repository-owned pre-commit hook so every commit runs the staged
checks automatically:

```fish
scripts/install-hooks
```

This sets `core.hooksPath` to `.githooks`; the installed `pre-commit` hook runs
`scripts/check --staged` before each commit.

## Running the checks

Run the full suite before opening a pull request:

```fish
scripts/check --all
```

`scripts/check` runs, in order:

1. Staged (and, for `--all`, working-tree and last-commit) whitespace checks via
   `git diff --check`.
2. Bash syntax validation (`bash -n`) on every tracked shell file.
3. ShellCheck on those same files.
4. `actionlint` on the GitHub Actions workflows.
5. `plutil -lint` on the LaunchAgent plist template (when `plutil` is available).
6. The isolated smoke tests in `tests/smoke.sh`.
7. A Gitleaks secret scan (redacted output).

`scripts/check --staged` runs the same suite scoped to staged content and is
what the pre-commit hook invokes. The `quality` workflow in
`.github/workflows/lint.yml` runs `scripts/check --all` on `macos-15` for every
push and pull request, so a green local run should match CI.

Missing tools fail fast with an install hint; install the tool listed and re-run.

## Tests

`tests/smoke.sh` exercises the tool end to end against stubbed `brew`, `conda`,
`python3`, and `launchctl` commands inside a temporary HOME, so it never touches
your real environment. It asserts, among other boundaries:

- Report mode performs no Homebrew or Conda mutations; maintenance mode performs
  exactly the documented ones.
- The **redaction guarantee**: private paths (the home directory and the Conda
  base) never appear in report output.
- Invalid configuration fails before any log directory is created.

New behavior must come with a test that covers both the change and its failure
boundary, matching the existing negative-assertion style.

## Changelog

The project follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
with semantic versioning. Add a bullet under the appropriate `### Added`,
`### Changed`, `### Fixed`, or `### Security` heading in the `## [Unreleased]`
section of [CHANGELOG.md](CHANGELOG.md) in the same pull request as your change,
unless the change is trivial enough not to warrant one (say so in the PR).

## Branch, pull request, and merge workflow

1. Create a topic branch from an up-to-date `main`.
2. Make focused commits with imperative subject lines. Keep unrelated changes
   out of the branch.
3. Run `scripts/check --all` and make sure it is green.
4. Open a pull request. The [pull request template](.github/pull_request_template.md)
   asks you to link the related issue, summarize the changes, confirm the safety
   and privacy checklist, and record the validation commands you ran — do not
   paste private report contents.
5. Verify project membership. Every pull request that links a tracked issue must
   be added to the "macOS System Health Roadmap" project (see "Project Tracking"
   below).
6. Wait for the `quality` CI workflow to pass.
7. Changes land on `main` by squash merge; the squash commit references the pull
   request number (for example, `Add community contribution templates (#15)`).
8. After merge, an agent-driven session performs cleanup without waiting to be
   asked: pull `main` locally (fast-forward), delete the merged local topic
   branch (and the remote branch, if GitHub's auto-delete-on-merge didn't
   already remove it), confirm the closed issue carries the labels and
   milestone the PR intended, and — when the work originated from a PM/spec
   thread — produce a short handoff extract (what merged, issue/PR numbers,
   what's next) back to that thread. This is a standing contract, not a
   one-off ask.

## Project Tracking

Every pull request that links a tracked issue must be added to the
"macOS System Health Roadmap" project.

- Project membership is **automatically verified** by a GitHub Actions
  workflow that runs when the PR is opened.
- If automation fails (rare), manually add the PR to the project before merge.
- Verify both the linked issue(s) and the PR have consistent status
  (e.g., both "Todo" or both "In Progress").

**Verification checklist:**

- [ ] PR links an issue using `Fixes #N` syntax
- [ ] Linked issue is in the "macOS System Health Roadmap" project
- [ ] PR has been added to the project (check PR details sidebar)

Open issues with the [bug report](.github/ISSUE_TEMPLATE/bug_report.yml) or
[feature request](.github/ISSUE_TEMPLATE/feature_request.yml) templates. Blank
issues are disabled so that every report captures the safety and privacy context
the project needs.

## Safety and privacy rules for every change

- Report mode stays read-only apart from the documented local logs and backups;
  maintenance mutations stay explicit and documented.
- Never commit credentials, personal identifiers, hostnames, environment names,
  absolute workstation paths, or unredacted reports. The Gitleaks scan and the
  redaction tests exist to catch regressions, but the responsibility is yours.
- Report security vulnerabilities through GitHub private vulnerability reporting
  described in [SECURITY.md](SECURITY.md), not a public issue.

See the [documentation index](docs/README.md), [roadmap](docs/planning/ROADMAP.md),
and [issue execution plan](docs/planning/ISSUES.md) for where the project is
headed.
