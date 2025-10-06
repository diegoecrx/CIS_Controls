"#!/usr/bin/env bash
# 1.1.23 - Disable Automounting (autofs)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

# Optional: set APPLY_REMOVE=1 to also remove autofs package
: ""${APPLY_REMOVE:=0}""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Stop, disable, and mask autofs service (idempotent)
if systemctl list-unit-files | grep -q '^autofs\.service'; then
  systemctl stop autofs 2>/dev/null || true
  systemctl disable autofs 2>/dev/null || true
  systemctl --now mask autofs 2>/dev/null || true
fi

# 3) Optional: remove autofs package when requested
if [[ ""$APPLY_REMOVE"" -eq 1 ]]; then
  if rpm -q autofs >/dev/null 2>&1; then
    yum -y remove autofs
  fi
fi

# 4) Verify
FAIL=0
# Service should be masked (preferred) or absent
if systemctl list-unit-files | grep -q '^autofs\.service'; then
  if ! systemctl is-enabled autofs 2>/dev/null | grep -q '^masked$'; then
    echo ""FAIL: autofs service is not masked.""
    FAIL=1
  fi
  if systemctl is-active --quiet autofs 2>/dev/null; then
    echo ""FAIL: autofs service is still active.""
    FAIL=1
  fi
else
  # No unit present; ensure package not installed when APPLY_REMOVE=1
  if [[ ""$APPLY_REMOVE"" -eq 1 ]] && rpm -q autofs >/dev/null 2>&1; then
    echo ""FAIL: autofs package still installed.""
    FAIL=1
  fi
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: Automounting disabled (autofs masked""$( [[ ""$APPLY_REMOVE"" -eq 1 ]] && echo "", package removed"" )"") per CIS 1.1.23.""
  exit 0
else
  exit 1
fi"
