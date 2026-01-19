#!/bin/bash
# CIS Oracle Linux 7 - 1.1.1.6 Ensure squashfs kernel module is not available
# This script disables the squashfs kernel module
# Compatible with OCI (Oracle Cloud Infrastructure)
# WARNING: Disabling squashfs will cause Snap packages to fail

set -e

echo "=== CIS 1.1.1.6 - Disable squashfs kernel module ==="
echo "WARNING: Disabling squashfs will cause Snap packages to fail!"

l_mname="squashfs"
l_mtype="fs"
l_mpath="/lib/modules/**/kernel/$l_mtype"
l_mpname="$(tr '-' '_' <<< "$l_mname")"
l_mndir="$(tr '-' '/' <<< "$l_mname")"

module_loadable_fix() {
    l_loadable="$(modprobe -n -v "$l_mname" 2>/dev/null)"
    [ "$(wc -l <<< "$l_loadable")" -gt "1" ] && l_loadable="$(grep -P -- "(^\h*install|\b$l_mname)\b" <<< "$l_loadable")"
    if ! grep -Pq -- '^\h*install \/bin\/(true|false)' <<< "$l_loadable"; then
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
