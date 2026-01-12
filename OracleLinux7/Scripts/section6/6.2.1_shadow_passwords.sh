#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 6.2.1
# Ensure accounts in /etc/passwd use shadowed passwords

set -e

echo "CIS 6.2.1 - Ensuring accounts use shadowed passwords..."

# Check for accounts not using shadow passwords
echo "Checking for accounts not using shadowed passwords..."
non_shadow=$(/bin/awk -F: '($2 != "x" ) { print $1 " is not set to shadowed passwords "}' /etc/passwd)

if [ -n "$non_shadow" ]; then
    echo "Found accounts not using shadow passwords:"
    echo "$non_shadow"
    echo ""
    echo "Running pwconv to migrate passwords to /etc/shadow..."
    pwconv
    echo "Passwords migrated to shadow file."
else
    echo "All accounts are using shadowed passwords."
fi

echo "CIS 6.2.1 remediation complete."