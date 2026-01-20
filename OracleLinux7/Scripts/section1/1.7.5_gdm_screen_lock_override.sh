#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 - 1.7.5 Ensure GDM screen locks cannot be overridden
# Compatible with OCI (Oracle Cloud Infrastructure)

echo "=== CIS 1.7.5 - Lock GDM screen lock settings ==="

# Check if GDM is installed
if ! rpm -q gdm > /dev/null 2>&1 && ! rpm -q gdm3 > /dev/null 2>&1; then
    echo " - GNOME Desktop Manager is not installed"
    echo " - Recommendation is Not Applicable"
    exit 0
fi

# Find dconf database directory with idle-delay setting
l_kfd="/etc/dconf/db/local.d"

if [ -d "$l_kfd" ]; then
    # Create locks directory
    mkdir -p "$l_kfd/locks"
    
    # Lock screen settings
    cat > "$l_kfd/locks/00-screensaver" << EOF
# Lock desktop screensaver idle-delay setting
/org/gnome/desktop/session/idle-delay

# Lock desktop screensaver lock-delay setting
/org/gnome/desktop/screensaver/lock-delay
EOF

    echo " - Created screen lock settings locks"
    
    dconf update
    echo " - Updated dconf database"
else
    echo " - Please run 1.7.4 first to configure screen lock settings"
fi

echo " - GDM screen lock settings lock complete"
