# Goal: Ensure no duplicate user names exist by renaming duplicate usernames to unique identifiers.
# Filename: 6.2.5_duplicate_usernames.sh
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

# Map to track user names
declare -A seen
FAIL=0

while IFS=: read -r user _; do
  # Skip root
  if [[ "$user" == "root" ]]; then
    continue
  fi
  if [[ -n ${seen[$user]:-} ]]; then
    # Duplicate found; determine new unique username
    idx=${seen[$user]}
    newname="${user}_dup${idx}"
    while getent passwd "$newname" >/dev/null; do
      idx=$((idx+1))
      newname="${user}_dup${idx}"
    done
    # Attempt rename
    if usermod -l "$newname" "$user" >/dev/null 2>&1; then
      echo "Renamed duplicate user $user to $newname" >&2
    else
      echo "ERROR: Failed to rename duplicate user $user to $newname" >&2
      FAIL=1
    fi
    # Track next index for base name
    seen[$user]=$((idx+1))
  else
    # first occurrence
    seen[$user]=1
  fi
done < /etc/passwd

# Verification: ensure each username is unique
dup_check=$(cut -d: -f1 /etc/passwd | sort | uniq -d || true)
if [[ -z "$dup_check" && "$FAIL" -eq 0 ]]; then
  echo "OK: No duplicate user names exist (CIS 6.2.5)."
  exit 0
else
  echo "FAIL: Duplicate usernames still detected or renaming errors occurred." >&2
  exit 1
fi