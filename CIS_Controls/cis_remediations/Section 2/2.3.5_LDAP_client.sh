"#!/usr/bin/env bash
# CIS 2.3.5 - Ensure LDAP client is not installed (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

PKG=""openldap-clients""
BACKUP_BASE=""/var/backups/cis""
TS=""$(date +%Y%m%d%H%M%S)""
BACKUP_DIR=""${BACKUP_BASE}/${TS}-ldap-client""

# Representative client binaries from the package (verification)
BINS=(ldapsearch ldapmodify ldapadd ldapdelete)

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Prepare backup dir (kept for consistency; client pkg has no config)
mkdir -p -m 0700 ""$BACKUP_DIR""

# 3) Remove LDAP client package (idempotent)
if rpm -q ""$PKG"" &>/dev/null; then
  yum -y remove ""$PKG"" >/dev/null || true
fi

# 4) Best-effort: terminate any running ldap* client processes
pkill -TERM -f '(^|/| )ldap(search|modify|add|delete)\b' 2>/dev/null || true
sleep 1
pkill -KILL -f '(^|/| )ldap(search|modify|add|delete)\b' 2>/dev/null || true

# 5) Verification
FAIL=0

# a) Package not installed
if rpm -q ""$PKG"" &>/dev/null; then
  echo ""FAIL: Package '$PKG' still installed""
  FAIL=1
fi

# b) Client binaries not present in PATH
for bin in ""${BINS[@]}""; do
  if command -v ""$bin"" >/dev/null 2>&1; then
    echo ""FAIL: Binary '$bin' still present in PATH""
    FAIL=1
  fi
done

# c) No lingering ldap* client processes
if pgrep -f '(^|/| )ldap(search|modify|add|delete)\b' >/dev/null 2>&1; then
  echo ""FAIL: LDAP client process still running""
  FAIL=1
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: LDAP client not installed/present (CIS 2.3.5)""
  exit 0
else
  exit 1
fi"
