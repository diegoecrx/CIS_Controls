#!/bin/bash
#############################################################################
# CIS Oracle Linux 7 Benchmark v4.0.0 - Section 3 Remediation Script
# Network Configuration
# Controls: 3.1 - 3.4
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

# Function to disable a kernel module
disable_kernel_module() {
    local module_name="$1"
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

# Function to set sysctl parameter
set_sysctl_param() {
    local param="$1"
    local value="$2"
    local conf_file="$3"
    
    # Set runtime value
    sysctl -w "${param}=${value}" 2>/dev/null || true
    
    # Persist in config file
    if grep -q "^${param}" "$conf_file" 2>/dev/null; then
        sed -i "s|^${param}.*|${param} = ${value}|" "$conf_file"
    else
        echo "${param} = ${value}" >> "$conf_file"
    fi
}

#############################################################################
# SECTION 3.1: Network Devices
#############################################################################

configure_network_devices() {
    print_section "3.1 Network Devices"
    
    # 3.1.1 Ensure IPv6 status is identified
    print_subsection "3.1.1 IPv6 status check"
    echo -e "${YELLOW}[INFO]${NC} IPv6 status should be reviewed based on environment requirements"
    
    # 3.1.2 Ensure wireless interfaces are disabled (Level 1 - Server)
    print_subsection "3.1.2 Disable wireless interfaces"
    
    # Check for wireless interfaces
    if command -v nmcli &>/dev/null; then
        nmcli radio wifi off 2>/dev/null || true
        nmcli radio wwan off 2>/dev/null || true
    fi
    
    # Disable wireless modules
    local wireless_modules=("cfg80211" "lib80211" "mac80211")
    for mod in "${wireless_modules[@]}"; do
        disable_kernel_module "$mod"
    done
    echo -e "${GREEN}[OK]${NC} Wireless interfaces disabled"
    
    # 3.1.3 Ensure bluetooth services are not in use
    print_subsection "3.1.3 Disable Bluetooth"
    systemctl stop bluetooth.service 2>/dev/null || true
    systemctl disable bluetooth.service 2>/dev/null || true
    systemctl mask bluetooth.service 2>/dev/null || true
    
    # Disable bluetooth module
    disable_kernel_module "bluetooth"
    echo -e "${GREEN}[OK]${NC} Bluetooth disabled"
}

#############################################################################
# SECTION 3.2: Network Kernel Modules
#############################################################################

configure_network_modules() {
    print_section "3.2 Network Kernel Modules"
    
    # 3.2.1 Ensure dccp kernel module is not available
    print_subsection "3.2.1 Disable DCCP"
    disable_kernel_module "dccp"
    echo -e "${GREEN}[OK]${NC} DCCP disabled"
    
    # 3.2.2 Ensure tipc kernel module is not available
    print_subsection "3.2.2 Disable TIPC"
    disable_kernel_module "tipc"
    echo -e "${GREEN}[OK]${NC} TIPC disabled"
    
    # 3.2.3 Ensure rds kernel module is not available
    print_subsection "3.2.3 Disable RDS"
    disable_kernel_module "rds"
    echo -e "${GREEN}[OK]${NC} RDS disabled"
    
    # 3.2.4 Ensure sctp kernel module is not available
    print_subsection "3.2.4 Disable SCTP"
    disable_kernel_module "sctp"
    echo -e "${GREEN}[OK]${NC} SCTP disabled"
}

#############################################################################
# SECTION 3.3: Network Parameters
#############################################################################

configure_network_params() {
    print_section "3.3 Network Parameters (Host and Router)"
    
    local sysctl_file="/etc/sysctl.d/60-netipv4_sysctl.conf"
    local sysctl_ipv6="/etc/sysctl.d/60-netipv6_sysctl.conf"
    
    # Initialize sysctl config files
    echo "# CIS Benchmark - Network Parameters (IPv4)" > "$sysctl_file"
    echo "# CIS Benchmark - Network Parameters (IPv6)" > "$sysctl_ipv6"
    
    # 3.3.1 Ensure ip forwarding is disabled
    print_subsection "3.3.1 Disable IP forwarding"
    set_sysctl_param "net.ipv4.ip_forward" "0" "$sysctl_file"
    set_sysctl_param "net.ipv6.conf.all.forwarding" "0" "$sysctl_ipv6"
    echo -e "${GREEN}[OK]${NC} IP forwarding disabled"
    
    # 3.3.2 Ensure packet redirect sending is disabled
    print_subsection "3.3.2 Disable packet redirect sending"
    set_sysctl_param "net.ipv4.conf.all.send_redirects" "0" "$sysctl_file"
    set_sysctl_param "net.ipv4.conf.default.send_redirects" "0" "$sysctl_file"
    echo -e "${GREEN}[OK]${NC} Packet redirect sending disabled"
    
    # 3.3.3 Ensure bogus ICMP responses are ignored
    print_subsection "3.3.3 Ignore bogus ICMP responses"
    set_sysctl_param "net.ipv4.icmp_ignore_bogus_error_responses" "1" "$sysctl_file"
    echo -e "${GREEN}[OK]${NC} Bogus ICMP responses ignored"
    
    # 3.3.4 Ensure broadcast ICMP requests are ignored
    print_subsection "3.3.4 Ignore broadcast ICMP requests"
    set_sysctl_param "net.ipv4.icmp_echo_ignore_broadcasts" "1" "$sysctl_file"
    echo -e "${GREEN}[OK]${NC} Broadcast ICMP requests ignored"
    
    # 3.3.5 Ensure ICMP redirects are not accepted
    print_subsection "3.3.5 Disable ICMP redirects"
    set_sysctl_param "net.ipv4.conf.all.accept_redirects" "0" "$sysctl_file"
    set_sysctl_param "net.ipv4.conf.default.accept_redirects" "0" "$sysctl_file"
    set_sysctl_param "net.ipv6.conf.all.accept_redirects" "0" "$sysctl_ipv6"
    set_sysctl_param "net.ipv6.conf.default.accept_redirects" "0" "$sysctl_ipv6"
    echo -e "${GREEN}[OK]${NC} ICMP redirects disabled"
    
    # 3.3.6 Ensure secure ICMP redirects are not accepted
    print_subsection "3.3.6 Disable secure ICMP redirects"
    set_sysctl_param "net.ipv4.conf.all.secure_redirects" "0" "$sysctl_file"
    set_sysctl_param "net.ipv4.conf.default.secure_redirects" "0" "$sysctl_file"
    echo -e "${GREEN}[OK]${NC} Secure ICMP redirects disabled"
    
    # 3.3.7 Ensure reverse path filtering is enabled
    print_subsection "3.3.7 Enable reverse path filtering"
    set_sysctl_param "net.ipv4.conf.all.rp_filter" "1" "$sysctl_file"
    set_sysctl_param "net.ipv4.conf.default.rp_filter" "1" "$sysctl_file"
    echo -e "${GREEN}[OK]${NC} Reverse path filtering enabled"
    
    # 3.3.8 Ensure source routed packets are not accepted
    print_subsection "3.3.8 Disable source routed packets"
    set_sysctl_param "net.ipv4.conf.all.accept_source_route" "0" "$sysctl_file"
    set_sysctl_param "net.ipv4.conf.default.accept_source_route" "0" "$sysctl_file"
    set_sysctl_param "net.ipv6.conf.all.accept_source_route" "0" "$sysctl_ipv6"
    set_sysctl_param "net.ipv6.conf.default.accept_source_route" "0" "$sysctl_ipv6"
    echo -e "${GREEN}[OK]${NC} Source routed packets disabled"
    
    # 3.3.9 Ensure suspicious packets are logged
    print_subsection "3.3.9 Log suspicious packets"
    set_sysctl_param "net.ipv4.conf.all.log_martians" "1" "$sysctl_file"
    set_sysctl_param "net.ipv4.conf.default.log_martians" "1" "$sysctl_file"
    echo -e "${GREEN}[OK]${NC} Suspicious packet logging enabled"
    
    # 3.3.10 Ensure TCP SYN cookies is enabled
    print_subsection "3.3.10 Enable TCP SYN cookies"
    set_sysctl_param "net.ipv4.tcp_syncookies" "1" "$sysctl_file"
    echo -e "${GREEN}[OK]${NC} TCP SYN cookies enabled"
    
    # 3.3.11 Ensure IPv6 router advertisements are not accepted
    print_subsection "3.3.11 Disable IPv6 router advertisements"
    set_sysctl_param "net.ipv6.conf.all.accept_ra" "0" "$sysctl_ipv6"
    set_sysctl_param "net.ipv6.conf.default.accept_ra" "0" "$sysctl_ipv6"
    echo -e "${GREEN}[OK]${NC} IPv6 router advertisements disabled"
    
    # Apply all sysctl settings
    sysctl --system &>/dev/null || true
    echo -e "${GREEN}[OK]${NC} All network parameters applied"
}

#############################################################################
# SECTION 3.4: Firewall Configuration
#############################################################################

configure_firewall() {
    print_section "3.4 Firewall Configuration"
    
    # Determine which firewall to use
    # Prefer firewalld on OL7, but support iptables and nftables
    
    # 3.4.1 Configure a single firewall utility
    print_subsection "3.4.1 Configure firewall utility"
    
    if rpm -q firewalld &>/dev/null; then
        configure_firewalld
    elif rpm -q nftables &>/dev/null; then
        configure_nftables
    else
        configure_iptables
    fi
}

configure_firewalld() {
    print_subsection "3.4.1.1-3.4.1.4 Configure firewalld"
    
    # Ensure firewalld is installed
    if ! rpm -q firewalld &>/dev/null; then
        yum install -y firewalld
    fi
    
    # Enable and start firewalld
    systemctl unmask firewalld
    systemctl enable firewalld
    systemctl start firewalld
    
    # Set default zone to drop
    firewall-cmd --set-default-zone=drop 2>/dev/null || true
    
    # Ensure loopback traffic is configured
    firewall-cmd --permanent --zone=trusted --add-interface=lo 2>/dev/null || true
    
    # Reload firewalld
    firewall-cmd --reload 2>/dev/null || true
    
    echo -e "${GREEN}[OK]${NC} firewalld configured and enabled"
    
    # Disable nftables and iptables if using firewalld
    systemctl stop nftables 2>/dev/null || true
    systemctl mask nftables 2>/dev/null || true
    systemctl stop iptables 2>/dev/null || true
    systemctl mask iptables 2>/dev/null || true
    
    echo -e "${YELLOW}[INFO]${NC} Review firewall rules with: firewall-cmd --list-all"
    log_message "INFO" "firewalld configured"
}

configure_nftables() {
    print_subsection "3.4.2.1-3.4.2.10 Configure nftables"
    
    # Ensure nftables is installed
    if ! rpm -q nftables &>/dev/null; then
        yum install -y nftables
    fi
    
    # Create base nftables configuration
    local nft_conf="/etc/nftables/cis.nft"
    mkdir -p /etc/nftables
    
    cat > "$nft_conf" << 'EOF'
#!/usr/sbin/nft -f
# CIS Benchmark nftables configuration

# Flush existing rules
flush ruleset

# Create inet table
table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;
        
        # Accept established/related connections
        ct state established,related accept
        
        # Accept loopback
        iif "lo" accept
        
        # Drop invalid packets
        ct state invalid drop
        
        # Accept ICMP (optional - adjust as needed)
        ip protocol icmp accept
        ip6 nexthdr icmpv6 accept
        
        # Accept SSH (adjust port as needed)
        tcp dport 22 accept
    }
    
    chain forward {
        type filter hook forward priority 0; policy drop;
    }
    
    chain output {
        type filter hook output priority 0; policy accept;
    }
}
EOF

    # Enable nftables
    systemctl unmask nftables
    systemctl enable nftables
    
    # Load configuration
    nft -f "$nft_conf" 2>/dev/null || true
    systemctl start nftables
    
    echo -e "${GREEN}[OK]${NC} nftables configured and enabled"
    
    # Disable firewalld and iptables
    systemctl stop firewalld 2>/dev/null || true
    systemctl mask firewalld 2>/dev/null || true
    systemctl stop iptables 2>/dev/null || true
    systemctl mask iptables 2>/dev/null || true
    
    echo -e "${YELLOW}[INFO]${NC} Review rules with: nft list ruleset"
    log_message "INFO" "nftables configured"
}

