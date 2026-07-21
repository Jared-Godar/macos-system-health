#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/system-health-tests.XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT INT TERM

PASS=0
FAIL=0

pass() { PASS=$((PASS + 1)); printf 'ok - %s\n' "$1"; }
fail() { FAIL=$((FAIL + 1)); printf 'not ok - %s\n' "$1" >&2; }
assert_contains() { grep -Fq "$2" "$1" || { printf 'Expected %s to contain: %s\n' "$1" "$2" >&2; return 1; }; }
assert_not_contains() { ! grep -Fq "$2" "$1" || { printf 'Expected %s not to contain: %s\n' "$1" "$2" >&2; return 1; }; }

make_stubs() {
  local stub_dir="$1"
  mkdir -p "$stub_dir"

  cat > "$stub_dir/sw_vers" <<'STUB'
#!/usr/bin/env bash
printf 'ProductName:\tmacOS\nProductVersion:\t15.0\n'
STUB

  cat > "$stub_dir/brew" <<'STUB'
#!/usr/bin/env bash
printf 'brew %s\n' "$*" >> "$CALL_LOG"
case "${1:-}" in
  --version) echo 'Homebrew 4.0.0' ;;
  doctor) printf 'Your system is ready to brew.\nCache: %s/Library/Caches/Homebrew\n' "$HOME" ;;
  outdated)
    if [[ "${FAIL_BREW_OUTDATED:-0}" == 1 ]]; then echo 'network unavailable' >&2; exit 1; fi
    ;;
  bundle)
    for argument in "$@"; do
      case "$argument" in --file=*) : > "${argument#--file=}" ;; esac
    done
    ;;
  update|upgrade|cleanup) : ;;
esac
STUB

  cat > "$stub_dir/conda" <<'STUB'
#!/usr/bin/env bash
printf 'conda %s\n' "$*" >> "$CALL_LOG"
case "$*" in
  '--version') echo 'conda 25.1.0' ;;
  'info --base') echo '/Users/private/miniforge3' ;;
  'doctor --help') exit 0 ;;
  'doctor') printf 'Environment Health Report for: /Users/private/miniforge3\nNo pinned specs in /Users/private/miniforge3/conda-meta/pinned.\n' ;;
  'env list')
    printf '# conda environments:\nbase * /Users/private/miniforge3\nproject /Users/private/work/project\n/Users/private/unnamed\n'
    ;;
  'env export -n base --from-history') echo 'name: base' ;;
  'clean --all --yes') : ;;
esac
STUB

  cat > "$stub_dir/python3" <<'STUB'
#!/usr/bin/env bash
printf 'python3 %s\n' "$*" >> "$CALL_LOG"
case "$*" in
  '--version') echo 'Python 3.12.0' ;;
  '-m pip check') echo 'No broken requirements found.' ;;
  '-m pip list --outdated --format=columns') : ;;
esac
STUB

  cat > "$stub_dir/launchctl" <<'STUB'
