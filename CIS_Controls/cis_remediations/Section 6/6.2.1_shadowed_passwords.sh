# Goal: Ensure all account entries in /etc/passwd use shadowed passwords by replacing password field with 'x'.
# Filename: 6.2.1_shadowed_passwords.sh
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

file="/etc/passwd"
# Backup before editing
if [[ -f "$file" && ! -f "${file}.bak" ]]; then
  cp "$file" "${file}.bak"
fi

# Replace password fields that are not 'x' with 'x'
awk -F: 'BEGIN{OFS=":"} {if($2 != "x") $2="x"; print}' "$file" > "${file}.tmp"
mv "${file}.tmp" "$file"

# Verification
bad=0
while IFS=: read -r user pass _; do
  if [[ "$pass" != "x" ]]; then
    bad=1
    break
  fi
done < "$file"

if [[ "$bad" -eq 0 ]]; then
  echo "OK: All accounts in /etc/passwd use shadowed password entries (CIS 6.2.1)."
  exit 0
else
  echo "FAIL: Some accounts in /etc/passwd do not use shadowed passwords." >&2
  exit 1
fi