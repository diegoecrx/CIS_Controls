#!/usr/bin/env bash
set -euo pipefail

# Goal: Ensure no users (excluding root) have .rhosts files.
# Filename: 6.2.17_rhosts_files.sh
# Applicability: Level 1 for both Server and Workstation
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

# This script iterates over interactive users (excluding root) and removes any
# .rhosts files found in their home directories.  Before deletion, the file
# contents are backed up to a file with a .bak extension.  A record of
# removals is stored in /var/backups/rhosts_files_backup.bak.

# Require root
if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

backup_file="/var/backups/rhosts_files_backup.bak"
mkdir -p "$(dirname "$backup_file")"
touch "$backup_file"

# Iterate through applicable users' home directories
while IFS= read -r dir; do
  [[ -z "$dir" ]] && continue
  if [[ -d "$dir" ]]; then
    file="$dir/.rhosts"
    if [[ -f "$file" && ! -h "$file" ]]; then
      # Backup before removal
      if [[ ! -f "$file.bak" ]]; then
        cp "$file" "$file.bak"
        echo "$file backed up to $file.bak" >> "$backup_file"
      fi
      rm -f "$file"
    fi
  fi
done < <(
  awk -F: '($1!~/(root|halt|sync|shutdown|nfsnobody)/ &&
            $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ &&
            $7!~/(\/usr)?\/bin\/false(\/)?$/) {print $6}' /etc/passwd
)

# Verification: ensure no .rhosts files exist for applicable users
fail=0
while IFS= read -r dir; do
  [[ -z "$dir" ]] && continue
  if [[ -d "$dir" ]]; then
    file="$dir/.rhosts"
    if [[ -f "$file" && ! -h "$file" ]]; then
      fail=1
    fi
  fi
done < <(
  awk -F: '($1!~/(root|halt|sync|shutdown|nfsnobody)/ &&
            $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ &&
            $7!~/(\/usr)?\/bin\/false(\/)?$/) {print $6}' /etc/passwd
)

if [[ $fail -eq 0 ]]; then
  echo "OK: No .rhosts files exist for non-root interactive users (CIS 6.2.17)."
  exit 0
else
  echo "FAIL: Some .rhosts files still exist." >&2
  exit 1
fi