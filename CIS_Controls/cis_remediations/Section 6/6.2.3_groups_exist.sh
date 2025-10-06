# Goal: Ensure all group IDs referenced in /etc/passwd exist in /etc/group; create missing groups.
# Filename: 6.2.3_groups_exist.sh
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

FAIL=0

# Read group IDs from /etc/passwd and ensure each exists
while IFS=: read -r user _ uid gid _; do
  # Skip system accounts (uid < 100) but still ensure groups exist for all
  if ! getent group "$gid" >/dev/null; then
    # Determine a group name to create
    groupname="$user"
    # If group name already exists with different gid, append suffix
    if getent group "$groupname" >/dev/null; then
      groupname="${user}_grp"
      # ensure this derived name is unique
      i=1
      while getent group "$groupname" >/dev/null; do
        groupname="${user}_grp${i}"
        i=$((i+1))
      done
    fi
    # Create the group
    if ! groupadd -g "$gid" "$groupname" >/dev/null 2>&1; then
      echo "ERROR: Failed to create group $groupname with GID $gid" >&2
      FAIL=1
    fi
  fi
done < /etc/passwd

# Verification: ensure there are no missing groups now
missing=0
while IFS=: read -r _ _ _ gid _; do
  if ! getent group "$gid" >/dev/null; then
    missing=1
    break
  fi
done < /etc/passwd

if [[ "$missing" -eq 0 && "$FAIL" -eq 0 ]]; then
  echo "OK: All groups referenced in /etc/passwd exist in /etc/group (CIS 6.2.3)."
  exit 0
else
  echo "FAIL: Some groups referenced in /etc/passwd do not exist in /etc/group." >&2
  exit 1
fi