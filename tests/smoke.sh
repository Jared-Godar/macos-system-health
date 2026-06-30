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

test_report_boundary() {
  local case_dir="$TMP_ROOT/report"
  mkdir -p "$case_dir/home" "$case_dir/tmp"
  make_stubs "$case_dir/stubs"
  : > "$case_dir/calls.log"
  run_health "$case_dir" report
  assert_not_contains "$case_dir/calls.log" 'brew update'
  assert_not_contains "$case_dir/calls.log" 'brew upgrade'
  assert_not_contains "$case_dir/calls.log" 'brew cleanup'
  assert_not_contains "$case_dir/calls.log" 'conda clean --all --yes'
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

run_test test_report_boundary
run_test test_maintenance_boundary
run_test test_failed_check_is_not_outdated
run_test test_invalid_threshold
run_test test_xml_escaping

printf '%s passed; %s failed\n' "$PASS" "$FAIL"
(( FAIL == 0 ))
