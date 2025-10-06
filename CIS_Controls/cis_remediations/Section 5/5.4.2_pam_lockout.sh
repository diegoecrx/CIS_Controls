# Goal: Configure account lockout after a number of failed login attempts using pam_tally2.
# Filename: 5.4.2_pam_lockout.sh
# Applicability: Level 1 Workstation, Level 2 Server
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

# Default parameters for pam_tally2
DENY=${LOCKOUT_DENY:-5}
UNLOCK=${LOCKOUT_UNLOCK_TIME:-900}

for pam_file in /etc/pam.d/system-auth /etc/pam.d/password-auth; do
  [[ -f "$pam_file" ]] || continue
  # Backup original
  [[ ! -f "${pam_file}.bak" ]] && cp "$pam_file" "${pam_file}.bak"
  # Ensure auth line exists
  if ! grep -Eq '^\s*auth\s+required\s+pam_tally2.so' "$pam_file"; then
    echo "auth required pam_tally2.so deny=${DENY} onerr=fail unlock_time=${UNLOCK}" >> "$pam_file"
  fi
  # Ensure account line exists
  if ! grep -Eq '^\s*account\s+required\s+pam_tally2.so' "$pam_file"; then
    echo "account required pam_tally2.so" >> "$pam_file"
  fi
done

# Verification
ok=1
for pam_file in /etc/pam.d/system-auth /etc/pam.d/password-auth; do
  [[ -f "$pam_file" ]] || continue
  grep -Eq '^\s*auth\s+required\s+pam_tally2.so' "$pam_file" || ok=0
  grep -Eq '^\s*account\s+required\s+pam_tally2.so' "$pam_file" || ok=0
done

if [[ $ok -eq 1 ]]; then
  echo "OK: Account lockout configured with pam_tally2 (CIS 5.4.2)."
  exit 0
else
  echo "FAIL: Account lockout configuration missing or incorrect." >&2
  exit 1
fi
