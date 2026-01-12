#!/bin/bash
# CIS Oracle Linux 7 - 1.7.3 Ensure GDM disable-user-list option is enabled
# Compatible with OCI (Oracle Cloud Infrastructure)

echo "=== CIS 1.7.3 - Enable GDM disable-user-list ==="

# Check if GDM is installed
if ! rpm -q gdm > /dev/null 2>&1 && ! rpm -q gdm3 > /dev/null 2>&1; then
    echo " - GNOME Desktop Manager is not installed"
    echo " - Recommendation is Not Applicable"
    exit 0
fi

l_gdmprofile="gdm"

# Create dconf profile if needed
if [ ! -f "/etc/dconf/profile/$l_gdmprofile" ]; then
    mkdir -p /etc/dconf/profile
    cat > "/etc/dconf/profile/$l_gdmprofile" << EOF
user-db:user
system-db:$l_gdmprofile
file-db:/usr/share/$l_gdmprofile/greeter-dconf-defaults
EOF
fi

# Create dconf database directory
mkdir -p "/etc/dconf/db/$l_gdmprofile.d/"

# Create disable-user-list config
cat > "/etc/dconf/db/$l_gdmprofile.d/00-login-screen" << EOF
[org/gnome/login-screen]
# Do not show the user list
disable-user-list=true
EOF

echo " - Created GDM disable-user-list configuration"

dconf update
echo " - Updated dconf database"

echo " - GDM disable-user-list configuration complete"
