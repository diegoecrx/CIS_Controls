# Goal: Audit SUID executables to detect potentially rogue programs. This is a manual audit.
# Filename: 6.1.13_suid_executables.sh
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

# Find all setuid executables on local filesystem
echo "INFO: Listing SUID executables on the system:" >&2
find / -xdev -perm -4000 -type f 2>/dev/null | sort >&2
echo "OK: Audit of SUID executables completed (CIS 6.1.13). Review the list above for unexpected files." 
exit 0