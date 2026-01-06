#!/bin/bash
#################################################################################
# CIS Oracle Linux 7 Benchmark v4.0.0 - Section 1 Remediation Script
# Automated hardening script for Oracle Linux 7 (OCI)
# This script implements remediations from CIS Benchmark controls 1.1.1.1 to 1.7.10
#################################################################################

# Exit on error, treat unset variables as error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging
LOGFILE="/var/log/cis_remediation_section1_$(date +%Y%m%d_%H%M%S).log"

log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOGFILE"
}

warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1" | tee -a "$LOGFILE"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1" | tee -a "$LOGFILE"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root"
   exit 1
fi

log "Starting CIS Oracle Linux 7 Section 1 Remediation..."

#################################################################################
# 1.1.1.1 - 1.1.1.8: Disable unnecessary kernel modules (filesystems/drivers)
#################################################################################

# Function to disable a kernel module
disable_kernel_module() {
    local l_mname="$1"
    local l_mtype="$2"
    local l_mpath="/lib/modules/**/kernel/$l_mtype"
    local l_mpname="$(tr '-' '_' <<< "$l_mname")"
    local l_mndir="$(tr '-' '/' <<< "$l_mname")"

    log "1.1.1.x: Disabling kernel module: $l_mname"

    # Check if module exists
    for l_mdir in $l_mpath; do
        if [ -d "$l_mdir/$l_mndir" ] && [ -n "$(ls -A "$l_mdir/$l_mndir" 2>/dev/null)" ]; then
            log " - Module $l_mname exists in $l_mdir, disabling..."

            # Blacklist the module
            if ! modprobe --showconfig 2>/dev/null | grep -Pq -- "^\h*blacklist\h+$l_mpname\b"; then
                echo "blacklist $l_mname" >> /etc/modprobe.d/"$l_mpname".conf
                log " - Blacklisted $l_mname"
            fi

            # Set install to /bin/false for running kernel
            if [ "$l_mdir" = "/lib/modules/$(uname -r)/kernel/$l_mtype" ]; then
                l_loadable="$(modprobe -n -v "$l_mname" 2>/dev/null)"
                if ! grep -Pq -- '^\h*install \/bin\/(true|false)' <<< "$l_loadable"; then
                    echo "install $l_mname /bin/false" >> /etc/modprobe.d/"$l_mpname".conf
                    log " - Set $l_mname install to /bin/false"
                fi
                # Unload if loaded
                if lsmod | grep "$l_mname" > /dev/null 2>&1; then
                    modprobe -r "$l_mname" 2>/dev/null || warn "Could not unload $l_mname (may be in use)"
                    log " - Unloaded $l_mname"
                fi
            fi
        fi
    done
}

# 1.1.1.1 - Ensure cramfs kernel module is not available
disable_kernel_module "cramfs" "fs"

# 1.1.1.2 - Ensure freevxfs kernel module is not available
disable_kernel_module "freevxfs" "fs"

# 1.1.1.3 - Ensure hfs kernel module is not available
disable_kernel_module "hfs" "fs"

# 1.1.1.4 - Ensure hfsplus kernel module is not available
disable_kernel_module "hfsplus" "fs"

# 1.1.1.5 - Ensure jffs2 kernel module is not available
disable_kernel_module "jffs2" "fs"

# 1.1.1.6 - Ensure squashfs kernel module is not available (Level 2)
disable_kernel_module "squashfs" "fs"

# 1.1.1.7 - Ensure udf kernel module is not available
disable_kernel_module "udf" "fs"

# 1.1.1.8 - Ensure usb-storage kernel module is not available
disable_kernel_module "usb-storage" "drivers"

#################################################################################
# 1.1.2.1.1 - 1.1.2.1.4: /tmp mount options
#################################################################################

log "1.1.2.1.x: Configuring /tmp mount options..."

