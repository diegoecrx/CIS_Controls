# Goal: Ensure the sudo package is installed so delegated administrative access is available.
# Filename: 5.2.1_sudo.sh
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

FAIL=0
if ! rpm -q sudo >/dev/null 2>&1; then
  yum install -y sudo >/dev/null 2>&1 || FAIL=1
fi

if rpm -q sudo >/dev/null 2>&1; then
  echo "OK: sudo package installed (CIS 5.2.1)."
  exit 0
else
  echo "FAIL: sudo package not installed." >&2
  exit 1
fi
