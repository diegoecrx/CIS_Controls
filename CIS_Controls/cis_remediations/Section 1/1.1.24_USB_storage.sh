"#!/usr/bin/env bash
# 1.1.24 - Disable USB Storage (usb-storage)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONF=""/etc/modprobe.d/usb-storage.conf""
LINE=""install usb-storage /bin/true""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Ensure conf exists and backed up once
[[ -f ""$CONF"" ]] || install -m 0644 /dev/null ""$CONF""
[[ ! -f ""${CONF}.bak"" ]] && cp -p ""$CONF"" ""${CONF}.bak""

# 3) Enforce rule (append if missing, or replace any existing 'install usb-storage' line)
if grep -qE '^\s*install\s+usb-storage\b' ""$CONF""; then
  sed -ri 's|^\s*install\s+usb-storage\b.*$|install usb-storage /bin/true|' ""$CONF""
else
  echo ""$LINE"" >> ""$CONF""
fi

# 4) Unload module if present
if lsmod | grep -q '^usb_storage'; then
  modprobe -r usb-storage 2>/dev/null || rmmod usb-storage 2>/dev/null || true
fi

# 5) Verify
FAIL=0
modprobe -n -v usb-storage 2>/dev/null | grep -q -- ""/bin/true"" || { echo ""FAIL: modprobe rule not effective""; FAIL=1; }
lsmod | grep -q '^usb_storage' && { echo ""FAIL: usb-storage module still loaded""; FAIL=1; }

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: usb-storage disabled per CIS 1.1.24""
  exit 0
else
  exit 1
fi"
