# Goal: Configure SSH to limit concurrent unauthenticated connections using MaxStartups.
# Filename: 5.3.21_ssh_maxstartups.sh
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
value=${SSH_MAXSTARTUPS:-"10:30:60"}

[[ ! -f "$cfg" ]] && { echo "ERROR: $cfg not found" >&2; exit 1; }
[[ ! -f "${cfg}.bak" ]] && cp "$cfg" "${cfg}.bak"

if grep -Eiq '^\s*MaxStartups\b' "$cfg"; then
  sed -i -E 's/^\s*MaxStartups\s+.*/MaxStartups '"$value"'/I' "$cfg"
else
  echo "MaxStartups $value" >> "$cfg"
fi

systemctl reload sshd 2>/dev/null || systemctl reload sshd.service 2>/dev/null || true

if grep -Eq '^\s*MaxStartups\s+'"$value" "$cfg"; then
  echo "OK: SSH MaxStartups configured (CIS 5.3.21)."
  exit 0
else
  echo "FAIL: SSH MaxStartups directive not set correctly." >&2
  exit 1
fi
