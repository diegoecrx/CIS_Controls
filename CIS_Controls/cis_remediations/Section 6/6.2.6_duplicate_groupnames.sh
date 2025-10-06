# Goal: Ensure no duplicate group names exist by renaming duplicate groups to unique names.
# Filename: 6.2.6_duplicate_groupnames.sh
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

declare -A seen
FAIL=0

while IFS=: read -r groupname _ gid _; do
  # Skip root group
  if [[ "$groupname" == "root" ]]; then
    continue
  fi
  if [[ -n ${seen[$groupname]:-} ]]; then
    # duplicate group
    idx=${seen[$groupname]}
    newname="${groupname}_dup${idx}"
    while getent group "$newname" >/dev/null; do
      idx=$((idx+1))
      newname="${groupname}_dup${idx}"
    done
    if groupmod -n "$newname" "$groupname" >/dev/null 2>&1; then
      echo "Renamed duplicate group $groupname to $newname" >&2
    else
      echo "ERROR: Failed to rename group $groupname to $newname" >&2
      FAIL=1
    fi
    seen[$groupname]=$((idx+1))
  else
    seen[$groupname]=1
  fi
done < /etc/group

# Verification
dup_check=$(cut -d: -f1 /etc/group | sort | uniq -d || true)
if [[ -z "$dup_check" && "$FAIL" -eq 0 ]]; then
  echo "OK: No duplicate group names exist (CIS 6.2.6)."
  exit 0
else
  echo "FAIL: Duplicate group names still detected or renaming errors occurred." >&2
  exit 1
fi