# Check if /tmp entry exists in fstab
if ! grep -qE '^\s*[^#]+\s+/tmp\s+' /etc/fstab; then
    log " - Adding /tmp entry to /etc/fstab"
    echo "tmpfs /tmp tmpfs defaults,rw,nosuid,nodev,noexec,relatime 0 0" >> /etc/fstab
else
    # Update existing /tmp entry with proper options
    log " - Updating /tmp mount options in /etc/fstab"
    sed -ri 's|^(\s*[^#]+\s+/tmp\s+\S+\s+)\S+(.*)$|\1defaults,rw,nosuid,nodev,noexec,relatime\2|' /etc/fstab
fi

# Remount /tmp if mounted
if findmnt -kn /tmp > /dev/null 2>&1; then
    mount -o remount,noexec,nodev,nosuid /tmp || warn "Could not remount /tmp"
    log " - Remounted /tmp with secure options"
else
    mount /tmp 2>/dev/null || warn "Could not mount /tmp"
fi

#################################################################################
# 1.1.2.2.1 - 1.1.2.2.4: /dev/shm mount options
#################################################################################

log "1.1.2.2.x: Configuring /dev/shm mount options..."

if ! grep -qE '^\s*[^#]+\s+/dev/shm\s+' /etc/fstab; then
    log " - Adding /dev/shm entry to /etc/fstab"
    echo "tmpfs /dev/shm tmpfs defaults,rw,nosuid,nodev,noexec,relatime 0 0" >> /etc/fstab
else
    log " - Updating /dev/shm mount options in /etc/fstab"
    sed -ri 's|^(\s*[^#]+\s+/dev/shm\s+\S+\s+)\S+(.*)$|\1defaults,rw,nosuid,nodev,noexec,relatime\2|' /etc/fstab
fi

if findmnt -kn /dev/shm > /dev/null 2>&1; then
    mount -o remount,noexec,nodev,nosuid /dev/shm || warn "Could not remount /dev/shm"
    log " - Remounted /dev/shm with secure options"
fi

#################################################################################
# 1.1.2.3.x - 1.1.2.7.x: Mount options for /home, /var, /var/tmp, /var/log, /var/log/audit
# Note: These require separate partitions. Script adds options if partition exists.
#################################################################################

configure_mount_options() {
    local mount_point="$1"
    local options="$2"
    
    if findmnt -kn "$mount_point" > /dev/null 2>&1; then
        log "Configuring mount options for $mount_point..."
        if grep -qE "^\s*[^#]+\s+${mount_point}\s+" /etc/fstab; then
            # Get current device and fstype
            current_line=$(grep -E "^\s*[^#]+\s+${mount_point}\s+" /etc/fstab)
            sed -ri "s|^(\s*[^#]+\s+${mount_point}\s+\S+\s+)\S+(.*)$|\1${options}\2|" /etc/fstab
            log " - Updated $mount_point options in /etc/fstab"
        fi
        mount -o remount "$mount_point" 2>/dev/null || warn "Could not remount $mount_point"
    else
        warn "$mount_point is not a separate partition - skipping"
    fi
}

# 1.1.2.3.x - /home options (nodev, nosuid)
configure_mount_options "/home" "defaults,rw,nosuid,nodev,relatime"

# 1.1.2.4.x - /var options (nodev, nosuid)
configure_mount_options "/var" "defaults,rw,nosuid,nodev,relatime"

# 1.1.2.5.x - /var/tmp options (nodev, nosuid, noexec)
configure_mount_options "/var/tmp" "defaults,rw,nosuid,nodev,noexec,relatime"

# 1.1.2.6.x - /var/log options (nodev, nosuid, noexec)
configure_mount_options "/var/log" "defaults,rw,nosuid,nodev,noexec,relatime"

# 1.1.2.7.x - /var/log/audit options (nodev, nosuid, noexec)
configure_mount_options "/var/log/audit" "defaults,rw,nosuid,nodev,noexec,relatime"

#################################################################################
# 1.2.2 - Ensure gpgcheck is globally activated
#################################################################################