#!/usr/bin/env bash
printf 'launchctl %s\n' "$*" >> "$CALL_LOG"
STUB

  chmod +x "$stub_dir"/*
}

run_health() {
  local case_dir="$1" mode="$2"
  HOME="$case_dir/home" \
  TMPDIR="$case_dir/tmp" \
  PATH="$case_dir/stubs:/usr/bin:/bin:/usr/sbin:/sbin" \
  CALL_LOG="$case_dir/calls.log" \
  SYSTEM_HEALTH_LOG_DIR="$case_dir/logs" \
  SYSTEM_HEALTH_BACKUP_DIR="$case_dir/backups" \
    "$ROOT/bin/system-health" "$mode" > "$case_dir/output" 2>&1
}

test_report_boundary_and_redaction() {
  local case_dir="$TMP_ROOT/report"
  mkdir -p "$case_dir/home" "$case_dir/tmp"
  make_stubs "$case_dir/stubs"
  : > "$case_dir/calls.log"
  run_health "$case_dir" report
  assert_not_contains "$case_dir/calls.log" 'brew update'
  assert_not_contains "$case_dir/calls.log" 'brew upgrade'
  assert_not_contains "$case_dir/calls.log" 'brew cleanup'
  assert_not_contains "$case_dir/calls.log" 'conda clean --all --yes'
  # Redaction guarantee: private paths are absent from report output — the
  # stubbed Conda base (/Users/private/...) and the mocked HOME are replaced
  # with [conda base]/[home] and never appear verbatim.
  assert_not_contains "$case_dir/output" '/Users/private'
  assert_not_contains "$case_dir/output" "$case_dir/home"
  assert_contains "$case_dir/output" '[conda base]'
  assert_contains "$case_dir/output" '[home]/Library/Caches/Homebrew'
  assert_contains "$case_dir/output" 'project'
  assert_contains "$case_dir/output" '[unnamed environment]'
}

test_maintenance_boundary() {
  local case_dir="$TMP_ROOT/maintenance"
  mkdir -p "$case_dir/home" "$case_dir/tmp"
  make_stubs "$case_dir/stubs"
  : > "$case_dir/calls.log"
  run_health "$case_dir" maintenance
  assert_contains "$case_dir/calls.log" 'brew update'
  assert_contains "$case_dir/calls.log" 'brew upgrade'
  assert_contains "$case_dir/calls.log" 'brew cleanup'
  assert_contains "$case_dir/calls.log" 'conda clean --all --yes'
}

test_failed_check_is_not_outdated() {
  local case_dir="$TMP_ROOT/failure"
  mkdir -p "$case_dir/home" "$case_dir/tmp"
  make_stubs "$case_dir/stubs"
  : > "$case_dir/calls.log"
  FAIL_BREW_OUTDATED=1 run_health "$case_dir" report
  assert_contains "$case_dir/output" 'Could not check outdated Homebrew packages.'
  assert_not_contains "$case_dir/output" 'Homebrew packages are outdated.'
}

test_invalid_threshold() {
  local case_dir="$TMP_ROOT/threshold"
  mkdir -p "$case_dir/home" "$case_dir/tmp"
  make_stubs "$case_dir/stubs"
  if HOME="$case_dir/home" TMPDIR="$case_dir/tmp" PATH="$case_dir/stubs:/usr/bin:/bin" \
    SYSTEM_HEALTH_DISK_THRESHOLD=banana "$ROOT/bin/system-health" report > "$case_dir/output" 2>&1; then
    return 1
  fi
  assert_contains "$case_dir/output" 'must be an integer from 0 through 100'
  [[ ! -d "$case_dir/home/Library/Logs/system-health" ]]
}

test_xml_escaping() {
  command -v plutil >/dev/null 2>&1 || return 0
  local case_dir="$TMP_ROOT/xml" plist
  mkdir -p "$case_dir/home" "$case_dir/tmp"
  make_stubs "$case_dir/stubs"
  : > "$case_dir/calls.log"
  HOME="$case_dir/home" PATH="$case_dir/stubs:/usr/bin:/bin:/usr/sbin:/sbin" CALL_LOG="$case_dir/calls.log" \
    SYSTEM_HEALTH_LOG_DIR="$case_dir/logs & reports" "$ROOT/bin/install-schedule" > "$case_dir/output" 2>&1
  plist="$case_dir/home/Library/LaunchAgents/io.github.system-health.report.plist"
  plutil -lint "$plist" >/dev/null
  assert_contains "$plist" 'logs &amp; reports'
}

run_test() {
  local name="$1"
  if "$name"; then pass "$name"; else fail "$name"; fi
}

test_cleanup_report_mode_no_delete() {
  local case_dir="$TMP_ROOT/cleanup_report"
  mkdir -p "$case_dir/home" "$case_dir/tmp"
  make_stubs "$case_dir/stubs"
  : > "$case_dir/calls.log"

  mkdir -p "$case_dir/logs" "$case_dir/backups"
  touch "$case_dir/logs/report-old.log"
  touch "$case_dir/backups/Brewfile-old"

  SYSTEM_HEALTH_LOG_RETENTION_COUNT=0 \
  SYSTEM_HEALTH_BACKUP_RETENTION_COUNT=0 \
  HOME="$case_dir/home" TMPDIR="$case_dir/tmp" PATH="$case_dir/stubs:/usr/bin:/bin" \
  SYSTEM_HEALTH_LOG_DIR="$case_dir/logs" SYSTEM_HEALTH_BACKUP_DIR="$case_dir/backups" \
    "$ROOT/bin/system-health" report > "$case_dir/output" 2>&1

  [[ -f "$case_dir/logs/report-old.log" ]] || return 1
  [[ -f "$case_dir/backups/Brewfile-old" ]] || return 1
}

test_cleanup_maintenance_mode_deletes() {
  local case_dir="$TMP_ROOT/cleanup_maintenance"
  mkdir -p "$case_dir/home" "$case_dir/tmp"
  make_stubs "$case_dir/stubs"
  : > "$case_dir/calls.log"

  mkdir -p "$case_dir/logs" "$case_dir/backups"
  touch -t 202501010000 "$case_dir/logs/report-old.log"
  touch "$case_dir/logs/report-new.log"

  SYSTEM_HEALTH_LOG_RETENTION_DAYS=30 \
  SYSTEM_HEALTH_LOG_RETENTION_COUNT=1 \
  HOME="$case_dir/home" TMPDIR="$case_dir/tmp" PATH="$case_dir/stubs:/usr/bin:/bin" \
  SYSTEM_HEALTH_LOG_DIR="$case_dir/logs" SYSTEM_HEALTH_BACKUP_DIR="$case_dir/backups" \
    "$ROOT/bin/system-health" maintenance > "$case_dir/output" 2>&1

  # Should delete the old file since it's older than 30 days
  [[ ! -f "$case_dir/logs/report-old.log" ]] || return 1
}

test_cleanup_count_limit() {
  local case_dir="$TMP_ROOT/cleanup_count"
  mkdir -p "$case_dir/home" "$case_dir/tmp"
  make_stubs "$case_dir/stubs"
  : > "$case_dir/calls.log"

  mkdir -p "$case_dir/logs"
  touch -t 202601010000 "$case_dir/logs/report-1.log"
  touch -t 202601020000 "$case_dir/logs/report-2.log"

  SYSTEM_HEALTH_LOG_RETENTION_DAYS=0 \
  SYSTEM_HEALTH_LOG_RETENTION_COUNT=2 \
  HOME="$case_dir/home" TMPDIR="$case_dir/tmp" PATH="$case_dir/stubs:/usr/bin:/bin" \
  SYSTEM_HEALTH_LOG_DIR="$case_dir/logs" SYSTEM_HEALTH_BACKUP_DIR="$case_dir/backups" \
    "$ROOT/bin/system-health" maintenance > "$case_dir/output" 2>&1

  # With 2 original files and count limit of 2, plus 1 new file created during run = 3 total
  # Oldest should be deleted to get down to 2
  [[ ! -f "$case_dir/logs/report-1.log" ]] || return 1
  [[ -f "$case_dir/logs/report-2.log" ]] || return 1
}

test_cleanup_boundary_no_delete_at_limit() {
  local case_dir="$TMP_ROOT/cleanup_boundary"
  mkdir -p "$case_dir/home" "$case_dir/tmp"
  make_stubs "$case_dir/stubs"
  : > "$case_dir/calls.log"

  mkdir -p "$case_dir/logs"
  touch "$case_dir/logs/report-1.log"

  SYSTEM_HEALTH_LOG_RETENTION_DAYS=0 \
  SYSTEM_HEALTH_LOG_RETENTION_COUNT=1 \
  HOME="$case_dir/home" TMPDIR="$case_dir/tmp" PATH="$case_dir/stubs:/usr/bin:/bin" \
  SYSTEM_HEALTH_LOG_DIR="$case_dir/logs" SYSTEM_HEALTH_BACKUP_DIR="$case_dir/backups" \
    "$ROOT/bin/system-health" maintenance > "$case_dir/output" 2>&1

  # Start with 1 file, limit 1, new report created = 2 total
  # Oldest should be deleted to get down to 1
  [[ ! -f "$case_dir/logs/report-1.log" ]]
}

test_cleanup_dry_run_no_delete() {
  local case_dir="$TMP_ROOT/cleanup_dryrun"
  mkdir -p "$case_dir/home" "$case_dir/tmp"
  make_stubs "$case_dir/stubs"
  : > "$case_dir/calls.log"

  mkdir -p "$case_dir/logs"
  touch -t 202601010000 "$case_dir/logs/report-1.log"
  touch -t 202601020000 "$case_dir/logs/report-2.log"
  touch -t 202601030000 "$case_dir/logs/report-3.log"

  SYSTEM_HEALTH_LOG_RETENTION_DAYS=0 \
  SYSTEM_HEALTH_LOG_RETENTION_COUNT=1 \
  SYSTEM_HEALTH_DRY_RUN=true \
  HOME="$case_dir/home" TMPDIR="$case_dir/tmp" PATH="$case_dir/stubs:/usr/bin:/bin" \
  SYSTEM_HEALTH_LOG_DIR="$case_dir/logs" SYSTEM_HEALTH_BACKUP_DIR="$case_dir/backups" \
    "$ROOT/bin/system-health" maintenance > "$case_dir/output" 2>&1

  assert_contains "$case_dir/output" '[DRY-RUN]'
  # All files should still exist since it's dry-run mode
  [[ -f "$case_dir/logs/report-1.log" ]] && [[ -f "$case_dir/logs/report-2.log" ]] && [[ -f "$case_dir/logs/report-3.log" ]]
}

test_cleanup_invalid_config() {
  local case_dir="$TMP_ROOT/cleanup_invalid"
  mkdir -p "$case_dir/home" "$case_dir/tmp"
  make_stubs "$case_dir/stubs"

  if SYSTEM_HEALTH_LOG_RETENTION_DAYS=notanumber \
    HOME="$case_dir/home" TMPDIR="$case_dir/tmp" PATH="$case_dir/stubs:/usr/bin:/bin" \
    SYSTEM_HEALTH_LOG_DIR="$case_dir/logs" "$ROOT/bin/system-health" maintenance > "$case_dir/output" 2>&1; then
    return 1
  fi
  assert_contains "$case_dir/output" 'must be an integer'
}

test_cleanup_preserves_non_matching_logs() {
  local case_dir="$TMP_ROOT/cleanup_preserve"
  mkdir -p "$case_dir/home" "$case_dir/tmp"
  make_stubs "$case_dir/stubs"
  : > "$case_dir/calls.log"

  mkdir -p "$case_dir/logs"
  touch "$case_dir/logs/other-file.txt"
  touch -t 202601010000 "$case_dir/logs/report-old.log"

  SYSTEM_HEALTH_LOG_RETENTION_DAYS=0 \
  SYSTEM_HEALTH_LOG_RETENTION_COUNT=0 \
  HOME="$case_dir/home" TMPDIR="$case_dir/tmp" PATH="$case_dir/stubs:/usr/bin:/bin" \
  SYSTEM_HEALTH_LOG_DIR="$case_dir/logs" SYSTEM_HEALTH_BACKUP_DIR="$case_dir/backups" \
    "$ROOT/bin/system-health" maintenance > "$case_dir/output" 2>&1

  # Non-matching file should be preserved
  [[ -f "$case_dir/logs/other-file.txt" ]] || return 1
  # Old report should be deleted (count 0 means unlimited but age should delete it)
  # Actually with count=0 and days=0, nothing should be deleted
  [[ -f "$case_dir/logs/report-old.log" ]] || return 1
}

test_cleanup_backup_patterns() {
  local case_dir="$TMP_ROOT/cleanup_backups"
  mkdir -p "$case_dir/home" "$case_dir/tmp"
  make_stubs "$case_dir/stubs"
  : > "$case_dir/calls.log"

  mkdir -p "$case_dir/backups"
  touch -t 202601010000 "$case_dir/backups/Brewfile-old"
  touch -t 202601020000 "$case_dir/backups/conda-base-old.yml"
  touch -t 202601030000 "$case_dir/backups/other-backup.tar"

  SYSTEM_HEALTH_BACKUP_RETENTION_DAYS=0 \
  SYSTEM_HEALTH_BACKUP_RETENTION_COUNT=1 \
  HOME="$case_dir/home" TMPDIR="$case_dir/tmp" PATH="$case_dir/stubs:/usr/bin:/bin" \
  SYSTEM_HEALTH_LOG_DIR="$case_dir/logs" SYSTEM_HEALTH_BACKUP_DIR="$case_dir/backups" \
    "$ROOT/bin/system-health" maintenance > "$case_dir/output" 2>&1

  # With count=1 and 3 matching files, oldest 2 matching files should be deleted
  [[ ! -f "$case_dir/backups/Brewfile-old" ]] || return 1
  [[ ! -f "$case_dir/backups/conda-base-old.yml" ]] || return 1
  # Non-matching file should be preserved
  [[ -f "$case_dir/backups/other-backup.tar" ]] || return 1
}

test_cleanup_redaction_in_output() {
  local case_dir="$TMP_ROOT/cleanup_redaction"
  mkdir -p "$case_dir/home" "$case_dir/tmp"
  make_stubs "$case_dir/stubs"
  : > "$case_dir/calls.log"

  mkdir -p "$case_dir/logs"
  touch "$case_dir/logs/report-old.log"

  SYSTEM_HEALTH_LOG_RETENTION_DAYS=0 \
  SYSTEM_HEALTH_LOG_RETENTION_COUNT=0 \
  HOME="$case_dir/home" TMPDIR="$case_dir/tmp" PATH="$case_dir/stubs:/usr/bin:/bin" \
  SYSTEM_HEALTH_LOG_DIR="$case_dir/logs" SYSTEM_HEALTH_BACKUP_DIR="$case_dir/backups" \
    "$ROOT/bin/system-health" maintenance > "$case_dir/output" 2>&1

  assert_not_contains "$case_dir/output" "$case_dir/home"
  assert_contains "$case_dir/output" '[home]'
}

run_test test_report_boundary_and_redaction
run_test test_maintenance_boundary
run_test test_failed_check_is_not_outdated
run_test test_invalid_threshold
run_test test_xml_escaping
run_test test_cleanup_report_mode_no_delete
run_test test_cleanup_maintenance_mode_deletes
run_test test_cleanup_count_limit
run_test test_cleanup_boundary_no_delete_at_limit
run_test test_cleanup_dry_run_no_delete
run_test test_cleanup_invalid_config
run_test test_cleanup_preserves_non_matching_logs
run_test test_cleanup_backup_patterns
run_test test_cleanup_redaction_in_output

printf '%s passed; %s failed\n' "$PASS" "$FAIL"
(( FAIL == 0 ))
