#!/usr/bin/env bash
set -euo pipefail

# Goal: Ensure the rsyslog service is enabled and running.
# Filename: 4.2.1.2_rsyslog_service.sh
# Applicability: Level 1 for both Server and Workstation
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

if systemctl list-unit-files | grep -q '^rsyslog.service'; then
  systemctl enable --now rsyslog >/dev/null 2>&1 || true
else
  echo "ERROR: rsyslog service file not found" >&2
fi

if systemctl is-enabled rsyslog >/dev/null 2>&1 && systemctl is-active rsyslog >/dev/null 2>&1; then
  echo "OK: rsyslog service is enabled and running (CIS 4.2.1.2)."
  exit 0
else
  echo "FAIL: rsyslog service is not enabled and running." >&2
  exit 1
fi