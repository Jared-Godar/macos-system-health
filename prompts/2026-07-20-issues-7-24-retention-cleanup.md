# Issues #7 + #24: Log & Backup Snapshot Retention with Dry-Run

**Tracking issues:** #7, #24
**Branch:** feature/retention-and-cleanup
**Milestone:** v1.0

---

## What This Does

Implements configurable retention and cleanup for:
- System-health logs in `$LOG_DIR` (age/count-based removal)
- Backup snapshots (`Brewfile-*`, `conda-base-*.yml`) in `$BACKUP_DIR`
- Dry-run mode for maintenance actions (preview mutations safely before execution)

Solves two v1.0 issues in one cohesive PR: users stop accumulating unbounded disk usage from time-series data.

---

## Requirements

### Functional

1. **Log Retention (Issue #7):**
   - Add configurable retention policy: `SYSTEM_HEALTH_LOG_RETENTION_DAYS` (integer, default 30)
   - Add configurable retention policy: `SYSTEM_HEALTH_LOG_RETENTION_COUNT` (integer, default 100; 0 = unlimited)
   - Apply **both** (cleanup if **either** limit exceeded): oldest-first removal
   - Only remove logs matching pattern `report-*.log` (preserve other files)
   - Log the cleanup action to current report

2. **Backup Snapshot Retention (Issue #24):**
   - Add configurable retention policy: `SYSTEM_HEALTH_BACKUP_RETENTION_DAYS` (integer, default 30)
   - Add configurable retention policy: `SYSTEM_HEALTH_BACKUP_RETENTION_COUNT` (integer, default 50; 0 = unlimited)
   - Apply **both** (cleanup if **either** limit exceeded): oldest-first removal
   - Remove only `Brewfile-*` and `conda-base-*.yml` files (preserve other backups)
   - Log the cleanup action to current report

3. **Dry-Run Mode (Issue #7):**
   - Add `SYSTEM_HEALTH_DRY_RUN` env var (boolean; default false)
   - When set, **print all mutations** that would happen (logs/backups to delete) but **do not execute** them
   - Include in dry-run output:
     - Files to be deleted with timestamps/sizes
     - Retention policy that triggered removal
   - Dry-run **blocks actual cleanup** but **does not block report generation**
   - Dry-run output goes to stdout and to report (prefixed `[DRY-RUN]`)

4. **Maintenance Mode Only:**
   - Log and backup cleanup only runs when `MODE=maintenance`
   - Report mode never deletes anything
   - Dry-run can be used with either mode (useful for previewing before switching to maintenance)

### Testing

1. **Smoke test coverage** (`tests/smoke.sh`):
   - Default retention: report mode does not delete; maintenance mode cleans up
   - Explicit retention counts: cleanup respects `_COUNT` limit (delete oldest when N+1 files exist)
   - Explicit retention days: cleanup respects `_DAYS` limit (delete older than threshold)
   - Dry-run with cleanup: prints what would be deleted but does not delete
   - Invalid config: non-numeric `_RETENTION_*` values fail before cleanup runs
   - Boundary: exactly N files with retention count=N does not delete anything
   - Boundary: file exactly at age threshold (e.g., created 30 days ago at midnight) is handled consistently (document choice: delete or keep)

2. **No regressions:**
   - All existing report/maintenance tests still pass
   - Redaction guarantee: cleanup output never leaks home directory
   - Lock file: cleanup respects existing lock (another run in progress)

### Changelog

Add to `[Unreleased] ### Added` section:
- Log retention: configurable age/count-based cleanup via `SYSTEM_HEALTH_LOG_RETENTION_*` environment variables (#7).
- Backup snapshot retention: configurable age/count-based cleanup for `Brewfile-*` and `conda-base-*.yml` via `SYSTEM_HEALTH_BACKUP_RETENTION_*` (#24).
- Maintenance mode: dry-run preview via `SYSTEM_HEALTH_DRY_RUN` to safely preview mutations before execution (#7).

---

## Implementation Checklist

- [ ] **Create `lib/cleanup.sh`** (or integrate into main):
  - `cleanup_logs()` — parse `LOG_DIR`, apply retention policy, report deletions
  - `cleanup_backups()` — parse `BACKUP_DIR`, apply retention policy, report deletions
  - `should_cleanup_file()` — age/count logic for a single file
  - `report_cleanup_action()` — format for stdout and report logging

- [ ] **Integrate into `bin/system-health` maintenance mode:**
  - After checks complete, before exiting maintenance mode, call cleanup functions
  - Pass dry-run flag through call chain
  - Preserve all existing report/maintenance behavior

- [ ] **Configuration validation:**
  - Reject non-numeric `SYSTEM_HEALTH_*_RETENTION_*` values before any cleanup
  - Set sensible defaults (30 days, 100 logs, 50 backups)
  - Document defaults in help output

- [ ] **Dry-run mode:**
  - When enabled, collect deletion list but do not execute `rm`
  - Print planned deletions to stdout (format: `[DRY-RUN] Would delete: <file> (<age>d, <size>)`)
  - Append dry-run summary to report
  - Exit with success (do not treat planned deletions as errors)

- [ ] **Testing:**
  - Add 6–8 new test cases to `tests/smoke.sh` (see Testing section above)
  - Verify redaction in cleanup output
  - Verify lock file interaction

- [ ] **CONTRIBUTING.md update (if needed):**
  - Mention new environment variables in prerequisites or examples

---

## Branch & Workflow

1. **Branch:** `feature/retention-and-cleanup`
2. **Commits:** Small, focused commits per logical unit (cleanup logic, dry-run, tests)
3. **Pre-push:** `scripts/check --all` passes
4. **PR template:** Link issues (#7, #24), confirm tests pass, reference dry-run verification steps
5. **Labels:** `area:script`, `type:enhancement`
6. **Milestone:** `v1.0`

---

## Verification Checklist (for PR)

- [ ] Logs older than 30 days are removed in maintenance mode
- [ ] Fewer than 100 logs are kept if count limit is exceeded
- [ ] Backups older than 30 days are removed in maintenance mode
- [ ] Report mode never deletes logs or backups
- [ ] Dry-run prints planned deletions and does not delete
- [ ] Invalid config (non-numeric retention values) fails fast with clear error
- [ ] Redaction guarantee: no home directory paths in cleanup output
- [ ] All existing smoke tests still pass
- [ ] CHANGELOG.md updated in this PR

---

## Notes

- **Age calculation:** Use `stat` or similar; be consistent with timestamp format (e.g., seconds since epoch)
- **Deletions order:** Always oldest first (predictable, safe)
- **Both limits apply:** If either age or count is exceeded, cleanup runs (logical OR)
- **Output redaction:** Cleanup output must strip home directory from file paths before printing (existing `redact_stream()` function in main script)
- **No external dependencies:** Use only shell builtins + standard macOS utilities (`stat`, `find`, `rm`)

---

## Links

- Issue #7: https://github.com/Jared-Godar/macos-system-health/issues/7
- Issue #24: https://github.com/Jared-Godar/macos-system-health/issues/24
- Milestone v1.0: https://github.com/Jared-Godar/macos-system-health/milestone/1

---

**Executor:** Use this as your detailed spec. Read it fully before starting. All verification steps must pass locally before opening the PR.
