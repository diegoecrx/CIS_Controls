#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.5.1.4
# Ensure inactive password lock is 30 days or less

set -e

echo "CIS 4.5.1.4 - Configuring inactive password lock..."

# Set default inactive period for new users
useradd -D -f 30
echo " - Set default INACTIVE to 30 days for new users"

# Get UID_MIN
UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)

# Update existing users with passwords
echo " - Updating existing user accounts..."
while IFS=: read -r username _ uid _ _ _ _; do
    # Skip system accounts
    if [ "$uid" -ge "$UID_MIN" ]; then
        # Check if user has a password set
        if passwd -S "$username" 2>/dev/null | grep -qE '^[^ ]+ (PS|P) '; then
            chage --inactive 30 "$username" 2>/dev/null && \
                echo "   - Updated $username" || true
        fi
    fi
done < /etc/passwd

# Also update root
chage --inactive 30 root 2>/dev/null && echo "   - Updated root" || true

echo ""
echo "Verification:"
useradd -D | grep INACTIVE

echo ""
echo "CIS 4.5.1.4 remediation complete."
