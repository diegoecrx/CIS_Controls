# Goal: Enable and start the cron daemon so scheduled tasks can run reliably.
# Filename: 5.1.1_crond.sh
# Applicability: Level 1 for Server and Workstation
#!/usr/bin/env bash
set -euo pipefail

# Metadata flags (Level 1 only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

# Install cronie if not already present and enable the crond service
FAIL=0
if ! rpm -q cronie >/dev/null 2>&1; then
  yum install -y cronie >/dev/null 2>&1 || FAIL=1
fi

# Enable and start the cron service
if systemctl list-unit-files | grep -q '^crond\.service'; then
  systemctl enable --now crond >/dev/null 2>&1 || FAIL=1
else
  echo "ERROR: crond service file not found" >&2
  FAIL=1
fi

# Verification: cron daemon should be installed, enabled and active
if rpm -q cronie >/dev/null 2>&1 && \
   systemctl is-enabled crond >/dev/null 2>&1 && \
   systemctl is-active crond >/dev/null 2>&1; then
  echo "OK: cron daemon installed and running (CIS 5.1.1)."
  exit 0
else
  echo "FAIL: cron daemon not properly enabled or running." >&2
  exit 1
fi
