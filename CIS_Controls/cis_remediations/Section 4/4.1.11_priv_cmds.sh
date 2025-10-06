#!/usr/bin/env bash
set -euo pipefail

# Goal: Collect execution of privileged commands by adding audit rules for all setuid and setgid files.
# Filename: 4.1.11_priv_cmds.sh
# Applicability: Level 2 for both Server and Workstation
APPLIES_L1=0
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

rules_file="/etc/audit/rules.d/50-privileged.rules"
[[ -f "$rules_file" && ! -f "${rules_file}.bak" ]] && cp "$rules_file" "${rules_file}.bak"

# Ensure file exists
touch "$rules_file"

FAIL=0
# Discover setuid or setgid files on local filesystems and add audit rules for each
find / -xdev \( -perm -4000 -o -perm -2000 \) -type f 2>/dev/null | while read -r file; do
  rule="-a always,exit -F path=${file} -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged"
  grep -Fxq "$rule" "$rules_file" || echo "$rule" >> "$rules_file"
done

# Reload rules
command -v augenrules >/dev/null 2>&1 && augenrules --load >/dev/null 2>&1 || true

# Verification: ensure at least one rule exists in the rules file
if grep -q "-F auid>=1000" "$rules_file"; then
  echo "OK: Privileged command audit rules configured (CIS 4.1.11)."
  exit 0
else
  echo "FAIL: No privileged command audit rules found." >&2
  exit 1
fi