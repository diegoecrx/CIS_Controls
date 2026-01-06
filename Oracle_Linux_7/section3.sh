#!/bin/bash
#############################################################################
# CIS Oracle Linux 7 Benchmark v4.0.0 - Section 3 Remediation Script
# Network Configuration
# Controls: 3.1.1 - 3.4.4.x
#############################################################################

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log file
LOG_FILE="/var/log/cis_section3_remediation_$(date +%Y%m%d_%H%M%S).log"

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

# Function to set sysctl parameter
set_sysctl_param() {
    local param="$1"
    local value="$2"
    local config_file="$3"
    
    # Set in config file
    if grep -q "^${param}" "$config_file" 2>/dev/null; then
        sed -i "s|^${param}.*|${param} = ${value}|" "$config_file"
    else
        echo "${param} = ${value}" >> "$config_file"
    fi
    
    # Apply immediately
    sysctl -w "${param}=${value}" > /dev/null 2>&1 || true
    log_message "INFO" "Set ${param} = ${value}"
}

# Function to disable a kernel module
disable_kernel_module() {
    local l_mname="$1"
    local l_mtype="$2"
    local l_mpath="/lib/modules/**/kernel/$l_mtype"
    local l_mpname="$(tr '-' '_' <<< "$l_mname")"
    local l_mndir="$(tr '-' '/' <<< "$l_mname")"

    print_subsection "Disabling kernel module: $l_mname"

    for l_mdir in $l_mpath; do
        if [ -d "$l_mdir/$l_mndir" ] && [ -n "$(ls -A "$l_mdir/$l_mndir" 2>/dev/null)" ]; then
            # Blacklist the module
            if ! modprobe --showconfig 2>/dev/null | grep -Pq -- "^\h*blacklist\h+$l_mpname\b"; then
                echo "blacklist $l_mname" >> /etc/modprobe.d/"$l_mpname".conf
                log_message "INFO" "Blacklisted $l_mname"
            fi

            # Set install to /bin/false
            if [ "$l_mdir" = "/lib/modules/$(uname -r)/kernel/$l_mtype" ]; then
                l_loadable="$(modprobe -n -v "$l_mname" 2>/dev/null)"
                if ! grep -Pq -- '^\h*install \/bin\/(true|false)' <<< "$l_loadable"; then
                    echo "install $l_mname /bin/false" >> /etc/modprobe.d/"$l_mpname".conf
                    log_message "INFO" "Set $l_mname install to /bin/false"
                fi
                # Unload if loaded
                if lsmod | grep "$l_mname" > /dev/null 2>&1; then
                    modprobe -r "$l_mname" 2>/dev/null || log_message "WARN" "Could not unload $l_mname"
                fi
            fi
            echo -e "${GREEN}[OK]${NC} Disabled $l_mname"
        fi
    done
}

#############################################################################
# SECTION 3.1: Network Devices
#############################################################################

