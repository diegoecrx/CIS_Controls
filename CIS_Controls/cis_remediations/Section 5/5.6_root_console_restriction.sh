# Goal: Ensure root login is restricted to system consoles. This control is manual and requires administrative review.
# Filename: 5.6_root_console_restriction.sh
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

# This control is manual.  It audits the /etc/securetty file and reports entries.
# Administrators should remove any console names that are not in a physically secure location.

securetty="/etc/securetty"
if [[ ! -f "$securetty" ]]; then
  echo "OK: /etc/securetty does not exist; root login is restricted by default (CIS 5.6)."
  exit 0
fi

echo "INFO: Contents of $securetty:" >&2
cat "$securetty" >&2
echo "INFO: Review the above consoles and remove entries that are not in physically secure locations." >&2

# Always exit 0 for manual control after outputting guidance
echo "OK: Manual review required for root console restrictions (CIS 5.6)."
exit 0