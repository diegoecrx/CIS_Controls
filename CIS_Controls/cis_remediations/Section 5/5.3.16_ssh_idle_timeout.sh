# Goal: Configure SSH idle timeout by setting ClientAliveInterval and ClientAliveCountMax.
# Filename: 5.3.16_ssh_idle_timeout.sh
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
interval=${SSH_CLIENT_ALIVE_INTERVAL:-900}
countmax=${SSH_CLIENT_ALIVE_COUNT_MAX:-0}

[[ ! -f "$cfg" ]] && { echo "ERROR: $cfg not found" >&2; exit 1; }
[[ ! -f "${cfg}.bak" ]] && cp "$cfg" "${cfg}.bak"

if grep -Eiq '^\s*ClientAliveInterval\b' "$cfg"; then
  sed -i -E 's/^\s*ClientAliveInterval\s+.*/ClientAliveInterval '"$interval"'/I' "$cfg"
else
  echo "ClientAliveInterval $interval" >> "$cfg"
fi

if grep -Eiq '^\s*ClientAliveCountMax\b' "$cfg"; then
  sed -i -E 's/^\s*ClientAliveCountMax\s+.*/ClientAliveCountMax '"$countmax"'/I' "$cfg"
else
  echo "ClientAliveCountMax $countmax" >> "$cfg"
fi

systemctl reload sshd 2>/dev/null || systemctl reload sshd.service 2>/dev/null || true

if grep -Eq '^\s*ClientAliveInterval\s+'"$interval" "$cfg" && \
   grep -Eq '^\s*ClientAliveCountMax\s+'"$countmax" "$cfg"; then
  echo "OK: SSH idle timeout configured (CIS 5.3.16)."
  exit 0
else
  echo "FAIL: SSH idle timeout parameters not configured correctly." >&2
  exit 1
fi
