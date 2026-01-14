#!/bin/bash
# CIS Oracle Linux 7 - 1.1.1.7 Ensure udf kernel module is not available
# This script disables the udf kernel module
# Compatible with OCI (Oracle Cloud Infrastructure)
# NOTE: This script should NOT be applied on Microsoft Azure systems

set -e

echo "=== CIS 1.1.1.7 - Disable udf kernel module ==="
echo "NOTE: Microsoft Azure requires udf - do not disable on Azure systems!"

l_mname="udf"
l_mtype="fs"
l_mpath="/lib/modules/**/kernel/$l_mtype"
l_mpname="$(tr '-' '_' <<< "$l_mname")"
l_mndir="$(tr '-' '/' <<< "$l_mname")"

module_loadable_fix() {
    if ! modprobe --showconfig | grep -Pq -- "^\h*install\h+$l_mpname\b"; then
        echo " - setting module \"$l_mname\" to not be loadable"
        echo "install $l_mname /bin/false" >> /etc/modprobe.d/"$l_mpname".conf
    fi
}

module_loaded_fix() {
    if lsmod | grep "$l_mname" > /dev/null 2>&1; then
        echo " - unloading module \"$l_mname\""
        modprobe -r "$l_mname"
    fi
}

module_deny_fix() {
    if ! modprobe --showconfig | grep -Pq -- "^\h*blacklist\h+$l_mpname\b"; then
        echo " - deny listing \"$l_mname\""
        echo "blacklist $l_mname" >> /etc/modprobe.d/"$l_mpname".conf
    fi
}

for l_mdir in $l_mpath; do
    if [ -d "$l_mdir/$l_mndir" ] && [ -n "$(ls -A $l_mdir/$l_mndir 2>/dev/null)" ]; then
        echo " - module: \"$l_mname\" exists in \"$l_mdir\""
        echo " - checking if disabled..."
        module_deny_fix
        if [ "$l_mdir" = "/lib/modules/$(uname -r)/kernel/$l_mtype" ]; then
            module_loadable_fix
            module_loaded_fix
        fi
    else
        echo " - module: \"$l_mname\" doesn't exist in \"$l_mdir\""
    fi
done

echo " - remediation of module: \"$l_mname\" complete"
