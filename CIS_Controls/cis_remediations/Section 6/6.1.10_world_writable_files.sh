# Goal: Ensure no world writable files exist by removing write permission for 'other' on all regular files.
# Filename: 6.1.10_world_writable_files.sh
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

# Find all regular files on the local filesystem that are world writable and remove the write bit for others.
FAIL=0
while IFS= read -r -d '' file; do
  # Backup each file once
  if [[ -f "$file" && ! -f "${file}.bak" ]]; then
    cp "$file" "${file}.bak"
  fi
  chmod o-w "$file" || FAIL=1
done < <(find / -xdev -type f -perm -0002 -print0 2>/dev/null)

# Verification: ensure no world writable regular files remain
if find / -xdev -type f -perm -0002 -print -quit 2>/dev/null | grep -q .; then
  echo "FAIL: World writable files still exist after remediation." >&2
  exit 1
else
  if [[ "$FAIL" -eq 0 ]]; then
    echo "OK: World writable files removed or corrected (CIS 6.1.10)."
    exit 0
  else
    echo "FAIL: Errors occurred while removing world writable permissions." >&2
    exit 1
  fi
fi