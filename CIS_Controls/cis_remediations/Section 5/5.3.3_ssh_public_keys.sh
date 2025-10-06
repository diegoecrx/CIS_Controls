# Goal: Ensure SSH host public key files are owned by root and have secure permissions.
# Filename: 5.3.3_ssh_public_keys.sh
# Applicability: Level 1 Workstation, Level 2 Server
#!/usr/bin/env bash
set -euo pipefail

APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

FAIL=0
find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' 2>/dev/null | while read -r key; do
  [[ ! -f "${key}.bak_perm" ]] && stat -c "%a %U %G" "$key" > "${key}.bak_perm" || true
  # Remove execute bit from owner and write/execute from group/others
  chmod u-x,go-wx "$key" || FAIL=1
  chown root:root "$key" || FAIL=1
done

bad=0
for key in $(find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' 2>/dev/null); do
  [[ $(stat -c %U "$key") == "root" ]] || bad=1
  [[ $(stat -c %G "$key") == "root" ]] || bad=1
  # Mode should be at most 644
  [[ $(stat -c %a "$key") -le 644 ]] || bad=1
done
if [[ $bad -eq 0 ]]; then
  echo "OK: SSH public host keys secured (CIS 5.3.3)."
  exit 0
else
  echo "FAIL: One or more public host keys have incorrect ownership or permissions." >&2
  exit 1
fi
