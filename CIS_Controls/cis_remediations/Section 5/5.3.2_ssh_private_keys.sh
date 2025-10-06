# Goal: Ensure SSH host private keys are owned by root and are not readable by group or others.
# Filename: 5.3.2_ssh_private_keys.sh
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
# Find private host key files
find /etc/ssh -xdev -type f -name 'ssh_host_*_key' 2>/dev/null | while read -r key; do
  # Backup permission info
  [[ ! -f "${key}.bak_perm" ]] && stat -c "%a %U %G" "$key" > "${key}.bak_perm" || true
  chown root:root "$key" || FAIL=1
  chmod u-x,go-rwx "$key" || FAIL=1
done

# Verification: ensure there are private keys and all meet criteria
bad=0
for key in $(find /etc/ssh -xdev -type f -name 'ssh_host_*_key' 2>/dev/null); do
  [[ $(stat -c %U "$key") == "root" ]] || bad=1
  [[ $(stat -c %G "$key") == "root" ]] || bad=1
  [[ $(stat -c %a "$key") -le 600 ]] || bad=1
done
if [[ $bad -eq 0 ]]; then
  echo "OK: SSH private host keys secured (CIS 5.3.2)."
  exit 0
else
  echo "FAIL: One or more private host keys have incorrect ownership or permissions." >&2
  exit 1
fi
