# Goal: Set SSH LoginGraceTime to limit the period for user login.
# Filename: 5.3.17_ssh_login_grace.sh
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
value=${SSH_LOGIN_GRACE_TIME:-60}

[[ ! -f "$cfg" ]] && { echo "ERROR: $cfg not found" >&2; exit 1; }
[[ ! -f "${cfg}.bak" ]] && cp "$cfg" "${cfg}.bak"

if grep -Eiq '^\s*LoginGraceTime\b' "$cfg"; then
  sed -i -E 's/^\s*LoginGraceTime\s+.*/LoginGraceTime '"$value"'/I' "$cfg"
else
  echo "LoginGraceTime $value" >> "$cfg"
fi

systemctl reload sshd 2>/dev/null || systemctl reload sshd.service 2>/dev/null || true

if grep -Eq '^\s*LoginGraceTime\s+'"$value" "$cfg"; then
  echo "OK: SSH LoginGraceTime set to $value seconds (CIS 5.3.17)."
  exit 0
else
  echo "FAIL: SSH LoginGraceTime not configured correctly." >&2
  exit 1
fi
