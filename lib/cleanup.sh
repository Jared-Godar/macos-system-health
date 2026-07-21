#!/usr/bin/env bash

# Log and backup cleanup library for system-health.
# Exports: cleanup_logs, cleanup_backups, validate_cleanup_config

validate_cleanup_config() {
  local log_days log_count backup_days backup_count
  log_days="${SYSTEM_HEALTH_LOG_RETENTION_DAYS:-30}"
  log_count="${SYSTEM_HEALTH_LOG_RETENTION_COUNT:-100}"
  backup_days="${SYSTEM_HEALTH_BACKUP_RETENTION_DAYS:-30}"
  backup_count="${SYSTEM_HEALTH_BACKUP_RETENTION_COUNT:-50}"

  if ! [[ "$log_days" =~ ^[0-9]+$ ]]; then
    echo "SYSTEM_HEALTH_LOG_RETENTION_DAYS must be an integer." >&2
    return 1
  fi
  if ! [[ "$log_count" =~ ^[0-9]+$ ]]; then
    echo "SYSTEM_HEALTH_LOG_RETENTION_COUNT must be an integer." >&2
    return 1
  fi
  if ! [[ "$backup_days" =~ ^[0-9]+$ ]]; then
    echo "SYSTEM_HEALTH_BACKUP_RETENTION_DAYS must be an integer." >&2
    return 1
  fi
  if ! [[ "$backup_count" =~ ^[0-9]+$ ]]; then
    echo "SYSTEM_HEALTH_BACKUP_RETENTION_COUNT must be an integer." >&2
    return 1
  fi
  return 0
}

file_age_days() {
  local file="$1"
  local now mtime age_seconds age_days
  now=$(date +%s)
  mtime=$(stat -f%m "$file" 2>/dev/null) || return 1
  age_seconds=$((now - mtime))
  age_days=$((age_seconds / 86400))
  echo "$age_days"
}

file_size_bytes() {
  local file="$1"
  stat -f%z "$file" 2>/dev/null
}

format_bytes() {
  local bytes="$1"
  if (( bytes < 1024 )); then
    echo "${bytes}B"
  elif (( bytes < 1024 * 1024 )); then
    echo "$((bytes / 1024))KB"
  else
    echo "$((bytes / 1024 / 1024))MB"
  fi
}

cleanup_logs() {
  local log_dir="$1" dry_run="${2:-0}" log_func="${3:-log}"
  local log_days log_count now_time cutoff_time count cleanup_reason
  local tmpfile i file mtime

  log_days="${SYSTEM_HEALTH_LOG_RETENTION_DAYS:-30}"
  log_count="${SYSTEM_HEALTH_LOG_RETENTION_COUNT:-100}"

  if ! [[ -d "$log_dir" ]]; then
    return 0
  fi

  now_time=$(date +%s)
  cutoff_time=$((now_time - (log_days * 86400)))

  tmpfile=$(mktemp) || return 1
  trap 'rm -f "$tmpfile"' RETURN

  # Build sorted list of files
  find "$log_dir" -maxdepth 1 -name 'report-*.log' -type f -print0 |
    while IFS= read -r -d '' file; do
      mtime=$(stat -f%m "$file" 2>/dev/null) || continue
      printf '%s %s\n' "$mtime" "$file"
    done | sort -n | cut -d' ' -f2- > "$tmpfile"

  count=0
  while IFS= read -r _; do
    count=$((count + 1))
  done < "$tmpfile"

  cleanup_reason=""

  if (( log_count > 0 && count > log_count )); then
    cleanup_reason="count limit ($log_count)"
  fi

  if (( log_days > 0 )) && [[ -z "$cleanup_reason" ]]; then
    while IFS= read -r file; do
      mtime=$(stat -f%m "$file" 2>/dev/null) || continue
      if (( mtime < cutoff_time )); then
        cleanup_reason="age limit ($log_days days)"
        break
      fi
    done < "$tmpfile"
  fi

  if [[ -z "$cleanup_reason" ]]; then
    return 0
  fi

  i=0
  while IFS= read -r file; do
    local should_delete=0
    local age size size_fmt

    # Delete if exceeding count limit (oldest files first)
    if (( log_count > 0 && count > log_count && i < count - log_count )); then
      should_delete=1
    fi

    # Also delete if exceeding age limit (but only if count limit didn't already mark for deletion)
    if (( log_days > 0 && should_delete == 0 )); then
      mtime=$(stat -f%m "$file" 2>/dev/null) || continue
      if (( mtime < cutoff_time )); then
        should_delete=1
      fi
    fi

    if (( should_delete )); then
      age=$(file_age_days "$file") || age="unknown"
      size=$(file_size_bytes "$file") || size=0
      size_fmt=$(format_bytes "$size")

      local msg="[cleanup] Would delete: $file ($age days old, $size_fmt)"
      if (( dry_run )); then
        "$log_func" "[DRY-RUN] $msg"
      else
        rm -f "$file"
        "$log_func" "$msg"
      fi
    fi
    i=$((i + 1))
  done < "$tmpfile"
}

