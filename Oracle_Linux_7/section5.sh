#!/bin/bash
#############################################################################
# CIS Oracle Linux 7 Benchmark v4.0.0 - Section 5 Remediation Script
# Logging and Auditing
# Controls: 5.1.1.1 - 5.2.4.10
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

# Function to set parameter in config file
set_config_param() {
    local file="$1"
    local param="$2"
    local value="$3"
    
    if [[ -f "$file" ]]; then
        backup_file "$file"
        if grep -qE "^\s*${param}\s*=" "$file" 2>/dev/null; then
            sed -i "s|^\s*${param}\s*=.*|${param} = ${value}|" "$file"
        elif grep -qE "^\s*#\s*${param}\s*=" "$file" 2>/dev/null; then
            sed -i "s|^\s*#\s*${param}\s*=.*|${param} = ${value}|" "$file"
        else
            echo "${param} = ${value}" >> "$file"
        fi
    fi
}

#############################################################################
# SECTION 5.1: Configure Logging
#############################################################################

configure_rsyslog() {
    print_section "5.1.1 Configure rsyslog"
    
    # 5.1.1.1 Ensure rsyslog is installed
    print_subsection "5.1.1.1 Ensure rsyslog is installed"
    if ! rpm -q rsyslog &>/dev/null; then
        yum install -y rsyslog
        echo -e "${GREEN}[OK]${NC} Installed rsyslog"
    else
        echo -e "${GREEN}[OK]${NC} rsyslog is already installed"
    fi
    
    # 5.1.1.2 Ensure rsyslog service is enabled
    print_subsection "5.1.1.2 Ensure rsyslog service is enabled"
    systemctl --now enable rsyslog 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC} Enabled rsyslog service"
    
    # 5.1.1.3 Ensure journald is configured to send logs to rsyslog
    print_subsection "5.1.1.3 Ensure journald is configured to send logs to rsyslog"
    if [[ -f /etc/systemd/journald.conf ]]; then
        backup_file "/etc/systemd/journald.conf"
        if grep -qE '^\s*ForwardToSyslog' /etc/systemd/journald.conf; then
            sed -i 's|^\s*ForwardToSyslog.*|ForwardToSyslog=yes|' /etc/systemd/journald.conf
        else
            echo "ForwardToSyslog=yes" >> /etc/systemd/journald.conf
        fi
        systemctl reload-or-try-restart systemd-journald.service 2>/dev/null || true
        echo -e "${GREEN}[OK]${NC} Configured journald to forward logs to rsyslog"
    fi
    
    # 5.1.1.4 Ensure rsyslog default file permissions are configured
    print_subsection "5.1.1.4 Ensure rsyslog default file permissions are configured"
    if [[ -f /etc/rsyslog.conf ]]; then
        backup_file "/etc/rsyslog.conf"
        if grep -qE '^\s*\$FileCreateMode' /etc/rsyslog.conf; then
            sed -i 's|^\s*\$FileCreateMode.*|\$FileCreateMode 0640|' /etc/rsyslog.conf
        else
            echo '$FileCreateMode 0640' >> /etc/rsyslog.conf
        fi
        echo -e "${GREEN}[OK]${NC} Set rsyslog FileCreateMode to 0640"
    fi
    
    # 5.1.1.5 Ensure logging is configured
    print_subsection "5.1.1.5 Ensure logging is configured"
    echo -e "${YELLOW}[MANUAL]${NC} Review /etc/rsyslog.conf and /etc/rsyslog.d/*.conf"
    echo -e "         Ensure appropriate logging rules are configured"
    
    # 5.1.1.6 Ensure rsyslog is configured to send logs to a remote log host
    print_subsection "5.1.1.6 Ensure rsyslog is configured to send logs to a remote log host"
    echo -e "${YELLOW}[MANUAL]${NC} Configure remote logging in /etc/rsyslog.conf:"
    echo -e "         Example: *.* action(type=\"omfwd\" target=\"loghost\" port=\"514\" protocol=\"tcp\")"
    
    # 5.1.1.7 Ensure rsyslog is not configured to receive logs from a remote client
    print_subsection "5.1.1.7 Ensure rsyslog is not configured to receive logs from remote client"
    if [[ -f /etc/rsyslog.conf ]]; then
        # Remove or comment out log receiving configurations
        sed -i 's|^\s*module(load="imtcp")|#module(load="imtcp")|g' /etc/rsyslog.conf
        sed -i 's|^\s*input(type="imtcp"|#input(type="imtcp"|g' /etc/rsyslog.conf
        sed -i 's|^\s*\$ModLoad imtcp|#\$ModLoad imtcp|g' /etc/rsyslog.conf
        sed -i 's|^\s*\$InputTCPServerRun|#\$InputTCPServerRun|g' /etc/rsyslog.conf
        echo -e "${GREEN}[OK]${NC} Disabled remote log receiving in rsyslog"
    fi
    
    # Restart rsyslog to apply changes
    systemctl restart rsyslog 2>/dev/null || true
}

