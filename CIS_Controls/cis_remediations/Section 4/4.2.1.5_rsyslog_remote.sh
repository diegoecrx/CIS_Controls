#!/usr/bin/env bash
set -euo pipefail

# Goal: Configure rsyslog to send logs to a remote log host using a modern omfwd action.
# Filename: 4.2.1.5_rsyslog_remote.sh
# Applicability: Level 1 for both Server and Workstation
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

# Remote log host configuration (override with environment variables)
REMOTE_HOST=${REMOTE_HOST:-"loghost.example.com"}
REMOTE_PORT=${REMOTE_PORT:-514}
PROTOCOL=${PROTOCOL:-tcp}
RETRY_COUNT=${RETRY_COUNT:-5}
QUEUE_SIZE=${QUEUE_SIZE:-10000}

# Build the omfwd action line
ACTION_LINE="*.* action(type=\"omfwd\" target=\"${REMOTE_HOST}\" port=\"${REMOTE_PORT}\" protocol=\"${PROTOCOL}\" action.resumeRetryCount=\"${RETRY_COUNT}\" queue.type=\"LinkedList\" queue.size=\"${QUEUE_SIZE}\")"

update_rsyslog_file() {
  local file=$1
  [[ -f "$file" && ! -f "${file}.bak" ]] && cp "$file" "${file}.bak"
  grep -Fq "$ACTION_LINE" "$file" || echo "$ACTION_LINE" >> "$file"
}

main_conf="/etc/rsyslog.conf"
update_rsyslog_file "$main_conf"

for conf in /etc/rsyslog.d/*.conf; do
  [[ -f "$conf" ]] || continue
  update_rsyslog_file "$conf"
done

systemctl reload rsyslog 2>/dev/null || true

# Verification
if grep -Fq "$ACTION_LINE" "$main_conf"; then
  echo "OK: Remote rsyslog forwarding configured (CIS 4.2.1.5)."
  exit 0
else
  echo "FAIL: Remote rsyslog forwarding not configured in main config." >&2
  exit 1
fi