#!/bin/bash
#############################################################################
# CIS Oracle Linux 7 Benchmark v4.0.0 - Section 5 Remediation Script
# Logging and Auditing
# Controls: 5.1 - 5.3
#############################################################################

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log file
LOG_FILE="/var/log/cis_section5_remediation_$(date +%Y%m%d_%H%M%S).log"

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
# SECTION 5.1: Configure Logging
#############################################################################

configure_rsyslog() {
    print_section "5.1.1 Configure rsyslog"
    
    # 5.1.1.1 Ensure rsyslog is installed
    print_subsection "5.1.1.1 Install rsyslog"
    if ! rpm -q rsyslog &>/dev/null; then
        yum install -y rsyslog
    fi
    echo -e "${GREEN}[OK]${NC} rsyslog installed"
    
    # 5.1.1.2 Ensure rsyslog service is enabled and active
    print_subsection "5.1.1.2 Enable rsyslog"
    systemctl enable rsyslog
    systemctl start rsyslog
    echo -e "${GREEN}[OK]${NC} rsyslog enabled and started"
    
    # 5.1.1.3 Ensure journald is configured to send logs to rsyslog
    print_subsection "5.1.1.3 Configure journald to forward to rsyslog"
    local journald_conf="/etc/systemd/journald.conf"
    backup_file "$journald_conf"
    
    if grep -q "^ForwardToSyslog" "$journald_conf"; then
        sed -i 's/^ForwardToSyslog.*/ForwardToSyslog=yes/' "$journald_conf"
    else
        echo "ForwardToSyslog=yes" >> "$journald_conf"
    fi
    echo -e "${GREEN}[OK]${NC} journald configured to forward to rsyslog"
    
    # 5.1.1.4 Ensure rsyslog default file permissions are configured
    print_subsection "5.1.1.4 Configure rsyslog file permissions"
    local rsyslog_conf="/etc/rsyslog.conf"
    backup_file "$rsyslog_conf"
    
    if grep -q '^\$FileCreateMode' "$rsyslog_conf"; then
        sed -i 's/^\$FileCreateMode.*/\$FileCreateMode 0640/' "$rsyslog_conf"
    else
        echo '$FileCreateMode 0640' >> "$rsyslog_conf"
    fi
    echo -e "${GREEN}[OK]${NC} rsyslog file permissions set to 0640"
    
    # 5.1.1.5 Ensure logging is configured
    print_subsection "5.1.1.5 Configure rsyslog logging rules"
    local rsyslog_cis="/etc/rsyslog.d/50-cis.conf"
    
    cat > "$rsyslog_cis" << 'EOF'
# CIS Benchmark - Logging Configuration
*.emerg                         :omusrmsg:*
auth,authpriv.*                 /var/log/secure
mail.*                          -/var/log/maillog
cron.*                          /var/log/cron
*.=warning;*.=err               -/var/log/warn
*.crit                          /var/log/warn
*.*;mail.none;news.none         -/var/log/messages
local0,local1.*                 -/var/log/localmessages
local2,local3.*                 -/var/log/localmessages
local4,local5.*                 -/var/log/localmessages
local6,local7.*                 -/var/log/localmessages
EOF
    
    echo -e "${GREEN}[OK]${NC} rsyslog logging rules configured"
    
    # 5.1.1.6 Ensure rsyslog is configured to send logs to a remote log host
    print_subsection "5.1.1.6 Configure remote logging"
    echo -e "${YELLOW}[MANUAL]${NC} Configure remote log host if required:"
    echo -e "         Add to rsyslog.conf: *.* action(type=\"omfwd\" target=\"<LOGHOST>\" port=\"514\" protocol=\"tcp\")"
    log_message "INFO" "Remote logging must be configured manually"
    
    # 5.1.1.7 Ensure rsyslog is not configured to receive logs from a remote client
    print_subsection "5.1.1.7 Disable remote log reception"
    sed -i 's/^\$ModLoad imtcp/# $ModLoad imtcp/' "$rsyslog_conf" 2>/dev/null || true
    sed -i 's/^\$InputTCPServerRun/# $InputTCPServerRun/' "$rsyslog_conf" 2>/dev/null || true
    sed -i 's/^\$ModLoad imudp/# $ModLoad imudp/' "$rsyslog_conf" 2>/dev/null || true
    sed -i 's/^\$UDPServerRun/# $UDPServerRun/' "$rsyslog_conf" 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC} Remote log reception disabled"
    
    # Restart rsyslog
    systemctl restart rsyslog
}