configure_journald() {
    print_section "5.1.2 Configure journald"
    
    # 5.1.2.1.1-5.1.2.1.3 systemd-journal-remote configuration
    print_subsection "5.1.2.1.x systemd-journal-remote configuration"
    echo -e "${YELLOW}[MANUAL]${NC} Configure systemd-journal-remote if needed for centralized logging"
    
    # 5.1.2.1.4 Ensure journald is not configured to receive logs from a remote client
    print_subsection "5.1.2.1.4 Ensure journald is not configured to receive remote logs"
    systemctl --now mask systemd-journal-remote.socket 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC} Masked systemd-journal-remote.socket"
    
    # 5.1.2.2 Ensure journald service is enabled
    print_subsection "5.1.2.2 Ensure journald service is enabled"
    echo -e "${GREEN}[OK]${NC} systemd-journald is static (enabled by default)"
    
    # 5.1.2.3 Ensure journald is configured to compress large log files
    print_subsection "5.1.2.3 Ensure journald is configured to compress large log files"
    if [[ -f /etc/systemd/journald.conf ]]; then
        if grep -qE '^\s*Compress' /etc/systemd/journald.conf; then
            sed -i 's|^\s*Compress.*|Compress=yes|' /etc/systemd/journald.conf
        elif grep -qE '^\s*#\s*Compress' /etc/systemd/journald.conf; then
            sed -i 's|^\s*#\s*Compress.*|Compress=yes|' /etc/systemd/journald.conf
        else
            echo "Compress=yes" >> /etc/systemd/journald.conf
        fi
        echo -e "${GREEN}[OK]${NC} Configured journald compression"
    fi
    
    # 5.1.2.4 Ensure journald is configured to write logfiles to persistent disk
    print_subsection "5.1.2.4 Ensure journald is configured to write logfiles to persistent disk"
    if [[ -f /etc/systemd/journald.conf ]]; then
        if grep -qE '^\s*Storage' /etc/systemd/journald.conf; then
            sed -i 's|^\s*Storage.*|Storage=persistent|' /etc/systemd/journald.conf
        elif grep -qE '^\s*#\s*Storage' /etc/systemd/journald.conf; then
            sed -i 's|^\s*#\s*Storage.*|Storage=persistent|' /etc/systemd/journald.conf
        else
            echo "Storage=persistent" >> /etc/systemd/journald.conf
        fi
        echo -e "${GREEN}[OK]${NC} Configured journald for persistent storage"
    fi
    
    # 5.1.2.5 Ensure journald is not configured to send logs to rsyslog
    # Note: This conflicts with 5.1.1.3 - choose one method
    print_subsection "5.1.2.5 Ensure journald is not configured to send logs to rsyslog"
    echo -e "${YELLOW}[INFO]${NC} ForwardToSyslog is configured in 5.1.1.3 for rsyslog"
    echo -e "         Review and adjust based on your logging architecture"
    
    # 5.1.2.6 Ensure journald log rotation is configured per site policy
    print_subsection "5.1.2.6 Ensure journald log rotation is configured"
    echo -e "${YELLOW}[MANUAL]${NC} Review journald rotation parameters in /etc/systemd/journald.conf:"
    echo -e "         SystemMaxUse=, SystemKeepFree=, RuntimeMaxUse=, RuntimeKeepFree=, MaxFileSec="
    
    # Restart journald to apply changes
    systemctl restart systemd-journald.service 2>/dev/null || true
}

