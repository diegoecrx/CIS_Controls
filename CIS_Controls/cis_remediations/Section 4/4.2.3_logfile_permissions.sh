#!/usr/bin/env bash
set -euo pipefail

# Goal: Ensure permissions on all log files under /var/log are configured to remove group and world access.
# Filename: 4.2.3_logfile_permissions.sh
# Applicability: Level 1 for both Server and Workstation (manual control)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

# Adjust permissions on existing log files
find /var/log -type f -exec chmod g-wx,o-rwx {} +

# Verification: check for any file with world readable or writable permissions
if find /var/log -type f \( -perm /0022 -o -perm /0002 -o -perm /0020 \) | read -r _; then
  echo "FAIL: Some log files still have group or world access." >&2
  exit 1
else
  echo "OK: Log file permissions configured (CIS 4.2.3)."
  exit 0
fi