configure_journald() {
    print_section "5.1.2 Configure journald"
    
    local journald_conf="/etc/systemd/journald.conf"
    
    # 5.1.2.1 Ensure journald service is enabled and active
    print_subsection "5.1.2.1 Enable journald"
    systemctl enable systemd-journald
    echo -e "${GREEN}[OK]${NC} journald enabled"
    
    # 5.1.2.2 Ensure journald is configured to compress large log files
    print_subsection "5.1.2.2 Configure journald compression"
    if grep -q "^Compress" "$journald_conf"; then
        sed -i 's/^Compress.*/Compress=yes/' "$journald_conf"
    else
        echo "Compress=yes" >> "$journald_conf"
    fi
    echo -e "${GREEN}[OK]${NC} journald compression enabled"
    
    # 5.1.2.3 Ensure journald is configured to write logs to persistent disk
    print_subsection "5.1.2.3 Configure journald persistence"
    if grep -q "^Storage" "$journald_conf"; then
        sed -i 's/^Storage.*/Storage=persistent/' "$journald_conf"
    else
        echo "Storage=persistent" >> "$journald_conf"
    fi
    
    # Create persistent log directory
    mkdir -p /var/log/journal
    systemd-tmpfiles --create --prefix /var/log/journal
    echo -e "${GREEN}[OK]${NC} journald persistence configured"
    
    # 5.1.2.4 Ensure journald is not configured to receive logs from a remote client
    print_subsection "5.1.2.4 Disable remote log reception"
    echo -e "${YELLOW}[INFO]${NC} Verify systemd-journal-remote is not enabled"
    systemctl disable systemd-journal-remote.socket 2>/dev/null || true
    systemctl mask systemd-journal-remote.socket 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC} Remote journal reception disabled"
    
    # Restart journald
    systemctl restart systemd-journald
}

configure_log_permissions() {
    print_section "5.1.3 Configure log file permissions"
    
    # 5.1.3.1 Ensure permissions on /var/log are configured
    print_subsection "5.1.3.1 Configure /var/log permissions"
    chmod g-wx,o-rwx /var/log
    echo -e "${GREEN}[OK]${NC} /var/log permissions configured"
    
    # 5.1.3.2 Ensure permissions on log files are configured
    print_subsection "5.1.3.2 Configure log file permissions"
    find /var/log -type f -exec chmod g-wx,o-rwx {} \; 2>/dev/null || true
    find /var/log -type d -exec chmod g-w,o-rwx {} \; 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC} Log file permissions configured"
}

#############################################################################
# SECTION 5.2: Configure System Accounting (auditd)
#############################################################################

configure_auditd() {
    print_section "5.2.1 Configure auditd"
    
    # 5.2.1.1 Ensure auditd is installed
    print_subsection "5.2.1.1 Install auditd"
    if ! rpm -q audit &>/dev/null; then
        yum install -y audit audit-libs
    fi
    echo -e "${GREEN}[OK]${NC} auditd installed"
    
    # 5.2.1.2 Ensure auditing for processes that start prior to auditd is enabled
    print_subsection "5.2.1.2 Enable early audit"
    grubby --update-kernel ALL --args "audit=1" 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC} Early audit enabled in kernel"
    
    # 5.2.1.3 Ensure audit_backlog_limit is sufficient
    print_subsection "5.2.1.3 Configure audit backlog"
    grubby --update-kernel ALL --args "audit_backlog_limit=8192" 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC} Audit backlog limit set"
    
    # 5.2.1.4 Ensure auditd service is enabled and active
    print_subsection "5.2.1.4 Enable auditd"
    systemctl enable auditd
    systemctl start auditd
    echo -e "${GREEN}[OK]${NC} auditd enabled and started"
}

configure_audit_data() {
    print_section "5.2.2 Configure Data Retention"
    
    local auditd_conf="/etc/audit/auditd.conf"
    backup_file "$auditd_conf"
    
    # 5.2.2.1 Ensure audit log storage size is configured
    print_subsection "5.2.2.1 Configure audit log size"
    sed -i 's/^max_log_file\s*=.*/max_log_file = 8/' "$auditd_conf"
    echo -e "${GREEN}[OK]${NC} Audit log size set to 8MB"
    
    # 5.2.2.2 Ensure audit logs are not automatically deleted
    print_subsection "5.2.2.2 Configure audit log retention"
    sed -i 's/^max_log_file_action\s*=.*/max_log_file_action = keep_logs/' "$auditd_conf"
    echo -e "${GREEN}[OK]${NC} Audit logs configured to keep_logs"
    
    # 5.2.2.3 Ensure system is disabled when audit logs are full
    print_subsection "5.2.2.3 Configure action on full logs"
    sed -i 's/^space_left_action\s*=.*/space_left_action = email/' "$auditd_conf"
    sed -i 's/^action_mail_acct\s*=.*/action_mail_acct = root/' "$auditd_conf"
    sed -i 's/^admin_space_left_action\s*=.*/admin_space_left_action = halt/' "$auditd_conf"
    echo -e "${GREEN}[OK]${NC} Audit full disk actions configured"
}

