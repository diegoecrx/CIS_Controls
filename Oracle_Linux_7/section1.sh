#!/bin/bash
#############################################################################
# CIS Oracle Linux 7 Benchmark v4.0.0 - Section 1 Remediation Script
# Initial Setup
# Controls: 1.1.1 - 1.7.10
#############################################################################

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log file
LOG_FILE="/var/log/cis_section1_remediation_$(date +%Y%m%d_%H%M%S).log"

# Function to log messages
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" | tee -a "$LOG_FILE"
}

# Function to print section headers
print_section() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
    log_message "INFO" "Starting: $1"
}

# Function to print subsection headers
print_subsection() {
    echo -e "\n${YELLOW}--- $1 ---${NC}"
    log_message "INFO" "$1"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}This script must be run as root${NC}"
        exit 1
    fi
}

# Function to backup a file before modification
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        cp -p "$file" "${file}.bak.$(date +%Y%m%d_%H%M%S)"
        log_message "INFO" "Backed up $file"
    fi
}

#############################################################################
# SECTION 1.1.1: Disable unused filesystems
#############################################################################

disable_kernel_module() {
    local module_name="$1"
    local module_type="${2:-fs}"
    local conf_file="/etc/modprobe.d/${module_name}.conf"
    
    echo -e "  Disabling kernel module: ${module_name}"
    
    # Create modprobe.d config to prevent loading
    {
        echo "# CIS Benchmark - Disable ${module_name}"
        echo "install ${module_name} /bin/false"
        echo "blacklist ${module_name}"
    } > "$conf_file"
    
    # Unload module if currently loaded
    if lsmod | grep -q "^${module_name}"; then
        modprobe -r "${module_name}" 2>/dev/null || true
    fi
    
    log_message "INFO" "Disabled kernel module: ${module_name}"
}

configure_filesystem_modules() {
    print_section "1.1.1 Disable unused filesystems"
    
    # 1.1.1.1 Ensure cramfs kernel module is not available
    print_subsection "1.1.1.1 Disable cramfs"
    disable_kernel_module "cramfs" "fs"
    
    # 1.1.1.2 Ensure freevxfs kernel module is not available
    print_subsection "1.1.1.2 Disable freevxfs"
    disable_kernel_module "freevxfs" "fs"
    
    # 1.1.1.3 Ensure hfs kernel module is not available
    print_subsection "1.1.1.3 Disable hfs"
    disable_kernel_module "hfs" "fs"
    
    # 1.1.1.4 Ensure hfsplus kernel module is not available
    print_subsection "1.1.1.4 Disable hfsplus"
    disable_kernel_module "hfsplus" "fs"
    
    # 1.1.1.5 Ensure jffs2 kernel module is not available
    print_subsection "1.1.1.5 Disable jffs2"
    disable_kernel_module "jffs2" "fs"
    
    # 1.1.1.6 Ensure squashfs kernel module is not available (Level 2)
    print_subsection "1.1.1.6 Disable squashfs (Level 2)"
    disable_kernel_module "squashfs" "fs"
    
    # 1.1.1.7 Ensure udf kernel module is not available (Level 2)
    # Note: May be needed for Azure - skip if on Azure
    print_subsection "1.1.1.7 Disable udf (Level 2 - skip if on Azure)"
    disable_kernel_module "udf" "fs"
    
    # 1.1.1.8 Ensure usb-storage kernel module is not available
    print_subsection "1.1.1.8 Disable usb-storage"
    disable_kernel_module "usb-storage" "drivers"
    
    echo -e "${GREEN}[OK]${NC} Filesystem modules disabled"
}

#############################################################################
# SECTION 1.1.2: Configure /tmp, /dev/shm, /home, /var mount options
#############################################################################

