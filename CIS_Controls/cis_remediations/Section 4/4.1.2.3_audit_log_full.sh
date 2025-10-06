#!/usr/bin/env bash
set -euo pipefail

# Goal: Configure actions when audit logs are filling up: email when space left, mail root and halt when full.
# Filename: 4.1.2.3_audit_log_full.sh
# Applicability: Level 2 for both Server and Workstation
APPLIES_L1=0
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

conf_file="/etc/audit/auditd.conf"
[[ -f "$conf_file" && ! -f "${conf_file}.bak" ]] && cp "$conf_file" "${conf_file}.bak"

# Configure space_left_action to email
if grep -q '^\s*space_left_action\s*=' "$conf_file"; then
  sed -i 's/^\s*space_left_action\s*=.*/space_left_action = email/' "$conf_file"
else
  echo 'space_left_action = email' >> "$conf_file"
fi

# Configure action_mail_acct to root
if grep -q '^\s*action_mail_acct\s*=' "$conf_file"; then
  sed -i 's/^\s*action_mail_acct\s*=.*/action_mail_acct = root/' "$conf_file"
else
  echo 'action_mail_acct = root' >> "$conf_file"
fi

# Configure admin_space_left_action to halt
if grep -q '^\s*admin_space_left_action\s*=' "$conf_file"; then
  sed -i 's/^\s*admin_space_left_action\s*=.*/admin_space_left_action = halt/' "$conf_file"
else
  echo 'admin_space_left_action = halt' >> "$conf_file"
fi

# Verification
ok=1
grep -q '^\s*space_left_action\s*=\s*email' "$conf_file" || ok=0
grep -q '^\s*action_mail_acct\s*=\s*root' "$conf_file" || ok=0
grep -q '^\s*admin_space_left_action\s*=\s*halt' "$conf_file" || ok=0

if [[ $ok -eq 1 ]]; then
  echo "OK: Audit log full actions configured (CIS 4.1.2.3)."
  exit 0
else
  echo "FAIL: Audit log full actions not configured correctly." >&2
  exit 1
fi