configure_audit_rules() {
    print_section "5.2.3 Configure Audit Rules"
    
    local audit_rules_dir="/etc/audit/rules.d"
    mkdir -p "$audit_rules_dir"
    
    # Create comprehensive audit rules file
    local cis_rules="${audit_rules_dir}/50-cis.rules"
    
    print_subsection "Creating CIS audit rules"
    
    cat > "$cis_rules" << 'EOF'
# CIS Oracle Linux 7 Benchmark v4.0.0 - Audit Rules

# 5.2.3.1 Ensure changes to system administration scope (sudoers) is collected
-w /etc/sudoers -p wa -k scope
-w /etc/sudoers.d/ -p wa -k scope

# 5.2.3.2 Ensure actions as another user are always logged
-a always,exit -F arch=b64 -C euid!=uid -F euid=0 -Fauid>=1000 -F auid!=4294967295 -S execve -k actions
-a always,exit -F arch=b32 -C euid!=uid -F euid=0 -Fauid>=1000 -F auid!=4294967295 -S execve -k actions

# 5.2.3.3 Ensure events that modify the sudo log file are collected
-w /var/log/sudo.log -p wa -k sudo_log_file

# 5.2.3.4 Ensure events that modify date and time information are collected
-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change
-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change
-a always,exit -F arch=b64 -S clock_settime -k time-change
-a always,exit -F arch=b32 -S clock_settime -k time-change
-w /etc/localtime -p wa -k time-change

# 5.2.3.5 Ensure events that modify the system's network environment are collected
-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale
-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale
-w /etc/issue -p wa -k system-locale
-w /etc/issue.net -p wa -k system-locale
-w /etc/hosts -p wa -k system-locale
-w /etc/sysconfig/network -p wa -k system-locale

# 5.2.3.6 Ensure use of privileged commands are collected
# This rule should be regenerated based on setuid/setgid files on the system
# find / -xdev \( -perm -4000 -o -perm -2000 \) -type f | awk '{print "-a always,exit -F path=" $1 " -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged" }'

# 5.2.3.7 Ensure unsuccessful file access attempts are collected
-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access
-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access
-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access
-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access

# 5.2.3.8 Ensure events that modify user/group information are collected
-w /etc/group -p wa -k identity
-w /etc/passwd -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/security/opasswd -p wa -k identity

# 5.2.3.9 Ensure discretionary access control permission modification events are collected
-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod

# 5.2.3.10 Ensure successful file system mounts are collected
-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts
-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts

# 5.2.3.11 Ensure session initiation information is collected
-w /var/run/utmp -p wa -k session
-w /var/log/wtmp -p wa -k logins
-w /var/log/btmp -p wa -k logins

# 5.2.3.12 Ensure login and logout events are collected
-w /var/log/lastlog -p wa -k logins
-w /var/log/faillock/ -p wa -k logins

# 5.2.3.13 Ensure file deletion events by users are collected
-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete
-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete

# 5.2.3.14 Ensure events that modify the system's Mandatory Access Controls are collected
-w /etc/selinux/ -p wa -k MAC-policy
-w /usr/share/selinux/ -p wa -k MAC-policy

# 5.2.3.15 Ensure successful and unsuccessful attempts to use the chcon command are recorded
-a always,exit -F path=/usr/bin/chcon -F perm=x -F auid>=1000 -F auid!=4294967295 -k perm_chng

# 5.2.3.16 Ensure successful and unsuccessful attempts to use the setfacl command are recorded
-a always,exit -F path=/usr/bin/setfacl -F perm=x -F auid>=1000 -F auid!=4294967295 -k perm_chng

# 5.2.3.17 Ensure successful and unsuccessful attempts to use the chacl command are recorded
-a always,exit -F path=/usr/bin/chacl -F perm=x -F auid>=1000 -F auid!=4294967295 -k perm_chng

# 5.2.3.18 Ensure successful and unsuccessful attempts to use the usermod command are recorded
-a always,exit -F path=/usr/sbin/usermod -F perm=x -F auid>=1000 -F auid!=4294967295 -k usermod

# 5.2.3.19 Ensure kernel module loading unloading and modification is collected
-a always,exit -F arch=b64 -S init_module -S delete_module -S finit_module -k modules
-a always,exit -F arch=b32 -S init_module -S delete_module -S finit_module -k modules
-w /sbin/insmod -p x -k modules
-w /sbin/rmmod -p x -k modules
-w /sbin/modprobe -p x -k modules

# 5.2.3.20 Ensure the audit configuration is immutable
-e 2
EOF

    echo -e "${GREEN}[OK]${NC} CIS audit rules created"
    
    # 5.2.3.21 Ensure the running and on disk configuration is the same
    print_subsection "5.2.3.21 Apply audit rules"
    
    # Load the audit rules
    augenrules --load 2>/dev/null || auditctl -R "$cis_rules" 2>/dev/null || true
    
    echo -e "${GREEN}[OK]${NC} Audit rules applied"
    echo -e "${YELLOW}[INFO]${NC} Note: System reboot required for immutable audit rules"
}

