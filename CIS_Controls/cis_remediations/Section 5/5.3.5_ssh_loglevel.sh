# Goal: Set SSH daemon log level to INFO to ensure sufficient logging without excessive verbosity.
# Filename: 5.3.5_ssh_loglevel.sh
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
level="INFO"

if [[ ! -f "$cfg" ]]; then
  echo "ERROR: $cfg not found" >&2
  exit 1
fi

[[ ! -f "${cfg}.bak" ]] && cp "$cfg" "${cfg}.bak"

# Replace or append LogLevel directive
if grep -Eiq '^\s*LogLevel\b' "$cfg"; then
  # Use sed to replace the current LogLevel value (case-insensitive)
  sed -i -E 's/^\s*LogLevel\s+.*/LogLevel '"$level"'/I' "$cfg"
else
  echo "LogLevel $level" >> "$cfg"
fi

systemctl reload sshd 2>/dev/null || systemctl reload sshd.service 2>/dev/null || true

# Verification
if grep -Eq '^\s*LogLevel\s+'"$level" "$cfg"; then
  echo "OK: SSH LogLevel set to $level (CIS 5.3.5)."
  exit 0
else
  echo "FAIL: SSH LogLevel not configured properly." >&2
  exit 1
fi
