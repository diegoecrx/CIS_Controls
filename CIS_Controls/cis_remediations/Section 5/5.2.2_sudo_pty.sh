# Goal: Configure sudo to use a pseudo‑terminal (pty) for all command executions.
# Filename: 5.2.2_sudo_pty.sh
# Applicability: Level 1 for Server and Workstation
#!/usr/bin/env bash
set -euo pipefail

APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

# Ensure sudo package is installed
rpm -q sudo >/dev/null 2>&1 || yum install -y sudo >/dev/null 2>&1

# Create drop‑in file for use_pty directive
conf_dir="/etc/sudoers.d"
conf_file="$conf_dir/00-use-pty"
mkdir -p "$conf_dir"

if [[ ! -f "$conf_file" ]]; then
  echo "Defaults use_pty" > "$conf_file"
else
  # Ensure the directive exists only once
  grep -q '^Defaults\s\+use_pty' "$conf_file" || echo "Defaults use_pty" >> "$conf_file"
fi
chown root:root "$conf_file"
chmod 0440 "$conf_file"

# Verification: check if use_pty is defined globally
if grep -Rqs '^Defaults\s\+use_pty' /etc/sudoers /etc/sudoers.d; then
  echo "OK: sudo configured to use pty for commands (CIS 5.2.2)."
  exit 0
else
  echo "FAIL: sudo use_pty directive not found." >&2
  exit 1
fi
