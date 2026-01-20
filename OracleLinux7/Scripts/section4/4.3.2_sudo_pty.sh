#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 4.3.2
# Ensure sudo commands use pty
# This script configures sudo to use pty

set -e

echo "CIS 4.3.2 - Configuring sudo to use pty..."

# Check if use_pty is already configured
if grep -rPi '^\s*Defaults\s+([^#\n\r]+,)?use_pty' /etc/sudoers /etc/sudoers.d/ 2>/dev/null; then
    echo "use_pty is already configured."
else
    echo "Adding use_pty to sudoers..."
    echo "Defaults use_pty" > /etc/sudoers.d/00_use_pty
    chmod 440 /etc/sudoers.d/00_use_pty
fi

echo "Verifying configuration:"
grep -ri "use_pty" /etc/sudoers /etc/sudoers.d/ 2>/dev/null || true

echo "CIS 4.3.2 remediation complete."