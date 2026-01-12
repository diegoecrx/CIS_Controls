#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.5.1.1
# Ensure strong password hashing algorithm is configured
# This script configures sha512 hashing

set -e

echo "CIS 4.5.1.1 - Configuring strong password hashing algorithm..."

# Configure /etc/libuser.conf
if [ -f /etc/libuser.conf ]; then
    cp /etc/libuser.conf /etc/libuser.conf.backup.$(date +%Y%m%d%H%M%S)
    if grep -q "^crypt_style" /etc/libuser.conf; then
        sed -i 's/^crypt_style.*/crypt_style = sha512/' /etc/libuser.conf
    else
        echo "crypt_style = sha512" >> /etc/libuser.conf
    fi
fi

# Configure /etc/login.defs
cp /etc/login.defs /etc/login.defs.backup.$(date +%Y%m%d%H%M%S)
if grep -q "^ENCRYPT_METHOD" /etc/login.defs; then
    sed -i 's/^ENCRYPT_METHOD.*/ENCRYPT_METHOD SHA512/' /etc/login.defs
else
    echo "ENCRYPT_METHOD SHA512" >> /etc/login.defs
fi

echo "Verifying configuration:"
grep -i "crypt_style" /etc/libuser.conf 2>/dev/null || true
grep -i "ENCRYPT_METHOD" /etc/login.defs

echo "CIS 4.5.1.1 remediation complete."