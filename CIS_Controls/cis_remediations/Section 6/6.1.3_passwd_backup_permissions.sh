# Goal: Ensure ownership and permissions on /etc/passwd- backup file are configured securely.
# Filename: 6.1.3_passwd_backup_permissions.sh
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

file="/etc/passwd-"
if [[ -e "$file" ]]; then
  [[ ! -f "${file}.bak" ]] && cp "$file" "${file}.bak"
  chown root:root "$file"
  # Remove user execute; remove group write and others write
  chmod u-x,go-wx "$file"
fi

# Verification
if [[ -e "$file" ]]; then
  perm=$(stat -c %a "$file")
  owner=$(stat -c %U "$file")
  group=$(stat -c %G "$file")
  if [[ "$owner" == "root" && "$group" == "root" && "$perm" == "644" ]]; then
    echo "OK: /etc/passwd- permissions and ownership configured correctly (CIS 6.1.3)."
    exit 0
  else
    echo "FAIL: /etc/passwd- permissions or ownership incorrect (owner=$owner, group=$group, mode=$perm)." >&2
    exit 1
  fi
else
  echo "OK: /etc/passwd- does not exist; nothing to configure (CIS 6.1.3)."
  exit 0
fi