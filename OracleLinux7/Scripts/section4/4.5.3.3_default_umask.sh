#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.5.3.3
# Ensure default user umask is configured
# This script configures default umask

set -e

echo "CIS 4.5.3.3 - Configuring default user umask..."

# Configure umask in /etc/profile.d with proper naming for early loading
cat > /etc/profile.d/50-systemwide_umask.sh << 'EOF'
# CIS 4.5.3.3 - Default user umask
umask 027
EOF

chmod 644 /etc/profile.d/50-systemwide_umask.sh
echo " - Created /etc/profile.d/50-systemwide_umask.sh with umask 027"

# Comment out or update umask in /etc/bashrc
if grep -q "^\s*umask" /etc/bashrc 2>/dev/null; then
    sed -i 's/^\([[:space:]]*umask[[:space:]]\+[0-9]\+\)/#\1  # Commented by CIS 4.5.3.3 - umask set in \/etc\/profile.d\//' /etc/bashrc
    echo " - Commented out umask lines in /etc/bashrc"
fi

# Comment out or update umask in /etc/profile
if grep -q "^\s*umask" /etc/profile 2>/dev/null; then
    sed -i 's/^\([[:space:]]*umask[[:space:]]\+[0-9]\+\)/#\1  # Commented by CIS 4.5.3.3 - umask set in \/etc\/profile.d\//' /etc/profile
    echo " - Commented out umask lines in /etc/profile"
fi

# Update /etc/login.defs
if grep -q "^UMASK" /etc/login.defs 2>/dev/null; then
    sed -i 's/^UMASK.*/UMASK 027/' /etc/login.defs
    echo " - Updated UMASK to 027 in /etc/login.defs"
else
    echo "UMASK 027" >> /etc/login.defs
    echo " - Added UMASK 027 to /etc/login.defs"
fi

echo ""
echo "CIS 4.5.3.3 remediation complete."
echo "Note: Users may need to log out and back in for changes to take effect."