log "1.2.2: Enabling gpgcheck globally..."

# Set gpgcheck=1 in /etc/yum.conf
if [ -f /etc/yum.conf ]; then
    if grep -q '^gpgcheck' /etc/yum.conf; then
        sed -i 's/^gpgcheck\s*=\s*.*/gpgcheck=1/' /etc/yum.conf
    else
        echo "gpgcheck=1" >> /etc/yum.conf
    fi
    log " - Set gpgcheck=1 in /etc/yum.conf"
fi

# Set gpgcheck=1 in all repo files
find /etc/yum.repos.d/ -name "*.repo" -exec sed -ri 's/^gpgcheck\s*=\s*.*/gpgcheck=1/' {} \; 2>/dev/null
log " - Updated gpgcheck in all repo files"

#################################################################################
# 1.2.3 - Ensure repo_gpgcheck is globally activated (Level 2)
#################################################################################

log "1.2.3: Enabling repo_gpgcheck globally..."

if [ -f /etc/yum.conf ]; then
    if grep -q '^repo_gpgcheck' /etc/yum.conf; then
        sed -i 's/^repo_gpgcheck\s*=\s*.*/repo_gpgcheck=1/' /etc/yum.conf
    else
        sed -i '/^\[main\]/a repo_gpgcheck=1' /etc/yum.conf
    fi
    log " - Set repo_gpgcheck=1 in /etc/yum.conf"
fi

#################################################################################
# 1.3.2 - Ensure permissions on bootloader config are configured
#################################################################################

log "1.3.2: Configuring bootloader permissions..."

# For BIOS systems
if [ -f /boot/grub2/grub.cfg ]; then
    chown root:root /boot/grub2/grub.cfg
    chmod u-x,go-rwx /boot/grub2/grub.cfg
    log " - Secured /boot/grub2/grub.cfg"
fi

if [ -f /boot/grub2/grubenv ]; then
    chown root:root /boot/grub2/grubenv
    chmod u-x,go-rwx /boot/grub2/grubenv
    log " - Secured /boot/grub2/grubenv"
fi

if [ -f /boot/grub2/user.cfg ]; then
    chown root:root /boot/grub2/user.cfg
    chmod u-x,go-rwx /boot/grub2/user.cfg
    log " - Secured /boot/grub2/user.cfg"
fi

# For UEFI systems - update fstab with proper permissions
if [ -d /boot/efi/EFI ]; then
    if grep -qE '^\s*[^#]+\s+/boot/efi\s+' /etc/fstab; then
        sed -ri 's|^(\s*[^#]+\s+/boot/efi\s+\S+\s+)\S+(.*)$|\1defaults,umask=0027,fmask=0077,uid=0,gid=0\2|' /etc/fstab
        log " - Updated /boot/efi mount options for UEFI"
    fi
fi

#################################################################################
# 1.3.3 - Ensure authentication required for single user mode
#################################################################################

log "1.3.3: Configuring single user mode authentication..."

for service in rescue.service emergency.service; do
    if [ -f /usr/lib/systemd/system/$service ]; then
        if ! grep -q '/sbin/sulogin' /usr/lib/systemd/system/$service; then
            sed -i 's|^ExecStart=.*|ExecStart=-/bin/sh -c "/sbin/sulogin; /usr/bin/systemctl --fail --no-block default"|' /usr/lib/systemd/system/$service
            log " - Configured $service to require authentication"
        fi
    fi
done

#################################################################################
# 1.4.1 - Ensure address space layout randomization (ASLR) is enabled
#################################################################################

log "1.4.1: Enabling ASLR..."

if ! grep -q 'kernel.randomize_va_space' /etc/sysctl.d/60-kernel_sysctl.conf 2>/dev/null; then
    echo "kernel.randomize_va_space = 2" >> /etc/sysctl.d/60-kernel_sysctl.conf
