#!/usr/bin/env bash
set -euo pipefail

# Goal: Configure auditd not to automatically delete logs when they are full.
# Filename: 4.1.2.2_audit_log_keep.sh
# Applicability: Level 2 for both Server and Workstation
APPLIES_L1=0
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

conf_file="/etc/audit/auditd.conf"
# Backup original configuration if not already backed up
if [[ -f "$conf_file" && ! -f "${conf_file}.bak" ]]; then
  cp "$conf_file" "${conf_file}.bak"
fi

# Ensure logs are not automatically deleted
if grep -q '^\s*max_log_file_action\s*=' "$conf_file"; then
  sed -i 's/^\s*max_log_file_action\s*=.*/max_log_file_action = keep_logs/' "$conf_file"
else
  echo 'max_log_file_action = keep_logs' >> "$conf_file"
fi

# Verification
if grep -q '^\s*max_log_file_action\s*=\s*keep_logs' "$conf_file"; then
  echo "OK: max_log_file_action configured to keep_logs (CIS 4.1.2.2)."
  exit 0
else
  echo "FAIL: max_log_file_action not set to keep_logs." >&2
  exit 1
fi