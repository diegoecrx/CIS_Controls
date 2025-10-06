#!/usr/bin/env bash
set -euo pipefail

# Goal: Ensure users own their home directories and create missing directories.
# Filename: 6.2.12_home_ownership.sh
# Applicability: Level 1 for both Server and Workstation
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

# This script checks every interactive user on the system and verifies that the
# user's home directory exists and is owned by the correct user.  If a home
# directory is missing, it is created with restrictive permissions.  If a home
# directory exists but is not owned by the corresponding user, ownership is
# corrected and group/other write access is removed.  A backup record of any
# ownership changes is stored in /var/backups/home_owner_backup.bak.

# Require root
if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

backup_file="/var/backups/home_owner_backup.bak"
mkdir -p "$(dirname "$backup_file")"
touch "$backup_file"

# Iterate through all interactive users (exclude system service accounts)
while IFS=" " read -r user dir; do
  # Skip empty home directories paths
  [[ -z "$dir" ]] && continue
  if [[ ! -d "$dir" ]]; then
    # Create missing home directory
    mkdir -p "$dir"
    # Set directory permissions to remove group write and all permissions for others
    chmod g-w,o-rwx "$dir"
    # Set ownership to the user
    chown "$user" "$dir"
  else
    # Check directory owner
    owner=$(stat -L -c "%U" "$dir" || echo "")
    if [[ "$owner" != "$user" ]]; then
      # Record the previous owner in backup file
      echo "$dir was owned by $owner" >> "$backup_file"
      # Remove group write and all permissions for others
      chmod g-w,o-rwx "$dir"
      # Correct the owner
      chown "$user" "$dir"
    fi
  fi
done < <(
  awk -F: '($1!~/(halt|sync|shutdown|nfsnobody)/ &&
            $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ &&
            $7!~/(\/usr)?\/bin\/false(\/)?$/) { print $1, $6 }' /etc/passwd
)

# Verification
fail=0
while IFS=" " read -r user dir; do
  [[ -z "$dir" ]] && continue
  if [[ -d "$dir" ]]; then
    owner=$(stat -L -c "%U" "$dir" || echo "")
    if [[ "$owner" != "$user" ]]; then
      fail=1
    fi
  fi
done < <(
  awk -F: '($1!~/(halt|sync|shutdown|nfsnobody)/ &&
            $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ &&
            $7!~/(\/usr)?\/bin\/false(\/)?$/) { print $1, $6 }' /etc/passwd
)

if [[ $fail -eq 0 ]]; then
  echo "OK: All home directories are owned by their respective users (CIS 6.2.12)."
  exit 0
else
  echo "FAIL: Some home directories are not owned by the correct user." >&2
  exit 1
fi