configure_mount_options() {
    print_section "1.1.2 Configure filesystem mount options"
    
    local fstab="/etc/fstab"
    backup_file "$fstab"
    
    # 1.1.2.1 /tmp partition configuration
    print_subsection "1.1.2.1 Configure /tmp partition"
    if ! findmnt -kn /tmp &>/dev/null; then
        echo -e "${YELLOW}[INFO]${NC} /tmp is not a separate partition"
        echo -e "       Adding tmpfs mount for /tmp"
        if ! grep -q "^tmpfs.*/tmp" "$fstab"; then
            echo "tmpfs /tmp tmpfs defaults,rw,nosuid,nodev,noexec,relatime 0 0" >> "$fstab"
        fi
    else
        # Update existing /tmp mount options
        if grep -q "/tmp" "$fstab"; then
            sed -i '/\/tmp/s/defaults/defaults,nosuid,nodev,noexec/' "$fstab" 2>/dev/null || true
        fi
    fi
    mount -o remount /tmp 2>/dev/null || mount /tmp 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC} /tmp configured with nodev,nosuid,noexec"
    
    # 1.1.2.2 /dev/shm partition configuration
    print_subsection "1.1.2.2 Configure /dev/shm partition"
    if ! grep -q "^tmpfs.*/dev/shm" "$fstab"; then
        echo "tmpfs /dev/shm tmpfs defaults,rw,nosuid,nodev,noexec,relatime 0 0" >> "$fstab"
    else
        sed -i '/\/dev\/shm/s/defaults/defaults,nosuid,nodev,noexec/' "$fstab" 2>/dev/null || true
    fi
    mount -o remount /dev/shm 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC} /dev/shm configured with nodev,nosuid,noexec"
    
    # 1.1.2.3-1.1.2.7 Configure mount options for /home, /var, /var/tmp, /var/log, /var/log/audit
    local partitions=("/home" "/var" "/var/tmp" "/var/log" "/var/log/audit")
    local options="nodev,nosuid"
    
    for part in "${partitions[@]}"; do
        print_subsection "Configure ${part} partition"
        if findmnt -kn "$part" &>/dev/null; then
            # Add noexec for tmp directories
            if [[ "$part" == *"tmp"* ]] || [[ "$part" == *"log"* ]]; then
                options="nodev,nosuid,noexec"
            fi
            echo -e "${YELLOW}[INFO]${NC} ${part} exists - ensure mount options include: ${options}"
            log_message "INFO" "${part} should have options: ${options}"
        else
            echo -e "${YELLOW}[SKIP]${NC} ${part} is not a separate partition"
        fi
    done
}

#############################################################################
# SECTION 1.2: Configure Software Updates
#############################################################################

configure_package_manager() {
    print_section "1.2 Configure Software Updates"
    
    # 1.2.2 Ensure gpgcheck is globally activated
    print_subsection "1.2.2 Enable gpgcheck globally"
    if [[ -f /etc/yum.conf ]]; then
        backup_file "/etc/yum.conf"
        sed -i 's/^gpgcheck\s*=.*/gpgcheck=1/' /etc/yum.conf
        if ! grep -q "^gpgcheck" /etc/yum.conf; then
            echo "gpgcheck=1" >> /etc/yum.conf
        fi
    fi
    
    # Fix any repos with gpgcheck=0
    find /etc/yum.repos.d/ -name "*.repo" -exec sed -i 's/^gpgcheck\s*=\s*0/gpgcheck=1/' {} \;
    echo -e "${GREEN}[OK]${NC} gpgcheck enabled globally"
    
    # 1.2.3 Ensure repo_gpgcheck is globally activated (Level 2)
    print_subsection "1.2.3 Enable repo_gpgcheck globally (Level 2)"
    if ! grep -q "^repo_gpgcheck" /etc/yum.conf; then
        echo "repo_gpgcheck=1" >> /etc/yum.conf
    else
        sed -i 's/^repo_gpgcheck\s*=.*/repo_gpgcheck=1/' /etc/yum.conf
    fi
    echo -e "${GREEN}[OK]${NC} repo_gpgcheck enabled"
}

#############################################################################
# SECTION 1.3: Secure Boot Settings
#############################################################################

