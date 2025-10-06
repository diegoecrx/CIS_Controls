# Goal: Ensure the default group for the root account is GID 0.
# Filename: 5.5.3_root_default_group.sh
# Applicability: Level 1 for Server and Workstation
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

# Check current root GID and change if necessary
root_gid=$(id -g root)
if [[ "$root_gid" -ne 0 ]]; then
  usermod -g 0 root >/dev/null 2>&1 || true
fi

# Verification
new_gid=$(id -g root)
if [[ "$new_gid" -eq 0 ]]; then
  echo "OK: Root default group is GID 0 (CIS 5.5.3)."
  exit 0
else
  echo "FAIL: Root default group is not GID 0." >&2
  exit 1
fi