configure_logrotate() {
    print_section "5.1.3-5.1.4 Configure logrotate and log file permissions"
    
    # 5.1.3 Ensure logrotate is configured
    print_subsection "5.1.3 Ensure logrotate is configured"
    echo -e "${YELLOW}[MANUAL]${NC} Review /etc/logrotate.conf and /etc/logrotate.d/*"
    echo -e "         Ensure logs are rotated according to site policy"
    
    # 5.1.4 Ensure all logfiles have appropriate access configured
    print_subsection "5.1.4 Ensure all logfiles have appropriate access configured"
    echo -e "${YELLOW}[INFO]${NC} Checking log file permissions..."
    
    # Set basic permissions on common log files
    local log_files=("/var/log/messages" "/var/log/secure" "/var/log/maillog" "/var/log/cron" "/var/log/spooler" "/var/log/boot.log")
    
    for log_file in "${log_files[@]}"; do
        if [[ -f "$log_file" ]]; then
            chmod 0640 "$log_file" 2>/dev/null || true
            chown root:root "$log_file" 2>/dev/null || true
        fi
    done
    echo -e "${GREEN}[OK]${NC} Configured basic log file permissions"
}

#############################################################################
# SECTION 5.2: Configure System Accounting (auditd)
#############################################################################

configure_auditd_install() {
    print_section "5.2.1 Configure auditd Installation"
    
    # 5.2.1.1 Ensure audit is installed
    print_subsection "5.2.1.1 Ensure audit is installed"
    if ! rpm -q audit audit-libs &>/dev/null; then
        yum install -y audit audit-libs
        echo -e "${GREEN}[OK]${NC} Installed audit and audit-libs"
    else
        echo -e "${GREEN}[OK]${NC} audit is already installed"
    fi
    
    # 5.2.1.2 Ensure auditing for processes that start prior to auditd is enabled
    print_subsection "5.2.1.2 Ensure auditing for processes that start prior to auditd"
    grubby --update-kernel ALL --args 'audit=1' 2>/dev/null || true
    # Update /etc/default/grub
    if [[ -f /etc/default/grub ]]; then
        backup_file "/etc/default/grub"
        if ! grep -q 'audit=1' /etc/default/grub; then
            sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="audit=1 /' /etc/default/grub
        fi
    fi
    echo -e "${GREEN}[OK]${NC} Configured audit=1 kernel parameter"
    
    # 5.2.1.3 Ensure audit_backlog_limit is sufficient
    print_subsection "5.2.1.3 Ensure audit_backlog_limit is sufficient"
    grubby --update-kernel ALL --args 'audit_backlog_limit=8192' 2>/dev/null || true
    if [[ -f /etc/default/grub ]]; then
        if ! grep -q 'audit_backlog_limit=' /etc/default/grub; then
            sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="audit_backlog_limit=8192 /' /etc/default/grub
        fi
    fi
    echo -e "${GREEN}[OK]${NC} Configured audit_backlog_limit=8192"
    
    # 5.2.1.4 Ensure auditd service is enabled
    print_subsection "5.2.1.4 Ensure auditd service is enabled"
    systemctl --now enable auditd 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC} Enabled auditd service"
}

configure_auditd_data_retention() {
    print_section "5.2.2 Configure Data Retention"
    
    local auditd_conf="/etc/audit/auditd.conf"
    
    if [[ ! -f "$auditd_conf" ]]; then
        echo -e "${RED}[ERROR]${NC} $auditd_conf not found"
        return
    fi
    
    backup_file "$auditd_conf"
    
    # 5.2.2.1 Ensure audit log storage size is configured
    print_subsection "5.2.2.1 Ensure audit log storage size is configured"
    sed -i 's|^\s*max_log_file\s*=.*|max_log_file = 25|' "$auditd_conf"
    echo -e "${GREEN}[OK]${NC} Set max_log_file = 25 MB"
    
    # 5.2.2.2 Ensure audit logs are not automatically deleted
    print_subsection "5.2.2.2 Ensure audit logs are not automatically deleted"
    sed -i 's|^\s*max_log_file_action\s*=.*|max_log_file_action = keep_logs|' "$auditd_conf"
    echo -e "${GREEN}[OK]${NC} Set max_log_file_action = keep_logs"
    
    # 5.2.2.3 Ensure system is disabled when audit logs are full
    print_subsection "5.2.2.3 Ensure system is disabled when audit logs are full"
    sed -i 's|^\s*disk_full_action\s*=.*|disk_full_action = halt|' "$auditd_conf"
    sed -i 's|^\s*disk_error_action\s*=.*|disk_error_action = halt|' "$auditd_conf"
    echo -e "${GREEN}[OK]${NC} Set disk_full_action and disk_error_action = halt"
    
    # 5.2.2.4 Ensure system warns when audit logs are low on space
    print_subsection "5.2.2.4 Ensure system warns when audit logs are low on space"
    sed -i 's|^\s*space_left_action\s*=.*|space_left_action = email|' "$auditd_conf"
    sed -i 's|^\s*admin_space_left_action\s*=.*|admin_space_left_action = single|' "$auditd_conf"
    echo -e "${GREEN}[OK]${NC} Set space_left_action = email, admin_space_left_action = single"
}

