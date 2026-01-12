#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.5.1.5
# Ensure all users last password change date is in the past
# This script provides audit check - PRINT ONLY

echo "CIS 4.5.1.5 - Checking password change dates..."
echo "==========================================="
echo ""
echo "[AUDIT] This control requires manual verification."
echo ""
echo "Run the following command to check password change dates:"
echo ""
echo '  for usr in $(cut -d: -f1 /etc/shadow); do'
echo '    [[ $(chage --list $usr | grep "^Last password change" | cut -d: -f2) > $(date) ]] && echo "$usr: Password change date in the future"'
echo '  done'
echo ""
echo "If any user has a password change date in the future, investigate and correct:"
echo "  chage -d <YYYY-MM-DD> <username>"
echo ""
echo "CIS 4.5.1.5 - Manual review required."