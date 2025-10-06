# Goal: Limit password reuse by configuring PAM to remember previous passwords.
# Filename: 5.4.4_password_history.sh
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

REMEMBER=${PASSWORD_REMEMBER_COUNT:-5}
LINE="password required pam_pwhistory.so use_authtok remember=${REMEMBER} retry=3"

for pam_file in /etc/pam.d/system-auth /etc/pam.d/password-auth; do
  [[ -f "$pam_file" ]] || continue
  [[ ! -f "${pam_file}.bak" ]] && cp "$pam_file" "${pam_file}.bak"
  if ! grep -Eq '^\s*password\s+required\s+pam_pwhistory.so' "$pam_file"; then
    echo "$LINE" >> "$pam_file"
  fi
done

# Verification
ok=1
for pam_file in /etc/pam.d/system-auth /etc/pam.d/password-auth; do
  [[ -f "$pam_file" ]] || continue
  grep -Eq '^\s*password\s+required\s+pam_pwhistory.so' "$pam_file" || ok=0
done

if [[ $ok -eq 1 ]]; then
  echo "OK: Password history enforcement configured (CIS 5.4.4)."
  exit 0
else
  echo "FAIL: Password history enforcement not configured in all PAM files." >&2
  exit 1
fi
