#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.2.3.6
# Ensure use of privileged commands are collected

set -e

echo "CIS 5.2.3.6 - Configuring privileged commands audit rules..."

UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)
AUDIT_RULE_FILE="/etc/audit/rules.d/50-privileged.rules"

# Clear existing file
> "${AUDIT_RULE_FILE}"

# Find all privileged commands and add audit rules
for PARTITION in $(findmnt -n -l -k -it $(awk '/nodev/ { print $2 }' /proc/filesystems | paste -sd,) 2>/dev/null | grep -Pv "noexec|nosuid" | awk '{print $1}'); do
    find "${PARTITION}" -xdev \( -perm -4000 -o -perm -2000 \) -type f 2>/dev/null | while read -r PROG; do
        echo "-a always,exit -F path=${PROG} -F perm=x -F auid>=${UID_MIN} -F auid!=unset -k privileged" >> "${AUDIT_RULE_FILE}"
    done
done

# Remove duplicates
sort -u "${AUDIT_RULE_FILE}" -o "${AUDIT_RULE_FILE}"

augenrules --load

echo "Privileged commands rules created:"
wc -l "${AUDIT_RULE_FILE}"

if [[ $(auditctl -s | grep "enabled") =~ "2" ]]; then echo "NOTE: Reboot required."; fi

echo "CIS 5.2.3.6 remediation complete."