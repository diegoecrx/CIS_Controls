"#!/usr/bin/env bash
# 1.6.1.4 - Ensure the SELinux mode is enforcing or permissive (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONF=""/etc/selinux/config""
STAMP=""$(date +%Y%m%d%H%M%S)""

# Choose enforcing (default) or permissive. Either value is compliant for 1.6.1.4.
SELINUX_MODE=""${SELINUX_MODE:-enforcing}""   # valid: enforcing | permissive

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Validate requested mode
case ""$SELINUX_MODE"" in
  enforcing|permissive) ;;
  *) echo ""ERROR: SELINUX_MODE must be 'enforcing' or 'permissive'.""; exit 2 ;;
esac

# 3) Ensure config file exists, back it up, and set SELINUX=<mode> (not disabled)
[[ -f ""$CONF"" ]] || install -m 0644 -o root -g root /dev/null ""$CONF""
cp -p ""$CONF"" ""${CONF}.bak-${STAMP}""

awk -v mode=""$SELINUX_MODE"" '
  BEGIN{done_s=0; done_t=0}
  /^[[:space:]]*SELINUX[[:space:]]*=/     { print ""SELINUX="" mode; done_s=1; next }
  /^[[:space:]]*SELINUXTYPE[[:space:]]*=/ { print $0; done_t=1; next }
  { print }
  END{
    if (!done_s) print ""SELINUX="" mode
  }
' ""$CONF"" > ""${CONF}.new""
mv ""${CONF}.new"" ""$CONF""

# 4) Runtime: set mode now if SELinux is enabled (setenforce works only when not disabled)
RUNTIME_STATUS=""$(getenforce 2>/dev/null || echo ""Unknown"")""
if [[ ""$RUNTIME_STATUS"" == ""Enforcing"" || ""$RUNTIME_STATUS"" == ""Permissive"" ]]; then
  if [[ ""$SELINUX_MODE"" == ""enforcing"" && ""$RUNTIME_STATUS"" != ""Enforcing"" ]]; then
    setenforce 1 || true
  elif [[ ""$SELINUX_MODE"" == ""permissive"" && ""$RUNTIME_STATUS"" != ""Permissive"" ]]; then
    setenforce 0 || true
  fi
else
  echo ""INFO: Runtime SELinux appears disabled (getenforce: $RUNTIME_STATUS). Bootloader/kernel changes and reboot may be required.""
fi

# 5) Verify
FAIL=0

# 5a) Config must NOT be disabled and must match requested mode
if ! grep -Eq ""^[[:space:]]*SELINUX[[:space:]]*=[[:space:]]*(${SELINUX_MODE})[[:space:]]*$"" ""$CONF""; then
  echo ""FAIL: /etc/selinux/config does not set SELINUX=$SELINUX_MODE""
  FAIL=1
fi
if grep -Eq ""^[[:space:]]*SELINUX[[:space:]]*=[[:space:]]*disabled[[:space:]]*$"" ""$CONF""; then
  echo ""FAIL: /etc/selinux/config sets SELINUX=disabled""
  FAIL=1
fi

# 5b) Runtime should be Enforcing or Permissive (CIS requires not Disabled)
RUNTIME_STATUS=""$(getenforce 2>/dev/null || echo ""Unknown"")""
if [[ ""$RUNTIME_STATUS"" != ""Enforcing"" && ""$RUNTIME_STATUS"" != ""Permissive"" ]]; then
  echo ""FAIL: Runtime SELinux mode is not Enforcing/Permissive (current: $RUNTIME_STATUS)""
  echo ""HINT: Ensure 1.6.1.2 removed 'selinux=0'/'enforcing=0' from kernel cmdline and reboot.""
  FAIL=1
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: SELinux mode configured to '$SELINUX_MODE' and not disabled (CIS 1.6.1.4).""
  [[ ""$SELINUX_MODE"" == ""enforcing"" ]] && echo ""NOTE: Some environments accept 'permissive' for this control; 'enforcing' is stricter.""
  exit 0
else
  exit 1
fi"
