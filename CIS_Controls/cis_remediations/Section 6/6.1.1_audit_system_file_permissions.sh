# Goal: Audit system file permissions to identify unauthorized changes. This is a manual control that collects audit data for review.
# Filename: 6.1.1_audit_system_file_permissions.sh
# Applicability: Level 2 for Server and Workstation (from Profile Applicability)
#!/usr/bin/env bash
set -euo pipefail

# Applicability flags derived from Profile Applicability (Level 2 - Server/Workstation)
APPLIES_L1=0
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

# Ensure script runs as root
if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

# Perform an audit of system file permissions using rpm verification. The options skip time, size and MD5 to focus on permission changes.
audit_output="$(rpm -Va --nomtime --nosize --nomd5)"

if [[ -z "$audit_output" ]]; then
  echo "OK: No discrepancies in system file permissions were detected (CIS 6.1.1)."
else
  echo "INFO: The following files have permission discrepancies:" >&2
  echo "$audit_output" >&2
  echo "OK: Audit completed. Please investigate the above discrepancies manually (CIS 6.1.1)."
fi

exit 0