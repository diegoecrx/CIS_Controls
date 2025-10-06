#!/usr/bin/env bash
set -euo pipefail

# Goal: Ensure users' dot files are not group or world writable.
# Filename: 6.2.14_dot_files.sh
# Applicability: Level 1 for both Server and Workstation
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

# This script scans dot files (hidden files beginning with a dot) in interactive
# users' home directories and removes group and world write permissions.  A
# record of modified files and their original permissions is stored in
# /var/backups/dotfile_permission_backup.bak.

# Require root
if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

backup_file="/var/backups/dotfile_permission_backup.bak"
mkdir -p "$(dirname "$backup_file")"
touch "$backup_file"

# Iterate through interactive users' home directories
while IFS= read -r dir; do
  [[ -z "$dir" ]] && continue
  if [[ -d "$dir" ]]; then
    for file in "$dir"/.*; do
      # Skip '.' and '..'
      [[ "$file" == "$dir/." || "$file" == "$dir/.." ]] && continue
      # Operate only on regular files (not symlinks or directories)
      if [[ -f "$file" && ! -h "$file" ]]; then
        fileperm=$(stat -L -c "%A" "$file" || echo "")
        # group write bit (pos 6) and others write bit (pos 9)
        gw=${fileperm:5:1}
        ow=${fileperm:8:1}
        if [[ "$gw" != "-" ]] || [[ "$ow" != "-" ]]; then
          echo "$file had permissions $fileperm" >> "$backup_file"
          chmod go-w "$file"
        fi
      fi
    done
  fi
done < <(
  awk -F: '($1!~/(halt|sync|shutdown|nfsnobody)/ &&
            $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ &&
            $7!~/(\/usr)?\/bin\/false(\/)?$/) {print $6}' /etc/passwd
)

# Verification: ensure no dot files in interactive users' home dirs are group/world writable
fail=0
while IFS= read -r dir; do
  [[ -z "$dir" ]] && continue
  if [[ -d "$dir" ]]; then
    for file in "$dir"/.*; do
      [[ "$file" == "$dir/." || "$file" == "$dir/.." ]] && continue
      if [[ -f "$file" && ! -h "$file" ]]; then
        fileperm=$(stat -L -c "%A" "$file" || echo "")
        gw=${fileperm:5:1}
        ow=${fileperm:8:1}
        if [[ "$gw" != "-" ]] || [[ "$ow" != "-" ]]; then
          fail=1
        fi
      fi
    done
  fi
done < <(
  awk -F: '($1!~/(halt|sync|shutdown|nfsnobody)/ &&
            $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ &&
            $7!~/(\/usr)?\/bin\/false(\/)?$/) {print $6}' /etc/passwd
)

if [[ $fail -eq 0 ]]; then
  echo "OK: No dot files are group or world writable (CIS 6.2.14)."
  exit 0
else
  echo "FAIL: Some dot files still have group or world write permissions." >&2
  exit 1
fi