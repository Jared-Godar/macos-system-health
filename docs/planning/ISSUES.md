# Issue execution plan

> Updated 2026-06-30. The [public project board](https://github.com/users/Jared-Godar/projects/3) is the source of truth for live status; this document records sequencing, dependencies, and acceptance intent.

| Phase | Issues | Outcome |
|---|---|---|
| 1. Define contracts | [#6](https://github.com/Jared-Godar/macos-system-health/issues/6), [#9](https://github.com/Jared-Godar/macos-system-health/issues/9) | Specify v1.0 support policy and immutable safety boundaries |
| 2. Harden execution | [#7](https://github.com/Jared-Godar/macos-system-health/issues/7), [#11](https://github.com/Jared-Godar/macos-system-health/issues/11) | Dry-run, retention, opt-in checks, bounded execution |
| 3. Structure outputs | [#10](https://github.com/Jared-Godar/macos-system-health/issues/10) | Stable internal result model and optional JSON |
| 4. Decouple delivery | [#13](https://github.com/Jared-Godar/macos-system-health/issues/13) | Notification interface independent of report generation |
| 5. Validate platforms | [#8](https://github.com/Jared-Godar/macos-system-health/issues/8) | Confirm final behavior on Intel hardware |
| 6. Release | [#12](https://github.com/Jared-Godar/macos-system-health/issues/12) | Reproducible checksums, signing decision, v1.0 release |

## Phase 1: define the contract

- Start with [#6](https://github.com/Jared-Godar/macos-system-health/issues/6) and [#9](https://github.com/Jared-Godar/macos-system-health/issues/9) as documentation-only PRs.
- #6 — Define v1.0 acceptance criteria:
  - Supported macOS versions and architectures
  - Bash 3.2 compatibility
  - Optional-tool behavior when Homebrew, Conda, pip, or `msmtp` is absent
  - Exit-code meanings
  - Privacy and redaction requirements
  - Required report, maintenance, scheduling, and email tests
  - Explicit v1.0 release checklist
- #9 — Publish the ADR:
  - Report mode remains read-only except for logs and inventory backups
  - Maintenance requires explicit selection
  - Enumerate permitted mutations
  - Explain why Conda and pip upgrades remain manual
  - Define expectations for future dry-run and notification features

These prevent later features from quietly weakening the safety model.

## Phase 2: harden execution

- Split #7 into two deliverables, ideally separate PRs:
  - Maintenance dry-run
    - Interface: `bin/system-health maintenance --dry-run`
    - Run diagnostic checks normally
    - Print planned mutations
    - Never execute `brew update`, `brew upgrade`, `brew cleanup`, or `conda clean`
    - Add negative tests proving no mutation commands run
  - Log retention
    - Configurable age and count limits
    - Delete only recognized `report-*.log` files
    - Never delete the current report, scheduler logs, unrelated files, or backups
    - Default to no automatic deletion until explicitly configured
    - Test exclusively in temporary directories

- Then implement #11:
  - Independent Homebrew, Conda, and pip enable/disable controls
  - A conservative default command timeout
  - Clear skipped, timed-out, warning, and failure states
  - No new required dependencies
  - Scheduled runs must not hang indefinitely

This likely requires refactoring `run_logged` and `capture_output` into one consistent command-execution boundary.

## Phase 3: structured output

- Implement #10 only after command results have consistent statuses.
  - Keep text as the default
  - Add something like `--format json`
  - Include `schema_version`, timestamps, mode, checks, warnings, issues, and exit status
  - Never generate JSON by parsing the existing text report
  - Preserve redaction before serialization
  - Test JSON validity, escaping, schema stability, and absence of private paths
  - Treat schema changes as compatibility-sensitive

## Phase 4: notifications

- Implement #13 after report generation is separated from presentation.
  - Produce a finalized report/result first
  - Pass it to a notifier interface afterward
  - Keep credentials entirely in local configuration
  - Preserve msmtp as the initial provider
  - Make “no notifier configured” a normal condition
  - Ensure notification failure cannot corrupt or erase the local report
  - Test providers with stubs rather than real credentials

## Phase 5: Intel validation

- Run #8 against the feature-complete release candidate, not today’s intermediate code.
  - Validate:
    - PATH discovery
    - Report and maintenance boundaries
    - Dry-run behavior
    - Command timeouts
    - LaunchAgent installation and triggering
    - Text and JSON output
    - Redaction and file permissions

If Intel hardware is unavailable, mark this issue explicitly blocked rather than treating CI emulation as equivalent evidence.

## Phase 6: release provenance

- Finish with #12:
  - Decide whether the project actually needs packaged artifacts
  - At minimum, document tag verification and publish SHA-256 checksums for any distributed files
  - Prefer signed tags or a documented GitHub-native provenance mechanism
  - Automate release generation only after the process is reproducible
  - Add a release verification section to the runbook

## Milestone recommendation

Keep these in v1.0:

- #6 acceptance criteria
- #9 ADR
- #7 dry-run and retention
- #11 opt-ins and timeouts
- #8 Intel validation
- #12 release provenance

Move #10 JSON and #13 notification providers to a v1.1 milestone unless #6 establishes them as true v1.0 requirements. They are valuable, but they substantially increase API and integration surface. Do not change their milestones until the #6 acceptance-criteria decision is merged.

## Proposed project-board status

- In progress: #6 and #9
- Next: #7 and #11
- Todo: #8, #10, #12, and #13

## Delivery rules

- Use one focused pull request per independently reviewable behavior; split #7 into dry-run and retention changes.
- Add isolated regression tests before changing the live workstation path.
- Preserve text output and existing environment-variable defaults unless an issue explicitly changes their compatibility contract.
- Run `scripts/check --all` locally and require the protected `checks` status before merging.
- Update the README, runbook, changelog, and this plan in the same pull request when user-visible behavior changes.
