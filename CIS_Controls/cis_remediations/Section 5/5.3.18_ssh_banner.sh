# Goal: Configure SSH to display a warning banner by specifying a Banner file.
# Filename: 5.3.18_ssh_banner.sh
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
banner_file="/etc/issue.net"

if [[ ! -f "$cfg" ]]; then
  echo "ERROR: $cfg not found" >&2
  exit 1
fi
[[ ! -f "${cfg}.bak" ]] && cp "$cfg" "${cfg}.bak"

# Ensure the banner file exists with a generic warning if missing
if [[ ! -f "$banner_file" ]]; then
  cat > "$banner_file" <<'EOF_BANNER'
Authorized uses only. All activity may be monitored and reported.
EOF_BANNER
  chown root:root "$banner_file"
  chmod 0644 "$banner_file"
fi

# Configure Banner directive
if grep -Eiq '^\s*Banner\b' "$cfg"; then
  sed -i -E 's/^\s*Banner\s+.*/Banner '"$banner_file"'/I' "$cfg"
else
  echo "Banner $banner_file" >> "$cfg"
fi

systemctl reload sshd 2>/dev/null || systemctl reload sshd.service 2>/dev/null || true

if grep -Eq '^\s*Banner\s+'"$banner_file" "$cfg"; then
  echo "OK: SSH warning banner configured (CIS 5.3.18)."
  exit 0
else
  echo "FAIL: SSH Banner directive not configured properly." >&2
  exit 1
fi
