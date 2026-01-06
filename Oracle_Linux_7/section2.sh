#!/bin/bash
#############################################################################
# CIS Oracle Linux 7 Benchmark v4.0.0 - Section 2 Remediation Script
# Services Configuration
# Controls: 2.1.1 - 2.3.5
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

# Function to backup a file before modification
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        cp -p "$file" "${file}.bak.$(date +%Y%m%d_%H%M%S)"
        log_message "INFO" "Backed up $file"
    fi
}

# Function to stop, disable and mask a service
disable_service() {
    local service_name="$1"
    local description="${2:-$service_name}"
    
    print_subsection "Disabling $description service"
    
    if systemctl is-active --quiet "$service_name" 2>/dev/null; then
        systemctl stop "$service_name"
        log_message "INFO" "Stopped $service_name"
        echo -e "${GREEN}[OK]${NC} Stopped $service_name"
    fi
    
    if systemctl is-enabled --quiet "$service_name" 2>/dev/null; then
        systemctl disable "$service_name" 2>/dev/null || true
        log_message "INFO" "Disabled $service_name"
        echo -e "${GREEN}[OK]${NC} Disabled $service_name"
    fi
    
    systemctl mask "$service_name" 2>/dev/null || true
    log_message "INFO" "Masked $service_name"
    echo -e "${GREEN}[OK]${NC} Masked $service_name"
}

# Function to remove a package
remove_package() {
    local package_name="$1"
    local description="${2:-$package_name}"
    
    print_subsection "Removing $description package"
    
    if rpm -q "$package_name" &>/dev/null; then
        yum remove -y "$package_name"
        log_message "INFO" "Removed package $package_name"
        echo -e "${GREEN}[OK]${NC} Removed $package_name"
    else
        log_message "INFO" "Package $package_name is not installed"
        echo -e "${YELLOW}[SKIP]${NC} $package_name is not installed"
    fi
}

#############################################################################
# SECTION 2.1: Time Synchronization
#############################################################################

configure_time_synchronization() {
    print_section "2.1 Time Synchronization"
    
    # 2.1.1 Ensure time synchronization is in use
    print_subsection "2.1.1 Ensure time synchronization is in use (chrony)"
    
    if ! rpm -q chrony &>/dev/null; then
        yum install -y chrony
        log_message "INFO" "Installed chrony package"
        echo -e "${GREEN}[OK]${NC} Installed chrony"
    else
        echo -e "${YELLOW}[OK]${NC} chrony is already installed"
    fi
    
    # 2.1.2 Ensure chrony is configured
    print_subsection "2.1.2 Ensure chrony is configured"
    
    backup_file "/etc/chrony.conf"
    
    # Check if server/pool is configured
    if ! grep -qE "^(server|pool)" /etc/chrony.conf; then
        log_message "WARN" "No NTP server/pool configured in /etc/chrony.conf"
        echo -e "${YELLOW}[WARN]${NC} No NTP server/pool configured"
        echo -e "${YELLOW}       Add time sources to /etc/chrony.conf:${NC}"
        echo -e "${YELLOW}       Example: pool <time_source> iburst${NC}"
        echo -e "${YELLOW}       Example: server <time_source> iburst${NC}"
    else
        echo -e "${GREEN}[OK]${NC} NTP server/pool is configured"
    fi
    
    # Enable and start chronyd
    systemctl enable chronyd
    systemctl start chronyd
    log_message "INFO" "Enabled and started chronyd"
    echo -e "${GREEN}[OK]${NC} Enabled and started chronyd"
    
    # 2.1.3 Ensure chrony is not run as the root user
    print_subsection "2.1.3 Ensure chrony is not run as the root user"
    
    backup_file "/etc/sysconfig/chronyd"
    
    if [[ -f /etc/sysconfig/chronyd ]]; then
        if grep -q "^OPTIONS=" /etc/sysconfig/chronyd; then
            if ! grep -q "OPTIONS=.*-u" /etc/sysconfig/chronyd; then
                sed -i 's/^OPTIONS="\(.*\)"/OPTIONS="-u chrony \1"/' /etc/sysconfig/chronyd
                log_message "INFO" "Added -u chrony to OPTIONS"
                echo -e "${GREEN}[OK]${NC} Configured chrony to run as non-root user"
            else
                echo -e "${GREEN}[OK]${NC} chrony already configured to run as non-root"
            fi
        else
            echo 'OPTIONS="-u chrony"' >> /etc/sysconfig/chronyd
            log_message "INFO" "Added OPTIONS with -u chrony"
            echo -e "${GREEN}[OK]${NC} Configured chrony to run as non-root user"
        fi
    else
        echo 'OPTIONS="-u chrony"' > /etc/sysconfig/chronyd
        log_message "INFO" "Created /etc/sysconfig/chronyd with OPTIONS"
        echo -e "${GREEN}[OK]${NC} Configured chrony to run as non-root user"
    fi
    
    # Restart chronyd to apply changes
    systemctl restart chronyd
    log_message "INFO" "Restarted chronyd"
}

