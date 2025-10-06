"#!/usr/bin/env bash
# CIS 2.3.4 - Ensure telnet client is not installed (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

PKG=""telnet""
BACKUP_BASE=""/var/backups/cis""
TS=""$(date +%Y%m%d%H%M%S)""
BACKUP_DIR=""${BACKUP_BASE}/${TS}-telnet-client""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Prepare backup dir (no config for client; kept for consistency)
mkdir -p -m 0700 ""$BACKUP_DIR""

# 3) Remove telnet client (idempotent)
if rpm -q ""$PKG"" &>/dev/null; then
  yum -y remove ""$PKG"" >/dev/null || true
fi

# 4) Best-effort: ensure no interactive client processes remain
pkill -TERM -x telnet 2>/dev/null || true
sleep 1
pkill -KILL -x telnet 2>/dev/null || true

# 5) Verification
FAIL=0

# a) Package not installed
if rpm -q ""$PKG"" &>/dev/null; then
  echo ""FAIL: Package '$PKG' still installed""
  FAIL=1
fi

# b) Client binary not present in PATH
if command -v telnet >/dev/null 2>&1; then
  echo ""FAIL: 'telnet' binary still present in PATH""
  FAIL=1
fi

# c) No lingering telnet client process
if pgrep -x telnet >/dev/null 2>&1; then
  echo ""FAIL: 'telnet' client process still running""
  FAIL=1
fi

# d) Optional: warn if TCP 23 is in use (not a hard fail; pertains to server)
if ss -ltn 2>/dev/null | awk '$1==""LISTEN"" && $4 ~ /(:|\.)(23)$/ {found=1} END{exit !found}'; then
  echo ""NOTE: TCP port 23 is listening; ensure no Telnet server is present (handled in CIS 2.2.15).""
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: telnet client not installed/present (CIS 2.3.4)""
  exit 0
else
  exit 1
fi"
