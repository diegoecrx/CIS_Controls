# Goal: Enable PAM integration in SSH to leverage system authentication modules.
# Filename: 5.3.19_ssh_pam.sh
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
value="yes"

[[ ! -f "$cfg" ]] && { echo "ERROR: $cfg not found" >&2; exit 1; }
[[ ! -f "${cfg}.bak" ]] && cp "$cfg" "${cfg}.bak"

if grep -Eiq '^\s*UsePAM\b' "$cfg"; then
  sed -i -E 's/^\s*UsePAM\s+.*/UsePAM '"$value"'/I' "$cfg"
else
  echo "UsePAM $value" >> "$cfg"
fi

systemctl reload sshd 2>/dev/null || systemctl reload sshd.service 2>/dev/null || true

if grep -Eq '^\s*UsePAM\s+'"$value" "$cfg"; then
  echo "OK: SSH UsePAM enabled (CIS 5.3.19)."
  exit 0
else
  echo "FAIL: SSH UsePAM directive not set correctly." >&2
  exit 1
fi
