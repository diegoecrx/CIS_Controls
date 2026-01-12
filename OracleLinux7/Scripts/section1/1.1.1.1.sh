#!/usr/bin/env bash
#
# CIS Control 1.1.1.1 - Ensure cramfs kernel module is not available
# OCI-Compatible Remediation Script
#
# This script automatically disables the cramfs kernel module

set -e

echo "=== CIS 1.1.1.1: Disabling cramfs kernel module ==="

l_mname="cramfs"
l_mtype="fs"
l_mpath="/lib/modules/**/kernel/$l_mtype"
l_mpname="$(tr '-' '_' <<< "$l_mname")"
l_mndir="$(tr '-' '/' <<< "$l_mname")"

module_loadable_fix() {
    if ! modprobe --showconfig | grep -Pq -- "^\h*install\h+$l_mpname\h+/bin/(true|false)"; then
        echo " - Setting module \"$l_mname\" to be not loadable"
        echo -e "install $l_mname /bin/false" >> /etc/modprobe.d/"$l_mpname".conf
    fi
}

module_loaded_fix() {
    if lsmod | grep "$l_mname" > /dev/null 2>&1; then
        echo " - Unloading module \"$l_mname\""
        modprobe -r "$l_mname" 2>/dev/null || true
    fi
}

module_deny_fix() {
    if ! modprobe --showconfig | grep -Pq -- "^\h*blacklist\h+$l_mpname\b"; then
        echo " - Deny listing \"$l_mname\""
        echo -e "blacklist $l_mname" >> /etc/modprobe.d/"$l_mpname".conf
    fi
}

# Check if the module exists on the system
for l_mdir in $l_mpath; do
    if [ -d "$l_mdir/$l_mndir" ] && [ -n "$(ls -A $l_mdir/$l_mndir 2>/dev/null)" ]; then
        echo " - Module: \"$l_mname\" exists in \"$l_mdir\""
        echo " - Checking if disabled..."
        module_deny_fix
        if [ "$l_mdir" = "/lib/modules/$(uname -r)/kernel/$l_mtype" ]; then
            module_loadable_fix
            module_loaded_fix
        fi
    else
        echo " - Module: \"$l_mname\" doesn't exist in \"$l_mdir\""
    fi
done

echo " - Remediation of module: \"$l_mname\" complete"
echo "=== CIS 1.1.1.1: COMPLETED ==="
