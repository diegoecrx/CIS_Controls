"#!/usr/bin/env bash
# 1.7.4 - Ensure permissions on /etc/motd are configured (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

MOTD=""/etc/motd""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) If /etc/motd does not exist, consider this control Not Applicable (CIS 1.7.1 allows removal)
if [[ ! -e ""$MOTD"" ]]; then
  echo ""OK: $MOTD not present; permissions control not applicable (see CIS 1.7.1).""
  exit 0
fi

# 3) Apply ownership and permissions per CIS
chown root:root ""$MOTD""
# Remove: user execute; group write/exec; others write/exec
chmod u-x,go-wx ""$MOTD""

# 4) Verify
FAIL=0

# 4a) Ownership root:root
if [[ ""$(stat -c '%u:%g' ""$MOTD"")"" != ""0:0"" ]]; then
  echo ""FAIL: $MOTD not owned by root:root""
  FAIL=1
fi

# 4b) Mode: user must NOT have execute; group/others must NOT have write/execute
MODE=""$(stat -c '%a' ""$MOTD"")""
# take last three digits (owner, group, other)
U=$((10#${MODE: -3:1}))
G=$((10#${MODE: -2:1}))
O=$((10#${MODE: -1}))

# user exec bit is (1), group write/exec are (2|1), other write/exec are (2|1)
if (( U & 1 )); then
  echo ""FAIL: $MOTD user has execute permission (mode=$MODE)""
  FAIL=1
fi
if (( G & 3 )); then
  echo ""FAIL: $MOTD group has write and/or execute permission (mode=$MODE)""
  FAIL=1
fi
if (( O & 3 )); then
  echo ""FAIL: $MOTD other has write and/or execute permission (mode=$MODE)""
  FAIL=1
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: $MOTD permissions set (chown root:root; chmod u-x,go-wx) per CIS 1.7.4.""
  exit 0
else
  exit 1
fi"
