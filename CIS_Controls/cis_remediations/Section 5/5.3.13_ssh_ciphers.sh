# Goal: Configure SSH to use only strong ciphers for encrypted communications.
# Filename: 5.3.13_ssh_ciphers.sh
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
default_ciphers="chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr"
ciphers=${SSH_STRONG_CIPHERS:-$default_ciphers}

[[ ! -f "$cfg" ]] && { echo "ERROR: $cfg not found" >&2; exit 1; }
[[ ! -f "${cfg}.bak" ]] && cp "$cfg" "${cfg}.bak"

if grep -Eiq '^\s*Ciphers\b' "$cfg"; then
  sed -i -E 's/^\s*Ciphers\s+.*/Ciphers '"$ciphers"'/I' "$cfg"
else
  echo "Ciphers $ciphers" >> "$cfg"
fi

systemctl reload sshd 2>/dev/null || systemctl reload sshd.service 2>/dev/null || true

if grep -Eq '^\s*Ciphers\s+'"$ciphers" "$cfg"; then
  echo "OK: SSH ciphers set to $ciphers (CIS 5.3.13)."
  exit 0
else
  echo "FAIL: SSH ciphers directive not configured correctly." >&2
  exit 1
fi
