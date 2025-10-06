"#!/usr/bin/env bash
# CIS 1.1.1.3 - Disable udf
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1     # Level 2 profiles inherit Level 1 items
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONF=""/etc/modprobe.d/udf.conf""
LINE=""install udf /bin/true""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Ensure conf exists and backed up once
if [[ ! -f ""$CONF"" ]]; then
  install -m 0644 /dev/null ""$CONF""
fi
[[ ! -f ""${CONF}.bak"" ]] && cp -p ""$CONF"" ""${CONF}.bak""

# 3) Enforce rule (append if missing, or replace any existing 'install udf' line)
if grep -qE '^\s*install\s+udf\b' ""$CONF""; then
  sed -ri 's|^\s*install\s+udf\b.*$|install udf /bin/true|' ""$CONF""
else
  echo ""$LINE"" >> ""$CONF""
fi

# 4) Unload module if present
if lsmod | grep -q '^udf'; then
  modprobe -r udf 2>/dev/null || rmmod udf 2>/dev/null || true
fi

# 5) Verify
FAIL=0
modprobe -n -v udf 2>/dev/null | grep -q -- ""/bin/true"" || { echo ""FAIL: modprobe rule not effective""; FAIL=1; }
lsmod | grep -q '^udf' && { echo ""FAIL: udf module still loaded""; FAIL=1; }

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: udf disabled per CIS 1.1.1.3""
  exit 0
else
  exit 1
fi"
