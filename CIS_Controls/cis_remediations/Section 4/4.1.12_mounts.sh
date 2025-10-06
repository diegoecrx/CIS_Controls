#!/usr/bin/env bash
set -euo pipefail

# Goal: Collect successful file system mount events.
# Filename: 4.1.12_mounts.sh
# Applicability: Level 2 for both Server and Workstation
APPLIES_L1=0
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

rules_file="/etc/audit/rules.d/50-mounts.rules"
[[ -f "$rules_file" && ! -f "${rules_file}.bak" ]] && cp "$rules_file" "${rules_file}.bak"

read -r -d '' REQUIRED_RULES <<'RULES'
-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts
-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts
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
  echo "OK: Mount events audit rules configured (CIS 4.1.12)."
  exit 0
else
  echo "FAIL: Missing mount audit rules." >&2
  exit 1
fi