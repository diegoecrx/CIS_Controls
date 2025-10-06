# Goal: Configure SSH to use only strong key exchange algorithms (KexAlgorithms).
# Filename: 5.3.15_ssh_kex.sh
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
default_kex="curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256"
kex=${SSH_STRONG_KEX:-$default_kex}

[[ ! -f "$cfg" ]] && { echo "ERROR: $cfg not found" >&2; exit 1; }
[[ ! -f "${cfg}.bak" ]] && cp "$cfg" "${cfg}.bak"

if grep -Eiq '^\s*KexAlgorithms\b' "$cfg"; then
  sed -i -E 's/^\s*KexAlgorithms\s+.*/KexAlgorithms '"$kex"'/I' "$cfg"
else
  echo "KexAlgorithms $kex" >> "$cfg"
fi

systemctl reload sshd 2>/dev/null || systemctl reload sshd.service 2>/dev/null || true

if grep -Eq '^\s*KexAlgorithms\s+'"$kex" "$cfg"; then
  echo "OK: SSH key exchange algorithms set to $kex (CIS 5.3.15)."
  exit 0
else
  echo "FAIL: SSH key exchange algorithms not configured correctly." >&2
  exit 1
fi
