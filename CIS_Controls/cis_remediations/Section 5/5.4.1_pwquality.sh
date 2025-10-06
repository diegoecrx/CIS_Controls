# Goal: Configure password creation requirements using pwquality and PAM modules.
# Filename: 5.4.1_pwquality.sh
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

# Desired password quality parameters
MINLEN=${MIN_PASSWORD_LENGTH:-14}
MINCLASS=${MIN_PASSWORD_CLASSES:-4}
PWCONF="/etc/security/pwquality.conf"

# Ensure pwquality.conf exists and backup
[[ ! -f "$PWCONF" ]] && touch "$PWCONF"
[[ ! -f "${PWCONF}.bak" ]] && cp "$PWCONF" "${PWCONF}.bak"

# Set minlen
if grep -Eq '^\s*minlen\s*=' "$PWCONF"; then
  sed -i -E 's/^\s*minlen\s*=.*/minlen = '"$MINLEN"'/' "$PWCONF"
else
  echo "minlen = $MINLEN" >> "$PWCONF"
fi

# Set minclass
if grep -Eq '^\s*minclass\s*=' "$PWCONF"; then
  sed -i -E 's/^\s*minclass\s*=.*/minclass = '"$MINCLASS"'/' "$PWCONF"
else
  echo "minclass = $MINCLASS" >> "$PWCONF"
fi

# Update pam configuration to use pam_pwquality.so
for pam_file in /etc/pam.d/system-auth /etc/pam.d/password-auth; do
  if [[ -f "$pam_file" ]]; then
    [[ ! -f "${pam_file}.bak" ]] && cp "$pam_file" "${pam_file}.bak"
    if ! grep -Eq '^\s*password\s+requisite\s+pam_pwquality.so' "$pam_file"; then
      # Insert after the first password line (if any), else append
      sed -i '/^password\s/s//password requisite pam_pwquality.so try_first_pass retry=3\n&/1' "$pam_file" || echo "password requisite pam_pwquality.so try_first_pass retry=3" >> "$pam_file"
    fi
    # Ensure retry parameter is present
    sed -i -E 's/^(\s*password\s+requisite\s+pam_pwquality.so.*)(?<!retry=[0-9]+)(\s*)$/\1 retry=3\2/' "$pam_file"
  fi
done

# Verification
ok=1
grep -Eq '^\s*minlen\s*=\s*([1-9][0-9]*)' "$PWCONF" || ok=0
grep -Eq '^\s*minclass\s*=\s*([1-9][0-9]*)' "$PWCONF" || ok=0
for pam_file in /etc/pam.d/system-auth /etc/pam.d/password-auth; do
  grep -Eq '^\s*password\s+requisite\s+pam_pwquality.so' "$pam_file" || ok=0
done
if [[ $ok -eq 1 ]]; then
  echo "OK: Password creation requirements configured (CIS 5.4.1)."
  exit 0
else
  echo "FAIL: Password quality settings not properly configured." >&2
  exit 1
fi