#############################################################################
# SECTION 2.2: Special Purpose Services
#############################################################################

configure_services() {
    print_section "2.2 Special Purpose Services"
    
    # 2.2.1 Ensure autofs services are not in use
    print_subsection "2.2.1 Ensure autofs services are not in use"
    if rpm -q autofs &>/dev/null; then
        disable_service "autofs" "autofs"
        remove_package "autofs" "autofs"
    else
        echo -e "${YELLOW}[SKIP]${NC} autofs is not installed"
    fi
    
    # 2.2.2 Ensure avahi daemon services are not in use
    print_subsection "2.2.2 Ensure avahi daemon services are not in use"
    if rpm -q avahi-autoipd &>/dev/null || rpm -q avahi &>/dev/null; then
        disable_service "avahi-daemon.socket" "avahi-daemon socket"
        disable_service "avahi-daemon.service" "avahi-daemon service"
        remove_package "avahi-autoipd" "avahi-autoipd"
        remove_package "avahi" "avahi"
    else
        echo -e "${YELLOW}[SKIP]${NC} avahi is not installed"
    fi
    
    # 2.2.3 Ensure dhcp server services are not in use
    print_subsection "2.2.3 Ensure dhcp server services are not in use"
    if rpm -q dhcp-server &>/dev/null; then
        disable_service "dhcpd.service" "DHCPv4 server"
        disable_service "dhcpd6.service" "DHCPv6 server"
        remove_package "dhcp-server" "dhcp-server"
    else
        echo -e "${YELLOW}[SKIP]${NC} dhcp-server is not installed"
    fi
    
    # 2.2.4 Ensure dns server services are not in use
    print_subsection "2.2.4 Ensure dns server services are not in use"
    if rpm -q bind &>/dev/null; then
        disable_service "named.service" "BIND DNS server"
        remove_package "bind" "bind"
    else
        echo -e "${YELLOW}[SKIP]${NC} bind is not installed"
    fi
    
    # 2.2.5 Ensure dnsmasq services are not in use
    print_subsection "2.2.5 Ensure dnsmasq services are not in use"
    if rpm -q dnsmasq &>/dev/null; then
        disable_service "dnsmasq.service" "dnsmasq"
        remove_package "dnsmasq" "dnsmasq"
    else
        echo -e "${YELLOW}[SKIP]${NC} dnsmasq is not installed"
    fi
    
    # 2.2.6 Ensure samba file server services are not in use
    print_subsection "2.2.6 Ensure samba file server services are not in use"
    if rpm -q samba &>/dev/null; then
        disable_service "smb.service" "Samba SMB"
        remove_package "samba" "samba"
    else
        echo -e "${YELLOW}[SKIP]${NC} samba is not installed"
    fi
    
    # 2.2.7 Ensure ftp server services are not in use
    print_subsection "2.2.7 Ensure ftp server services are not in use"
    if rpm -q vsftpd &>/dev/null; then
        disable_service "vsftpd.service" "vsftpd"
        remove_package "vsftpd" "vsftpd"
    else
        echo -e "${YELLOW}[SKIP]${NC} vsftpd is not installed"
    fi
    
    # 2.2.8 Ensure message access server services are not in use
    print_subsection "2.2.8 Ensure message access server services are not in use"
    if rpm -q dovecot &>/dev/null; then
        disable_service "dovecot.socket" "dovecot socket"
        disable_service "dovecot.service" "dovecot"
        remove_package "dovecot" "dovecot"
    fi
    if rpm -q cyrus-imapd &>/dev/null; then
        disable_service "cyrus-imapd.service" "cyrus-imapd"
        remove_package "cyrus-imapd" "cyrus-imapd"
    fi
    if ! rpm -q dovecot &>/dev/null && ! rpm -q cyrus-imapd &>/dev/null; then
        echo -e "${YELLOW}[SKIP]${NC} dovecot and cyrus-imapd are not installed"
    fi
    
    # 2.2.9 Ensure network file system services are not in use
    print_subsection "2.2.9 Ensure network file system services are not in use"
    if rpm -q nfs-utils &>/dev/null; then
        disable_service "nfs-server.service" "NFS server"
        remove_package "nfs-utils" "nfs-utils"
    else
        echo -e "${YELLOW}[SKIP]${NC} nfs-utils is not installed"
    fi
    
    # 2.2.10 Ensure nis server services are not in use
    print_subsection "2.2.10 Ensure nis server services are not in use"
    if rpm -q ypserv &>/dev/null; then
        disable_service "ypserv.service" "NIS server"
        remove_package "ypserv" "ypserv"
    else
        echo -e "${YELLOW}[SKIP]${NC} ypserv is not installed"
    fi
    
    # 2.2.11 Ensure print server services are not in use
    print_subsection "2.2.11 Ensure print server services are not in use"
    if rpm -q cups &>/dev/null; then
        disable_service "cups.socket" "CUPS socket"
        disable_service "cups.service" "CUPS"
        remove_package "cups" "cups"
    else
        echo -e "${YELLOW}[SKIP]${NC} cups is not installed"
    fi
    
    # 2.2.12 Ensure rpcbind services are not in use
    print_subsection "2.2.12 Ensure rpcbind services are not in use"
    if rpm -q rpcbind &>/dev/null; then
        disable_service "rpcbind.socket" "rpcbind socket"
        disable_service "rpcbind.service" "rpcbind"
        remove_package "rpcbind" "rpcbind"
    else
        echo -e "${YELLOW}[SKIP]${NC} rpcbind is not installed"
    fi
    
    # 2.2.13 Ensure rsync services are not in use
    print_subsection "2.2.13 Ensure rsync services are not in use"
    if rpm -q rsync-daemon &>/dev/null; then
        disable_service "rsyncd.socket" "rsyncd socket"
        disable_service "rsyncd.service" "rsyncd"
        remove_package "rsync-daemon" "rsync-daemon"
    else
        echo -e "${YELLOW}[SKIP]${NC} rsync-daemon is not installed"
    fi
    
    # 2.2.14 Ensure snmp services are not in use
    print_subsection "2.2.14 Ensure snmp services are not in use"
    if rpm -q net-snmp &>/dev/null; then
        disable_service "snmpd.service" "SNMP daemon"
        remove_package "net-snmp" "net-snmp"
    else
        echo -e "${YELLOW}[SKIP]${NC} net-snmp is not installed"
    fi
    
    # 2.2.15 Ensure telnet server services are not in use
    print_subsection "2.2.15 Ensure telnet server services are not in use"
    if rpm -q telnet-server &>/dev/null; then
        disable_service "telnet.socket" "telnet socket"
        remove_package "telnet-server" "telnet-server"
    else
        echo -e "${YELLOW}[SKIP]${NC} telnet-server is not installed"
    fi
    
    # 2.2.16 Ensure tftp server services are not in use
    print_subsection "2.2.16 Ensure tftp server services are not in use"
    if rpm -q tftp-server &>/dev/null; then
        disable_service "tftp.socket" "TFTP socket"
        disable_service "tftp.service" "TFTP"
        remove_package "tftp-server" "tftp-server"
    else
        echo -e "${YELLOW}[SKIP]${NC} tftp-server is not installed"
    fi
    
    # 2.2.17 Ensure web proxy server services are not in use
    print_subsection "2.2.17 Ensure web proxy server services are not in use"
    if rpm -q squid &>/dev/null; then
        disable_service "squid.service" "Squid proxy"
        remove_package "squid" "squid"
    else
        echo -e "${YELLOW}[SKIP]${NC} squid is not installed"
    fi
    
    # 2.2.18 Ensure web server services are not in use
    print_subsection "2.2.18 Ensure web server services are not in use"
    if rpm -q httpd &>/dev/null; then
        disable_service "httpd.socket" "httpd socket"
        disable_service "httpd.service" "Apache httpd"
        remove_package "httpd" "httpd"
    fi
    if rpm -q nginx &>/dev/null; then
        disable_service "nginx.service" "nginx"
        remove_package "nginx" "nginx"
    fi
    if ! rpm -q httpd &>/dev/null && ! rpm -q nginx &>/dev/null; then
        echo -e "${YELLOW}[SKIP]${NC} httpd and nginx are not installed"
    fi
    
    # 2.2.19 Ensure xinetd services are not in use
    print_subsection "2.2.19 Ensure xinetd services are not in use"
    if rpm -q xinetd &>/dev/null; then
        disable_service "xinetd.service" "xinetd"
        remove_package "xinetd" "xinetd"
    else
        echo -e "${YELLOW}[SKIP]${NC} xinetd is not installed"
    fi
    
    # 2.2.20 Ensure X window server services are not in use
    print_subsection "2.2.20 Ensure X window server services are not in use"
    if rpm -q xorg-x11-server-common &>/dev/null; then
        remove_package "xorg-x11-server-common" "X Window Server"
    else
        echo -e "${YELLOW}[SKIP]${NC} xorg-x11-server-common is not installed"
    fi
    
    # 2.2.21 Ensure mail transfer agent is configured for local-only mode
    print_subsection "2.2.21 Ensure mail transfer agent is configured for local-only mode"
    
    if rpm -q postfix &>/dev/null; then
        backup_file "/etc/postfix/main.cf"
        
        if grep -q "^inet_interfaces" /etc/postfix/main.cf; then
            sed -i 's/^inet_interfaces.*/inet_interfaces = loopback-only/' /etc/postfix/main.cf
        else
            echo "inet_interfaces = loopback-only" >> /etc/postfix/main.cf
        fi
        
        log_message "INFO" "Configured postfix for local-only mode"
        echo -e "${GREEN}[OK]${NC} Configured postfix inet_interfaces = loopback-only"
        
        systemctl restart postfix
        log_message "INFO" "Restarted postfix"
    else
        echo -e "${YELLOW}[SKIP]${NC} postfix is not installed"
    fi
    
    # 2.2.22 Ensure only approved services are listening on a network interface (Manual)
    print_subsection "2.2.22 Ensure only approved services are listening (Manual)"
    echo -e "${YELLOW}[MANUAL]${NC} Review listening services with: ss -plntu"
    echo -e "${YELLOW}         For unneeded services, run:${NC}"
    echo -e "${YELLOW}         # systemctl stop <service_name>.socket <service_name>.service${NC}"
    echo -e "${YELLOW}         # yum remove <package_name>${NC}"
    echo -e "${YELLOW}         OR if dependency required:${NC}"
    echo -e "${YELLOW}         # systemctl mask <service_name>.socket <service_name>.service${NC}"
    log_message "INFO" "2.2.22 - Manual review required for listening services"
}

