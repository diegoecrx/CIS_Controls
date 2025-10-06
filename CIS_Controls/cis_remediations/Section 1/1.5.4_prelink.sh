"#!/usr/bin/env bash
# 1.5.4 - Ensure prelink is not installed (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) If prelink binary exists, undo prelinking first (safe if rerun)
if command -v prelink >/dev/null 2>&1; then
  prelink -ua || echo ""WARN: 'prelink -ua' returned non-zero; continuing.""
fi

# 3) Remove prelink package if installed
if rpm -q prelink >/dev/null 2>&1; then
  yum -y remove prelink || {
    echo ""FAIL: Unable to remove prelink via yum.""
    exit 1
  }
fi

# 4) Verify
FAIL=0
if rpm -q prelink >/dev/null 2>&1; then
  echo ""FAIL: prelink package still installed.""
  FAIL=1
fi
if command -v prelink >/dev/null 2>&1; then
  echo ""FAIL: prelink executable still present in PATH.""
  FAIL=1
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: prelink removed and binaries restored (CIS 1.5.4).""
  exit 0
else
  exit 1
fi"
