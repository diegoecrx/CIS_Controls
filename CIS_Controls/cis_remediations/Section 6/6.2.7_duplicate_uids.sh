# Goal: Ensure no duplicate UIDs exist by assigning unique UIDs to duplicate accounts.
# Filename: 6.2.7_duplicate_uids.sh
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

declare -A uid_seen
FAIL=0

# Determine maximum UID currently in use to assign new UIDs
maxuid=$(cut -d: -f3 /etc/passwd | sort -n | tail -n1)

while IFS=: read -r user _ uid gid rest; do
  # Skip root user
  if [[ "$user" == "root" ]]; then
    uid_seen[$uid]=$user
    continue
  fi
  if [[ -n ${uid_seen[$uid]:-} ]]; then
    # Duplicate UID found; assign new unique UID
    newuid=$((maxuid+1))
    while getent passwd "$newuid" >/dev/null; do
      newuid=$((newuid+1))
    done
    if usermod -u "$newuid" "$user" >/dev/null 2>&1; then
      echo "Changed UID for $user from $uid to $newuid" >&2
      maxuid=$newuid
    else
      echo "ERROR: Failed to change UID for user $user" >&2
      FAIL=1
    fi
  else
    uid_seen[$uid]=$user
  fi
done < /etc/passwd

# Verification: ensure UIDs unique
dup_uid=$(cut -d: -f3 /etc/passwd | sort | uniq -d || true)
if [[ -z "$dup_uid" && "$FAIL" -eq 0 ]]; then
  echo "OK: No duplicate UIDs exist (CIS 6.2.7)."
  exit 0
else
  echo "FAIL: Duplicate UIDs still exist or remediations failed." >&2
  exit 1
fi