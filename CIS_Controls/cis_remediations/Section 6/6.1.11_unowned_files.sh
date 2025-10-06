# Goal: Ensure there are no files or directories without an owner; assign unowned items to root.
# Filename: 6.1.11_unowned_files.sh
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
# Find unowned files or directories on local filesystem and change ownership to root
while IFS= read -r -d '' item; do
  # Backup if regular file
  if [[ -f "$item" && ! -f "${item}.bak" ]]; then
    cp "$item" "${item}.bak"
  fi
  chown root "$item" || FAIL=1
done < <(find / -xdev \( -type f -o -type d \) -nouser -print0 2>/dev/null)

# Verification: ensure no unowned items remain
if find / -xdev \( -type f -o -type d \) -nouser -print -quit 2>/dev/null | grep -q .; then
  echo "FAIL: Unowned files or directories still exist after remediation." >&2
  exit 1
else
  if [[ "$FAIL" -eq 0 ]]; then
    echo "OK: All unowned files and directories have been assigned to root (CIS 6.1.11)."
    exit 0
  else
    echo "FAIL: Errors occurred while correcting unowned files/directories." >&2
    exit 1
  fi
fi