configure_network_devices() {
    print_section "3.1 Network Devices"
    
    # 3.1.1 Ensure IPv6 status is identified (Manual)
    print_subsection "3.1.1 Ensure IPv6 status is identified (Manual)"
    if grep -Pqs '^\h*0\b' /sys/module/ipv6/parameters/disable; then
        echo -e "${YELLOW}[INFO]${NC} IPv6 is enabled on this system"
        log_message "INFO" "IPv6 is enabled - configure according to site policy"
    else
        echo -e "${YELLOW}[INFO]${NC} IPv6 is disabled on this system"
        log_message "INFO" "IPv6 is disabled"
    fi
    
    # 3.1.2 Ensure wireless interfaces are disabled
    print_subsection "3.1.2 Ensure wireless interfaces are disabled"
    if [ -n "$(find /sys/class/net/*/ -type d -name wireless 2>/dev/null)" ]; then
        l_dname=$(for driverdir in $(find /sys/class/net/*/ -type d -name wireless | xargs -0 dirname 2>/dev/null); do 
            basename "$(readlink -f "$driverdir"/device/driver/module)" 2>/dev/null
        done | sort -u)
        for l_mname in $l_dname; do
            if ! modprobe -n -v "$l_mname" 2>/dev/null | grep -P -- '^\h*install \/bin\/(true|false)'; then
                echo "install $l_mname /bin/false" >> /etc/modprobe.d/"$l_mname".conf
            fi
            if lsmod | grep "$l_mname" > /dev/null 2>&1; then
                modprobe -r "$l_mname" 2>/dev/null || true
            fi
            if ! grep -Pq -- "^\h*blacklist\h+$l_mname\b" /etc/modprobe.d/*; then
                echo "blacklist $l_mname" >> /etc/modprobe.d/"$l_mname".conf
            fi
            log_message "INFO" "Disabled wireless module: $l_mname"
        done
        echo -e "${GREEN}[OK]${NC} Disabled wireless interfaces"
    else
        echo -e "${YELLOW}[SKIP]${NC} No wireless interfaces found"
    fi
    
    # 3.1.3 Ensure bluetooth services are not in use
    print_subsection "3.1.3 Ensure bluetooth services are not in use"
    if rpm -q bluez &>/dev/null; then
        systemctl stop bluetooth.service 2>/dev/null || true
        systemctl mask bluetooth.service 2>/dev/null || true
        yum remove -y bluez 2>/dev/null || true
        log_message "INFO" "Removed bluetooth services"
        echo -e "${GREEN}[OK]${NC} Removed bluetooth"
    else
        echo -e "${YELLOW}[SKIP]${NC} bluez is not installed"
    fi
}

#############################################################################
# SECTION 3.2: Uncommon Network Protocols
#############################################################################

configure_uncommon_protocols() {
    print_section "3.2 Uncommon Network Protocols"
    
    # 3.2.1 Ensure dccp kernel module is not available
    disable_kernel_module "dccp" "net"
    
    # 3.2.2 Ensure tipc kernel module is not available
    disable_kernel_module "tipc" "net"
    
    # 3.2.3 Ensure rds kernel module is not available
    disable_kernel_module "rds" "net"
    
    # 3.2.4 Ensure sctp kernel module is not available
    disable_kernel_module "sctp" "net"
}

#############################################################################
# SECTION 3.3: Network Parameters
#############################################################################

configure_network_parameters() {
    print_section "3.3 Network Parameters"
    
    # Create sysctl config files
    local IPV4_CONF="/etc/sysctl.d/60-netipv4_sysctl.conf"
    local IPV6_CONF="/etc/sysctl.d/60-netipv6_sysctl.conf"
    
    touch "$IPV4_CONF"
    touch "$IPV6_CONF"
    
    # 3.3.1 Ensure ip forwarding is disabled
    print_subsection "3.3.1 Ensure ip forwarding is disabled"
    set_sysctl_param "net.ipv4.ip_forward" "0" "$IPV4_CONF"
    sysctl -w net.ipv4.route.flush=1 > /dev/null 2>&1 || true
    
    # Check if IPv6 is enabled
    if grep -Pqs '^\h*0\b' /sys/module/ipv6/parameters/disable; then
        set_sysctl_param "net.ipv6.conf.all.forwarding" "0" "$IPV6_CONF"
        sysctl -w net.ipv6.route.flush=1 > /dev/null 2>&1 || true
    fi
    echo -e "${GREEN}[OK]${NC} Disabled IP forwarding"
    
    # 3.3.2 Ensure packet redirect sending is disabled
    print_subsection "3.3.2 Ensure packet redirect sending is disabled"
    set_sysctl_param "net.ipv4.conf.all.send_redirects" "0" "$IPV4_CONF"
    set_sysctl_param "net.ipv4.conf.default.send_redirects" "0" "$IPV4_CONF"
    sysctl -w net.ipv4.route.flush=1 > /dev/null 2>&1 || true
    echo -e "${GREEN}[OK]${NC} Disabled packet redirect sending"
    
    # 3.3.3 Ensure bogus icmp responses are ignored
    print_subsection "3.3.3 Ensure bogus icmp responses are ignored"
    set_sysctl_param "net.ipv4.icmp_ignore_bogus_error_responses" "1" "$IPV4_CONF"
    sysctl -w net.ipv4.route.flush=1 > /dev/null 2>&1 || true
    echo -e "${GREEN}[OK]${NC} Ignoring bogus ICMP responses"
    
    # 3.3.4 Ensure broadcast icmp requests are ignored
    print_subsection "3.3.4 Ensure broadcast icmp requests are ignored"
    set_sysctl_param "net.ipv4.icmp_echo_ignore_broadcasts" "1" "$IPV4_CONF"
    sysctl -w net.ipv4.route.flush=1 > /dev/null 2>&1 || true
    echo -e "${GREEN}[OK]${NC} Ignoring broadcast ICMP requests"
    
    # 3.3.5 Ensure icmp redirects are not accepted
    print_subsection "3.3.5 Ensure icmp redirects are not accepted"
    set_sysctl_param "net.ipv4.conf.all.accept_redirects" "0" "$IPV4_CONF"
    set_sysctl_param "net.ipv4.conf.default.accept_redirects" "0" "$IPV4_CONF"
    sysctl -w net.ipv4.route.flush=1 > /dev/null 2>&1 || true
    
    if grep -Pqs '^\h*0\b' /sys/module/ipv6/parameters/disable; then
        set_sysctl_param "net.ipv6.conf.all.accept_redirects" "0" "$IPV6_CONF"
        set_sysctl_param "net.ipv6.conf.default.accept_redirects" "0" "$IPV6_CONF"
        sysctl -w net.ipv6.route.flush=1 > /dev/null 2>&1 || true
    fi
    echo -e "${GREEN}[OK]${NC} Not accepting ICMP redirects"
    
    # 3.3.6 Ensure secure icmp redirects are not accepted
    print_subsection "3.3.6 Ensure secure icmp redirects are not accepted"
    set_sysctl_param "net.ipv4.conf.all.secure_redirects" "0" "$IPV4_CONF"
    set_sysctl_param "net.ipv4.conf.default.secure_redirects" "0" "$IPV4_CONF"
    sysctl -w net.ipv4.route.flush=1 > /dev/null 2>&1 || true
    echo -e "${GREEN}[OK]${NC} Not accepting secure ICMP redirects"
    
    # 3.3.7 Ensure reverse path filtering is enabled
    print_subsection "3.3.7 Ensure reverse path filtering is enabled"
    set_sysctl_param "net.ipv4.conf.all.rp_filter" "1" "$IPV4_CONF"
    set_sysctl_param "net.ipv4.conf.default.rp_filter" "1" "$IPV4_CONF"
    sysctl -w net.ipv4.route.flush=1 > /dev/null 2>&1 || true
    echo -e "${GREEN}[OK]${NC} Enabled reverse path filtering"
    
    # 3.3.8 Ensure source routed packets are not accepted
    print_subsection "3.3.8 Ensure source routed packets are not accepted"
    set_sysctl_param "net.ipv4.conf.all.accept_source_route" "0" "$IPV4_CONF"
    set_sysctl_param "net.ipv4.conf.default.accept_source_route" "0" "$IPV4_CONF"
    sysctl -w net.ipv4.route.flush=1 > /dev/null 2>&1 || true
    
    if grep -Pqs '^\h*0\b' /sys/module/ipv6/parameters/disable; then
        set_sysctl_param "net.ipv6.conf.all.accept_source_route" "0" "$IPV6_CONF"
        set_sysctl_param "net.ipv6.conf.default.accept_source_route" "0" "$IPV6_CONF"
        sysctl -w net.ipv6.route.flush=1 > /dev/null 2>&1 || true
    fi
    echo -e "${GREEN}[OK]${NC} Not accepting source routed packets"
    
    # 3.3.9 Ensure suspicious packets are logged
    print_subsection "3.3.9 Ensure suspicious packets are logged"
    set_sysctl_param "net.ipv4.conf.all.log_martians" "1" "$IPV4_CONF"
    set_sysctl_param "net.ipv4.conf.default.log_martians" "1" "$IPV4_CONF"
    sysctl -w net.ipv4.route.flush=1 > /dev/null 2>&1 || true
    echo -e "${GREEN}[OK]${NC} Logging suspicious packets"
    
    # 3.3.10 Ensure tcp syn cookies is enabled
    print_subsection "3.3.10 Ensure tcp syn cookies is enabled"
    set_sysctl_param "net.ipv4.tcp_syncookies" "1" "$IPV4_CONF"
    sysctl -w net.ipv4.route.flush=1 > /dev/null 2>&1 || true
    echo -e "${GREEN}[OK]${NC} Enabled TCP SYN cookies"
    
    # 3.3.11 Ensure ipv6 router advertisements are not accepted
    print_subsection "3.3.11 Ensure ipv6 router advertisements are not accepted"
    if grep -Pqs '^\h*0\b' /sys/module/ipv6/parameters/disable; then
        set_sysctl_param "net.ipv6.conf.all.accept_ra" "0" "$IPV6_CONF"
        set_sysctl_param "net.ipv6.conf.default.accept_ra" "0" "$IPV6_CONF"
        sysctl -w net.ipv6.route.flush=1 > /dev/null 2>&1 || true
        echo -e "${GREEN}[OK]${NC} Not accepting IPv6 router advertisements"
    else
        echo -e "${YELLOW}[SKIP]${NC} IPv6 is disabled"
    fi
    
    # Apply all sysctl settings
    sysctl --system > /dev/null 2>&1 || true
}

#############################################################################
# SECTION 3.4: Firewall Configuration
#############################################################################

configure_firewall() {
    print_section "3.4 Firewall Configuration"
    
    # 3.4.1.1 Ensure iptables is installed
    print_subsection "3.4.1.1 Ensure iptables is installed"
    if ! rpm -q iptables &>/dev/null; then
        yum install -y iptables
        log_message "INFO" "Installed iptables"
        echo -e "${GREEN}[OK]${NC} Installed iptables"
    else
        echo -e "${GREEN}[OK]${NC} iptables is already installed"
    fi
    
    # 3.4.1.2 - Firewall utility selection (Manual)
    print_subsection "3.4.1.2 Ensure a single firewall configuration utility is in use (Manual)"
    echo -e "${YELLOW}[MANUAL]${NC} Choose one firewall utility and configure accordingly:"
    echo -e "         Option 1: firewalld"
    echo -e "         Option 2: nftables"
    echo -e "         Option 3: iptables-services"
    log_message "INFO" "Manual review required for firewall utility selection"
    
    # 3.4.2.1 Ensure firewalld is installed (if using firewalld)
    print_subsection "3.4.2.1 Ensure firewalld is installed"
    if ! rpm -q firewalld &>/dev/null; then
        yum install -y firewalld
        log_message "INFO" "Installed firewalld"
        echo -e "${GREEN}[OK]${NC} Installed firewalld"
    else
        echo -e "${GREEN}[OK]${NC} firewalld is already installed"
    fi
    
    # 3.4.2.2 Ensure firewalld service enabled and running
    print_subsection "3.4.2.2 Ensure firewalld service enabled and running"
    systemctl unmask firewalld 2>/dev/null || true
    systemctl enable firewalld 2>/dev/null || true
    systemctl start firewalld 2>/dev/null || true
    log_message "INFO" "Enabled and started firewalld"
    echo -e "${GREEN}[OK]${NC} firewalld is enabled and running"
    
    # 3.4.2.3 & 3.4.2.4 - Manual firewall configuration
    print_subsection "3.4.2.3-4 Firewall zone and service configuration (Manual)"
    echo -e "${YELLOW}[MANUAL]${NC} Review firewall configuration:"
    echo -e "         List active zones: firewall-cmd --get-active-zones"
    echo -e "         List services: firewall-cmd --list-all"
    echo -e "         Remove unnecessary services as needed"
    log_message "INFO" "Manual review required for firewall services and zones"
}

#############################################################################
# MAIN EXECUTION
#############################################################################

main() {
    echo -e "${GREEN}"
    echo "=============================================================="
    echo " CIS Oracle Linux 7 Benchmark v4.0.0"
    echo " Section 3: Network Configuration"
    echo " Controls: 3.1.1 - 3.4.4.x"
    echo "=============================================================="
    echo -e "${NC}"
    
    # Check for root privileges
    check_root
    
    # Initialize log file
    echo "CIS Oracle Linux 7 Benchmark v4.0.0 - Section 3 Remediation" > "$LOG_FILE"
    echo "Started: $(date)" >> "$LOG_FILE"
    echo "=======================================================" >> "$LOG_FILE"
    
    # Execute remediation sections
    configure_network_devices
    configure_uncommon_protocols
    configure_network_parameters
    configure_firewall
    
    # Summary
    print_section "Remediation Complete"
    echo -e "${GREEN}Section 3 remediation has been completed.${NC}"
    echo -e "Log file: ${YELLOW}$LOG_FILE${NC}"
    echo ""
    echo -e "${YELLOW}IMPORTANT POST-REMEDIATION STEPS:${NC}"
    echo -e "1. Review firewall configuration: ${BLUE}firewall-cmd --list-all${NC}"
    echo -e "2. Verify network connectivity after changes"
    echo -e "3. Review sysctl settings: ${BLUE}sysctl -a | grep net.ipv4${NC}"
    echo -e "4. Reboot may be required for kernel module changes"
    echo ""
    
    log_message "INFO" "Section 3 remediation completed"
    echo "Completed: $(date)" >> "$LOG_FILE"
}

# Run main function
main "$@"
