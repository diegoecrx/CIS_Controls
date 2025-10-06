"#!/usr/bin/env bash
# 1.7.6 - Ensure permissions on /etc/issue.net are configured (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

ISSUE_NET=""/etc/issue.net""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) If /etc/issue.net does not exist, treat as Not Applicable (content managed by CIS 1.7.3)
if [[ ! -e ""$ISSUE_NET"" ]]; then
  echo ""OK: $ISSUE_NET not present; permissions control not applicable (see CIS 1.7.3).""
  exit 0
fi

# 3) Apply ownership and permissions per CIS
chown root:root ""$ISSUE_NET""
# Remove: user execute; group write/exec; others write/exec
chmod u-x,go-wx ""$ISSUE_NET""

# 4) Verify
FAIL=0

# Ownership must be root:root
if [[ ""$(stat -c '%u:%g' ""$ISSUE_NET"")"" != ""0:0"" ]]; then
  echo ""FAIL: $ISSUE_NET not owned by root:root""
  FAIL=1
fi

# Mode checks: no exec for owner; no write/exec for group/others
MODE=""$(stat -c '%a' ""$ISSUE_NET"")""
U=$((10#${MODE: -3:1}))
G=$((10#${MODE: -2:1}))
O=$((10#${MODE: -1}))
(( U & 1 )) && { echo ""FAIL: $ISSUE_NET user has execute permission (mode=$MODE)""; FAIL=1; }
(( G & 3 )) && { echo ""FAIL: $ISSUE_NET group has write/execute (mode=$MODE)""; FAIL=1; }
(( O & 3 )) && { echo ""FAIL: $ISSUE_NET other has write/execute (mode=$MODE)""; FAIL=1; }

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: $ISSUE_NET permissions set (chown root:root; chmod u-x,go-wx) per CIS 1.7.6.""
  exit 0
else
  exit 1
fi"
