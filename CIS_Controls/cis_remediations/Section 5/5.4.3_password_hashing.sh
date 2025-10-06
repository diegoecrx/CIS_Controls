# Goal: Ensure SHA-512 is used for password hashing by configuring pam_unix.so in PAM configuration.
# Filename: 5.4.3_password_hashing.sh
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

for pam_file in /etc/pam.d/system-auth /etc/pam.d/password-auth; do
  [[ -f "$pam_file" ]] || continue
  [[ ! -f "${pam_file}.bak" ]] && cp "$pam_file" "${pam_file}.bak"
  # Remove md5 option and add sha512 if missing on pam_unix.so lines
  sed -i -E '/pam_unix\.so/ { s/\bmd5\b//g; /sha512/! s/pam_unix\.so/pam_unix.so sha512/ }' "$pam_file"
done

# Verification
ok=1
for pam_file in /etc/pam.d/system-auth /etc/pam.d/password-auth; do
  [[ -f "$pam_file" ]] || continue
  grep -Eq 'pam_unix\.so.*sha512' "$pam_file" || ok=0
done
if [[ $ok -eq 1 ]]; then
  echo "OK: Password hashing configured for SHA-512 (CIS 5.4.3)."
  exit 0
else
  echo "FAIL: Password hashing algorithm not set to SHA-512 in all PAM configs." >&2
  exit 1
fi
