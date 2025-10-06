# Goal: Ensure no duplicate GIDs exist by assigning unique GIDs to duplicate groups.
# Filename: 6.2.8_duplicate_gids.sh
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

declare -A gid_seen
FAIL=0

# Determine maximum GID in use
maxgid=$(cut -d: -f3 /etc/group | sort -n | tail -n1)

while IFS=: read -r groupname passwd gid members; do
  # Skip root group
  if [[ "$groupname" == "root" ]]; then
    gid_seen[$gid]=$groupname
    continue
  fi
  if [[ -n ${gid_seen[$gid]:-} ]]; then
    # Duplicate GID found; assign new unique GID
    newgid=$((maxgid+1))
    while getent group "$newgid" >/dev/null; do
      newgid=$((newgid+1))
    done
    if groupmod -g "$newgid" "$groupname" >/dev/null 2>&1; then
      echo "Changed GID for group $groupname from $gid to $newgid" >&2
      maxgid=$newgid
    else
      echo "ERROR: Failed to change GID for group $groupname" >&2
      FAIL=1
    fi
  else
    gid_seen[$gid]=$groupname
  fi
done < /etc/group

# Verification
dup_gid=$(cut -d: -f3 /etc/group | sort | uniq -d || true)
if [[ -z "$dup_gid" && "$FAIL" -eq 0 ]]; then
  echo "OK: No duplicate GIDs exist (CIS 6.2.8)."
  exit 0
else
  echo "FAIL: Duplicate GIDs still exist or remediations failed." >&2
  exit 1
fi