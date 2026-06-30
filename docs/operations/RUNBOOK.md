# Operations runbook

## Install

```bash
chmod +x bin/system-health bin/install-schedule
bin/system-health report
```

Confirm the report contains no unexpected private data before enabling email or scheduling.

## Routine operation

Run `bin/system-health report` for a health snapshot. Exit code `0` means no hard failure; warnings are summarized in the report. Run `bin/system-health maintenance` only after reviewing outdated packages and when you have time to test affected tools.

## Schedule and verify

```bash
bin/install-schedule
launchctl print "gui/$UID/io.github.system-health.report"
tail -n 100 "$HOME/Library/Logs/system-health/scheduler.log"
```

To trigger a scheduled run immediately:

```bash
launchctl kickstart -k "gui/$UID/io.github.system-health.report"
```

## Remove the schedule

```bash
launchctl bootout "gui/$UID/io.github.system-health.report"
rm "$HOME/Library/LaunchAgents/io.github.system-health.report.plist"
```

## Failure recovery

- `Another system-health run appears active`: verify no run is active, then remove the stale directory under `${TMPDIR:-/tmp}/system-health-$UID.lock`.
- Homebrew failure: run `brew doctor`, resolve actionable warnings, then retry report mode.
- Conda inconsistency: restore or recreate the affected environment; do not use pip to replace Conda-managed base packages.
- Email failure: run `msmtp` interactively with a test message and inspect its local configuration. Never paste credentials into logs or issues.
- Low disk space: inspect large files before cleanup. The script does not delete user data.

## Backups and rollback

The backup directory contains timestamped Brewfiles and minimal Conda base definitions. Before maintenance, make a normal system backup. Homebrew upgrades are not automatically rolled back; use package-specific pinning or reinstall a known version when supported.

## Incident evidence

When opening an issue, share only redacted output. Logs can contain installed package names and environment names even though this project avoids usernames, serial numbers, and absolute environment paths.
