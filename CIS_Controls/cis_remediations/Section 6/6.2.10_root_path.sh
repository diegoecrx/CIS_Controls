# Goal: Ensure root's PATH integrity by correcting insecure directory permissions.
# Filename: 6.2.10_root_path.sh
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

PATH_FILE_BACKUP="/var/backups/root_path_perm.bak"
mkdir -p /var/backups

fail=0

# Iterate through directories in PATH
IFS=: read -ra pathdirs <<< "$PATH"
for dir in "${pathdirs[@]}"; do
  # Reject empty entries or '.' entries as insecure
  if [[ -z "$dir" || "$dir" == "." ]]; then
    echo "WARNING: PATH contains empty or current-directory entry: '$dir'" >&2
    fail=1
    continue
  fi
  # Ensure directory exists
  if [[ ! -d "$dir" ]]; then
    echo "WARNING: PATH directory $dir does not exist" >&2
    fail=1
    continue
  fi
  # Backup original permissions if not already backed up
  if [[ ! -f "$PATH_FILE_BACKUP" ]]; then
    : > "$PATH_FILE_BACKUP"
  fi
  if ! grep -q "^$dir " "$PATH_FILE_BACKUP"; then
    mode=$(stat -c %a "$dir")
    echo "$dir $mode" >> "$PATH_FILE_BACKUP"
  fi
  # Check and correct world and group writable bits
  perm=$(stat -c %a "$dir")
  owner=$(( perm / 100 ))
  group=$(( (perm / 10) % 10 ))
  other=$(( perm % 10 ))
  if (( other >= 2 )); then
    chmod o-w "$dir"
  fi
  if (( group >= 2 )); then
    chmod g-w "$dir"
  fi
done

# Verification
verify_fail=0
IFS=: read -ra pathdirs <<< "$PATH"
for dir in "${pathdirs[@]}"; do
  if [[ -z "$dir" || "$dir" == "." || ! -d "$dir" ]]; then
    verify_fail=1
    continue
  fi
  perm=$(stat -c %a "$dir")
  group=$(( (perm / 10) % 10 ))
  other=$(( perm % 10 ))
  if (( other >= 2 || group >= 2 )); then
    verify_fail=1
  fi
done

if [[ "$verify_fail" -eq 0 && "$fail" -eq 0 ]]; then
  echo "OK: Root PATH directories are secure (CIS 6.2.10)."
  exit 0
else
  echo "FAIL: Root PATH contains insecure elements or directories with improper permissions." >&2
  exit 1
fi