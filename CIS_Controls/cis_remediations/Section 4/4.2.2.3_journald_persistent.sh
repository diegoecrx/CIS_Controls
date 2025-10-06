#!/usr/bin/env bash
set -euo pipefail

# Goal: Configure journald to write log files to persistent disk storage.
# Filename: 4.2.2.3_journald_persistent.sh
# Applicability: Level 1 for both Server and Workstation
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

conf_file="/etc/systemd/journald.conf"
[[ -f "$conf_file" && ! -f "${conf_file}.bak" ]] && cp "$conf_file" "${conf_file}.bak"

if grep -q '^\s*Storage' "$conf_file"; then
  sed -i 's/^\s*Storage\s*=.*/Storage=persistent/' "$conf_file"
else
  echo 'Storage=persistent' >> "$conf_file"
fi

systemctl restart systemd-journald 2>/dev/null || true

# Verification
if grep -q '^\s*Storage\s*=\s*persistent' "$conf_file"; then
  echo "OK: journald persistent storage enabled (CIS 4.2.2.3)."
  exit 0
else
  echo "FAIL: journald persistent storage not enabled." >&2
  exit 1
fi