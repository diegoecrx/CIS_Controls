# Goal: Restrict at command usage to authorized users by enforcing at.allow and removing at.deny.
# Filename: 5.1.9_at_allow.sh
# Applicability: Level 1 for Server and Workstation
#!/usr/bin/env bash
set -euo pipefail

APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

# Remove /etc/at.deny if present (backup first)
if [[ -f /etc/at.deny ]]; then
  [[ ! -f /etc/at.deny.bak ]] && cp /etc/at.deny /etc/at.deny.bak
  rm -f /etc/at.deny
fi

# Ensure /etc/at.allow exists
if [[ ! -f /etc/at.allow ]]; then
  touch /etc/at.allow
fi

# Set ownership and permissions
chown root:root /etc/at.allow
chmod u-x,og-rwx /etc/at.allow

# Verification
FAIL=0
if [[ -f /etc/at.deny ]]; then
  FAIL=1
fi
if [[ ! -f /etc/at.allow ]] || [[ $(stat -c %U /etc/at.allow) != "root" ]] || [[ $(stat -c %G /etc/at.allow) != "root" ]] || [[ $(stat -c %a /etc/at.allow) -gt 600 ]]; then
  FAIL=1
fi

if [[ $FAIL -eq 0 ]]; then
  echo "OK: at access restricted via /etc/at.allow (CIS 5.1.9)."
  exit 0
else
  echo "FAIL: at access restriction not correctly configured." >&2
  exit 1
fi
