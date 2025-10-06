# Goal: Ensure all password fields in /etc/shadow are not empty by locking accounts with empty passwords.
# Filename: 6.2.2_shadow_passwords.sh
# Applicability: Level 1 for Server and Workstation
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

# Identify accounts in /etc/shadow with empty password fields and lock them
FAIL=0
while IFS=: read -r user pass _; do
  # Skip system accounts that may legitimately have empty passwords (like nologin) only if user starts with '#': not necessary
  if [[ -z "$pass" ]]; then
    # Lock the account to prevent login
    passwd -l "$user" >/dev/null 2>&1 || FAIL=1
  fi
done < /etc/shadow

# Verification: ensure no empty password fields remain
empty_found=0
grep -q '^[^:]*::' /etc/shadow && empty_found=1

if [[ "$empty_found" -eq 0 && "$FAIL" -eq 0 ]]; then
  echo "OK: No empty password fields remain in /etc/shadow (CIS 6.2.2)."
  exit 0
else
  echo "FAIL: Some /etc/shadow entries still have empty password fields or failed to lock." >&2
  exit 1
fi