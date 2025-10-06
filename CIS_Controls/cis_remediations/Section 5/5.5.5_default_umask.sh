# Goal: Ensure the system's default umask is configured to a secure value (027) and applied consistently.
# Filename: 5.5.5_default_umask.sh
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

# Desired umask value (three-digit octal). Override via UMASK_VALUE env.
UMASK_VALUE=${UMASK_VALUE:-027}

login_defs="/etc/login.defs"
# Backup login.defs
[[ -f "$login_defs" && ! -f "${login_defs}.bak" ]] && cp "$login_defs" "${login_defs}.bak"

# Set UMASK value in login.defs
if grep -q '^\s*UMASK' "$login_defs"; then
  sed -i "s/^\s*UMASK\s\+.*/UMASK\t${UMASK_VALUE}/" "$login_defs"
else
  echo -e "UMASK\t${UMASK_VALUE}" >> "$login_defs"
fi
# Set USERGROUPS_ENAB to no as recommended
if grep -q '^\s*USERGROUPS_ENAB' "$login_defs"; then
  sed -i "s/^\s*USERGROUPS_ENAB\s\+.*/USERGROUPS_ENAB\tno/" "$login_defs"
else
  echo -e "USERGROUPS_ENAB\tno" >> "$login_defs"
fi

# Ensure pam_umask module is included in PAM configuration
for pam_file in /etc/pam.d/system-auth /etc/pam.d/password-auth; do
  [[ -f "$pam_file" ]] || continue
  [[ ! -f "${pam_file}.bak" ]] && cp "$pam_file" "${pam_file}.bak"
  if ! grep -q '^\s*session\s\+optional\s\+pam_umask\.so' "$pam_file"; then
    echo 'session optional pam_umask.so' >> "$pam_file"
  fi
done

# Files to inspect for umask definitions
files=(/etc/profile /etc/bashrc)
for f in /etc/profile.d/*.sh; do
  [[ -f "$f" ]] && files+=("$f")
done

# Backup and update umask definitions in those files
for file in "${files[@]}"; do
  [[ -f "$file" ]] || continue
  [[ ! -f "${file}.bak" ]] && cp "$file" "${file}.bak"
  # Replace existing umask lines with secure value if they are too permissive
  if grep -Eq '^[^#]*umask' "$file"; then
    # Accept patterns like umask 022 or umask u=rwx,g=rx,o=rx. We'll replace numeric modes less restrictive than 027.
    sed -i -E "s/^\s*umask\s+[0-7]{3}/umask ${UMASK_VALUE}/" "$file"
    # Replace symbolic umask patterns that grant world write
    sed -i -E "s/^\s*umask\s+u=[rwx,]+,g=[rwx,]+,o=[rwx,]+/umask ${UMASK_VALUE}/" "$file"
  fi
done

# Create our own umask configuration file in /etc/profile.d
umask_conf="/etc/profile.d/cis_umask.sh"
[[ -f "$umask_conf" && ! -f "${umask_conf}.bak" ]] && cp "$umask_conf" "${umask_conf}.bak"
cat > "$umask_conf" <<EOF
umask ${UMASK_VALUE}
EOF
chmod 644 "$umask_conf"

# Verification
verify_fail=0
if ! grep -q "^UMASK\s\+${UMASK_VALUE}" "$login_defs"; then
  verify_fail=1
fi
if ! grep -q "^USERGROUPS_ENAB\s\+no" "$login_defs"; then
  verify_fail=1
fi
for pam_file in /etc/pam.d/system-auth /etc/pam.d/password-auth; do
  [[ -f "$pam_file" ]] || continue
  grep -q '^\s*session\s\+optional\s\+pam_umask\.so' "$pam_file" || verify_fail=1
done
if [[ ! -f "$umask_conf" ]] || ! grep -q "umask ${UMASK_VALUE}" "$umask_conf"; then
  verify_fail=1
fi

if [[ "$verify_fail" -eq 0 ]]; then
  echo "OK: Default user umask configured to ${UMASK_VALUE} (CIS 5.5.5)."
  exit 0
else
  echo "FAIL: Default user umask not correctly configured." >&2
  exit 1
fi