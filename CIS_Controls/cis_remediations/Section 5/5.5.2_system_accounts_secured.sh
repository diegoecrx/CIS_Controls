# Goal: Ensure system accounts (UID below UID_MIN) are secured by using a nologin shell and locking accounts.
# Filename: 5.5.2_system_accounts_secured.sh
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

# Determine UID_MIN from login.defs
login_defs="/etc/login.defs"
UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' "$login_defs" 2>/dev/null || echo 1000)

# Path to nologin
NOLOGIN=$(which nologin || echo "/sbin/nologin")

FAIL=0

# Iterate over system accounts (UID < UID_MIN)
while IFS=: read -r user _ uid _ _ _ shell; do
  # Skip root and special accounts that must remain functional
  if [[ "$user" == "root" || "$user" == "sync" || "$user" == "shutdown" || "$user" == "halt" ]]; then
    continue
  fi
  if (( uid < UID_MIN )); then
    # Ensure shell is nologin or /bin/false or /usr/bin/false
    case "$shell" in
      "$NOLOGIN"|"/bin/false"|"/usr/bin/false") : ;;
      *)
        if ! usermod -s "$NOLOGIN" "$user" >/dev/null 2>&1; then
          echo "ERROR: Failed to set shell for $user" >&2
          FAIL=1
        fi
        ;;
    esac
    # Ensure account is locked
    lock_status=$(passwd -S "$user" 2>/dev/null | awk '{print $2}')
    if [[ "$lock_status" != "L" && "$lock_status" != "LK" ]]; then
      if ! usermod -L "$user" >/dev/null 2>&1; then
        echo "ERROR: Failed to lock system account $user" >&2
        FAIL=1
      fi
    fi
  fi
done < /etc/passwd

# Verification
verify_fail=0
while IFS=: read -r user _ uid _ _ _ shell; do
  if [[ "$user" == "root" || "$user" == "sync" || "$user" == "shutdown" || "$user" == "halt" ]]; then
    continue
  fi
  if (( uid < UID_MIN )); then
    case "$shell" in
      "$NOLOGIN"|"/bin/false"|"/usr/bin/false") : ;;
      *) verify_fail=1;;
    esac
    lock_status=$(passwd -S "$user" 2>/dev/null | awk '{print $2}')
    if [[ "$lock_status" != "L" && "$lock_status" != "LK" ]]; then
      verify_fail=1
    fi
  fi
done < /etc/passwd

if [[ "$verify_fail" -eq 0 && "$FAIL" -eq 0 ]]; then
  echo "OK: System accounts secured with nologin shell and locked (CIS 5.5.2)."
  exit 0
else
  echo "FAIL: One or more system accounts are not properly secured." >&2
  exit 1
fi