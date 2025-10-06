# Goal: Secure the /etc/cron.d directory by ensuring proper ownership and permissions.
# Filename: 5.1.7_cron_d.sh
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

dir="/etc/cron.d"
FAIL=0
if [[ -d "$dir" ]]; then
  if [[ ! -e "$dir.bak_perm" ]]; then
    stat -c "%a %U %G" "$dir" > "$dir.bak_perm" || true
  fi
  chown root:root "$dir" || FAIL=1
  chmod og-rwx "$dir" || FAIL=1
else
  echo "ERROR: $dir directory not found." >&2
  FAIL=1
fi

if [[ -d "$dir" ]] && \
   [[ $(stat -c %U "$dir") == "root" ]] && \
   [[ $(stat -c %G "$dir") == "root" ]] && \
   [[ $(stat -c %a "$dir") -le 700 ]]; then
  echo "OK: $dir ownership and permissions configured (CIS 5.1.7)."
  exit 0
else
  echo "FAIL: $dir ownership or permissions incorrect." >&2
  exit 1
fi
