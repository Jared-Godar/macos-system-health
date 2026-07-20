# Governance baseline

Minimal, lean-by-design governance for this repo. Established during the #22 audit.

## Label taxonomy

Kept the existing default set rather than replacing it — it already covers `type:`:

- `bug`, `documentation`, `enhancement`, `dependencies`, `github_actions`,
  `good first issue`, `help wanted`, `question`, `wontfix`, `duplicate`, `invalid`

Added an `area:*` and `priority:*` layer on top:

- `area:script` — `bin/system-health` and related script logic
- `area:scheduling` — LaunchAgent/cron scheduling infrastructure
- `area:reporting` — report/email output and formatting
- `area:governance` — labels, CHANGELOG, branch protection, PR/issue process
- `priority:high` — should land in the next milestone pass
- `priority:medium` — worth doing, not urgent
- `priority:low` — nice to have, defer freely

New issues should carry one existing type-ish label (`bug`/`enhancement`/`documentation`),
one `area:*` label, and one `priority:*` label.

## CHANGELOG structure

Already in place at `CHANGELOG.md` in [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
format with semantic versioning. Every PR with substantive changes adds an entry under
`## [Unreleased]` in the same PR — treat this as a merge gate, not release-time cleanup.

## Branch protection

Not yet enabled (see #23). Once enabled, the baseline rule for `main` is:

- Require a pull request before merging
- Require the `quality` status check (from `.github/workflows/lint.yml`) to pass
- Require branches to be up to date before merging
- Disallow force pushes

## PR metadata standards

- Use the existing `.github/pull_request_template.md`.
- Reference the issue being closed (`Closes #N`).
- Apply one `area:*` label and one `priority:*` label matching the linked issue.
- Assign to the `v1.0` milestone when the work is scoped to that milestone.
