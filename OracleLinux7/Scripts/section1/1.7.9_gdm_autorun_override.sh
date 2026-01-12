#!/bin/bash
# CIS Oracle Linux 7 - 1.7.9 Ensure GDM autorun-never is not overridden
# Compatible with OCI (Oracle Cloud Infrastructure)

echo "=== CIS 1.7.9 - Lock GDM autorun-never setting ==="

# Check if GDM is installed
if ! rpm -q gdm > /dev/null 2>&1 && ! rpm -q gdm3 > /dev/null 2>&1; then
    echo " - GNOME Desktop Manager is not installed"
    echo " - Recommendation is Not Applicable"
    exit 0
fi

l_kfd="/etc/dconf/db/local.d"

if [ -d "$l_kfd" ]; then
    mkdir -p "$l_kfd/locks"
    
    cat > "$l_kfd/locks/00-media-autorun" << EOF
# Lock desktop media-handling autorun-never setting
/org/gnome/desktop/media-handling/autorun-never
EOF

    echo " - Created autorun-never settings lock"
    
    dconf update
    echo " - Updated dconf database"
else
    echo " - Please run 1.7.8 first to configure autorun-never"
fi

echo " - GDM autorun-never lock complete"
