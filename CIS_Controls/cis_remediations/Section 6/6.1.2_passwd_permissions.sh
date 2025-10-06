# Goal: Ensure ownership and permissions on /etc/passwd are configured securely.
# Filename: 6.1.2_passwd_permissions.sh
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
# Backup file if not already backed up
if [[ -f "$file" && ! -f "${file}.bak" ]]; then
  cp "$file" "${file}.bak"
fi

# Set ownership to root:root
chown root:root "$file"

# Set permissions: remove user execute, remove group write/execute, remove others write/execute
chmod u-x,g-wx,o-wx "$file"

# Verification
perm=$(stat -c %a "$file")
owner=$(stat -c %U "$file")
group=$(stat -c %G "$file")
if [[ "$owner" == "root" && "$group" == "root" && "$perm" == "644" ]]; then
  echo "OK: /etc/passwd permissions and ownership configured correctly (CIS 6.1.2)."
  exit 0
else
  echo "FAIL: /etc/passwd permissions or ownership incorrect (owner=$owner, group=$group, mode=$perm)." >&2
  exit 1
fi