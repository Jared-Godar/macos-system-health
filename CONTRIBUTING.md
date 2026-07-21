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

Install the repository-owned hooks so the checks run automatically:

```fish
scripts/install-hooks
```

This sets `core.hooksPath` to `.githooks`, which installs two hooks:

- `pre-commit` runs `scripts/check --staged` before each commit.
- `pre-push` runs `scripts/check --all` on the **committed** state and refuses a
  push whose gate is red, so a stale green receipt can never be reported for a
  pushed state (see [AGENTS.md](AGENTS.md), "Receipts expire on the next
  mutation"). It also whitespace-checks every commit in the pushed range, not
  just the tip. Bypass in a genuine emergency with `git push --no-verify`.

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

## Editor settings

The repo tracks one file of shared VS Code settings, `.vscode/settings.json`
(the rest of `.vscode/` stays gitignored for personal editor state — see the
`!.vscode/settings.json` negation in `.gitignore`). It exists to stop the
Python extension from warning about a `.venv` interpreter this Bash-only repo
never has, plus a small set of settings evidenced by the repo's own tooling:

- `python.defaultInterpreterPath: "python3"` and
  `python.terminal.activateEnvironment: false` stop the interpreter hunt
  without hardcoding a machine-specific path — `"python3"` resolves via `PATH`,
  mirroring `bin/system-health`'s own `command -v python3` check.
- `files.associations` maps the seven extensionless Bash scripts (the same
  `SHELL_FILES` set `scripts/check` lints) to `shellscript`, so ShellCheck
  integration and syntax highlighting engage without a shebang-sniff.
- `"[markdown]": { "files.trimTrailingWhitespace": false }` pairs with
  `.gitattributes`' `artifacts/** -whitespace`: several tracked files under
  `artifacts/` rely on Markdown hard line breaks (trailing double spaces), and
  an editor that trims on save would silently break their rendering. **Do not
  remove either half without the other** — they exist together to protect the
  same tracked content.
- `files.eol: "\n"` keeps this Unix-only, Bash-tooled repo free of CRLF, which
  would trip the whitespace gate.

Nothing else is shipped here — no formatter, linter, theme, or ruler settings.

## Labels & Issue Classification

Issues are labeled to enable filtering, dashboarding, and workflow tracking in
GitHub Projects. The schema is documented in [.github/labels.json](.github/labels.json).

The **required set is type-aware**, and its authoritative, machine-readable
definition is [.github/label-policy.json](.github/label-policy.json) — the single
source of truth the PR label gate (`.github/workflows/label-policy-gate.yml`)
enforces on every pull request. In one sentence: AREA, PRIORITY, TYPE, EFFORT, and
STATUS are required on every issue and PR, and RISK is additionally required
whenever TYPE is `type:feature` or `type:bug`, while CONFIDENCE and HOUSEKEEPING
stay optional. Wherever this prose and `.github/label-policy.json` appear to differ,
the policy file governs.

**Required labels for all open issues:**

- **AREA:** Component affected — `area:governance`, `area:reporting`, `area:scheduling`, `area:script`
- **PRIORITY:** Urgency — `priority:high` (next milestone), `priority:medium` (worth doing), `priority:low` (defer freely)
- **TYPE:** Work type — `type:feature`, `type:bug`, `type:docs`, `type:community-contribution`
- **EFFORT:** Estimated size — `effort:small` (1–2 days), `effort:medium` (3–5 days), `effort:large` (1+ weeks)
- **STATUS:** Workflow state — `status:ready` (no blockers), `status:blocked` (waiting on external input), `status:stalled` (waiting on review/decision)

**Conditionally required / optional labels:**

- **RISK:** Impact level — `risk:high` (security/data), `risk:medium` (workflow-affecting), `risk:low` (minimal/reversible). **Required** for `type:feature` and `type:bug`; optional otherwise (see the policy file above).
- **CONFIDENCE:** Validation — `confidence:low` (needs research), `confidence:unconfirmed` (community-reported)
- **HOUSEKEEPING:** Meta labels — `dependencies`, `duplicate`, `help-wanted`

See `.github/labels.json` for complete schema and label combinations.

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

- [ ] PR links an issue using `Fixes #N`, `Closes #N`, or `Resolves #N` syntax
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
[issue execution plan](docs/planning/ISSUES.md), and [PM workflow & governance](docs/PM-WORKFLOW.md)
for where the project is headed and how it is coordinated.