#############################################################################
# SECTION 2.3: Service Clients
#############################################################################

configure_service_clients() {
    print_section "2.3 Service Clients"
    
    # 2.3.1 Ensure ftp client is not installed
    print_subsection "2.3.1 Ensure ftp client is not installed"
    remove_package "ftp" "FTP client"
    
    # 2.3.2 Ensure ldap client is not installed
    print_subsection "2.3.2 Ensure ldap client is not installed"
    remove_package "openldap-clients" "LDAP client"
    
    # 2.3.3 Ensure nis client is not installed
    print_subsection "2.3.3 Ensure nis client is not installed"
    remove_package "ypbind" "NIS client (ypbind)"
    
    # 2.3.4 Ensure telnet client is not installed
    print_subsection "2.3.4 Ensure telnet client is not installed"
    remove_package "telnet" "Telnet client"
    
    # 2.3.5 Ensure tftp client is not installed
    print_subsection "2.3.5 Ensure tftp client is not installed"
    remove_package "tftp" "TFTP client"
}

#############################################################################
# MAIN EXECUTION
#############################################################################

main() {
    echo -e "${GREEN}"
    echo "=============================================================="
    echo " CIS Oracle Linux 7 Benchmark v4.0.0"
    echo " Section 2: Services Configuration"
    echo " Controls: 2.1.1 - 2.3.5"
    echo "=============================================================="
    echo -e "${NC}"
    
    # Check for root privileges
    check_root
    
    # Initialize log file
    echo "CIS Oracle Linux 7 Benchmark v4.0.0 - Section 2 Remediation" > "$LOG_FILE"
    echo "Started: $(date)" >> "$LOG_FILE"
    echo "=======================================================" >> "$LOG_FILE"
    
    # Execute remediation sections
    configure_time_synchronization
    configure_services
    configure_service_clients
    
    # Summary
    print_section "Remediation Complete"
    echo -e "${GREEN}Section 2 remediation has been completed.${NC}"
    echo -e "Log file: ${YELLOW}$LOG_FILE${NC}"
    echo ""
    echo -e "${YELLOW}IMPORTANT POST-REMEDIATION STEPS:${NC}"
    echo -e "1. Review listening services: ${BLUE}ss -plntu${NC}"
    echo -e "2. Verify chrony is synchronized: ${BLUE}chronyc sources${NC}"
    echo -e "3. Configure NTP time sources in ${BLUE}/etc/chrony.conf${NC} if not already done"
    echo -e "4. Reboot the system to ensure all changes take effect"
    echo ""
    
    log_message "INFO" "Section 2 remediation completed"
    echo "Completed: $(date)" >> "$LOG_FILE"
}

# Run main function
main "$@"
