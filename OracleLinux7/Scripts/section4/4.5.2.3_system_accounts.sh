#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 4.5.2.3
# Ensure system accounts are secured
# This script secures system accounts

set -e

echo "CIS 4.5.2.3 - Securing system accounts..."

# Get UID_MIN value
UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)

# Set shell to nologin for system accounts (except root, sync, shutdown, halt)
echo "Setting nologin shell for system accounts..."
awk -F: -v uid_min="$UID_MIN" '
    $1!="root" && $1!="sync" && $1!="shutdown" && $1!="halt" && $1!~/^\+/ &&
    $3<uid_min &&
    $7!="/usr/sbin/nologin" && $7!="/sbin/nologin" && $7!="/bin/false" && $7!="/usr/bin/false" {
        print $1
    }
' /etc/passwd | while read user; do
    echo " - Setting nologin for: $user"
    usermod -s /usr/sbin/nologin "$user" 2>/dev/null || true
done

# Lock system accounts
echo ""
echo "Locking system accounts..."
awk -F: -v uid_min="$UID_MIN" '
    $1!="root" && $1!~/^\+/ && $3<uid_min {
        print $1
    }
' /etc/passwd | while read user; do
    # Check if account is already locked
    status=$(passwd -S "$user" 2>/dev/null | awk '{print $2}')
    if [[ "$status" != "L" && "$status" != "LK" ]]; then
        echo " - Locking account: $user"
        usermod -L "$user" 2>/dev/null || true
    fi
done

echo ""
echo "CIS 4.5.2.3 remediation complete."