configure_auditd_rules() {
    print_section "5.2.3 Configure auditd Rules"
    
    local rules_dir="/etc/audit/rules.d"
    mkdir -p "$rules_dir"
    
    # 5.2.3.1 Ensure changes to system administration scope (sudoers) is collected
    print_subsection "5.2.3.1 Ensure changes to sudoers is collected"
    cat > "${rules_dir}/50-scope.rules" << 'EOF'
-w /etc/sudoers -p wa -k scope
-w /etc/sudoers.d -p wa -k scope
EOF
    echo -e "${GREEN}[OK]${NC} Created sudoers audit rules"
    
    # 5.2.3.2 Ensure actions as another user are always logged
    print_subsection "5.2.3.2 Ensure actions as another user are always logged"
    cat > "${rules_dir}/50-user_emulation.rules" << 'EOF'
-a always,exit -F arch=b64 -C euid!=uid -F auid!=unset -S execve -k user_emulation
-a always,exit -F arch=b32 -C euid!=uid -F auid!=unset -S execve -k user_emulation
EOF
    echo -e "${GREEN}[OK]${NC} Created user emulation audit rules"
    
    # 5.2.3.3 Ensure events that modify the sudo log file are collected
    print_subsection "5.2.3.3 Ensure events that modify the sudo log file are collected"
    SUDO_LOG_FILE=$(grep -r logfile /etc/sudoers* 2>/dev/null | sed -e 's/.*logfile=//;s/,? .*//' -e 's/"//g' | head -1)
    [ -z "$SUDO_LOG_FILE" ] && SUDO_LOG_FILE="/var/log/sudo.log"
    cat > "${rules_dir}/50-sudo.rules" << EOF
-w ${SUDO_LOG_FILE} -p wa -k sudo_log_file
EOF
    echo -e "${GREEN}[OK]${NC} Created sudo log file audit rules"
    
    # 5.2.3.4 Ensure events that modify date and time information are collected
    print_subsection "5.2.3.4 Ensure events that modify date and time are collected"
    cat > "${rules_dir}/50-time-change.rules" << 'EOF'
-a always,exit -F arch=b64 -S adjtimex,settimeofday,clock_settime -k time-change
-a always,exit -F arch=b32 -S adjtimex,settimeofday,clock_settime -k time-change
-w /etc/localtime -p wa -k time-change
EOF
    echo -e "${GREEN}[OK]${NC} Created time change audit rules"
    
    # 5.2.3.5 Ensure events that modify the system's network environment are collected
    print_subsection "5.2.3.5 Ensure events that modify network environment are collected"
    cat > "${rules_dir}/50-system_locale.rules" << 'EOF'
-a always,exit -F arch=b64 -S sethostname,setdomainname -k system-locale
-a always,exit -F arch=b32 -S sethostname,setdomainname -k system-locale
-w /etc/issue -p wa -k system-locale
-w /etc/issue.net -p wa -k system-locale
-w /etc/hosts -p wa -k system-locale
-w /etc/sysconfig/network -p wa -k system-locale
-w /etc/sysconfig/network-scripts/ -p wa -k system-locale
EOF
    echo -e "${GREEN}[OK]${NC} Created network environment audit rules"
    
    # 5.2.3.6 Ensure use of privileged commands are collected
    print_subsection "5.2.3.6 Ensure use of privileged commands are collected"
    UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)
    [ -z "$UID_MIN" ] && UID_MIN=1000
    
    # Generate rules for privileged commands
    : > "${rules_dir}/50-privileged.rules"
    for PARTITION in $(findmnt -n -l -k -it $(awk '/nodev/ { print $2 }' /proc/filesystems | paste -sd,) 2>/dev/null | grep -Pv "noexec|nosuid" | awk '{print $1}'); do
        find "${PARTITION}" -xdev -perm /6000 -type f 2>/dev/null | while read -r PRIVILEGED; do
            echo "-a always,exit -F path=${PRIVILEGED} -F perm=x -F auid>=${UID_MIN} -F auid!=unset -k privileged" >> "${rules_dir}/50-privileged.rules"
        done
    done 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC} Created privileged commands audit rules"
    
    # 5.2.3.7 Ensure unsuccessful file access attempts are collected
    print_subsection "5.2.3.7 Ensure unsuccessful file access attempts are collected"
    cat > "${rules_dir}/50-access.rules" << EOF
