#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.5.3.3
# Ensure default user umask is configured
# This script configures default umask

set -e

echo "CIS 4.5.3.3 - Configuring default user umask..."

# Configure umask in /etc/profile.d
cat > /etc/profile.d/umask.sh << 'EOF'
# CIS 4.5.3.3 - Default user umask
umask 027
EOF

chmod 644 /etc/profile.d/umask.sh

# Update /etc/bashrc
if grep -q "^\s*umask" /etc/bashrc; then
    sed -i 's/^\s*umask\s\+[0-9]\+/umask 027/' /etc/bashrc
else
    echo "" >> /etc/bashrc
    echo "# CIS 4.5.3.3 - Default user umask" >> /etc/bashrc
    echo "umask 027" >> /etc/bashrc
fi

# Update /etc/profile
if grep -q "^\s*umask" /etc/profile; then
    sed -i 's/^\s*umask\s\+[0-9]\+/umask 027/' /etc/profile
else
    echo "" >> /etc/profile
    echo "# CIS 4.5.3.3 - Default user umask" >> /etc/profile
    echo "umask 027" >> /etc/profile
fi

# Update /etc/login.defs
if grep -q "^UMASK" /etc/login.defs; then
    sed -i 's/^UMASK.*/UMASK 027/' /etc/login.defs
else
    echo "UMASK 027" >> /etc/login.defs
fi

echo "Verifying umask configuration:"
grep -E "umask|UMASK" /etc/profile /etc/bashrc /etc/login.defs 2>/dev/null | head -10

echo ""
echo "CIS 4.5.3.3 remediation complete."