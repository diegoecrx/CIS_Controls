#!/usr/bin/env bash
set -euo pipefail

# Goal: Configure journald to compress large log files.
# Filename: 4.2.2.2_journald_compress.sh
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

if grep -q '^\s*Compress' "$conf_file"; then
  sed -i 's/^\s*Compress\s*=.*/Compress=yes/' "$conf_file"
else
  echo 'Compress=yes' >> "$conf_file"
fi

systemctl restart systemd-journald 2>/dev/null || true

# Verification
if grep -q '^\s*Compress\s*=\s*yes' "$conf_file"; then
  echo "OK: journald compression enabled (CIS 4.2.2.2)."
  exit 0
else
  echo "FAIL: journald compression not enabled." >&2
  exit 1
fi