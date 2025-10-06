# Goal: Ensure there are no files or directories without a group; assign ungrouped items to root group.
# Filename: 6.1.12_ungrouped_files.sh
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
# Find ungrouped files or directories and change group to root
while IFS= read -r -d '' item; do
  # Backup if regular file
  if [[ -f "$item" && ! -f "${item}.bak" ]]; then
    cp "$item" "${item}.bak"
  fi
  chgrp root "$item" || FAIL=1
done < <(find / -xdev \( -type f -o -type d \) -nogroup -print0 2>/dev/null)

# Verification: ensure no ungrouped items remain
if find / -xdev \( -type f -o -type d \) -nogroup -print -quit 2>/dev/null | grep -q .; then
  echo "FAIL: Ungrouped files or directories still exist after remediation." >&2
  exit 1
else
  if [[ "$FAIL" -eq 0 ]]; then
    echo "OK: All ungrouped files and directories have been assigned to the root group (CIS 6.1.12)."
    exit 0
  else
    echo "FAIL: Errors occurred while correcting ungrouped files/directories." >&2
    exit 1
  fi
fi