fi
sysctl -w kernel.randomize_va_space=2 > /dev/null 2>&1
log " - ASLR enabled (kernel.randomize_va_space = 2)"

#################################################################################
# 1.4.2 - Ensure ptrace_scope is restricted
#################################################################################

log "1.4.2: Restricting ptrace_scope..."

if ! grep -q 'kernel.yama.ptrace_scope' /etc/sysctl.d/60-kernel_sysctl.conf 2>/dev/null; then
    echo "kernel.yama.ptrace_scope = 1" >> /etc/sysctl.d/60-kernel_sysctl.conf
fi
sysctl -w kernel.yama.ptrace_scope=1 > /dev/null 2>&1
log " - ptrace_scope restricted (kernel.yama.ptrace_scope = 1)"

#################################################################################
# 1.4.3 - Ensure core dump backtraces are disabled
#################################################################################

log "1.4.3: Disabling core dump backtraces..."

mkdir -p /etc/systemd
if [ ! -f /etc/systemd/coredump.conf ]; then
    cat > /etc/systemd/coredump.conf << EOF
[Coredump]
ProcessSizeMax=0
EOF
else
    if grep -q '^ProcessSizeMax' /etc/systemd/coredump.conf; then
        sed -i 's/^ProcessSizeMax.*/ProcessSizeMax=0/' /etc/systemd/coredump.conf
    else
        echo "ProcessSizeMax=0" >> /etc/systemd/coredump.conf
    fi
fi
log " - Core dump backtraces disabled (ProcessSizeMax=0)"

#################################################################################
# 1.4.4 - Ensure core dump storage is disabled
#################################################################################

log "1.4.4: Disabling core dump storage..."

if [ -f /etc/systemd/coredump.conf ]; then
    if grep -q '^Storage' /etc/systemd/coredump.conf; then
        sed -i 's/^Storage.*/Storage=none/' /etc/systemd/coredump.conf
    else
        echo "Storage=none" >> /etc/systemd/coredump.conf
    fi
fi
log " - Core dump storage disabled (Storage=none)"

#################################################################################
# 1.5.1.1 - 1.5.1.8: SELinux Configuration
# WARNING: These sections are COMMENTED OUT to prevent potential system lockout
# and to preserve existing SELinux configuration.
# Uncomment and review carefully before enabling.
#################################################################################

: <<'SELINUX_DISABLED'
#################################################################################
# 1.5.1.1 - Ensure SELinux is installed
#################################################################################

log "1.5.1.1: Ensuring SELinux is installed..."

if ! rpm -q libselinux > /dev/null 2>&1; then
    yum install -y libselinux > /dev/null 2>&1
    log " - Installed libselinux"
else
    log " - libselinux already installed"
fi

#################################################################################
# 1.5.1.2 - Ensure SELinux is not disabled in bootloader configuration
#################################################################################

log "1.5.1.2: Removing SELinux disable parameters from bootloader..."

grubby --update-kernel ALL --remove-args "selinux=0 enforcing=0" 2>/dev/null || true
if [ -f /etc/default/grub ]; then
    sed -ri 's/\s*(selinux|enforcing)=0\s*//g' /etc/default/grub
    log " - Removed selinux=0 and enforcing=0 from bootloader"
fi

#################################################################################
# 1.5.1.3 - Ensure SELinux policy is configured
#################################################################################

log "1.5.1.3: Configuring SELinux policy..."

if [ -f /etc/selinux/config ]; then
    sed -i 's/^SELINUXTYPE=.*/SELINUXTYPE=targeted/' /etc/selinux/config
    log " - Set SELinux policy to targeted"
fi

#################################################################################
# 1.5.1.4 & 1.5.1.5 - Ensure SELinux mode is enforcing
#################################################################################

log "1.5.1.4-5: Setting SELinux to enforcing mode..."

if [ -f /etc/selinux/config ]; then
    sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
    log " - Set SELinux to enforcing in config"
fi
setenforce 1 2>/dev/null || warn "Could not set SELinux to enforcing (may need reboot)"

