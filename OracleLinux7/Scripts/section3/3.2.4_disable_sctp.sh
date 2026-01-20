#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 3.2.4
# Ensure sctp kernel module is not available
# This script disables the sctp kernel module

set -e

echo "CIS 3.2.4 - Disabling sctp kernel module..."

l_mname="sctp"
l_mtype="net"
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
        modprobe -r "$l_mname" 2>/dev/null || echo "Could not unload $l_mname - may require reboot."
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

echo "CIS 3.2.4 remediation complete - sctp module disabled."
