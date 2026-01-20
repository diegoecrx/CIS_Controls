#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.2.3.19
# Ensure kernel module loading, unloading and modification is collected
# OCI compatible - handles ksplice symlinks

set -e

echo "CIS 5.2.3.19 - Configuring kernel module audit rules..."

UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)

# Create the audit rules file
cat > /etc/audit/rules.d/50-kernel_modules.rules << EOF
# CIS 5.2.3.19 - Kernel module loading, unloading and modification
-a always,exit -F arch=b64 -S init_module,finit_module,delete_module,create_module,query_module -F auid>=${UID_MIN} -F auid!=unset -k kernel_modules
-a always,exit -F path=/usr/bin/kmod -F perm=x -F auid>=${UID_MIN} -F auid!=unset -k kernel_modules
EOF

# Check for ksplice symlinks and add rules for them
echo " - Checking for ksplice symlinks..."
for tool in insmod rmmod modprobe depmod modinfo lsmod; do
    for path in /usr/sbin /sbin; do
        if [ -L "$path/$tool" ]; then
            target=$(readlink -f "$path/$tool")
            if [[ "$target" == *"ksplice"* ]]; then
                echo "-a always,exit -F path=$path/$tool -F perm=x -F auid>=${UID_MIN} -F auid!=unset -k kernel_modules" >> /etc/audit/rules.d/50-kernel_modules.rules
                echo "   - Added audit rule for $path/$tool -> $target"
            fi
        elif [ -f "$path/$tool" ]; then
            # If it's a regular file (not symlink), also audit it
            if ! grep -q "path=$path/$tool" /etc/audit/rules.d/50-kernel_modules.rules 2>/dev/null; then
                echo "-a always,exit -F path=$path/$tool -F perm=x -F auid>=${UID_MIN} -F auid!=unset -k kernel_modules" >> /etc/audit/rules.d/50-kernel_modules.rules
                echo "   - Added audit rule for $path/$tool"
            fi
        fi
    done
done

# Load rules
echo ""
echo "Loading audit rules..."
augenrules --load 2>/dev/null || true

echo ""
echo "Verifying rules:"
auditctl -l 2>/dev/null | grep kernel_modules | head -5 || echo "Rules will be active after reboot"

# Check if reboot required
if [[ $(auditctl -s 2>/dev/null | grep "enabled") =~ "2" ]]; then
    echo ""
    echo "NOTE: Reboot required to load rules (audit in immutable mode)."
fi

echo ""
echo "CIS 5.2.3.19 remediation complete."
