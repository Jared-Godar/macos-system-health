# macOS System Health

A conservative Bash utility for auditing and maintaining a developer workstation that uses Homebrew, Conda, and pip. Report mode is read-only apart from local logs and inventory backups; maintenance mode must be selected explicitly.

## What it checks

- macOS version, architecture, and root disk usage
- Homebrew diagnostics and outdated packages
- Conda diagnostics and environments
- pip dependency consistency and outdated packages
- timestamped, private-by-default logs and environment backups
- optional email delivery through an existing `msmtp` configuration

The tool deliberately does not run `conda update --all`, mass-upgrade pip packages, request `sudo`, collect hardware serial numbers, or embed credentials.

## Requirements

- macOS and Bash 3.2 or newer
- Optional: Homebrew, Conda, Python 3/pip, and `msmtp`

## Quick start

```bash
git clone https://github.com/Jared-Godar/macos-system-health.git
cd macos-system-health
chmod +x bin/system-health bin/install-schedule
bin/system-health report
```

Review the output, then run maintenance deliberately:

```bash
bin/system-health maintenance
```

Maintenance runs Homebrew update, upgrade, and cleanup plus Conda cache cleanup. It does not upgrade Conda or pip packages.

## JSON Output

Generate machine-readable reports with the `--format json` flag (report mode only):

```bash
bin/system-health report --format json
```

The JSON schema includes:
- `schema_version`: "1.0" (for future compatibility)
- `timestamp`: ISO 8601 UTC timestamp
- `mode`: "report"
- `exit_status`: 0 if healthy, >0 if issues detected
- `checks`: tool status (status, skipped, timed_out, duration_ms) for each tool
- `warnings`: non-critical issues with tool, message, and severity
- `issues`: critical issues with tool, message, and severity

All private paths are redacted before JSON serialization (same as text output).

Example: Extract warnings using `jq`:

```bash
bin/system-health report --format json | jq '.warnings'
```

Verify schema version:

```bash
bin/system-health report --format json | jq '.schema_version'
```

## Configuration

### Environment Variables

Settings are environment variables so no personal data needs to live in the repository.

| Variable | Default | Purpose |
| --- | --- | --- |
| `SYSTEM_HEALTH_LOG_DIR` | `~/Library/Logs/system-health` | Report location |
| `SYSTEM_HEALTH_BACKUP_DIR` | `~/Library/Application Support/system-health/backups` | Inventory backup location |
| `SYSTEM_HEALTH_DISK_THRESHOLD` | `85` | Disk warning percentage |
| `SYSTEM_HEALTH_EMAIL` | unset | Optional report recipient |

Never commit SMTP credentials. Configure authentication in `msmtp` using Keychain, 1Password, or another local secret store.

### Per-Tool Controls and Timeout

Create a configuration file at `~/.config/system-health/config.yaml` to control which checks run and set a command timeout:

```yaml
checks:
  homebrew: true    # Enable/disable Homebrew checks
  conda: true       # Enable/disable Conda checks
  pip: true         # Enable/disable pip checks

execution:
  command_timeout_seconds: 30  # Timeout for external commands (default: 30)
```

**Defaults:** All checks are enabled by default when no configuration file is present. The timeout default is conservative (30 seconds) and will not affect normal execution.

Example: Disable Conda checks while keeping Homebrew and pip enabled:

```yaml
checks:
  homebrew: true
  conda: false
  pip: true
```

To configure local and scheduled delivery through a read-only 1Password service account, provide the recipient and an existing 1Password secret reference:

```fish
bin/configure-email "you@example.com" "op://VAULT/ITEM/password"
```

The helper stores no password in the repository or `msmtp` configuration. It records the recipient in a private local configuration file, installs it in the local LaunchAgent, and sends a test message. Subsequent local and scheduled reports email by default; set `SYSTEM_HEALTH_EMAIL` to an empty value for a one-run local opt-out.

## Scheduling

`bin/install-schedule` installs a user LaunchAgent for a report every Monday at 7:00 a.m. It schedules report mode only. See the [operations runbook](docs/operations/RUNBOOK.md) for install, verification, recovery, and removal procedures.

## Safety model

- `report` is the default and suppresses Homebrew auto-update.
- `maintenance` is explicit and has a documented mutation boundary.
- A per-user lock prevents overlapping runs.
- `umask 077` limits new logs and backups to the current user.
- Commands are resolved from `PATH`; no username or package-manager prefix is hard-coded.
- Private paths are redacted from all report output: the home directory and the Conda base are rewritten to `[home]` and `[conda base]` before anything is logged or emailed. The redaction case in `tests/smoke.sh` (`test_report_boundary_and_redaction`) asserts they never appear.

See [ADR 0001](docs/ADRs/0001-report-and-maintenance-boundaries.md) for detailed rationale behind the two-mode architecture.

## Project status

This is an early portfolio release. See [CHANGELOG.md](CHANGELOG.md), the [roadmap](docs/planning/ROADMAP.md), the [issue execution plan](docs/planning/ISSUES.md), [SECURITY.md](SECURITY.md), the [security audit](docs/security/SECURITY-AUDIT.md), and the [publication checklist](docs/planning/PUBLICATION_CHECKLIST.md).

For v1.0 requirements, see the [v1.0 acceptance criteria](docs/v1.0-acceptance.md).

Browse the [documentation index](docs/README.md), including the documented [first-publication workflow](docs/planning/FIRST_GITHUB_PUSH.md).

## Development checks

Install the quality tools and repository-owned pre-commit hook:

```fish
brew install actionlint shellcheck gitleaks
scripts/install-hooks
```

Every commit then runs Bash syntax validation, ShellCheck, GitHub Actions and plist validation, isolated smoke tests, staged whitespace checks, and Gitleaks. Run the suite manually with:

```fish
scripts/check --all
```

## License

MIT — see [LICENSE](LICENSE).
