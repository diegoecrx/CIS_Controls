#!/usr/bin/env bash
set -euo pipefail

# Goal: Configure the maximum size of the audit log file to a site‑appropriate value.
# Filename: 4.1.2.1_audit_log_size.sh
# Applicability: Level 2 for both Server and Workstation
APPLIES_L1=0
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

# Desired size in megabytes for audit logs; adjust to site policy (default 8MB)
MAX_LOG_SIZE=${MAX_LOG_SIZE:-8}

conf_file="/etc/audit/auditd.conf"
# Backup original configuration if not already backed up
if [[ -f "$conf_file" && ! -f "${conf_file}.bak" ]]; then
  cp "$conf_file" "${conf_file}.bak"
fi

# Update or add the max_log_file directive
if grep -q '^\s*max_log_file\s*=' "$conf_file"; then
  sed -i "s/^\s*max_log_file\s*=.*/max_log_file = ${MAX_LOG_SIZE}/" "$conf_file"
else
  echo "max_log_file = ${MAX_LOG_SIZE}" >> "$conf_file"
fi

# Verification: confirm the configuration value
configured=$(grep -E '^\s*max_log_file\s*=' "$conf_file" | awk -F'=' '{gsub(/ /,""); print $2}')
if [[ "$configured" == "$MAX_LOG_SIZE" ]]; then
  echo "OK: max_log_file set to $configured MB (CIS 4.1.2.1)."
  exit 0
else
  echo "FAIL: max_log_file not correctly configured (expected $MAX_LOG_SIZE)." >&2
  exit 1
fi