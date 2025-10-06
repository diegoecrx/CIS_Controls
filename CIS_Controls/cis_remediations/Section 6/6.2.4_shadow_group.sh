# Goal: Ensure the 'shadow' group contains no members and no users use it as their primary group.
# Filename: 6.2.4_shadow_group.sh
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

# Obtain shadow group ID
shadow_gid=$(getent group shadow | awk -F: '{print $3}')
if [[ -z "$shadow_gid" ]]; then
  echo "OK: shadow group does not exist; no action required (CIS 6.2.4)."
  exit 0
fi

# Backup /etc/group before modifying
grp_file="/etc/group"
[[ -f "$grp_file" && ! -f "${grp_file}.bak" ]] && cp "$grp_file" "${grp_file}.bak"

# Remove any users from the shadow group membership list
sed -ri 's/^(shadow:[^:]*:[^:]*:).*/\1/' "$grp_file"

# For users whose primary GID is the shadow group, change to root group (GID 0)
FAIL=0
while IFS=: read -r user pass uid gid rest; do
  if [[ "$gid" == "$shadow_gid" && "$user" != "root" ]]; then
    if ! usermod -g 0 "$user" >/dev/null 2>&1; then
      echo "ERROR: Failed to change primary group for user $user from shadow to root" >&2
      FAIL=1
    fi
  fi
done < /etc/passwd

# Verification
ok=1
# Check group membership list
if getent group shadow | awk -F: '{print $4}' | grep -q '\S'; then
  ok=0
fi
# Check for users with shadow gid
while IFS=: read -r user pass uid gid rest; do
  if [[ "$gid" == "$shadow_gid" && "$user" != "root" ]]; then
    ok=0
    break
  fi
done < /etc/passwd

if [[ "$ok" -eq 1 && "$FAIL" -eq 0 ]]; then
  echo "OK: shadow group has no members and no users have it as primary group (CIS 6.2.4)."
  exit 0
else
  echo "FAIL: shadow group cleanup incomplete." >&2
  exit 1
fi