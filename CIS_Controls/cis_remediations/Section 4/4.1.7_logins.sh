#!/usr/bin/env bash
set -euo pipefail

# Goal: Collect login and logout events by monitoring relevant log files.
# Filename: 4.1.7_logins.sh
# Applicability: Level 2 for both Server and Workstation
APPLIES_L1=0
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

rules_file="/etc/audit/rules.d/50-logins.rules"
[[ -f "$rules_file" && ! -f "${rules_file}.bak" ]] && cp "$rules_file" "${rules_file}.bak"

read -r -d '' REQUIRED_RULES <<'RULES'
-w /var/log/lastlog -p wa -k logins
-w /var/run/faillock/ -p wa -k logins
RULES

touch "$rules_file"
while IFS= read -r rule; do
  [[ -z "$rule" ]] && continue
  grep -Fxq "$rule" "$rules_file" || echo "$rule" >> "$rules_file"
done <<< "$REQUIRED_RULES"

command -v augenrules >/dev/null 2>&1 && augenrules --load >/dev/null 2>&1 || true

# Verification
ok=1
while IFS= read -r rule; do
  [[ -z "$rule" ]] && continue
  grep -Fxq "$rule" "$rules_file" || ok=0
done <<< "$REQUIRED_RULES"
if [[ $ok -eq 1 ]]; then
  echo "OK: Login/logout audit rules configured (CIS 4.1.7)."
  exit 0
else
  echo "FAIL: Missing login/logout audit rules." >&2
  exit 1
fi