#!/usr/bin/env bash
set -euo pipefail

# Goal: Configure journald to forward logs to rsyslog.
# Filename: 4.2.2.1_journald_forward.sh
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

# Remove any existing ForwardToSyslog setting and set to yes
if grep -q '^\s*ForwardToSyslog' "$conf_file"; then
  sed -i 's/^\s*ForwardToSyslog\s*=.*/ForwardToSyslog=yes/' "$conf_file"
else
  echo 'ForwardToSyslog=yes' >> "$conf_file"
fi

systemctl restart systemd-journald 2>/dev/null || true

# Verification
if grep -q '^\s*ForwardToSyslog\s*=\s*yes' "$conf_file"; then
  echo "OK: journald configured to forward to syslog (CIS 4.2.2.1)."
  exit 0
else
  echo "FAIL: journald not forwarding to syslog." >&2
  exit 1
fi