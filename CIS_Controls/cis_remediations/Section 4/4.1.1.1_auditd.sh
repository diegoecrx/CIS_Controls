#!/usr/bin/env bash
set -euo pipefail

# Goal: Ensure the audit daemon (auditd) and its libraries are installed so that security‑relevant events can be captured.
# Filename: 4.1.1.1_auditd.sh
# Applicability: Level 2 for both Server and Workstation
# Flags: L1=0, L2=1, Server=1, Workstation=1
APPLIES_L1=0
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

# This script installs the auditd package if it is not already present.  It must be run as root.
if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

# Install auditd and its libraries if missing
FAIL=0
for pkg in audit audit-libs; do
  if ! rpm -q "$pkg" >/dev/null 2>&1; then
    if ! yum install -y "$pkg" >/dev/null 2>&1; then
      echo "ERROR: failed to install $pkg" >&2
      FAIL=1
    fi
  fi
done

# Verification: confirm both packages are installed
if rpm -q audit >/dev/null 2>&1 && rpm -q audit-libs >/dev/null 2>&1; then
  echo "OK: auditd and audit-libs are installed (CIS 4.1.1.1)."
  exit 0
else
  echo "FAIL: auditd and/or audit-libs are not installed." >&2
  exit 1
fi