#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.4.2.2.3
# Ensure password length is configured
# This script configures minlen in pwquality.conf

set -e

echo "CIS 4.4.2.2.3 - Configuring password minlen..."

PWQUALITY_CONF="/etc/security/pwquality.conf"

# Backup pwquality.conf
cp "$PWQUALITY_CONF" "${PWQUALITY_CONF}.backup.$(date +%Y%m%d%H%M%S)"

# Update existing minlen or add if not present
if grep -Eq '^\s*minlen\s*=' "$PWQUALITY_CONF"; then
    sed -i 's/^\s*minlen\s*=.*/minlen = 14/' "$PWQUALITY_CONF"
    echo " - Updated minlen to 14"
else
    echo "minlen = 14" >> "$PWQUALITY_CONF"
    echo " - Added minlen = 14"
fi

# Remove minlen from PAM files if present
for pam_file in system-auth password-auth; do
    if grep -q "pam_pwquality.so.*minlen" /etc/pam.d/"$pam_file" 2>/dev/null; then
        sed -ri 's/(^\s*password\s+(requisite|required|sufficient)\s+pam_pwquality\.so.*)(\s+minlen\s*=\s*[0-9]+)(.*$)/\1\4/' /etc/pam.d/"$pam_file"
        echo " - Removed minlen from /etc/pam.d/$pam_file"
    fi
done

echo ""
echo "Verifying configuration:"
grep -i "^minlen" "$PWQUALITY_CONF"

echo ""
echo "CIS 4.4.2.2.3 remediation complete."
