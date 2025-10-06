#!/usr/bin/env bash
set -euo pipefail

# Goal: Collect events that modify the system's network or locale settings by auditing sethostname, setdomainname and key configuration files.
# Filename: 4.1.5_system_locale.sh
# Applicability: Level 2 for both Server and Workstation
APPLIES_L1=0
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

rules_file="/etc/audit/rules.d/50-system_locale.rules"
[[ -f "$rules_file" && ! -f "${rules_file}.bak" ]] && cp "$rules_file" "${rules_file}.bak"

# Required rules for 32 and 64 bit architectures
read -r -d '' REQUIRED_RULES <<'RULES'
-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale
-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale
-w /etc/issue -p wa -k system-locale
-w /etc/issue.net -p wa -k system-locale
-w /etc/hosts -p wa -k system-locale
-w /etc/sysconfig/network -p wa -k system-locale
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
  echo "OK: System locale/network audit rules configured (CIS 4.1.5)."
  exit 0
else
  echo "FAIL: Missing system locale/network audit rules." >&2
  exit 1
fi