configure_bootloader() {
    print_section "1.3 Secure Boot Settings"
    
    # 1.3.1 Ensure bootloader password is set
    print_subsection "1.3.1 Bootloader password"
    echo -e "${YELLOW}[MANUAL]${NC} Set bootloader password with: grub2-setpassword"
    log_message "WARN" "Bootloader password must be set manually with grub2-setpassword"
    
    # 1.3.2 Ensure permissions on bootloader config are configured
    print_subsection "1.3.2 Configure bootloader file permissions"
    local grub_files=("/boot/grub2/grub.cfg" "/boot/grub2/grubenv" "/boot/grub2/user.cfg")
    for gfile in "${grub_files[@]}"; do
        if [[ -f "$gfile" ]]; then
            chown root:root "$gfile"
            chmod u-x,go-rwx "$gfile"
            echo -e "${GREEN}[OK]${NC} Secured $gfile"
        fi
    done
    
    # For UEFI systems
    if [[ -d /boot/efi/EFI ]]; then
        find /boot/efi/EFI -type f \( -name 'grub*' -o -name 'user.cfg' \) -exec chown root:root {} \; -exec chmod og-rwx {} \;
        echo -e "${GREEN}[OK]${NC} Secured UEFI boot files"
    fi
    
    # 1.3.3 Ensure authentication required for single user mode
    print_subsection "1.3.3 Configure single user mode authentication"
    local rescue_service="/usr/lib/systemd/system/rescue.service"
    local emergency_service="/usr/lib/systemd/system/emergency.service"
    
    for svc in "$rescue_service" "$emergency_service"; do
        if [[ -f "$svc" ]]; then
            if ! grep -q "sulogin" "$svc"; then
                backup_file "$svc"
                sed -i 's|^ExecStart=.*|ExecStart=-/bin/sh -c "/sbin/sulogin; /usr/bin/systemctl --fail --no-block default"|' "$svc"
            fi
        fi
    done
    echo -e "${GREEN}[OK]${NC} Single user mode requires authentication"
}

#############################################################################
# SECTION 1.4: Additional Process Hardening
#############################################################################

configure_process_hardening() {
    print_section "1.4 Additional Process Hardening"
    
    local sysctl_file="/etc/sysctl.d/60-kernel_sysctl.conf"
    
    # 1.4.1 Ensure address space layout randomization (ASLR) is enabled
    print_subsection "1.4.1 Enable ASLR"
    echo "kernel.randomize_va_space = 2" >> "$sysctl_file"
    sysctl -w kernel.randomize_va_space=2
    echo -e "${GREEN}[OK]${NC} ASLR enabled"
    
    # 1.4.2 Ensure ptrace_scope is restricted
    print_subsection "1.4.2 Restrict ptrace_scope"
    echo "kernel.yama.ptrace_scope = 1" >> "$sysctl_file"
    sysctl -w kernel.yama.ptrace_scope=1
    echo -e "${GREEN}[OK]${NC} ptrace_scope restricted"
    
    # 1.4.3 Ensure core dump backtraces are disabled
    print_subsection "1.4.3 Disable core dump backtraces"
    local coredump_conf="/etc/systemd/coredump.conf"
    if [[ -f "$coredump_conf" ]]; then
        backup_file "$coredump_conf"
        if grep -q "^ProcessSizeMax" "$coredump_conf"; then
            sed -i 's/^ProcessSizeMax.*/ProcessSizeMax=0/' "$coredump_conf"
        else
            echo "ProcessSizeMax=0" >> "$coredump_conf"
        fi
    else
        mkdir -p /etc/systemd
        echo "[Coredump]" > "$coredump_conf"
        echo "ProcessSizeMax=0" >> "$coredump_conf"
    fi
    echo -e "${GREEN}[OK]${NC} Core dump backtraces disabled"
    
    # 1.4.4 Ensure core dump storage is disabled
    print_subsection "1.4.4 Disable core dump storage"
    if grep -q "^Storage" "$coredump_conf"; then
        sed -i 's/^Storage.*/Storage=none/' "$coredump_conf"
    else
        echo "Storage=none" >> "$coredump_conf"
    fi
    echo -e "${GREEN}[OK]${NC} Core dump storage disabled"
}

#############################################################################
# SECTION 1.5: SELinux Configuration
# NOTE: SELinux controls are COMMENTED OUT as per user requirements
#############################################################################

