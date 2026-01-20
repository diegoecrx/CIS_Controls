#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 - 1.7.7 Ensure GDM disabling automatic mounting is not overridden
# Compatible with OCI (Oracle Cloud Infrastructure)

echo "=== CIS 1.7.7 - Lock GDM automount settings ==="

# Check if GDM is installed
if ! rpm -q gdm > /dev/null 2>&1 && ! rpm -q gdm3 > /dev/null 2>&1; then
    echo " - GNOME Desktop Manager is not installed"
    echo " - Recommendation is Not Applicable"
    exit 0
fi

l_kfd="/etc/dconf/db/local.d"

if [ -d "$l_kfd" ]; then
    mkdir -p "$l_kfd/locks"
    
    cat > "$l_kfd/locks/00-media-automount" << EOF
# Lock desktop media-handling automount setting
/org/gnome/desktop/media-handling/automount

# Lock desktop media-handling automount-open setting
/org/gnome/desktop/media-handling/automount-open
EOF

    echo " - Created automount settings locks"
    
    dconf update
    echo " - Updated dconf database"
else
    echo " - Please run 1.7.6 first to configure automount settings"
fi

echo " - GDM automount settings lock complete"
