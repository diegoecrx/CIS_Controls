#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 - 1.7.2 Ensure GDM login banner is configured
# Compatible with OCI (Oracle Cloud Infrastructure)

echo "=== CIS 1.7.2 - Configure GDM login banner ==="

# Check if GDM is installed
if ! rpm -q gdm > /dev/null 2>&1 && ! rpm -q gdm3 > /dev/null 2>&1; then
    echo " - GNOME Desktop Manager is not installed"
    echo " - Recommendation is Not Applicable"
    exit 0
fi

l_gdmprofile="gdm"
l_bmessage="'Authorized uses only. All activity may be monitored and reported'"

# Create dconf profile
if [ ! -f "/etc/dconf/profile/$l_gdmprofile" ]; then
    echo "Creating profile \"$l_gdmprofile\""
    mkdir -p /etc/dconf/profile
    cat > "/etc/dconf/profile/$l_gdmprofile" << EOF
user-db:user
system-db:$l_gdmprofile
file-db:/usr/share/$l_gdmprofile/greeter-dconf-defaults
EOF
fi

# Create dconf database directory
if [ ! -d "/etc/dconf/db/$l_gdmprofile.d/" ]; then
    echo "Creating dconf database directory"
    mkdir -p "/etc/dconf/db/$l_gdmprofile.d/"
fi

# Create banner message config
l_kfile="/etc/dconf/db/$l_gdmprofile.d/01-banner-message"
cat > "$l_kfile" << EOF
[org/gnome/login-screen]
banner-message-enable=true
banner-message-text=$l_bmessage
EOF

echo " - Created GDM banner configuration"

# Update dconf database
dconf update
echo " - Updated dconf database"

echo " - GDM login banner configuration complete"
