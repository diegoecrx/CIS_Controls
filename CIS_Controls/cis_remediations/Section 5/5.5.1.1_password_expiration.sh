# Goal: Ensure password expiration is 365 days or less by updating PASS_MAX_DAYS and user settings.
# Filename: 5.5.1.1_password_expiration.sh
# Applicability: Level 1 for Server and Workstation
#!/usr/bin/env bash
set -euo pipefail

# Applicability flags
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

# This control enforces a maximum password age.  It must be run as root.
if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

# Desired maximum days (override via MAX_DAYS environment variable)
MAX_DAYS=${MAX_DAYS:-365}

login_defs="/etc/login.defs"
# Backup login.defs if no backup exists
if [[ -f "$login_defs" && ! -f "${login_defs}.bak" ]]; then
  cp "$login_defs" "${login_defs}.bak"
fi

# Update PASS_MAX_DAYS directive
if grep -q '^\s*PASS_MAX_DAYS' "$login_defs"; then
  sed -i "s/^\s*PASS_MAX_DAYS\s\+.*/PASS_MAX_DAYS\t${MAX_DAYS}/" "$login_defs"
else
  echo -e "PASS_MAX_DAYS\t${MAX_DAYS}" >> "$login_defs"
fi

# Update existing user accounts: for each non-system account with a valid password, set maxdays
# Determine UID_MIN from login.defs
UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' "$login_defs" 2>/dev/null || echo 1000)

FAIL=0
while IFS=: read -r user _ uid _ _ _ _; do
  # Skip root and system accounts
  if [[ "$uid" -lt "$UID_MIN" ]] || [[ "$user" == "root" ]]; then
    continue
  fi
  # Skip users without a password (password field begins with '!' or '*')
  pw=$(getent shadow "$user" | cut -d: -f2 || true)
  if [[ -z "$pw" ]] || [[ "$pw" =~ ^[*!] ]]; then
    continue
  fi
  # Check current max days and update if necessary
  current_max=$(chage -l "$user" | awk -F: '/Maximum.*:/{gsub(/ /,""); print $2}')
  if [[ -z "$current_max" ]] || (( current_max > MAX_DAYS )); then
    if ! chage --maxdays "$MAX_DAYS" "$user" >/dev/null 2>&1; then
      echo "ERROR: Failed to set max days for user $user" >&2
      FAIL=1
    fi
  fi
done < /etc/passwd

# Verification
verify_fail=0
if ! grep -q "^PASS_MAX_DAYS\s\+${MAX_DAYS}" "$login_defs"; then
  verify_fail=1
fi
while IFS=: read -r user _ uid _ _ _ _; do
  if [[ "$uid" -lt "$UID_MIN" ]] || [[ "$user" == "root" ]]; then
    continue
  fi
  pw=$(getent shadow "$user" | cut -d: -f2 || true)
  if [[ -z "$pw" ]] || [[ "$pw" =~ ^[*!] ]]; then
    continue
  fi
  maxd=$(chage -l "$user" | awk -F: '/Maximum.*:/{gsub(/ /,""); print $2}')
  # If max days is still blank or greater than desired, fail
  if [[ -z "$maxd" ]] || (( maxd > MAX_DAYS )); then
    verify_fail=1
  fi
done < /etc/passwd

if [[ "$verify_fail" -eq 0 && "$FAIL" -eq 0 ]]; then
  echo "OK: PASS_MAX_DAYS set to ${MAX_DAYS} and user max days updated (CIS 5.5.1.1)."
  exit 0
else
  echo "FAIL: Password expiration settings not correctly applied." >&2
  exit 1
fi