#!/usr/bin/env bash
set -euo pipefail

# Goal: Ensure the audit daemon service (auditd) is enabled and running.
# Filename: 4.1.1.2_auditd_service.sh
# Applicability: Level 2 for both Server and Workstation
APPLIES_L1=0
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

# Root check
if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

# Enable and start the auditd service if available
FAIL=0
if systemctl list-unit-files | grep -q '^auditd.service'; then
  # Create backups of unit override if necessary (not required here)
  systemctl enable --now auditd >/dev/null 2>&1 || FAIL=1
else
  echo "ERROR: auditd service file not found" >&2
  FAIL=1
fi

# Verification: check enabled and active status
if systemctl is-enabled auditd >/dev/null 2>&1 && systemctl is-active auditd >/dev/null 2>&1; then
  echo "OK: auditd service is enabled and running (CIS 4.1.1.2)."
  exit 0
else
  echo "FAIL: auditd service is not enabled and running." >&2
  exit 1
fi