configure_iptables() {
    print_subsection "3.4.3.1-3.4.3.3 Configure iptables"
    
    # Ensure iptables packages are installed
    if ! rpm -q iptables &>/dev/null; then
        yum install -y iptables iptables-services
    fi
    
    # Flush existing rules
    iptables -F
    iptables -X
    
    # Set default policies
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT
    
    # Accept established/related connections
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    
    # Accept loopback traffic
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A OUTPUT -o lo -j ACCEPT
    
    # Drop invalid packets
    iptables -A INPUT -m state --state INVALID -j DROP
    
    # Accept SSH (adjust port as needed)
    iptables -A INPUT -p tcp --dport 22 -m state --state NEW -j ACCEPT
    
    # Save iptables rules
    service iptables save 2>/dev/null || iptables-save > /etc/sysconfig/iptables
    
    # Enable iptables
    systemctl unmask iptables
    systemctl enable iptables
    systemctl start iptables
    
    # Configure ip6tables similarly
    ip6tables -F
    ip6tables -X
    ip6tables -P INPUT DROP
    ip6tables -P FORWARD DROP
    ip6tables -P OUTPUT ACCEPT
    ip6tables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    ip6tables -A INPUT -i lo -j ACCEPT
    ip6tables -A OUTPUT -o lo -j ACCEPT
    ip6tables -A INPUT -m state --state INVALID -j DROP
    ip6tables -A INPUT -p tcp --dport 22 -m state --state NEW -j ACCEPT
    
    service ip6tables save 2>/dev/null || ip6tables-save > /etc/sysconfig/ip6tables
    systemctl enable ip6tables 2>/dev/null || true
    systemctl start ip6tables 2>/dev/null || true
    
    echo -e "${GREEN}[OK]${NC} iptables/ip6tables configured and enabled"
    
    # Disable firewalld and nftables
    systemctl stop firewalld 2>/dev/null || true
    systemctl mask firewalld 2>/dev/null || true
    systemctl stop nftables 2>/dev/null || true
    systemctl mask nftables 2>/dev/null || true
    
    echo -e "${YELLOW}[INFO]${NC} Review rules with: iptables -L -v -n"
    log_message "INFO" "iptables configured"
}

#############################################################################
# MAIN EXECUTION
#############################################################################

main() {
    echo -e "${GREEN}"
    echo "=============================================================="
    echo " CIS Oracle Linux 7 Benchmark v4.0.0"
    echo " Section 3: Network Configuration"
    echo " Controls: 3.1 - 3.4"
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
    configure_network_modules
    configure_network_params
    configure_firewall
    
    # Summary
    print_section "Remediation Complete"
    echo -e "${GREEN}Section 3 remediation has been completed.${NC}"
    echo -e "Log file: ${YELLOW}$LOG_FILE${NC}"
    echo ""
    echo -e "${YELLOW}IMPORTANT POST-REMEDIATION STEPS:${NC}"
    echo -e "1. Review sysctl settings: ${BLUE}sysctl -a | grep -E 'ip_forward|send_redirects|accept_redirects'${NC}"
    echo -e "2. Review firewall rules based on active firewall"
    echo -e "3. Test network connectivity"
    echo -e "4. Verify SSH access is preserved"
    echo ""
    
    log_message "INFO" "Section 3 remediation completed"
    echo "Completed: $(date)" >> "$LOG_FILE"
}

# Run main function
main "$@"
