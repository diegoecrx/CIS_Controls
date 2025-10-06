# Goal: Ensure inactive password lock is 30 days or less by setting default user add parameters and updating users.
# Filename: 5.5.1.4_inactive_password_lock.sh
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

# Desired inactivity days before account is locked (override via INACTIVE_DAYS env)
INACTIVE_DAYS=${INACTIVE_DAYS:-30}

# Set default for new accounts via useradd -D
DEFAULT_INACTIVE=$(useradd -D | awk -F= '/INACTIVE/{print $2}')
if [[ -z "$DEFAULT_INACTIVE" || "$DEFAULT_INACTIVE" -gt "$INACTIVE_DAYS" ]]; then
  useradd -D -f "$INACTIVE_DAYS" >/dev/null 2>&1 || true
fi

# Determine UID_MIN
login_defs="/etc/login.defs"
UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' "$login_defs" 2>/dev/null || echo 1000)

FAIL=0
# Update existing non-system accounts
while IFS=: read -r user _ uid _ _ _ _; do
  [[ "$uid" -lt "$UID_MIN" || "$user" == "root" ]] && continue
  pw=$(getent shadow "$user" | cut -d: -f2 || true)
  [[ -z "$pw" || "$pw" =~ ^[*!] ]] && continue
  current_inactive=$(chage -l "$user" | awk -F: '/Account expires/{next}; /Inactive.*:/{gsub(/ /,""); print $2}')
  if [[ -z "$current_inactive" ]] || (( current_inactive > INACTIVE_DAYS )); then
    if ! chage --inactive "$INACTIVE_DAYS" "$user" >/dev/null 2>&1; then
      echo "ERROR: Failed to set inactive days for user $user" >&2
      FAIL=1
    fi
  fi
done < /etc/passwd

# Verification
verify_fail=0
# Check default
new_default=$(useradd -D | awk -F= '/INACTIVE/{print $2}')
if [[ -z "$new_default" ]] || (( new_default > INACTIVE_DAYS )); then
  verify_fail=1
fi
while IFS=: read -r user _ uid _ _ _ _; do
  [[ "$uid" -lt "$UID_MIN" || "$user" == "root" ]] && continue
  pw=$(getent shadow "$user" | cut -d: -f2 || true)
  [[ -z "$pw" || "$pw" =~ ^[*!] ]] && continue
  inactive=$(chage -l "$user" | awk -F: '/Inactive.*:/{gsub(/ /,""); print $2}')
  if [[ -z "$inactive" ]] || (( inactive > INACTIVE_DAYS )); then
    verify_fail=1
  fi
done < /etc/passwd

if [[ "$verify_fail" -eq 0 && "$FAIL" -eq 0 ]]; then
  echo "OK: Inactive password lock set to ${INACTIVE_DAYS} days (CIS 5.5.1.4)."
  exit 0
else
  echo "FAIL: Inactive password lock not correctly applied." >&2
  exit 1
fi