#!/usr/bin/env bash
set -euo pipefail

# Goal: Ensure remote rsyslog messages are only accepted on designated log hosts by toggling TCP server lines.
# Filename: 4.2.1.6_rsyslog_remote_accept.sh
# Applicability: Level 1 for both Server and Workstation (manual determination)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

# Environment variable to indicate if this system is a log host (1=yes, 0=no)
IS_LOG_HOST=${IS_LOG_HOST:-0}

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

conf_file="/etc/rsyslog.conf"
[[ -f "$conf_file" && ! -f "${conf_file}.bak" ]] && cp "$conf_file" "${conf_file}.bak"

enable_line() {
  local pattern=$1
  if grep -q "^#\s*$pattern" "$conf_file"; then
    sed -i "s/^#\s*\($pattern\)/\1/" "$conf_file"
  elif ! grep -q "^$pattern" "$conf_file"; then
    echo "$pattern" >> "$conf_file"
  fi
}

disable_line() {
  local pattern=$1
  if grep -q "^$pattern" "$conf_file"; then
    sed -i "s/^$pattern/# $pattern/" "$conf_file"
  fi
}

if [[ "$IS_LOG_HOST" -eq 1 ]]; then
  # Ensure TCP server lines are enabled
  enable_line '$ModLoad imtcp'
  enable_line '$InputTCPServerRun 514'
else
  # Ensure TCP server lines are disabled/commented
  disable_line '$ModLoad imtcp'
  disable_line '$InputTCPServerRun 514'
fi

systemctl restart rsyslog 2>/dev/null || true

# Verification
if [[ "$IS_LOG_HOST" -eq 1 ]]; then
  if grep -q '^\$ModLoad imtcp' "$conf_file" && grep -q '^\$InputTCPServerRun 514' "$conf_file"; then
    echo "OK: rsyslog configured as log host (CIS 4.2.1.6)."
    exit 0
  else
    echo "FAIL: rsyslog TCP server lines not enabled on designated log host." >&2
    exit 1
  fi
else
  if ! grep -q '^\$ModLoad imtcp' "$conf_file" && ! grep -q '^\$InputTCPServerRun 514' "$conf_file"; then
    echo "OK: rsyslog not accepting remote messages (CIS 4.2.1.6)."
    exit 0
  else
    echo "FAIL: rsyslog still configured to accept remote messages on non-log host." >&2
    exit 1
  fi
fi