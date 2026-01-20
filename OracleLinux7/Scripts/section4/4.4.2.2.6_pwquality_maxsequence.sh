#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.4.2.2.6
# Ensure password maximum sequential characters is configured
# This script configures maxsequence in pwquality.conf

set -e

echo "CIS 4.4.2.2.6 - Configuring password maxsequence..."

PWQUALITY_CONF="/etc/security/pwquality.conf"

# Backup pwquality.conf
cp "$PWQUALITY_CONF" "${PWQUALITY_CONF}.backup.$(date +%Y%m%d%H%M%S)"

# Update existing maxsequence or add if not present
if grep -Eq '^\s*maxsequence\s*=' "$PWQUALITY_CONF"; then
    sed -i 's/^\s*maxsequence\s*=.*/maxsequence = 3/' "$PWQUALITY_CONF"
    echo " - Updated maxsequence to 3"
else
    echo "maxsequence = 3" >> "$PWQUALITY_CONF"
    echo " - Added maxsequence = 3"
fi

# Remove maxsequence from PAM files if present
for pam_file in system-auth password-auth; do
    if grep -q "pam_pwquality.so.*maxsequence" /etc/pam.d/"$pam_file" 2>/dev/null; then
        sed -ri 's/(^\s*password\s+(requisite|required|sufficient)\s+pam_pwquality\.so.*)(\s+maxsequence\s*=\s*\S+)(.*$)/\1\4/' /etc/pam.d/"$pam_file"
        echo " - Removed maxsequence from /etc/pam.d/$pam_file"
    fi
done

echo ""
echo "Verifying configuration:"
grep -i "^maxsequence" "$PWQUALITY_CONF" || echo "maxsequence not found"

echo ""
echo "CIS 4.4.2.2.6 remediation complete."
