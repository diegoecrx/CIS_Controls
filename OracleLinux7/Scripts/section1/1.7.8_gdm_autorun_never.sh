#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 - 1.7.8 Ensure GDM autorun-never is enabled
# Compatible with OCI (Oracle Cloud Infrastructure)

echo "=== CIS 1.7.8 - Enable GDM autorun-never ==="

# Check if GDM is installed
if ! rpm -q gdm > /dev/null 2>&1 && ! rpm -q gdm3 > /dev/null 2>&1; then
    echo " - GNOME Desktop Manager is not installed"
    echo " - Recommendation is Not Applicable"
    exit 0
fi

l_gpname="local"

mkdir -p /etc/dconf/profile
if [ ! -f /etc/dconf/profile/user ]; then
    cat > /etc/dconf/profile/user << EOF
user-db:user
system-db:$l_gpname
EOF
fi

mkdir -p "/etc/dconf/db/$l_gpname.d/"

l_kfile="/etc/dconf/db/$l_gpname.d/00-media-autorun"
cat > "$l_kfile" << EOF
[org/gnome/desktop/media-handling]
autorun-never=true
EOF

echo " - Created GDM autorun-never configuration"

dconf update
echo " - Updated dconf database"

echo " - GDM autorun-never enabled"
