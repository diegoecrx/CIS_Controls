#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 3.1.2
# Ensure wireless interfaces are disabled
# This script disables wireless interfaces

set -e

echo "CIS 3.1.2 - Disabling wireless interfaces..."

module_fix() {
    local l_mname="$1"
    
    if ! modprobe -n -v "$l_mname" 2>/dev/null | grep -P -- '^\h*install /bin/(true|false)' &>/dev/null; then
        echo " - Setting module: \"$l_mname\" to be un-loadable"
        echo "install $l_mname /bin/false" >> /etc/modprobe.d/"$l_mname".conf
    fi
    
    if lsmod | grep "$l_mname" &>/dev/null; then
        echo " - Unloading module \"$l_mname\""
        modprobe -r "$l_mname" 2>/dev/null || true
    fi
    
    if ! grep -Pq -- "^\h*blacklist\h+$l_mname\b" /etc/modprobe.d/* 2>/dev/null; then
        echo " - Blacklisting \"$l_mname\""
        echo "blacklist $l_mname" >> /etc/modprobe.d/"$l_mname".conf
    fi
}

# Find wireless interfaces and disable their drivers
if [ -n "$(find /sys/class/net/*/ -type d -name wireless 2>/dev/null)" ]; then
    l_dname=$(for driverdir in $(find /sys/class/net/*/ -type d -name wireless 2>/dev/null | xargs -0 dirname 2>/dev/null); do 
        basename "$(readlink -f "$driverdir"/device/driver/module 2>/dev/null)" 2>/dev/null
    done | sort -u)
    
    for l_mname in $l_dname; do
        if [ -n "$l_mname" ]; then
            module_fix "$l_mname"
        fi
    done
    echo "Wireless modules disabled."
else
    echo "No wireless interfaces found on this system."
fi

echo "CIS 3.1.2 remediation complete - wireless interfaces disabled."