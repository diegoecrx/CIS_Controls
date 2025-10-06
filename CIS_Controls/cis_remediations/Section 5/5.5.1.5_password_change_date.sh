# Goal: Ensure all users' last password change date is in the past by auditing and reporting future dates.
# Filename: 5.5.1.5_password_change_date.sh
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

# This script checks for any user accounts whose last password change date is in the future.
# It does not modify accounts but reports findings to the administrator.

# Determine UID_MIN
login_defs="/etc/login.defs"
UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' "$login_defs" 2>/dev/null || echo 1000)

FAIL=0
now_ts=$(date +%s)
while IFS=: read -r user _ uid _ _ _ _; do
  [[ "$uid" -lt "$UID_MIN" || "$user" == "root" ]] && continue
  pw=$(getent shadow "$user" | cut -d: -f2 || true)
  [[ -z "$pw" || "$pw" =~ ^[*!] ]] && continue
  last_change=$(chage -l "$user" | awk -F: '/Last password change/{print $2}' | sed 's/^ *//')
  # Skip if last_change is "never" or blank
  [[ -z "$last_change" || "$last_change" == "never" ]] && continue
  # Convert to epoch seconds
  lc_ts=$(date -d "$last_change" +%s 2>/dev/null || echo 0)
  if (( lc_ts > now_ts )); then
    echo "User $user has a password change date in the future: $last_change" >&2
    FAIL=1
  fi
done < /etc/passwd

if [[ "$FAIL" -eq 0 ]]; then
  echo "OK: All users have last password change dates in the past (CIS 5.5.1.5)."
  exit 0
else
  echo "FAIL: One or more users have password change dates in the future." >&2
  exit 1
fi