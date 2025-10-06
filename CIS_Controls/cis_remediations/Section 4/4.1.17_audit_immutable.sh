#!/usr/bin/env bash
set -euo pipefail

# Goal: Ensure the audit configuration is immutable by adding a final rule that sets -e 2.
# Filename: 4.1.17_audit_immutable.sh
# Applicability: Level 2 for both Server and Workstation
APPLIES_L1=0
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

rules_file="/etc/audit/rules.d/99-finalize.rules"
[[ -f "$rules_file" && ! -f "${rules_file}.bak" ]] && cp "$rules_file" "${rules_file}.bak"

# Ensure the file exists and contains '-e 2'
touch "$rules_file"
if ! grep -Fxq '-e 2' "$rules_file"; then
  echo '-e 2' >> "$rules_file"
fi

command -v augenrules >/dev/null 2>&1 && augenrules --load >/dev/null 2>&1 || true

# Verification
if grep -Fxq '-e 2' "$rules_file"; then
  echo "OK: Audit configuration made immutable (CIS 4.1.17)."
  exit 0
else
  echo "FAIL: Immutable audit rule missing." >&2
  exit 1
fi