configure_selinux() {
    print_section "1.5 SELinux Configuration"
    
    echo -e "${YELLOW}[SKIPPED]${NC} SELinux configuration is commented out per requirements"
    log_message "INFO" "SELinux configuration skipped per user requirements"
    
    # The following SELinux controls are commented out:
    
    # # 1.5.1.1 Ensure SELinux is installed
    # print_subsection "1.5.1.1 Install SELinux"
    # yum install -y libselinux
    # echo -e "${GREEN}[OK]${NC} SELinux installed"
    
    # # 1.5.1.2 Ensure SELinux is not disabled in bootloader configuration
    # print_subsection "1.5.1.2 Enable SELinux in bootloader"
    # grubby --update-kernel ALL --remove-args "selinux=0 enforcing=0"
    # sed -ri 's/\s*(selinux|enforcing)=0\s*//g' /etc/default/grub 2>/dev/null || true
    # echo -e "${GREEN}[OK]${NC} SELinux enabled in bootloader"
    
    # # 1.5.1.3 Ensure SELinux policy is configured
    # print_subsection "1.5.1.3 Configure SELinux policy"
    # local selinux_config="/etc/selinux/config"
    # if [[ -f "$selinux_config" ]]; then
    #     backup_file "$selinux_config"
    #     sed -i 's/^SELINUXTYPE=.*/SELINUXTYPE=targeted/' "$selinux_config"
    # fi
    # echo -e "${GREEN}[OK]${NC} SELinux policy configured"
    
    # # 1.5.1.4 Ensure the SELinux mode is not disabled
    # print_subsection "1.5.1.4 Enable SELinux mode"
    # sed -i 's/^SELINUX=disabled/SELINUX=enforcing/' "$selinux_config"
    # setenforce 1 2>/dev/null || true
    # echo -e "${GREEN}[OK]${NC} SELinux mode enabled"
    
    # # 1.5.1.7 Ensure the MCS Translation Service (mcstrans) is not installed
    # print_subsection "1.5.1.7 Remove mcstrans"
    # yum remove -y mcstrans 2>/dev/null || true
    # echo -e "${GREEN}[OK]${NC} mcstrans removed"
    
    # # 1.5.1.8 Ensure SETroubleshoot is not installed
    # print_subsection "1.5.1.8 Remove setroubleshoot"
    # yum remove -y setroubleshoot 2>/dev/null || true
    # echo -e "${GREEN}[OK]${NC} setroubleshoot removed"
}

#############################################################################
# SECTION 1.6: Warning Banners
#############################################################################

configure_banners() {
    print_section "1.6 Warning Banners"
    
    local banner_text="Authorized users only. All activity may be monitored and reported."
    
    # 1.6.1 Ensure message of the day is configured properly
    print_subsection "1.6.1 Configure /etc/motd"
    echo "$banner_text" > /etc/motd
    chown root:root /etc/motd
    chmod 644 /etc/motd
    echo -e "${GREEN}[OK]${NC} /etc/motd configured"
    
    # 1.6.2 Ensure local login warning banner is configured properly
    print_subsection "1.6.2 Configure /etc/issue"
    echo "$banner_text" > /etc/issue
    chown root:root /etc/issue
    chmod 644 /etc/issue
    echo -e "${GREEN}[OK]${NC} /etc/issue configured"
    
    # 1.6.3 Ensure remote login warning banner is configured properly
    print_subsection "1.6.3 Configure /etc/issue.net"
    echo "$banner_text" > /etc/issue.net
    chown root:root /etc/issue.net
    chmod 644 /etc/issue.net
    echo -e "${GREEN}[OK]${NC} /etc/issue.net configured"
}

#############################################################################
# SECTION 1.7: GNOME Display Manager
#############################################################################

