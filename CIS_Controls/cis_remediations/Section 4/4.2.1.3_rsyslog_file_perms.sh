#!/usr/bin/env bash
set -euo pipefail

# Goal: Ensure rsyslog uses restrictive default file permissions when creating log files.
# Filename: 4.2.1.3_rsyslog_file_perms.sh
# Applicability: Level 1 for both Server and Workstation
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

# Desired mode (without leading 0)
FILE_MODE=${FILE_MODE:-0640}

update_file_mode() {
  local file=$1
  # Backup original file
  if [[ -f "$file" && ! -f "${file}.bak" ]]; then
    cp "$file" "${file}.bak"
  fi
  if grep -q '^\s*\$FileCreateMode' "$file"; then
    # Replace existing directive with the desired mode
    sed -i "s/^\s*\$FileCreateMode.*/\$FileCreateMode ${FILE_MODE}/" "$file"
  else
    # Append directive
    echo "\$FileCreateMode ${FILE_MODE}" >> "$file"
  fi
}

FAIL=0
main_conf="/etc/rsyslog.conf"
update_file_mode "$main_conf" || FAIL=1

for conf in /etc/rsyslog.d/*.conf; do
  [[ -f "$conf" ]] || continue
  update_file_mode "$conf" || FAIL=1
done

# Reload rsyslog to apply new settings
systemctl reload rsyslog 2>/dev/null || true

# Verification: ensure all configs set FileCreateMode to desired value
ok=1
check_mode() {
  local file=$1
  local setmode
  setmode=$(grep '^\s*\$FileCreateMode' "$file" | awk '{print $2}')
  [[ "$setmode" == "$FILE_MODE" ]] || ok=0
}
check_mode "$main_conf"
for conf in /etc/rsyslog.d/*.conf; do
  [[ -f "$conf" ]] || continue
  check_mode "$conf"
done

if [[ $ok -eq 1 ]]; then
  echo "OK: rsyslog default file permissions configured (CIS 4.2.1.3)."
  exit 0
else
  echo "FAIL: rsyslog default file permissions are not correctly configured." >&2
  exit 1
fi