# Goal: Configure sudo to record executed commands to a log file and ensure the log exists.
# Filename: 5.2.3_sudo_logfile.sh
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

# Configure sudo log file
conf_dir="/etc/sudoers.d"
conf_file="$conf_dir/00-logfile"
mkdir -p "$conf_dir"
logfile="/var/log/sudo.log"

# Create drop-in file for sudo logging
if [[ ! -f "$conf_file" ]]; then
  echo "Defaults logfile=\"$logfile\"" > "$conf_file"
else
  # Ensure directive exists
  grep -q '^Defaults\s\+logfile=' "$conf_file" || echo "Defaults logfile=\"$logfile\"" >> "$conf_file"
fi
chown root:root "$conf_file"
chmod 0440 "$conf_file"

# Ensure log file exists with restrictive permissions
if [[ ! -f "$logfile" ]]; then
  touch "$logfile"
fi
chown root:root "$logfile"
chmod 0600 "$logfile"

# Verification
if grep -Rqs '^Defaults\s\+logfile=' /etc/sudoers /etc/sudoers.d && [[ -f "$logfile" ]] && [[ $(stat -c %U "$logfile") == "root" ]] && [[ $(stat -c %G "$logfile") == "root" ]] && [[ $(stat -c %a "$logfile") -le 600 ]]; then
  echo "OK: sudo logging configured and log file exists (CIS 5.2.3)."
  exit 0
else
  echo "FAIL: sudo logging not correctly configured." >&2
  exit 1
fi
