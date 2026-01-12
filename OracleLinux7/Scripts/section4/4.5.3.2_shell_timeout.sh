#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.5.3.2
# Ensure default user shell timeout is configured
# This script configures TMOUT

set -e

echo "CIS 4.5.3.2 - Configuring shell timeout..."

# Configure TMOUT in /etc/profile.d
cat > /etc/profile.d/tmout.sh << 'EOF'
# CIS 4.5.3.2 - Shell timeout
readonly TMOUT=900 ; export TMOUT
EOF

chmod 644 /etc/profile.d/tmout.sh

# Also add to /etc/bashrc if not present
if ! grep -q "^readonly TMOUT" /etc/bashrc; then
    echo "" >> /etc/bashrc
    echo "# CIS 4.5.3.2 - Shell timeout" >> /etc/bashrc
    echo "readonly TMOUT=900 ; export TMOUT" >> /etc/bashrc
fi

echo "Verifying TMOUT configuration:"
cat /etc/profile.d/tmout.sh

echo ""
echo "CIS 4.5.3.2 remediation complete."