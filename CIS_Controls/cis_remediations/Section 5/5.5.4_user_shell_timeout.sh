# Goal: Ensure a default shell inactivity timeout (TMOUT) is configured and not greater than 900 seconds.
# Filename: 5.5.4_user_shell_timeout.sh
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

# Desired timeout in seconds (override via TMOUT_VALUE env). Must not exceed 900.
TMOUT_VALUE=${TMOUT_VALUE:-900}
if (( TMOUT_VALUE > 900 )); then
  echo "ERROR: TMOUT_VALUE must not exceed 900." >&2
  exit 1
fi

# Files to check for TMOUT configurations
files=(/etc/profile /etc/bashrc)
for f in /etc/profile.d/*.sh; do
  [[ -f "$f" ]] && files+=("$f")
done

# Backup and sanitize existing TMOUT definitions
for file in "${files[@]}"; do
  [[ -f "$file" ]] || continue
  # Backup if no backup exists
  [[ ! -f "${file}.bak" ]] && cp "$file" "${file}.bak"
  # Replace TMOUT assignments with acceptable value
  if grep -Eq '^\s*TMOUT=' "$file"; then
    sed -i "s/^\s*TMOUT=.*/TMOUT=${TMOUT_VALUE}/" "$file"
  fi
  # Remove lines that set TMOUT to 0 or greater than allowed
  sed -i "/^\s*readonly\s*TMOUT/d" "$file"
  sed -i "/^\s*export\s*TMOUT/d" "$file"
done

# Create or update our own configuration file in /etc/profile.d
tmout_conf="/etc/profile.d/cis_tmout.sh"
[[ -f "$tmout_conf" && ! -f "${tmout_conf}.bak" ]] && cp "$tmout_conf" "${tmout_conf}.bak"
cat > "$tmout_conf" <<EOF
TMOUT=${TMOUT_VALUE}
readonly TMOUT
export TMOUT
EOF
chmod 644 "$tmout_conf"

# Verification
verify_fail=0
# Check our file exists and sets TMOUT
if [[ ! -f "$tmout_conf" ]]; then
  verify_fail=1
elif ! grep -q "^TMOUT=${TMOUT_VALUE}" "$tmout_conf"; then
  verify_fail=1
fi
# Ensure no other file sets TMOUT to an unacceptable value
for file in "${files[@]}"; do
  [[ -f "$file" ]] || continue
  while read -r line; do
    [[ "$line" =~ ^\s*TMOUT= ]] || continue
    value=$(echo "$line" | cut -d= -f2 | tr -d ' "')
    if [[ -n "$value" ]]; then
      if (( value == 0 || value > TMOUT_VALUE )); then
        verify_fail=1
      fi
    fi
  done < "$file"
done

if [[ "$verify_fail" -eq 0 ]]; then
  echo "OK: Shell inactivity timeout configured (CIS 5.5.4)."
  exit 0
else
  echo "FAIL: Shell inactivity timeout not correctly configured." >&2
  exit 1
fi