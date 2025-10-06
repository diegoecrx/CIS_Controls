# Goal: Ensure root is the only account with UID 0 by reassigning other UID 0 accounts to unique non-zero UIDs.
# Filename: 6.2.9_uid0_users.sh
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

# Determine max UID to assign new ones
maxuid=$(cut -d: -f3 /etc/passwd | sort -n | tail -n1)
FAIL=0

while IFS=: read -r user _ uid gid rest; do
  if [[ "$uid" -eq 0 && "$user" != "root" ]]; then
    # assign new UID
    newuid=$((maxuid+1))
    while getent passwd "$newuid" >/dev/null; do
      newuid=$((newuid+1))
    done
    if usermod -u "$newuid" "$user" >/dev/null 2>&1; then
      echo "Changed UID of $user from 0 to $newuid" >&2
      maxuid=$newuid
    else
      echo "ERROR: Failed to change UID for $user" >&2
      FAIL=1
    fi
  fi
done < /etc/passwd

# Verification: ensure only root has UID 0
uid0_others=$(awk -F: '($3==0 && $1!="root"){print $1}' /etc/passwd)
if [[ -z "$uid0_others" && "$FAIL" -eq 0 ]]; then
  echo "OK: root is the only UID 0 account (CIS 6.2.9)."
  exit 0
else
  echo "FAIL: Additional UID 0 accounts still exist or remediation failed: $uid0_others" >&2
  exit 1
fi