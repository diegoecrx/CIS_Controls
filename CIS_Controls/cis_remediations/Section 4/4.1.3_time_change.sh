#!/usr/bin/env bash
set -euo pipefail

# Goal: Collect events that modify date and time information via audit rules for both 32‑bit and 64‑bit architectures.
# Filename: 4.1.3_time_change.sh
# Applicability: Level 2 for both Server and Workstation
APPLIES_L1=0
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

rules_file="/etc/audit/rules.d/50-time_change.rules"
# Backup existing rules file if present
if [[ -f "$rules_file" && ! -f "${rules_file}.bak" ]]; then
  cp "$rules_file" "${rules_file}.bak"
fi

# Define required rules
read -r -d '' REQUIRED_RULES <<'RULES'
-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change
-a always,exit -F arch=b32 -S clock_settime -k time-change
-w /etc/localtime -p wa -k time-change
-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change
-a always,exit -F arch=b64 -S clock_settime -k time-change
RULES

# Ensure the rules file exists
touch "$rules_file"

# Add each rule if it is not already present
FAIL=0
while IFS= read -r rule; do
  # Skip empty lines
  [[ -z "$rule" ]] && continue
  grep -Fxq "$rule" "$rules_file" || echo "$rule" >> "$rules_file"
done <<< "$REQUIRED_RULES"

# Reload rules
if command -v augenrules >/dev/null 2>&1; then
  augenrules --load >/dev/null 2>&1 || true
fi

# Verification: check file contains required rules
ok=1
while IFS= read -r rule; do
  [[ -z "$rule" ]] && continue
  grep -Fxq "$rule" "$rules_file" || ok=0
done <<< "$REQUIRED_RULES"

if [[ $ok -eq 1 ]]; then
  echo "OK: Time change audit rules configured (CIS 4.1.3)."
  exit 0
else
  echo "FAIL: Some time change audit rules are missing." >&2
  exit 1
fi