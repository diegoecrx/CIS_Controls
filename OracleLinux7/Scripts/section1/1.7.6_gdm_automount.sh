#!/bin/bash
# CIS Oracle Linux 7 - 1.7.6 Ensure GDM automatic mounting of removable media is disabled
# Compatible with OCI (Oracle Cloud Infrastructure)

echo "=== CIS 1.7.6 - Disable GDM automatic mounting ==="

# Check if GDM is installed
if ! rpm -q gdm > /dev/null 2>&1 && ! rpm -q gdm3 > /dev/null 2>&1; then
    echo " - GNOME Desktop Manager is not installed"
    echo " - Recommendation is Not Applicable"
    exit 0
fi

l_gpname="local"

# Create dconf profile
mkdir -p /etc/dconf/profile
if [ ! -f /etc/dconf/profile/user ]; then
    cat > /etc/dconf/profile/user << EOF
user-db:user
system-db:$l_gpname
EOF
fi

# Create dconf database directory
mkdir -p "/etc/dconf/db/$l_gpname.d/"

# Create automount config
l_kfile="/etc/dconf/db/$l_gpname.d/00-media-automount"
cat > "$l_kfile" << EOF
[org/gnome/desktop/media-handling]
automount=false
automount-open=false
EOF

echo " - Created GDM automount configuration"

dconf update
echo " - Updated dconf database"

echo " - GDM automatic mounting disabled"
