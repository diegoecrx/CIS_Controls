# Goal: Ensure all users' home directories exist; create missing directories and set ownership correctly.
# Filename: 6.2.11_home_dirs_exist.sh
# Applicability: Level 1 for Server and Workstation
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

# Determine UID_MIN from login.defs
login_defs="/etc/login.defs"
UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' "$login_defs" 2>/dev/null || echo 1000)

FAIL=0
# Iterate through /etc/passwd
while IFS=: read -r user pass uid gid gecos home shell; do
  # Skip system accounts and nologin shells
  if (( uid < UID_MIN )) || [[ "$user" == "root" ]]; then
    continue
  fi
  # If home directory path is empty or equals '/', skip
  if [[ -z "$home" || "$home" == "/" ]]; then
    continue
  fi
  if [[ ! -d "$home" ]]; then
    mkdir -p "$home" || FAIL=1
    chown "$user":"$(id -gn "$user")" "$home" || FAIL=1
    chmod 750 "$home" || true
  fi
done < /etc/passwd

# Verification
missing=0
while IFS=: read -r user pass uid gid gecos home shell; do
  if (( uid < UID_MIN )) || [[ "$user" == "root" ]]; then
    continue
  fi
  if [[ -n "$home" && "$home" != "/" && ! -d "$home" ]]; then
    missing=1
    break
  fi
done < /etc/passwd

if [[ "$missing" -eq 0 && "$FAIL" -eq 0 ]]; then
  echo "OK: All users' home directories exist (CIS 6.2.11)."
  exit 0
else
  echo "FAIL: Some users' home directories are still missing or errors occurred." >&2
  exit 1
fi