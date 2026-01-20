#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.5.1.2
# Ensure password expiration is 365 days or less

set -e

echo "CIS 4.5.1.2 - Configuring password expiration..."

# Set PASS_MAX_DAYS in /etc/login.defs
if grep -q "^PASS_MAX_DAYS" /etc/login.defs; then
    sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   365/' /etc/login.defs
else
    echo "PASS_MAX_DAYS   365" >> /etc/login.defs
fi
echo " - Set PASS_MAX_DAYS to 365 in /etc/login.defs"

# Get UID_MIN
UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)

# Update existing users with passwords (excluding system accounts)
echo " - Updating existing user accounts..."
while IFS=: read -r username _ uid _ _ _ _; do
    # Skip system accounts and users without passwords
    if [ "$uid" -ge "$UID_MIN" ]; then
        # Check if user has a password set (not locked/disabled)
        if passwd -S "$username" 2>/dev/null | grep -qE '^[^ ]+ (PS|P) '; then
            chage --maxdays 365 "$username" 2>/dev/null && \
                echo "   - Updated $username" || true
        fi
    fi
done < /etc/passwd

# Also update root
chage --maxdays 365 root 2>/dev/null && echo "   - Updated root" || true

echo ""
echo "Verification:"
grep "^PASS_MAX_DAYS" /etc/login.defs

echo ""
echo "CIS 4.5.1.2 remediation complete."
