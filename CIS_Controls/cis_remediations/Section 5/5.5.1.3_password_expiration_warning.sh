# Goal: Ensure password expiration warning days are set so users are informed before password expiry.
# Filename: 5.5.1.3_password_expiration_warning.sh
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

# Desired warning days before expiration (can override via WARN_DAYS env)
WARN_DAYS=${WARN_DAYS:-7}

login_defs="/etc/login.defs"
[[ -f "$login_defs" && ! -f "${login_defs}.bak" ]] && cp "$login_defs" "${login_defs}.bak"

# Update PASS_WARN_AGE directive
if grep -q '^\s*PASS_WARN_AGE' "$login_defs"; then
  sed -i "s/^\s*PASS_WARN_AGE\s\+.*/PASS_WARN_AGE\t${WARN_DAYS}/" "$login_defs"
else
  echo -e "PASS_WARN_AGE\t${WARN_DAYS}" >> "$login_defs"
fi

# Determine UID_MIN
UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' "$login_defs" 2>/dev/null || echo 1000)

FAIL=0
# Update each non-system user's warn days
while IFS=: read -r user _ uid _ _ _ _; do
  [[ "$uid" -lt "$UID_MIN" || "$user" == "root" ]] && continue
  pw=$(getent shadow "$user" | cut -d: -f2 || true)
  [[ -z "$pw" || "$pw" =~ ^[*!] ]] && continue
  cur_warn=$(chage -l "$user" | awk -F: '/Warning.*:/{gsub(/ /,""); print $2}')
  if [[ -z "$cur_warn" ]] || (( cur_warn != WARN_DAYS )); then
    if ! chage --warndays "$WARN_DAYS" "$user" >/dev/null 2>&1; then
      echo "ERROR: Failed to set warn days for user $user" >&2
      FAIL=1
    fi
  fi
done < /etc/passwd

# Verification
verify_fail=0
if ! grep -q "^PASS_WARN_AGE\s\+${WARN_DAYS}" "$login_defs"; then
  verify_fail=1
fi
while IFS=: read -r user _ uid _ _ _ _; do
  [[ "$uid" -lt "$UID_MIN" || "$user" == "root" ]] && continue
  pw=$(getent shadow "$user" | cut -d: -f2 || true)
  [[ -z "$pw" || "$pw" =~ ^[*!] ]] && continue
  warn=$(chage -l "$user" | awk -F: '/Warning.*:/{gsub(/ /,""); print $2}')
  if [[ -z "$warn" ]] || (( warn != WARN_DAYS )); then
    verify_fail=1
  fi
done < /etc/passwd

if [[ "$verify_fail" -eq 0 && "$FAIL" -eq 0 ]]; then
  echo "OK: PASS_WARN_AGE set to ${WARN_DAYS} and user warn days updated (CIS 5.5.1.3)."
  exit 0
else
  echo "FAIL: Password expiration warning days not correctly applied." >&2
  exit 1
fi