#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.4.2.2.5
# Ensure password same consecutive characters is configured
# This script configures maxrepeat in pwquality.conf

set -e

echo "CIS 4.4.2.2.5 - Configuring password maxrepeat..."

PWQUALITY_CONF="/etc/security/pwquality.conf"

# Backup pwquality.conf
cp "$PWQUALITY_CONF" "${PWQUALITY_CONF}.backup.$(date +%Y%m%d%H%M%S)"

# Update existing maxrepeat or add if not present
if grep -Eq '^\s*maxrepeat\s*=' "$PWQUALITY_CONF"; then
    sed -i 's/^\s*maxrepeat\s*=.*/maxrepeat = 3/' "$PWQUALITY_CONF"
    echo " - Updated maxrepeat to 3"
else
    echo "maxrepeat = 3" >> "$PWQUALITY_CONF"
    echo " - Added maxrepeat = 3"
fi

# Remove maxrepeat from PAM files if present
for pam_file in system-auth password-auth; do
    if grep -q "pam_pwquality.so.*maxrepeat" /etc/pam.d/"$pam_file" 2>/dev/null; then
        sed -ri 's/(^\s*password\s+(requisite|required|sufficient)\s+pam_pwquality\.so.*)(\s+maxrepeat\s*=\s*\S+)(.*$)/\1\4/' /etc/pam.d/"$pam_file"
        echo " - Removed maxrepeat from /etc/pam.d/$pam_file"
    fi
done

echo ""
echo "Verifying configuration:"
grep -i "^maxrepeat" "$PWQUALITY_CONF" || echo "maxrepeat not found"

echo ""
echo "CIS 4.4.2.2.5 remediation complete."
