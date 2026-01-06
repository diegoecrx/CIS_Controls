#!/bin/bash
#############################################################################
# CIS Oracle Linux 7 Benchmark v4.0.0 - Section 2 Remediation Script
# Services
# Controls: 2.1 - 2.3
#############################################################################

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log file
LOG_FILE="/var/log/cis_section2_remediation_$(date +%Y%m%d_%H%M%S).log"

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

# Function to stop, disable and mask a service
disable_service() {
    local service_name="$1"
    
    if systemctl is-enabled "$service_name" &>/dev/null; then
        systemctl stop "$service_name" 2>/dev/null || true
        systemctl disable "$service_name" 2>/dev/null || true
        systemctl mask "$service_name" 2>/dev/null || true
        echo -e "${GREEN}[OK]${NC} Disabled and masked: $service_name"
        log_message "INFO" "Disabled and masked: $service_name"
    else
        echo -e "${YELLOW}[SKIP]${NC} $service_name is not enabled or not installed"
    fi
}

# Function to remove a package
remove_package() {
    local package_name="$1"
    
    if rpm -q "$package_name" &>/dev/null; then
        yum remove -y "$package_name" &>/dev/null
        echo -e "${GREEN}[OK]${NC} Removed: $package_name"
        log_message "INFO" "Removed: $package_name"
    else
        echo -e "${YELLOW}[SKIP]${NC} $package_name is not installed"
    fi
}

#############################################################################
# SECTION 2.1: Time Synchronization
#############################################################################

configure_time_sync() {
    print_section "2.1 Time Synchronization"
    
    # 2.1.1 Ensure a single time synchronization daemon is in use
    print_subsection "2.1.1 Configure time synchronization"
    
    # Check if chrony is installed
    if ! rpm -q chrony &>/dev/null; then
        yum install -y chrony
        echo -e "${GREEN}[OK]${NC} Installed chrony"
    fi
    
    # Enable and start chrony
    systemctl enable chronyd
    systemctl start chronyd
    
    # 2.1.2 Ensure chrony is configured
    print_subsection "2.1.2 Configure chrony"
    local chrony_conf="/etc/chrony.conf"
    
    if [[ -f "$chrony_conf" ]]; then
        # Ensure chrony runs as chrony user (default in OL7)
        if ! grep -q "^user chrony" "$chrony_conf"; then
            echo "user chrony" >> "$chrony_conf"
        fi
        echo -e "${GREEN}[OK]${NC} Chrony configured"
    fi
    
    # Restart chrony to apply changes
    systemctl restart chronyd
    echo -e "${GREEN}[OK]${NC} Time synchronization configured with chrony"
}

#############################################################################
# SECTION 2.2: Special Purpose Services
#############################################################################

