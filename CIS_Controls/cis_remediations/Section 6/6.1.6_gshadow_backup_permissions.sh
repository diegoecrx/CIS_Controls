# Goal: Ensure ownership and permissions on /etc/gshadow- backup file are configured securely.
# Filename: 6.1.6_gshadow_backup_permissions.sh
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

file="/etc/gshadow-"
if [[ -e "$file" ]]; then
  [[ ! -f "${file}.bak" ]] && cp "$file" "${file}.bak"
  chown root:root "$file"
  chmod 0000 "$file"
fi

# Verification
if [[ -e "$file" ]]; then
  perm=$(stat -c %a "$file")
  owner=$(stat -c %U "$file")
  group=$(stat -c %G "$file")
  if [[ "$owner" == "root" && "$group" == "root" && "$perm" == "0" ]]; then
    echo "OK: /etc/gshadow- permissions and ownership configured correctly (CIS 6.1.6)."
    exit 0
  else
    echo "FAIL: /etc/gshadow- permissions or ownership incorrect (owner=$owner, group=$group, mode=$perm)." >&2
    exit 1
  fi
else
  echo "OK: /etc/gshadow- does not exist; nothing to configure (CIS 6.1.6)."
  exit 0
fi