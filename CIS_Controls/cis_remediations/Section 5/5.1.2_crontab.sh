# Goal: Set secure ownership and permissions on /etc/crontab to protect cron configuration.
# Filename: 5.1.2_crontab.sh
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

cron_file="/etc/crontab"

FAIL=0

# Ensure the cron file exists
if [[ ! -e "$cron_file" ]]; then
  echo "ERROR: $cron_file does not exist." >&2
  FAIL=1
else
  # Backup once
  if [[ ! -e "${cron_file}.bak" ]]; then
    cp "$cron_file" "${cron_file}.bak"
  fi
  # Set ownership and permissions
  chown root:root "$cron_file" || FAIL=1
  chmod u-x,og-rwx "$cron_file" || FAIL=1
fi

# Verification
if [[ -e "$cron_file" ]] && \
   [[ $(stat -c %U "$cron_file") == "root" ]] && \
   [[ $(stat -c %G "$cron_file") == "root" ]] && \
   [[ $(stat -c %a "$cron_file") -le 600 ]]; then
  echo "OK: /etc/crontab permissions and ownership configured (CIS 5.1.2)."
  exit 0
else
  echo "FAIL: /etc/crontab permissions or ownership incorrect." >&2
  exit 1
fi
