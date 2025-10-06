"#!/usr/bin/env bash
# 1.6.1.5 - Ensure SELinux mode is ENFORCING (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=0
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONF=""/etc/selinux/config""
STAMP=""$(date +%Y%m%d%H%M%S)""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Ensure config file exists; backup; set SELINUX=enforcing
[[ -f ""$CONF"" ]] || install -m 0644 -o root -g root /dev/null ""$CONF""
cp -p ""$CONF"" ""${CONF}.bak-${STAMP}""

awk '
  BEGIN{done=0}
  /^[[:space:]]*SELINUX[[:space:]]*=/ { print ""SELINUX=enforcing""; done=1; next }
  { print }
  END{ if(!done) print ""SELINUX=enforcing"" }
' ""$CONF"" > ""${CONF}.new""
mv ""${CONF}.new"" ""$CONF""

# 3) Set runtime mode to enforcing if SELinux is active (not disabled)
RUNTIME_STATUS=""$(getenforce 2>/dev/null || echo ""Unknown"")""
if [[ ""$RUNTIME_STATUS"" == ""Permissive"" ]]; then
  setenforce 1 || true
elif [[ ""$RUNTIME_STATUS"" == ""Disabled"" || ""$RUNTIME_STATUS"" == ""Unknown"" ]]; then
  echo ""INFO: SELinux runtime is $RUNTIME_STATUS. Bootloader flags or reboot may be required (see CIS 1.6.1.2).""
fi

# 4) Verify
FAIL=0

# 4a) Config verification
grep -Eq '^[[:space:]]*SELINUX[[:space:]]*=[[:space:]]*enforcing[[:space:]]*$' ""$CONF"" \
  || { echo ""FAIL: /etc/selinux/config does not set SELINUX=enforcing""; FAIL=1; }

# 4b) Runtime verification
RUNTIME_STATUS=""$(getenforce 2>/dev/null || echo ""Unknown"")""
if [[ ""$RUNTIME_STATUS"" != ""Enforcing"" ]]; then
  echo ""FAIL: Runtime SELinux mode is not Enforcing (current: $RUNTIME_STATUS).""
  echo ""HINT: Ensure kernel cmdline has no 'selinux=0'/'enforcing=0' (CIS 1.6.1.2) and reboot if needed.""
  FAIL=1
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: SELinux is Enforcing and persisted (CIS 1.6.1.5).""
  exit 0
else
  exit 1
fi"
