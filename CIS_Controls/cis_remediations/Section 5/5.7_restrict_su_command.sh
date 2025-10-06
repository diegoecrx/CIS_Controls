# Goal: Restrict access to the su command to a specified group by configuring PAM and group membership.
# Filename: 5.7_restrict_su_command.sh
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

# Group to restrict su access. Override SU_GROUP environment variable to specify another group.
SU_GROUP=${SU_GROUP:-sugroup}

# Create group if it does not exist
if ! getent group "$SU_GROUP" >/dev/null; then
  groupadd "$SU_GROUP" >/dev/null 2>&1 || true
fi

su_file="/etc/pam.d/su"
# Backup pam su file
[[ -f "$su_file" && ! -f "${su_file}.bak" ]] && cp "$su_file" "${su_file}.bak"

# Remove existing pam_wheel.so lines to avoid duplicates
sed -i '/pam_wheel\.so/d' "$su_file"

# Insert required pam_wheel.so line to restrict su to the group
echo "auth required pam_wheel.so use_uid group=${SU_GROUP}" >> "$su_file"

# Verification
verify_fail=0
if ! getent group "$SU_GROUP" >/dev/null; then
  verify_fail=1
fi
if ! grep -q "pam_wheel.so.*group=${SU_GROUP}" "$su_file"; then
  verify_fail=1
fi

if [[ "$verify_fail" -eq 0 ]]; then
  echo "OK: Access to su command restricted to group ${SU_GROUP} (CIS 5.7)."
  exit 0
else
  echo "FAIL: su command restriction not correctly configured." >&2
  exit 1
fi