cleanup_backups() {
  local backup_dir="$1" dry_run="${2:-0}" log_func="${3:-log}"
  local backup_days backup_count now_time cutoff_time count cleanup_reason
  local tmpfile i file mtime

  backup_days="${SYSTEM_HEALTH_BACKUP_RETENTION_DAYS:-30}"
  backup_count="${SYSTEM_HEALTH_BACKUP_RETENTION_COUNT:-50}"

  if ! [[ -d "$backup_dir" ]]; then
    return 0
  fi

  now_time=$(date +%s)
  cutoff_time=$((now_time - (backup_days * 86400)))

  tmpfile=$(mktemp) || return 1
  trap 'rm -f "$tmpfile"' RETURN

  # Build sorted list of files
  find "$backup_dir" -maxdepth 1 \( -name 'Brewfile-*' -o -name 'conda-base-*.yml' \) -type f -print0 |
    while IFS= read -r -d '' file; do
      mtime=$(stat -f%m "$file" 2>/dev/null) || continue
      printf '%s %s\n' "$mtime" "$file"
    done | sort -n | cut -d' ' -f2- > "$tmpfile"

  count=0
  while IFS= read -r _; do
    count=$((count + 1))
  done < "$tmpfile"

  cleanup_reason=""

  if (( backup_count > 0 && count > backup_count )); then
    cleanup_reason="count limit ($backup_count)"
  fi

  if (( backup_days > 0 )) && [[ -z "$cleanup_reason" ]]; then
    while IFS= read -r file; do
      mtime=$(stat -f%m "$file" 2>/dev/null) || continue
      if (( mtime < cutoff_time )); then
        cleanup_reason="age limit ($backup_days days)"
        break
      fi
    done < "$tmpfile"
  fi

  if [[ -z "$cleanup_reason" ]]; then
    return 0
  fi

  i=0
  while IFS= read -r file; do
    local should_delete=0
    local age size size_fmt

    # Delete if exceeding count limit (oldest files first)
    if (( backup_count > 0 && count > backup_count && i < count - backup_count )); then
      should_delete=1
    fi

    # Also delete if exceeding age limit (but only if count limit didn't already mark for deletion)
    if (( backup_days > 0 && should_delete == 0 )); then
      mtime=$(stat -f%m "$file" 2>/dev/null) || continue
      if (( mtime < cutoff_time )); then
        should_delete=1
      fi
    fi

    if (( should_delete )); then
      age=$(file_age_days "$file") || age="unknown"
      size=$(file_size_bytes "$file") || size=0
      size_fmt=$(format_bytes "$size")

      local msg="[cleanup] Would delete: $file ($age days old, $size_fmt)"
      if (( dry_run )); then
        "$log_func" "[DRY-RUN] $msg"
      else
        rm -f "$file"
        "$log_func" "$msg"
      fi
    fi
    i=$((i + 1))
  done < "$tmpfile"
}