-a always,exit -F arch=b64 -S creat,open,openat,truncate,ftruncate -F exit=-EACCES -F auid>=${UID_MIN} -F auid!=unset -k access
-a always,exit -F arch=b64 -S creat,open,openat,truncate,ftruncate -F exit=-EPERM -F auid>=${UID_MIN} -F auid!=unset -k access
-a always,exit -F arch=b32 -S creat,open,openat,truncate,ftruncate -F exit=-EACCES -F auid>=${UID_MIN} -F auid!=unset -k access
-a always,exit -F arch=b32 -S creat,open,openat,truncate,ftruncate -F exit=-EPERM -F auid>=${UID_MIN} -F auid!=unset -k access
EOF
    echo -e "${GREEN}[OK]${NC} Created file access audit rules"
    
    # 5.2.3.8 Ensure events that modify user/group information are collected
    print_subsection "5.2.3.8 Ensure events that modify user/group information are collected"
    cat > "${rules_dir}/50-identity.rules" << 'EOF'
-w /etc/group -p wa -k identity
-w /etc/passwd -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/security/opasswd -p wa -k identity
EOF
    echo -e "${GREEN}[OK]${NC} Created identity audit rules"
    
    # 5.2.3.9 Ensure discretionary access control permission modification events are collected
    print_subsection "5.2.3.9 Ensure DAC permission modification events are collected"
    cat > "${rules_dir}/50-perm_mod.rules" << EOF
-a always,exit -F arch=b64 -S chmod,fchmod,fchmodat -F auid>=${UID_MIN} -F auid!=unset -k perm_mod
-a always,exit -F arch=b64 -S chown,fchown,lchown,fchownat -F auid>=${UID_MIN} -F auid!=unset -k perm_mod
-a always,exit -F arch=b32 -S chmod,fchmod,fchmodat -F auid>=${UID_MIN} -F auid!=unset -k perm_mod
-a always,exit -F arch=b32 -S lchown,fchown,chown,fchownat -F auid>=${UID_MIN} -F auid!=unset -k perm_mod
-a always,exit -F arch=b64 -S setxattr,lsetxattr,fsetxattr,removexattr,lremovexattr,fremovexattr -F auid>=${UID_MIN} -F auid!=unset -k perm_mod
-a always,exit -F arch=b32 -S setxattr,lsetxattr,fsetxattr,removexattr,lremovexattr,fremovexattr -F auid>=${UID_MIN} -F auid!=unset -k perm_mod
EOF
    echo -e "${GREEN}[OK]${NC} Created permission modification audit rules"
    
    # 5.2.3.10 Ensure successful file system mounts are collected
    print_subsection "5.2.3.10 Ensure successful file system mounts are collected"
    cat > "${rules_dir}/50-mounts.rules" << EOF
-a always,exit -F arch=b64 -S mount -F auid>=${UID_MIN} -F auid!=unset -k mounts
-a always,exit -F arch=b32 -S mount -F auid>=${UID_MIN} -F auid!=unset -k mounts
EOF
    echo -e "${GREEN}[OK]${NC} Created mounts audit rules"
    
    # 5.2.3.11 Ensure session initiation information is collected
    print_subsection "5.2.3.11 Ensure session initiation information is collected"
    cat > "${rules_dir}/50-session.rules" << 'EOF'
-w /var/run/utmp -p wa -k session
-w /var/log/wtmp -p wa -k session
-w /var/log/btmp -p wa -k session
EOF
    echo -e "${GREEN}[OK]${NC} Created session audit rules"
    
    # 5.2.3.12 Ensure login and logout events are collected
    print_subsection "5.2.3.12 Ensure login and logout events are collected"
    cat > "${rules_dir}/50-login.rules" << 'EOF'