remove_unnecessary_services() {
    print_section "2.2 Special Purpose Services"
    
    # 2.2.1 Ensure autofs services are not in use
    print_subsection "2.2.1 Disable autofs"
    disable_service "autofs"
    remove_package "autofs"
    
    # 2.2.2 Ensure avahi daemon services are not in use
    print_subsection "2.2.2 Disable avahi-daemon"
    disable_service "avahi-daemon.socket"
    disable_service "avahi-daemon.service"
    remove_package "avahi"
    remove_package "avahi-autoipd"
    
    # 2.2.3 Ensure dhcp server services are not in use
    print_subsection "2.2.3 Disable DHCP server"
    disable_service "dhcpd"
    remove_package "dhcp-server"
    
    # 2.2.4 Ensure dns server services are not in use
    print_subsection "2.2.4 Disable DNS server (BIND)"
    disable_service "named"
    remove_package "bind"
    
    # 2.2.5 Ensure dnsmasq services are not in use
    print_subsection "2.2.5 Disable dnsmasq"
    disable_service "dnsmasq"
    remove_package "dnsmasq"
    
    # 2.2.6 Ensure samba file server services are not in use
    print_subsection "2.2.6 Disable Samba"
    disable_service "smb"
    remove_package "samba"
    
    # 2.2.7 Ensure ftp server services are not in use
    print_subsection "2.2.7 Disable FTP server"
    disable_service "vsftpd"
    remove_package "vsftpd"
    
    # 2.2.8 Ensure message access server services are not in use
    print_subsection "2.2.8 Disable mail servers (dovecot, cyrus-imapd)"
    disable_service "dovecot"
    remove_package "dovecot"
    remove_package "cyrus-imapd"
    
    # 2.2.9 Ensure network file system services are not in use
    print_subsection "2.2.9 Disable NFS"
    disable_service "nfs-server"
    remove_package "nfs-utils"
    
    # 2.2.10 Ensure nis server services are not in use
    print_subsection "2.2.10 Disable NIS server"
    disable_service "ypserv"
    remove_package "ypserv"
    
    # 2.2.11 Ensure print server services are not in use
    print_subsection "2.2.11 Disable CUPS"
    disable_service "cups"
    remove_package "cups"
    
    # 2.2.12 Ensure rpcbind services are not in use
    print_subsection "2.2.12 Disable rpcbind"
    disable_service "rpcbind.socket"
    disable_service "rpcbind.service"
    remove_package "rpcbind"
    
    # 2.2.13 Ensure rsync services are not in use
    print_subsection "2.2.13 Disable rsync"
    disable_service "rsyncd"
    remove_package "rsync-daemon"
    
    # 2.2.14 Ensure snmp services are not in use
    print_subsection "2.2.14 Disable SNMP"
    disable_service "snmpd"
    remove_package "net-snmp"
    
    # 2.2.15 Ensure telnet server services are not in use
    print_subsection "2.2.15 Disable telnet server"
    disable_service "telnet.socket"
    remove_package "telnet-server"
    
    # 2.2.16 Ensure tftp server services are not in use
    print_subsection "2.2.16 Disable TFTP server"
    disable_service "tftp.socket"
    disable_service "tftp.service"
    remove_package "tftp-server"
    
    # 2.2.17 Ensure web proxy server services are not in use
    print_subsection "2.2.17 Disable Squid proxy"
    disable_service "squid"
    remove_package "squid"
    
    # 2.2.18 Ensure web server services are not in use
    print_subsection "2.2.18 Disable Apache/nginx"
    disable_service "httpd"
    disable_service "nginx"
    remove_package "httpd"
    remove_package "nginx"
    
    # 2.2.19 Ensure xinetd services are not in use
    print_subsection "2.2.19 Disable xinetd"
    disable_service "xinetd"
    remove_package "xinetd"
    
    # 2.2.20 Ensure X window server services are not in use
    print_subsection "2.2.20 Disable X Window System"
    echo -e "${YELLOW}[MANUAL]${NC} Remove X Window: yum remove xorg-x11-server*"
    log_message "WARN" "X Window removal should be done manually if needed"
    
    # 2.2.21 Ensure mail transfer agents are configured for local-only mode
    print_subsection "2.2.21 Configure MTA for local-only"
    local postfix_main="/etc/postfix/main.cf"
    if [[ -f "$postfix_main" ]]; then
        # Configure postfix to only listen on localhost
        if grep -q "^inet_interfaces" "$postfix_main"; then
            sed -i 's/^inet_interfaces.*/inet_interfaces = loopback-only/' "$postfix_main"
        else
            echo "inet_interfaces = loopback-only" >> "$postfix_main"
        fi
        systemctl restart postfix 2>/dev/null || true
        echo -e "${GREEN}[OK]${NC} Postfix configured for local-only"
    else
        echo -e "${YELLOW}[SKIP]${NC} Postfix not installed"
    fi
    
    # 2.2.22 Ensure only approved services are listening
    print_subsection "2.2.22 Review listening services"
    echo -e "${YELLOW}[MANUAL]${NC} Review listening services with: ss -plntu"
    log_message "WARN" "Manually review listening services"
}

#############################################################################
# SECTION 2.3: Service Clients
#############################################################################

remove_client_packages() {
    print_section "2.3 Service Clients"
    
    # 2.3.1 Ensure ftp client is not installed
    print_subsection "2.3.1 Remove FTP client"
    remove_package "ftp"
    
    # 2.3.2 Ensure ldap client is not installed
    print_subsection "2.3.2 Remove LDAP client"
    remove_package "openldap-clients"
    
    # 2.3.3 Ensure nis client is not installed
    print_subsection "2.3.3 Remove NIS client"
    remove_package "ypbind"
    
    # 2.3.4 Ensure telnet client is not installed
    print_subsection "2.3.4 Remove telnet client"
    remove_package "telnet"
    
    # 2.3.5 Ensure tftp client is not installed
    print_subsection "2.3.5 Remove TFTP client"
    remove_package "tftp"
}

#############################################################################
# MAIN EXECUTION
#############################################################################

main() {
    echo -e "${GREEN}"
    echo "=============================================================="
    echo " CIS Oracle Linux 7 Benchmark v4.0.0"
    echo " Section 2: Services"
    echo " Controls: 2.1 - 2.3"
    echo "=============================================================="
    echo -e "${NC}"
    
    # Check for root privileges
    check_root
    
    # Initialize log file
    echo "CIS Oracle Linux 7 Benchmark v4.0.0 - Section 2 Remediation" > "$LOG_FILE"
    echo "Started: $(date)" >> "$LOG_FILE"
    echo "=======================================================" >> "$LOG_FILE"
    
    # Execute remediation sections
    configure_time_sync
    remove_unnecessary_services
    remove_client_packages
    
    # Summary
    print_section "Remediation Complete"
    echo -e "${GREEN}Section 2 remediation has been completed.${NC}"
    echo -e "Log file: ${YELLOW}$LOG_FILE${NC}"
    echo ""
    echo -e "${YELLOW}IMPORTANT POST-REMEDIATION STEPS:${NC}"
    echo -e "1. Review services: ${BLUE}systemctl list-unit-files --state=enabled${NC}"
    echo -e "2. Review listening ports: ${BLUE}ss -plntu${NC}"
    echo -e "3. Verify time sync: ${BLUE}chronyc tracking${NC}"
    echo ""
    
    log_message "INFO" "Section 2 remediation completed"
    echo "Completed: $(date)" >> "$LOG_FILE"
}

# Run main function
main "$@"
