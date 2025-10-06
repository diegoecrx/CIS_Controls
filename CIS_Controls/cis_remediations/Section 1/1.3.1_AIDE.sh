"#!/usr/bin/env bash
# 1.3.1 - Ensure AIDE is installed (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

DB_DIR=""/var/lib/aide""
DB_NEW=""${DB_DIR}/aide.db.new.gz""
DB_CUR=""${DB_DIR}/aide.db.gz""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Ensure AIDE installed
if ! rpm -q aide >/dev/null 2>&1; then
  yum -y install aide
fi

# 3) Initialize database if not present
if [[ ! -f ""$DB_CUR"" ]]; then
  mkdir -p ""$DB_DIR""
  # --init may take time; allow non-zero exit only if DB still missing
  if aide --init; then
    :
  else
    echo ""WARN: 'aide --init' returned non-zero; continuing to check for DB file.""
  fi
  if [[ -f ""$DB_NEW"" ]]; then
    mv -f ""$DB_NEW"" ""$DB_CUR""
  fi
fi

# 4) Verify
FAIL=0
rpm -q aide >/dev/null 2>&1 || { echo ""FAIL: AIDE package not installed.""; FAIL=1; }
[[ -f ""$DB_CUR"" ]] || { echo ""FAIL: AIDE database not found at $DB_CUR.""; FAIL=1; }

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: AIDE installed and initialized (CIS 1.3.1).""
  exit 0
else
  exit 1
fi"
