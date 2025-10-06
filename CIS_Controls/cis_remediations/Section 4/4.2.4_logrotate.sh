#!/usr/bin/env bash
set -euo pipefail

# Goal: Ensure log rotation is configured per site policy (manual verification).
# Filename: 4.2.4_logrotate.sh
# Applicability: Level 1 for both Server and Workstation (manual control)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

# Ensure logrotate package is installed
if ! rpm -q logrotate >/dev/null 2>&1; then
  yum install -y logrotate >/dev/null 2>&1 || {
    echo "FAIL: Unable to install logrotate." >&2
    exit 1
  }
fi

# This control is manual: administrators must review /etc/logrotate.conf and /etc/logrotate.d/* and ensure logs are rotated according to site policy.
echo "INFO: logrotate is installed. Please review /etc/logrotate.conf and /etc/logrotate.d/* to ensure log rotation complies with your site policy." >&2

# Verification: confirm logrotate exists
if rpm -q logrotate >/dev/null 2>&1; then
  echo "OK: logrotate package present; manual review required (CIS 4.2.4)."
  exit 0
else
  echo "FAIL: logrotate package missing." >&2
  exit 1
fi