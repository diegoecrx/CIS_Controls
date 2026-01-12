#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.3.6
# Ensure sudo authentication timeout is configured correctly
# This script configures sudo timeout

set -e

echo "CIS 4.3.6 - Configuring sudo authentication timeout..."

# Check current timeout setting
echo "Current timestamp_timeout settings:"
grep -ri "timestamp_timeout" /etc/sudoers /etc/sudoers.d/ 2>/dev/null || echo "No timestamp_timeout set (default 5 minutes)"

# Add timeout configuration
if ! grep -rqi "timestamp_timeout" /etc/sudoers /etc/sudoers.d/ 2>/dev/null; then
    echo "Adding timestamp_timeout to sudoers..."
    echo "Defaults timestamp_timeout=15" > /etc/sudoers.d/00_timeout
    chmod 440 /etc/sudoers.d/00_timeout
fi

echo ""
echo "Verifying configuration:"
grep -ri "timestamp_timeout" /etc/sudoers /etc/sudoers.d/ 2>/dev/null || true

echo "CIS 4.3.6 remediation complete."