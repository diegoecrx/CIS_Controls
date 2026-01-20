#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 - 1.7.4 Ensure GDM screen locks when the user is idle
# Compatible with OCI (Oracle Cloud Infrastructure)

echo "=== CIS 1.7.4 - Configure GDM screen lock on idle ==="

# Check if GDM is installed
if ! rpm -q gdm > /dev/null 2>&1 && ! rpm -q gdm3 > /dev/null 2>&1; then
    echo " - GNOME Desktop Manager is not installed"
    echo " - Recommendation is Not Applicable"
    exit 0
fi

# Create dconf profile
mkdir -p /etc/dconf/profile
cat > /etc/dconf/profile/user << EOF
user-db:user
system-db:local
EOF

# Create dconf database directory
mkdir -p /etc/dconf/db/local.d

# Create screensaver config
l_idmv="900"  # idle-delay in seconds (15 minutes)
l_ldmv="5"    # lock-delay in seconds

cat > /etc/dconf/db/local.d/00-screensaver << EOF
# Specify the dconf path
[org/gnome/desktop/session]

# Number of seconds of inactivity before the screen goes blank
idle-delay=uint32 $l_idmv

# Specify the dconf path
[org/gnome/desktop/screensaver]

# Number of seconds after the screen is blank before locking
lock-delay=uint32 $l_ldmv
EOF

echo " - Created GDM screen lock configuration"

dconf update
echo " - Updated dconf database"

echo " - GDM screen lock configuration complete"
echo "NOTE: Users must log out and back in for changes to take effect"