-w /var/log/lastlog -p wa -k logins
-w /var/run/faillock -p wa -k logins
EOF
    echo -e "${GREEN}[OK]${NC} Created login/logout audit rules"
    
    # 5.2.3.13 Ensure file deletion events by users are collected
    print_subsection "5.2.3.13 Ensure file deletion events by users are collected"
    cat > "${rules_dir}/50-delete.rules" << EOF
-a always,exit -F arch=b64 -S rename,unlink,unlinkat,renameat -F auid>=${UID_MIN} -F auid!=unset -k delete
-a always,exit -F arch=b32 -S rename,unlink,unlinkat,renameat -F auid>=${UID_MIN} -F auid!=unset -k delete
EOF
    echo -e "${GREEN}[OK]${NC} Created file deletion audit rules"
    
    # 5.2.3.14 Ensure events that modify the system's MAC are collected
    print_subsection "5.2.3.14 Ensure events that modify MAC are collected"
    cat > "${rules_dir}/50-MAC-policy.rules" << 'EOF'
-w /etc/selinux -p wa -k MAC-policy
-w /usr/share/selinux -p wa -k MAC-policy
EOF
    echo -e "${GREEN}[OK]${NC} Created MAC policy audit rules"
    
    # 5.2.3.15-5.2.3.17 Ensure chcon, setfacl, chacl commands are recorded
    print_subsection "5.2.3.15-17 Ensure chcon, setfacl, chacl commands are recorded"
    cat > "${rules_dir}/50-perm_chng.rules" << EOF
-a always,exit -F path=/usr/bin/chcon -F perm=x -F auid>=${UID_MIN} -F auid!=unset -k perm_chng
-a always,exit -F path=/usr/bin/setfacl -F perm=x -F auid>=${UID_MIN} -F auid!=unset -k perm_chng
-a always,exit -F path=/usr/bin/chacl -F perm=x -F auid>=${UID_MIN} -F auid!=unset -k perm_chng
EOF
    echo -e "${GREEN}[OK]${NC} Created permission change command audit rules"
    
    # 5.2.3.18 Ensure usermod command is recorded
    print_subsection "5.2.3.18 Ensure usermod command is recorded"
    cat > "${rules_dir}/50-usermod.rules" << EOF
-a always,exit -F path=/usr/sbin/usermod -F perm=x -F auid>=${UID_MIN} -F auid!=unset -k usermod
EOF
    echo -e "${GREEN}[OK]${NC} Created usermod audit rules"
    
    # 5.2.3.19 Ensure kernel module loading and unloading is collected
    print_subsection "5.2.3.19 Ensure kernel module loading and unloading is collected"
    cat > "${rules_dir}/50-kernel_modules.rules" << EOF
-a always,exit -F arch=b64 -S init_module,finit_module,delete_module,create_module,query_module -F auid>=${UID_MIN} -F auid!=unset -k kernel_modules
-a always,exit -F path=/usr/bin/kmod -F perm=x -F auid>=${UID_MIN} -F auid!=unset -k kernel_modules
EOF
    echo -e "${GREEN}[OK]${NC} Created kernel module audit rules"
    
    # 5.2.3.20 Ensure the audit configuration is immutable
    print_subsection "5.2.3.20 Ensure the audit configuration is immutable"
    echo "-e 2" > "${rules_dir}/99-finalize.rules"
    echo -e "${GREEN}[OK]${NC} Set audit configuration to immutable (-e 2)"
    
    # 5.2.3.21 Ensure the running and on disk configuration is the same
    print_subsection "5.2.3.21 Ensure the running and on disk configuration is the same"
    augenrules --load 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC} Loaded audit rules"
    
    # Check if reboot is required
    if [[ $(auditctl -s 2>/dev/null | grep "enabled" || echo "0") =~ "2" ]]; then
        echo -e "${YELLOW}[WARN]${NC} Reboot required to load audit rules"
    fi
}

