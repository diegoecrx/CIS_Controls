#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
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

# Fix /etc/profile - comment out the entire umask block (if/else with umask 002/022)
# This handles the conditional umask that is standard in RHEL/OL
if grep -q "umask 00[02]" /etc/profile 2>/dev/null; then
    echo " - Commenting out umask block in /etc/profile..."
    # Comment out lines containing umask 002 or 022 (indented)
    sed -i 's/^\([[:space:]]*umask[[:space:]]\+00[0-9]\)$/# CIS 4.5.3.3: \1/' /etc/profile
fi

# Fix /etc/bashrc - comment out the umask lines
if grep -q "umask 00[02]" /etc/bashrc 2>/dev/null; then
    echo " - Commenting out umask lines in /etc/bashrc..."
    # Comment out lines containing umask 002 or 022 (indented)
    sed -i 's/^\([[:space:]]*umask[[:space:]]\+00[0-9]\)$/# CIS 4.5.3.3: \1/' /etc/bashrc
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
