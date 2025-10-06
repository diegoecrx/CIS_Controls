# Goal: Limit the number of SSH authentication attempts to reduce brute force attacks.
# Filename: 5.3.7_ssh_maxauth.sh
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
value=${MAX_AUTH_TRIES:-4}

[[ ! -f "$cfg" ]] && { echo "ERROR: $cfg not found" >&2; exit 1; }
[[ ! -f "${cfg}.bak" ]] && cp "$cfg" "${cfg}.bak"

if grep -Eiq '^\s*MaxAuthTries\b' "$cfg"; then
  sed -i -E 's/^\s*MaxAuthTries\s+.*/MaxAuthTries '"$value"'/I' "$cfg"
else
  echo "MaxAuthTries $value" >> "$cfg"
fi

systemctl reload sshd 2>/dev/null || systemctl reload sshd.service 2>/dev/null || true

if grep -Eq '^\s*MaxAuthTries\s+'"$value" "$cfg"; then
  echo "OK: SSH MaxAuthTries set to $value (CIS 5.3.7)."
  exit 0
else
  echo "FAIL: SSH MaxAuthTries not configured correctly." >&2
  exit 1
fi