#################################################################################
# 1.5.1.7 - Ensure the MCS Translation Service (mcstrans) is not installed
#################################################################################

log "1.5.1.7: Removing mcstrans if installed..."

if rpm -q mcstrans > /dev/null 2>&1; then
    yum remove -y mcstrans > /dev/null 2>&1
    log " - Removed mcstrans"
else
    log " - mcstrans not installed"
fi

#################################################################################
# 1.5.1.8 - Ensure SETroubleshoot is not installed
#################################################################################

log "1.5.1.8: Removing setroubleshoot if installed..."

if rpm -q setroubleshoot > /dev/null 2>&1; then
    yum remove -y setroubleshoot > /dev/null 2>&1
    log " - Removed setroubleshoot"
else
    log " - setroubleshoot not installed"
fi
SELINUX_DISABLED

log "1.5.1.x: SELinux configuration SKIPPED (commented out for safety)"
log "        To enable SELinux hardening, edit the script and remove the heredoc block"

#################################################################################
# 1.6.1 - Ensure message of the day is configured properly
#################################################################################

log "1.6.1: Configuring /etc/motd..."

if [ -f /etc/motd ]; then
    # Remove OS information from motd
    sed -ri 's/\\[mrsv]//g' /etc/motd
    # Remove references to OS name
    os_name=$(grep '^ID=' /etc/os-release 2>/dev/null | cut -d= -f2 | sed -e 's/"//g')
    if [ -n "$os_name" ]; then
        sed -ri "s/$os_name//gi" /etc/motd
    fi
    log " - Cleaned /etc/motd"
fi

#################################################################################
# 1.6.2 - Ensure local login warning banner is configured properly
#################################################################################

log "1.6.2: Configuring /etc/issue..."

echo "Authorized users only. All activity may be monitored and reported." > /etc/issue
log " - Set /etc/issue warning banner"

#################################################################################
# 1.6.3 - Ensure remote login warning banner is configured properly
#################################################################################

log "1.6.3: Configuring /etc/issue.net..."

echo "Authorized users only. All activity may be monitored and reported." > /etc/issue.net
log " - Set /etc/issue.net warning banner"

#################################################################################
# 1.6.4 - Ensure access to /etc/motd is configured
#################################################################################

log "1.6.4: Securing /etc/motd permissions..."

if [ -e /etc/motd ]; then
    chown root:root "$(readlink -e /etc/motd)"
    chmod u-x,go-wx "$(readlink -e /etc/motd)"
    log " - Secured /etc/motd permissions"
fi

#################################################################################
# 1.6.5 - Ensure access to /etc/issue is configured
#################################################################################

log "1.6.5: Securing /etc/issue permissions..."

chown root:root "$(readlink -e /etc/issue)"
chmod u-x,go-wx "$(readlink -e /etc/issue)"
log " - Secured /etc/issue permissions"

#################################################################################
# 1.6.6 - Ensure access to /etc/issue.net is configured
#################################################################################

log "1.6.6: Securing /etc/issue.net permissions..."

chown root:root "$(readlink -e /etc/issue.net)"
chmod u-x,go-wx "$(readlink -e /etc/issue.net)"
log " - Secured /etc/issue.net permissions"

#################################################################################
# 1.7.x - GNOME Display Manager (GDM) configuration
# These are only applicable if GDM is installed
#################################################################################

if rpm -q gdm > /dev/null 2>&1 || rpm -q gdm3 > /dev/null 2>&1; then
    log "1.7.x: Configuring GNOME Display Manager..."

    # 1.7.1 - Ensure GDM login banner is configured
    log "1.7.1: Configuring GDM login banner..."
    
    l_gdmprofile="gdm"
    
    # Create dconf profile if not exists
    if [ ! -f "/etc/dconf/profile/$l_gdmprofile" ]; then
        mkdir -p /etc/dconf/profile
        cat > "/etc/dconf/profile/$l_gdmprofile" << EOF
