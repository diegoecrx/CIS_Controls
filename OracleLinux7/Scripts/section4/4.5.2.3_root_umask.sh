#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 4.5.2.3
# Ensure root user umask is configured
# This script provides PRINT ONLY (affects root)

echo "CIS 4.5.2.3 - Checking root user umask..."
echo "==========================================="
echo ""
echo "[CAUTION] This control affects root user configuration."
echo "Changes should be reviewed carefully."
echo ""
echo "Current root umask settings in /root/.bash_profile and /root/.bashrc:"
grep -E '^\s*umask' /root/.bash_profile /root/.bashrc 2>/dev/null || echo "No umask found"
echo ""
echo "To remediate, add the following to /root/.bash_profile and /root/.bashrc:"
echo "  umask 0027"
echo ""
echo "Or more restrictive:"
echo "  umask 0077"
echo ""
echo "Example commands:"
echo "  echo 'umask 0027' >> /root/.bash_profile"
echo "  echo 'umask 0027' >> /root/.bashrc"
echo ""
echo "CIS 4.5.2.3 - Manual review required."