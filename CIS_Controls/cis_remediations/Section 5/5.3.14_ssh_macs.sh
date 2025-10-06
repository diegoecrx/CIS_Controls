# Goal: Configure SSH to use only strong MAC algorithms.
# Filename: 5.3.14_ssh_macs.sh
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
default_macs="hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256"
macs=${SSH_STRONG_MACS:-$default_macs}

[[ ! -f "$cfg" ]] && { echo "ERROR: $cfg not found" >&2; exit 1; }
[[ ! -f "${cfg}.bak" ]] && cp "$cfg" "${cfg}.bak"

if grep -Eiq '^\s*MACs\b' "$cfg"; then
  sed -i -E 's/^\s*MACs\s+.*/MACs '"$macs"'/I' "$cfg"
else
  echo "MACs $macs" >> "$cfg"
fi

systemctl reload sshd 2>/dev/null || systemctl reload sshd.service 2>/dev/null || true

if grep -Eq '^\s*MACs\s+'"$macs" "$cfg"; then
  echo "OK: SSH MAC algorithms set to $macs (CIS 5.3.14)."
  exit 0
else
  echo "FAIL: SSH MAC algorithms not configured correctly." >&2
  exit 1
fi