#############################################################################
# SECTION 5.3: Configure Integrity Checking
#############################################################################

configure_aide() {
    print_section "5.3 Configure Integrity Checking"
    
    # 5.3.1 Ensure AIDE is installed
    print_subsection "5.3.1 Install AIDE"
    if ! rpm -q aide &>/dev/null; then
        yum install -y aide
    fi
    echo -e "${GREEN}[OK]${NC} AIDE installed"
    
    # 5.3.2 Ensure filesystem integrity is regularly checked
    print_subsection "5.3.2 Configure AIDE cron job"
    local aide_cron="/etc/cron.d/aide"
    cat > "$aide_cron" << 'EOF'
# CIS Benchmark - AIDE file integrity check
0 5 * * * root /usr/sbin/aide --check
EOF
    chmod 600 "$aide_cron"
    echo -e "${GREEN}[OK]${NC} AIDE cron job configured"
    
    # 5.3.3 Ensure cryptographic mechanisms are used to protect the integrity of audit tools
    print_subsection "5.3.3 Configure AIDE for audit tools"
    local aide_conf="/etc/aide.conf"
    
    # Add audit tool integrity checking if not present
    if ! grep -q "/sbin/auditctl" "$aide_conf" 2>/dev/null; then
        cat >> "$aide_conf" << 'EOF'

# CIS Benchmark - Audit tool integrity
/sbin/auditctl p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/auditd p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/ausearch p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/aureport p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/autrace p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/augenrules p+i+n+u+g+s+b+acl+xattrs+sha512
EOF
    fi
    echo -e "${GREEN}[OK]${NC} AIDE configured for audit tools"
    
    # Initialize AIDE database
    print_subsection "Initialize AIDE database"
    echo -e "${YELLOW}[INFO]${NC} Initializing AIDE database (this may take a while)..."
    aide --init &>/dev/null &
    local aide_pid=$!
    
    # Show progress indicator
    local count=0
    while kill -0 $aide_pid 2>/dev/null; do
        count=$((count + 1))
        if [[ $((count % 10)) -eq 0 ]]; then
            echo -n "."
        fi
        sleep 1
        # Timeout after 5 minutes
        if [[ $count -gt 300 ]]; then
            echo ""
            echo -e "${YELLOW}[INFO]${NC} AIDE init running in background"
            break
        fi
    done
    echo ""
    
    # Move new database to active database
    if [[ -f /var/lib/aide/aide.db.new.gz ]]; then
        mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
        echo -e "${GREEN}[OK]${NC} AIDE database initialized"
    else
        echo -e "${YELLOW}[INFO]${NC} AIDE database initialization in progress - run manually if needed:"
        echo -e "         aide --init && mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz"
    fi
}

#############################################################################
# MAIN EXECUTION
#############################################################################

main() {
    echo -e "${GREEN}"
    echo "=============================================================="
    echo " CIS Oracle Linux 7 Benchmark v4.0.0"
    echo " Section 5: Logging and Auditing"
    echo " Controls: 5.1 - 5.3"
    echo "=============================================================="
    echo -e "${NC}"
    
    # Check for root privileges
    check_root
    
    # Initialize log file
    echo "CIS Oracle Linux 7 Benchmark v4.0.0 - Section 5 Remediation" > "$LOG_FILE"
    echo "Started: $(date)" >> "$LOG_FILE"
    echo "=======================================================" >> "$LOG_FILE"
    
    # Execute remediation sections
    configure_rsyslog
    configure_journald
    configure_log_permissions
    configure_auditd
    configure_audit_data
    configure_audit_rules
    configure_aide
    
    # Summary
    print_section "Remediation Complete"
    echo -e "${GREEN}Section 5 remediation has been completed.${NC}"
    echo -e "Log file: ${YELLOW}$LOG_FILE${NC}"
    echo ""
    echo -e "${YELLOW}IMPORTANT POST-REMEDIATION STEPS:${NC}"
    echo -e "1. Configure remote syslog server if required"
    echo -e "2. Review audit rules: ${BLUE}auditctl -l${NC}"
    echo -e "3. Verify AIDE database: ${BLUE}aide --check${NC}"
    echo -e "4. Regenerate privileged command rules based on system"
    echo -e "5. ${RED}REBOOT REQUIRED${NC} to apply immutable audit rules"
    echo ""
    
    log_message "INFO" "Section 5 remediation completed"
    echo "Completed: $(date)" >> "$LOG_FILE"
}

# Run main function
main "$@"
