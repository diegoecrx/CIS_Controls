# Goal: Disable PermitUserEnvironment in SSH to prevent users from altering environment variables.
# Filename: 5.3.12_ssh_user_env.sh
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
value="no"

[[ ! -f "$cfg" ]] && { echo "ERROR: $cfg not found" >&2; exit 1; }
[[ ! -f "${cfg}.bak" ]] && cp "$cfg" "${cfg}.bak"

if grep -Eiq '^\s*PermitUserEnvironment\b' "$cfg"; then
  sed -i -E 's/^\s*PermitUserEnvironment\s+.*/PermitUserEnvironment '"$value"'/I' "$cfg"
else
  echo "PermitUserEnvironment $value" >> "$cfg"
fi

systemctl reload sshd 2>/dev/null || systemctl reload sshd.service 2>/dev/null || true

if grep -Eq '^\s*PermitUserEnvironment\s+'"$value" "$cfg"; then
  echo "OK: SSH PermitUserEnvironment disabled (CIS 5.3.12)."
  exit 0
else
  echo "FAIL: SSH PermitUserEnvironment directive not set correctly." >&2
  exit 1
fi