user-db:user
system-db:$l_gdmprofile
file-db:/usr/share/$l_gdmprofile/greeter-dconf-defaults
EOF
        log " - Created dconf profile for GDM"
    fi
    
    # Create dconf database directory
    mkdir -p "/etc/dconf/db/$l_gdmprofile.d"
    
    # 1.7.2 - Ensure GDM disable-user-list option is enabled
    log "1.7.2: Disabling user list in GDM..."
    
    if ! grep -Piq '^\h*disable-user-list\h*=\h*true\b' /etc/dconf/db/$l_gdmprofile.d/* 2>/dev/null; then
        cat >> "/etc/dconf/db/$l_gdmprofile.d/00-login-screen" << EOF

[org/gnome/login-screen]
# Do not show the user list
disable-user-list=true
EOF
        log " - Disabled user list in GDM"
    fi
    
    # 1.7.3 - Ensure GDM screen locks when user is idle
    # 1.7.4 - Ensure GDM screen locks cannot be overridden
    log "1.7.3-4: Configuring GDM screen lock..."
    
    cat >> "/etc/dconf/db/$l_gdmprofile.d/00-screensaver" << EOF

[org/gnome/desktop/session]
idle-delay=uint32 900

[org/gnome/desktop/screensaver]
lock-enabled=true
lock-delay=uint32 5
EOF

    # Create locks directory
    mkdir -p "/etc/dconf/db/$l_gdmprofile.d/locks"
    cat >> "/etc/dconf/db/$l_gdmprofile.d/locks/00-screensaver" << EOF
/org/gnome/desktop/session/idle-delay
/org/gnome/desktop/screensaver/lock-enabled
/org/gnome/desktop/screensaver/lock-delay
EOF
    log " - Configured GDM screen lock settings"

    # 1.7.5 & 1.7.6 - Disable GDM automatic mounting
    log "1.7.5-6: Disabling GDM automatic mounting..."
    
    cat >> "/etc/dconf/db/$l_gdmprofile.d/00-media-automount" << EOF

[org/gnome/desktop/media-handling]
automount=false
automount-open=false
EOF
    log " - Disabled GDM automatic mounting"

    # 1.7.7 & 1.7.8 & 1.7.9 - Disable autorun
    log "1.7.7-9: Disabling GDM autorun..."
    
    cat >> "/etc/dconf/db/$l_gdmprofile.d/00-media-autorun" << EOF

[org/gnome/desktop/media-handling]
autorun-never=true
EOF

    # Lock autorun setting
    cat >> "/etc/dconf/db/$l_gdmprofile.d/locks/00-media-autorun" << EOF
/org/gnome/desktop/media-handling/autorun-never
EOF
    log " - Disabled GDM autorun"

    # Update dconf database
    dconf update 2>/dev/null || true
    log " - Updated dconf database"

    # 1.7.10 - Ensure XDMCP is not enabled
    log "1.7.10: Disabling XDMCP..."
    
    if [ -f /etc/gdm/custom.conf ]; then
        sed -i '/^\s*Enable\s*=\s*true/d' /etc/gdm/custom.conf
        log " - Disabled XDMCP in /etc/gdm/custom.conf"
    fi

else
    log "1.7.x: GNOME Desktop Manager not installed - skipping GDM configuration"
fi

#################################################################################
# Apply sysctl settings
#################################################################################

log "Applying sysctl settings..."
sysctl --system > /dev/null 2>&1 || true

#################################################################################
# Summary
#################################################################################

log "=========================================="
log "CIS Oracle Linux 7 Section 1 Remediation Complete"
log "=========================================="
log "Log file: $LOGFILE"
log ""
warn "IMPORTANT: Some changes require a system reboot to take effect:"
warn " - SELinux mode changes"
warn " - Kernel module blacklisting"
warn " - Mount option changes"
log ""
log "Please review the log file and reboot the system when convenient."

exit 0
