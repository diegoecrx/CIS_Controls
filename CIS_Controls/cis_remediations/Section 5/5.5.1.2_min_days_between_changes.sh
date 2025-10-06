# Goal: Ensure minimum days between password changes is configured to prevent immediate password reuse.
# Filename: 5.5.1.2_min_days_between_changes.sh
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

# Desired minimum days between password changes (can override via MIN_DAYS env)
MIN_DAYS=${MIN_DAYS:-1}

login_defs="/etc/login.defs"
[[ -f "$login_defs" && ! -f "${login_defs}.bak" ]] && cp "$login_defs" "${login_defs}.bak"

# Update PASS_MIN_DAYS directive
if grep -q '^\s*PASS_MIN_DAYS' "$login_defs"; then
  sed -i "s/^\s*PASS_MIN_DAYS\s\+.*/PASS_MIN_DAYS\t${MIN_DAYS}/" "$login_defs"
else
  echo -e "PASS_MIN_DAYS\t${MIN_DAYS}" >> "$login_defs"
fi

# Determine UID_MIN
UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' "$login_defs" 2>/dev/null || echo 1000)

FAIL=0
# Update each non-system user's minimum days if necessary
while IFS=: read -r user _ uid _ _ _ _; do
  [[ "$uid" -lt "$UID_MIN" || "$user" == "root" ]] && continue
  pw=$(getent shadow "$user" | cut -d: -f2 || true)
  [[ -z "$pw" || "$pw" =~ ^[*!] ]] && continue
  current_min=$(chage -l "$user" | awk -F: '/Minimum.*:/{gsub(/ /,""); print $2}')
  if [[ -z "$current_min" ]] || (( current_min != MIN_DAYS )); then
    if ! chage --mindays "$MIN_DAYS" "$user" >/dev/null 2>&1; then
      echo "ERROR: Failed to set minimum days for user $user" >&2
      FAIL=1
    fi
  fi
done < /etc/passwd

# Verification
verify_fail=0
if ! grep -q "^PASS_MIN_DAYS\s\+${MIN_DAYS}" "$login_defs"; then
  verify_fail=1
fi
while IFS=: read -r user _ uid _ _ _ _; do
  [[ "$uid" -lt "$UID_MIN" || "$user" == "root" ]] && continue
  pw=$(getent shadow "$user" | cut -d: -f2 || true)
  [[ -z "$pw" || "$pw" =~ ^[*!] ]] && continue
  mindays=$(chage -l "$user" | awk -F: '/Minimum.*:/{gsub(/ /,""); print $2}')
  if [[ -z "$mindays" ]] || (( mindays != MIN_DAYS )); then
    verify_fail=1
  fi
done < /etc/passwd

if [[ "$verify_fail" -eq 0 && "$FAIL" -eq 0 ]]; then
  echo "OK: PASS_MIN_DAYS set to ${MIN_DAYS} and user min days updated (CIS 5.5.1.2)."
  exit 0
else
  echo "FAIL: Minimum password change interval not correctly applied." >&2
  exit 1
fi