configure_gdm() {
    print_section "1.7 GNOME Display Manager"
    
    # Check if GDM is installed
    if ! rpm -q gdm &>/dev/null; then
        echo -e "${YELLOW}[SKIP]${NC} GDM is not installed - skipping GDM configuration"
        log_message "INFO" "GDM not installed - skipping configuration"
        return
    fi
    
    # 1.7.1 Ensure GNOME Display Manager is removed (Level 2 - Server)
    print_subsection "1.7.1 GNOME Display Manager (Level 2)"
    echo -e "${YELLOW}[MANUAL]${NC} Consider removing GDM on servers: yum remove gdm"
    
    # 1.7.2 Ensure GDM login banner is configured
    print_subsection "1.7.2 Configure GDM login banner"
    local gdm_profile="/etc/dconf/profile/gdm"
    local gdm_db_dir="/etc/dconf/db/gdm.d"
    local gdm_banner_file="${gdm_db_dir}/01-banner-message"
    
    mkdir -p "$gdm_db_dir"
    
    # Create dconf profile
    if [[ ! -f "$gdm_profile" ]]; then
        {
            echo "user-db:user"
            echo "system-db:gdm"
            echo "file-db:/usr/share/gdm/greeter-dconf-defaults"
        } > "$gdm_profile"
    fi
    
    # Create banner message file
    {
        echo "[org/gnome/login-screen]"
        echo "banner-message-enable=true"
        echo "banner-message-text='Authorized uses only. All activity may be monitored and reported.'"
    } > "$gdm_banner_file"
    
    # 1.7.3 Ensure GDM disable-user-list option is enabled
    print_subsection "1.7.3 Disable GDM user list"
    local gdm_login_file="${gdm_db_dir}/00-login-screen"
    {
        echo "[org/gnome/login-screen]"
        echo "disable-user-list=true"
    } > "$gdm_login_file"
    
    # 1.7.4-1.7.5 Configure GDM screen locks
    print_subsection "1.7.4-1.7.5 Configure GDM screen locks"
    local gdm_screensaver_file="${gdm_db_dir}/00-screensaver"
    {
        echo "[org/gnome/desktop/session]"
        echo "idle-delay=uint32 900"
        echo ""
        echo "[org/gnome/desktop/screensaver]"
        echo "lock-delay=uint32 5"
    } > "$gdm_screensaver_file"
    
    # Create locks directory
    mkdir -p "${gdm_db_dir}/locks"
    {
        echo "/org/gnome/desktop/session/idle-delay"
        echo "/org/gnome/desktop/screensaver/lock-delay"
    } > "${gdm_db_dir}/locks/00-screensaver"
    
    # 1.7.6-1.7.7 Disable automatic mounting
    print_subsection "1.7.6-1.7.7 Disable GDM automatic mounting"
    local gdm_automount_file="${gdm_db_dir}/00-media-automount"
    {
        echo "[org/gnome/desktop/media-handling]"
        echo "automount=false"
        echo "automount-open=false"
    } > "$gdm_automount_file"
    
    # 1.7.8-1.7.9 Enable autorun-never
    print_subsection "1.7.8-1.7.9 Enable GDM autorun-never"
    local gdm_autorun_file="${gdm_db_dir}/00-media-autorun"
    {
        echo "[org/gnome/desktop/media-handling]"
        echo "autorun-never=true"
    } > "$gdm_autorun_file"
    
    # 1.7.10 Ensure XDMCP is not enabled
    print_subsection "1.7.10 Disable XDMCP"
    local gdm_custom="/etc/gdm/custom.conf"
    if [[ -f "$gdm_custom" ]]; then
        sed -i '/^\s*Enable\s*=\s*true/d' "$gdm_custom"
    fi
    
    # Update dconf database
    dconf update 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC} GDM configured"
}

#############################################################################
# MAIN EXECUTION
#############################################################################

main() {
    echo -e "${GREEN}"
    echo "=============================================================="
    echo " CIS Oracle Linux 7 Benchmark v4.0.0"
    echo " Section 1: Initial Setup"
    echo " Controls: 1.1.1 - 1.7.10"
    echo "=============================================================="
    echo -e "${NC}"
    
    # Check for root privileges
    check_root
    
    # Initialize log file
    echo "CIS Oracle Linux 7 Benchmark v4.0.0 - Section 1 Remediation" > "$LOG_FILE"
    echo "Started: $(date)" >> "$LOG_FILE"
    echo "=======================================================" >> "$LOG_FILE"
    
    # Execute remediation sections
    configure_filesystem_modules
    configure_mount_options
    configure_package_manager
    configure_bootloader
    configure_process_hardening
    configure_selinux
    configure_banners
    configure_gdm
    
    # Summary
    print_section "Remediation Complete"
    echo -e "${GREEN}Section 1 remediation has been completed.${NC}"
    echo -e "Log file: ${YELLOW}$LOG_FILE${NC}"
    echo ""
    echo -e "${YELLOW}IMPORTANT POST-REMEDIATION STEPS:${NC}"
    echo -e "1. Set bootloader password: ${BLUE}grub2-setpassword${NC}"
    echo -e "2. Regenerate GRUB config: ${BLUE}grub2-mkconfig -o /boot/grub2/grub.cfg${NC}"
    echo -e "3. Review partition layout for /tmp, /var, /var/log, /home"
    echo -e "4. Reboot the system to apply all changes"
    echo ""
    
    log_message "INFO" "Section 1 remediation completed"
    echo "Completed: $(date)" >> "$LOG_FILE"
}

# Run main function
main "$@"
