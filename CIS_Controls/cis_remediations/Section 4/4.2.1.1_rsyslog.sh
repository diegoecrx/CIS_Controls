#!/usr/bin/env bash
set -euo pipefail

# Goal: Ensure the rsyslog package is installed to provide logging services.
# Filename: 4.2.1.1_rsyslog.sh
# Applicability: Level 1 for both Server and Workstation
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

FAIL=0
if ! rpm -q rsyslog >/dev/null 2>&1; then
  yum install -y rsyslog >/dev/null 2>&1 || FAIL=1
fi

if rpm -q rsyslog >/dev/null 2>&1; then
  echo "OK: rsyslog is installed (CIS 4.2.1.1)."
  exit 0
else
  echo "FAIL: rsyslog is not installed." >&2
  exit 1
fi