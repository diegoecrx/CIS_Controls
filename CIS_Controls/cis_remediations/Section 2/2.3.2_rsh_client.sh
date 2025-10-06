"#!/usr/bin/env bash
# CIS 2.3.2 - Ensure rsh client is not installed (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

# Scope: remove rsh client package (provides rsh, rlogin, rcp). No service units expected.
PKG=""rsh""
BACKUP_BASE=""/var/backups/cis""
TS=""$(date +%Y%m%d%H%M%S)""
BACKUP_DIR=""${BACKUP_BASE}/${TS}-rsh-client""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Prepare backup dir (kept for consistency; rsh has no configs to back up)
mkdir -p -m 0700 ""$BACKUP_DIR""

# 3) Remove rsh package if installed (idempotent)
if rpm -q ""$PKG"" &>/dev/null; then
  yum -y remove ""$PKG"" >/dev/null || true
fi

# 4) Best-effort: ensure no lingering client processes (rare)
pkill -TERM -x rsh 2>/dev/null || true
pkill -TERM -x rlogin 2>/dev/null || true
pkill -TERM -x rcp 2>/dev/null || true
sleep 1
pkill -KILL -x rsh 2>/dev/null || true
pkill -KILL -x rlogin 2>/dev/null || true
pkill -KILL -x rcp 2>/dev/null || true

# 5) Verification
FAIL=0

# a) Package not installed
if rpm -q ""$PKG"" &>/dev/null; then
  echo ""FAIL: Package '$PKG' still installed""
  FAIL=1
fi

# b) Client binaries not present in PATH
for bin in rsh rlogin rcp; do
  if command -v ""$bin"" >/dev/null 2>&1; then
    echo ""FAIL: Binary '$bin' still present in PATH""
    FAIL=1
  fi
done

# c) No lingering processes
if pgrep -x rsh >/dev/null 2>&1 || pgrep -x rlogin >/devnull 2>&1 || pgrep -x rcp >/dev/null 2>&1; then
  echo ""FAIL: rsh/rlogin/rcp client process still running""
  FAIL=1
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: rsh client not installed/present (CIS 2.3.2)""
  exit 0
else
  exit 1
fi"
