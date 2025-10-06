# Goal: Disable SSH X11 forwarding to prevent insecure X11 communications.
# Filename: 5.3.6_ssh_x11.sh
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

if [[ ! -f "$cfg" ]]; then
  echo "ERROR: $cfg not found" >&2
  exit 1
fi

[[ ! -f "${cfg}.bak" ]] && cp "$cfg" "${cfg}.bak"

if grep -Eiq '^\s*X11Forwarding\b' "$cfg"; then
  sed -i -E 's/^\s*X11Forwarding\s+.*/X11Forwarding no/I' "$cfg"
else
  echo "X11Forwarding no" >> "$cfg"
fi

systemctl reload sshd 2>/dev/null || systemctl reload sshd.service 2>/dev/null || true

if grep -Eq '^\s*X11Forwarding\s+no' "$cfg"; then
  echo "OK: SSH X11 forwarding disabled (CIS 5.3.6)."
  exit 0
else
  echo "FAIL: SSH X11 forwarding directive not set correctly." >&2
  exit 1
fi
