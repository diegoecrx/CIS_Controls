# Goal: Restrict cron usage to authorized users by enforcing cron.allow and removing cron.deny.
# Filename: 5.1.8_cron_allow.sh
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

# Remove /etc/cron.deny if it exists (back it up once)
if [[ -f /etc/cron.deny ]]; then
  [[ ! -f /etc/cron.deny.bak ]] && cp /etc/cron.deny /etc/cron.deny.bak
  rm -f /etc/cron.deny
fi

# Ensure /etc/cron.allow exists
if [[ ! -f /etc/cron.allow ]]; then
  touch /etc/cron.allow
fi

# Set ownership and permissions on cron.allow
chown root:root /etc/cron.allow
chmod u-x,og-rwx /etc/cron.allow

# Verification
FAIL=0
if [[ -f /etc/cron.deny ]]; then
  FAIL=1
fi
if [[ ! -f /etc/cron.allow ]] || [[ $(stat -c %U /etc/cron.allow) != "root" ]] || [[ $(stat -c %G /etc/cron.allow) != "root" ]] || [[ $(stat -c %a /etc/cron.allow) -gt 600 ]]; then
  FAIL=1
fi

if [[ $FAIL -eq 0 ]]; then
  echo "OK: cron access restricted via /etc/cron.allow (CIS 5.1.8)."
  exit 0
else
  echo "FAIL: cron access restriction not correctly configured." >&2
  exit 1
fi
