#!/usr/bin/env bash
set -euo pipefail

# Goal: Collect file deletion events by users via audit rules for 32 and 64 bit architectures.
# Filename: 4.1.13_deletion.sh
# Applicability: Level 2 for both Server and Workstation
APPLIES_L1=0
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

rules_file="/etc/audit/rules.d/50-deletion.rules"
[[ -f "$rules_file" && ! -f "${rules_file}.bak" ]] && cp "$rules_file" "${rules_file}.bak"

read -r -d '' REQUIRED_RULES <<'RULES'
-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete
-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete
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
  echo "OK: Deletion audit rules configured (CIS 4.1.13)."
  exit 0
else
  echo "FAIL: Missing deletion audit rules." >&2
  exit 1
fi