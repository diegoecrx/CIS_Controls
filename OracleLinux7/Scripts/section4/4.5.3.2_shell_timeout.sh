#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 4.5.3.2
# Ensure default user shell timeout is configured
# This script configures TMOUT in /etc/profile.d/ only (not /etc/bashrc to avoid readonly conflicts)

set -e

echo "CIS 4.5.3.2 - Configuring shell timeout..."

# Configure TMOUT in /etc/profile.d with proper naming for early loading
cat > /etc/profile.d/tmout.sh << 'EOF'
# CIS 4.5.3.2 - Shell timeout
readonly TMOUT=900 ; export TMOUT
EOF

chmod 644 /etc/profile.d/tmout.sh
echo " - Created /etc/profile.d/tmout.sh with TMOUT=900"

# Remove any TMOUT settings from /etc/bashrc to avoid readonly conflicts
if grep -q "TMOUT" /etc/bashrc 2>/dev/null; then
    sed -i '/CIS 4.5.3.2/d; /readonly TMOUT/d; /^TMOUT=/d' /etc/bashrc
    echo " - Removed conflicting TMOUT from /etc/bashrc"
fi

# Remove any TMOUT settings from /etc/profile to avoid conflicts
if grep -q "^TMOUT=" /etc/profile 2>/dev/null; then
    sed -i '/^TMOUT=/d' /etc/profile
    echo " - Removed conflicting TMOUT from /etc/profile"
fi

echo ""
echo "Verifying TMOUT configuration:"
cat /etc/profile.d/tmout.sh

echo ""
echo "CIS 4.5.3.2 remediation complete."
echo "Note: TMOUT is set in /etc/profile.d/tmout.sh only to avoid readonly variable conflicts."