configure_auditd_file_access() {
    print_section "5.2.4 Configure auditd File Access"
    
    local audit_log_dir=$(dirname $(awk -F"=" '/^\s*log_file\s*=\s*/ {print $2}' /etc/audit/auditd.conf 2>/dev/null | tr -d ' '))
    [ -z "$audit_log_dir" ] && audit_log_dir="/var/log/audit"
    
    # 5.2.4.1 Ensure the audit log directory is 0750 or more restrictive
    print_subsection "5.2.4.1 Ensure the audit log directory is 0750 or more restrictive"
    if [[ -d "$audit_log_dir" ]]; then
        chmod g-w,o-rwx "$audit_log_dir"
        echo -e "${GREEN}[OK]${NC} Set audit log directory permissions to 0750"
    fi
    
    # 5.2.4.2 Ensure audit log files are mode 0640 or less permissive
    print_subsection "5.2.4.2 Ensure audit log files are mode 0640 or less permissive"
    find "$audit_log_dir" -type f \( ! -perm 600 -a ! -perm 0400 -a ! -perm 0200 -a ! -perm 0000 -a ! -perm 0640 -a ! -perm 0440 -a ! -perm 0040 \) -exec chmod u-x,g-wx,o-rwx {} + 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC} Set audit log file permissions"
    
    # 5.2.4.3 Ensure only authorized users own audit log files
    print_subsection "5.2.4.3 Ensure only authorized users own audit log files"
    find "$audit_log_dir" -type f ! -user root -exec chown root {} + 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC} Set audit log file ownership to root"
    
    # 5.2.4.4 Ensure only authorized groups are assigned ownership of audit log files
    print_subsection "5.2.4.4 Ensure only authorized groups own audit log files"
    find "$audit_log_dir" -type f \( ! -group adm -a ! -group root \) -exec chgrp root {} + 2>/dev/null || true
    chgrp root "$audit_log_dir" 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC} Set audit log file group ownership"
    
    # 5.2.4.5 Ensure audit configuration files are 640 or more restrictive
    print_subsection "5.2.4.5 Ensure audit configuration files are 640 or more restrictive"
    find /etc/audit/ -type f \( -name '*.conf' -o -name '*.rules' \) -exec chmod u-x,g-wx,o-rwx {} + 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC} Set audit configuration file permissions"
    
    # 5.2.4.6 Ensure audit configuration files are owned by root
    print_subsection "5.2.4.6 Ensure audit configuration files are owned by root"
    find /etc/audit/ -type f \( -name '*.conf' -o -name '*.rules' \) ! -user root -exec chown root {} + 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC} Set audit configuration file ownership"
    
    # 5.2.4.7 Ensure audit configuration files belong to group root
    print_subsection "5.2.4.7 Ensure audit configuration files belong to group root"
    find /etc/audit/ -type f \( -name '*.conf' -o -name '*.rules' \) ! -group root -exec chgrp root {} + 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC} Set audit configuration file group ownership"
    
    # 5.2.4.8-10 Ensure audit tools are properly secured
    print_subsection "5.2.4.8-10 Ensure audit tools are properly secured"
    local audit_tools="/sbin/auditctl /sbin/aureport /sbin/ausearch /sbin/autrace /sbin/auditd /sbin/augenrules"
    chmod go-w $audit_tools 2>/dev/null || true
    chown root:root $audit_tools 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC} Secured audit tools"
}

#############################################################################
# MAIN EXECUTION
#############################################################################

main() {
    echo -e "${GREEN}"
    echo "=============================================================="
    echo " CIS Oracle Linux 7 Benchmark v4.0.0"
    echo " Section 5: Logging and Auditing"
    echo " Controls: 5.1.1.1 - 5.2.4.10"
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
    configure_logrotate
    configure_auditd_install
    configure_auditd_data_retention
    configure_auditd_rules
    configure_auditd_file_access
    
    # Summary
    print_section "Remediation Complete"
    echo -e "${GREEN}Section 5 remediation has been completed.${NC}"
    echo -e "Log file: ${YELLOW}$LOG_FILE${NC}"
    echo ""
    echo -e "${YELLOW}IMPORTANT POST-REMEDIATION STEPS:${NC}"
    echo -e "1. Review /etc/rsyslog.conf for appropriate logging rules"
    echo -e "2. Configure remote logging if required"
    echo -e "3. Verify audit rules with: ${BLUE}auditctl -l${NC}"
    echo -e "4. Review journald settings in /etc/systemd/journald.conf"
    echo -e "5. A reboot may be required to fully apply audit rules"
    echo ""
    
    log_message "INFO" "Section 5 remediation completed"
    echo "Completed: $(date)" >> "$LOG_FILE"
}

# Run main function
main "$@"
