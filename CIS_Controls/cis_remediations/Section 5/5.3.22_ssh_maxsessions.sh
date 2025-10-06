# Goal: Limit the number of open SSH sessions to prevent resource exhaustion.
# Filename: 5.3.22_ssh_maxsessions.sh
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
value=${SSH_MAXSESSIONS:-10}

[[ ! -f "$cfg" ]] && { echo "ERROR: $cfg not found" >&2; exit 1; }
[[ ! -f "${cfg}.bak" ]] && cp "$cfg" "${cfg}.bak"

if grep -Eiq '^\s*MaxSessions\b' "$cfg"; then
  sed -i -E 's/^\s*MaxSessions\s+.*/MaxSessions '"$value"'/I' "$cfg"
else
  echo "MaxSessions $value" >> "$cfg"
fi

systemctl reload sshd 2>/dev/null || systemctl reload sshd.service 2>/dev/null || true

if grep -Eq '^\s*MaxSessions\s+'"$value" "$cfg"; then
  echo "OK: SSH MaxSessions configured (CIS 5.3.22)."
  exit 0
else
  echo "FAIL: SSH MaxSessions directive not set correctly." >&2
  exit 1
fi
