#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.5.2.4
# Ensure system accounts are secured
# This script secures system accounts

set -e

echo "CIS 4.5.2.4 - Securing system accounts..."

# Set shell to nologin for system accounts
echo "Setting nologin shell for system accounts..."
awk -F: '($1!="root" && $1!="sync" && $1!="shutdown" && $1!="halt" && $1!~/^\+/ && $3<'"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"' && $7!="/usr/sbin/nologin" && $7!="/bin/false") {print $1}' /etc/passwd | while read user; do
    echo "Setting nologin for: $user"
    usermod -s /usr/sbin/nologin "$user" 2>/dev/null || true
done

# Lock system accounts
echo ""
echo "Locking system accounts..."
awk -F: '($1!="root" && $1!~/^\+/ && $3<'"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"') {print $1}' /etc/passwd | while read user; do
    passwd -S "$user" 2>/dev/null | grep -qE '^[^ ]+ L ' || {
        echo "Locking account: $user"
        usermod -L "$user" 2>/dev/null || true
    }
done

echo ""
echo "CIS 4.5.2.4 remediation complete."