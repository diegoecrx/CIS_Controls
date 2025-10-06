#!/usr/bin/env bash
set -euo pipefail

# Goal: Ensure users' home directories have permissions of 750 or more restrictive.
# Filename: 6.2.13_home_permissions.sh
# Applicability: Level 1 for both Server and Workstation
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

# This script audits the permissions on interactive users' home directories and
# removes any permissions in excess of 750.  Specifically, it strips group write
# permissions and all permissions for others.  A backup record of directories
# adjusted is stored in /var/backups/home_permission_backup.bak.

# Require root
if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

backup_file="/var/backups/home_permission_backup.bak"
mkdir -p "$(dirname "$backup_file")"
touch "$backup_file"

# Iterate through interactive users' home directories
while IFS= read -r dir; do
  [[ -z "$dir" ]] && continue
  if [[ -d "$dir" ]]; then
    dirperm=$(stat -L -c "%A" "$dir" || echo "")
    # Extract permission bits: positions correspond to rwxrwxrwx for directories
    gw=${dirperm:5:1}
    or8=${dirperm:7:1}
    or9=${dirperm:8:1}
    or10=${dirperm:9:1}
    # Note: for directories, stat -c "%A" returns 10 characters (e.g., drwxr-xr-x)
    # Indexing in bash strings starts at 0; we want characters 5,7,8,9 (0-based) for group write and others read/write/exec
    if [[ "$gw" != "-" ]] || [[ "$or8" != "-" ]] || [[ "$or9" != "-" ]] || [[ "$or10" != "-" ]]; then
      # Record original permissions
      echo "$dir had permissions $dirperm" >> "$backup_file"
      # Remove group write and all others permissions
      chmod g-w,o-rwx "$dir"
    fi
  fi
done < <(
  awk -F: '($1!~/(halt|sync|shutdown|nfsnobody)/ &&
            $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ &&
            $7!~/(\/usr)?\/bin\/false(\/)?$/) {print $6}' /etc/passwd
)

# Verification: check if any home directories still have permissions more permissive than 750
fail=0
while IFS= read -r dir; do
  [[ -z "$dir" ]] && continue
  if [[ -d "$dir" ]]; then
    dirperm=$(stat -L -c "%A" "$dir" || echo "")
    gw=${dirperm:5:1}
    or8=${dirperm:7:1}
    or9=${dirperm:8:1}
    or10=${dirperm:9:1}
    if [[ "$gw" != "-" ]] || [[ "$or8" != "-" ]] || [[ "$or9" != "-" ]] || [[ "$or10" != "-" ]]; then
      fail=1
    fi
  fi
done < <(
  awk -F: '($1!~/(halt|sync|shutdown|nfsnobody)/ &&
            $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ &&
            $7!~/(\/usr)?\/bin\/false(\/)?$/) {print $6}' /etc/passwd
)

if [[ $fail -eq 0 ]]; then
  echo "OK: Home directory permissions are 750 or more restrictive for all users (CIS 6.2.13)."
  exit 0
else
  echo "FAIL: Some home directories have permissions more permissive than 750." >&2
  exit 1
fi