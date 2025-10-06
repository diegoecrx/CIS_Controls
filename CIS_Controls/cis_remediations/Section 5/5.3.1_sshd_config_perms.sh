# Goal: Secure the SSH daemon configuration file by setting proper ownership and permissions.
# Filename: 5.3.1_sshd_config_perms.sh
# Applicability: Level 1 Workstation, Level 2 Server (as per spreadsheet)
#!/usr/bin/env bash
set -euo pipefail

# According to the profile, Level 1 applies to Workstation and Level 2 applies to Server
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

file="/etc/ssh/sshd_config"
FAIL=0
if [[ -f "$file" ]]; then
  # Backup file once
  [[ ! -f "${file}.bak" ]] && cp "$file" "${file}.bak"
  chown root:root "$file" || FAIL=1
  chmod og-rwx "$file" || FAIL=1
else
  echo "ERROR: $file not found." >&2
  FAIL=1
fi

# Verification
if [[ -f "$file" ]] && [[ $(stat -c %U "$file") == "root" ]] && [[ $(stat -c %G "$file") == "root" ]] && [[ $(stat -c %a "$file") -le 600 ]]; then
  echo "OK: sshd_config ownership and permissions configured (CIS 5.3.1)."
  exit 0
else
  echo "FAIL: sshd_config ownership or permissions incorrect." >&2
  exit 1
fi
