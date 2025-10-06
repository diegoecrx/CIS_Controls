"#!/usr/bin/env bash
# CIS 2.3.3 - Ensure talk client is not installed (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

PKG=""talk""
BACKUP_BASE=""/var/backups/cis""
TS=""$(date +%Y%m%d%H%M%S)""
BACKUP_DIR=""${BACKUP_BASE}/${TS}-talk-client""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Prepare backup dir (no standard configs for client; kept for consistency)
mkdir -p -m 0700 ""$BACKUP_DIR""

# 3) Remove talk package if installed (idempotent)
if rpm -q ""$PKG"" &>/dev/null; then
  yum -y remove ""$PKG"" >/dev/null || true
fi

# 4) Best-effort: terminate any running client processes
pkill -TERM -x talk 2>/dev/null || true
sleep 1
pkill -KILL -x talk 2>/dev/null || true

# 5) Verification
FAIL=0

# a) Package not installed
if rpm -q ""$PKG"" &>/dev/null; then
  echo ""FAIL: Package '$PKG' still installed""
  FAIL=1
fi

# b) Client binary not present in PATH
if command -v talk >/dev/null 2>&1; then
  echo ""FAIL: 'talk' binary still present in PATH""
  FAIL=1
fi

# c) No lingering processes
if pgrep -x talk >/dev/null 2>&1; then
  echo ""FAIL: 'talk' process still running""
  FAIL=1
fi

# d) Optional: informational notice about talk server ports (not a hard fail)
if ss -ltnu 2>/dev/null | awk '{print $5}' | grep -qE '(:|\.)(517|518)$'; then
  echo ""NOTE: Ports 517/518 in use (talk/ntalk servers). Ensure no talk server is installed elsewhere.""
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: talk client not installed/present (CIS 2.3.3)""
  exit 0
else
  exit 1
fi"
