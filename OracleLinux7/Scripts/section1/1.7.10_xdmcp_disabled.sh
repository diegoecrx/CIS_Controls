#!/bin/bash
# CIS Oracle Linux 7 - 1.7.10 Ensure XDMCP is not enabled
# Compatible with OCI (Oracle Cloud Infrastructure)
# WARNING: This affects remote display - exercise caution

echo "=== CIS 1.7.10 - Ensure XDMCP is not enabled ==="

GDM_CUSTOM_CONF="/etc/gdm/custom.conf"

if [ -f "$GDM_CUSTOM_CONF" ]; then
    # Remove Enable=true from xdmcp section
    if grep -q "Enable=true" "$GDM_CUSTOM_CONF"; then
        sed -i '/^\[xdmcp\]/,/^\[/{s/Enable=true/#Enable=false/}' "$GDM_CUSTOM_CONF"
        echo " - Disabled XDMCP in $GDM_CUSTOM_CONF"
    else
        echo " - XDMCP is not enabled (PASS)"
    fi
else
    echo " - $GDM_CUSTOM_CONF not found (GDM may not be installed)"
fi

echo " - XDMCP configuration complete"
