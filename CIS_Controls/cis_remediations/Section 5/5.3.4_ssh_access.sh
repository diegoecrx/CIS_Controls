# Goal: Limit SSH access to specific users or groups by configuring AllowUsers.
# Filename: 5.3.4_ssh_access.sh
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

cfg="/etc/ssh/sshd_config"
ALLOW_USERS=${SSH_ALLOWED_USERS:-root}

if [[ ! -f "$cfg" ]]; then
  echo "ERROR: $cfg not found." >&2
  exit 1
fi

# Backup
[[ ! -f "${cfg}.bak" ]] && cp "$cfg" "${cfg}.bak"

# Determine if any of the access control directives are already set (non-commented)
if ! grep -Eiq '^\s*(AllowUsers|AllowGroups|DenyUsers|DenyGroups)\b' "$cfg"; then
  echo "AllowUsers ${ALLOW_USERS}" >> "$cfg"
fi

# Reload sshd if available
systemctl reload sshd 2>/dev/null || systemctl reload sshd.service 2>/dev/null || true

# Verification
if grep -Eiq '^\s*(AllowUsers|AllowGroups|DenyUsers|DenyGroups)\b' "$cfg"; then
  echo "OK: SSH access directives configured (CIS 5.3.4)."
  exit 0
else
  echo "FAIL: SSH access directives not configured." >&2
  exit 1
fi
