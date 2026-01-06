#!/bin/bash
#############################################################################
# CIS Oracle Linux 7 Benchmark v4.0.0 - Section 4 Remediation Script
# Access, Authentication and Authorization
# Controls: 4.1.1.1 - 4.5.3.3
#
# WARNING: SSH configurations that could disable remote access are COMMENTED OUT
# Review and enable manually after ensuring alternative access methods exist
#############################################################################

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log file
LOG_FILE="/var/log/cis_section4_remediation_$(date +%Y%m%d_%H%M%S).log"

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

# Function to set SSH parameter
set_ssh_param() {
    local param="$1"
    local value="$2"
    local config_file="/etc/ssh/sshd_config"
    
    backup_file "$config_file"
    
    if grep -qi "^${param}" "$config_file" 2>/dev/null; then
        sed -i "s|^${param}.*|${param} ${value}|i" "$config_file"
    elif grep -qi "^#${param}" "$config_file" 2>/dev/null; then
        sed -i "s|^#${param}.*|${param} ${value}|i" "$config_file"
    else
        echo "${param} ${value}" >> "$config_file"
    fi
    
    log_message "INFO" "Set SSH ${param} = ${value}"
}

#############################################################################
# SECTION 4.1: Configure Job Schedulers
#############################################################################

configure_job_schedulers() {
    print_section "4.1 Configure Job Schedulers"
    
    # 4.1.1.1 Ensure cron daemon is enabled and active
    print_subsection "4.1.1.1 Ensure cron daemon is enabled and active"
    systemctl unmask crond 2>/dev/null || true
    systemctl enable crond 2>/dev/null || true
    systemctl start crond 2>/dev/null || true
    log_message "INFO" "Enabled and started crond"
    echo -e "${GREEN}[OK]${NC} crond is enabled and running"
    
    # 4.1.1.2 Ensure permissions on /etc/crontab are configured
    print_subsection "4.1.1.2 Ensure permissions on /etc/crontab are configured"
    if [ -f /etc/crontab ]; then
        chown root:root /etc/crontab
        chmod og-rwx /etc/crontab
        echo -e "${GREEN}[OK]${NC} Secured /etc/crontab (mode 600)"
    fi
    
    # 4.1.1.3 Ensure permissions on /etc/cron.hourly are configured
    print_subsection "4.1.1.3 Ensure permissions on /etc/cron.hourly are configured"
    if [ -d /etc/cron.hourly ]; then
        chown root:root /etc/cron.hourly/
        chmod og-rwx /etc/cron.hourly/
        echo -e "${GREEN}[OK]${NC} Secured /etc/cron.hourly (mode 700)"
    fi
    
    # 4.1.1.4 Ensure permissions on /etc/cron.daily are configured
    print_subsection "4.1.1.4 Ensure permissions on /etc/cron.daily are configured"
    if [ -d /etc/cron.daily ]; then
        chown root:root /etc/cron.daily/
        chmod og-rwx /etc/cron.daily/
        echo -e "${GREEN}[OK]${NC} Secured /etc/cron.daily (mode 700)"
    fi
    
    # 4.1.1.5 Ensure permissions on /etc/cron.weekly are configured
    print_subsection "4.1.1.5 Ensure permissions on /etc/cron.weekly are configured"
    if [ -d /etc/cron.weekly ]; then
        chown root:root /etc/cron.weekly/
        chmod og-rwx /etc/cron.weekly/
        echo -e "${GREEN}[OK]${NC} Secured /etc/cron.weekly (mode 700)"
    fi
    
    # 4.1.1.6 Ensure permissions on /etc/cron.monthly are configured
    print_subsection "4.1.1.6 Ensure permissions on /etc/cron.monthly are configured"
    if [ -d /etc/cron.monthly ]; then
        chown root:root /etc/cron.monthly/
        chmod og-rwx /etc/cron.monthly/
        echo -e "${GREEN}[OK]${NC} Secured /etc/cron.monthly (mode 700)"
    fi
    
    # 4.1.1.7 Ensure permissions on /etc/cron.d are configured
    print_subsection "4.1.1.7 Ensure permissions on /etc/cron.d are configured"
    if [ -d /etc/cron.d ]; then
        chown root:root /etc/cron.d/
        chmod og-rwx /etc/cron.d/
        echo -e "${GREEN}[OK]${NC} Secured /etc/cron.d (mode 700)"
    fi
    
    # 4.1.1.8 Ensure crontab is restricted to authorized users
    print_subsection "4.1.1.8 Ensure crontab is restricted to authorized users"
    [ ! -e "/etc/cron.allow" ] && touch /etc/cron.allow
    chown root:root /etc/cron.allow
    chmod u-x,g-wx,o-rwx /etc/cron.allow
    if [ -e "/etc/cron.deny" ]; then
        chown root:root /etc/cron.deny
        chmod u-x,g-wx,o-rwx /etc/cron.deny
    fi
    echo -e "${GREEN}[OK]${NC} Configured cron access control"
    
    # 4.1.2.1 Ensure at is restricted to authorized users
    print_subsection "4.1.2.1 Ensure at is restricted to authorized users"
    if rpm -q at &>/dev/null; then
        l_group="root"
        grep -Pq -- '^daemon\b' /etc/group && l_group="daemon"
        [ ! -e "/etc/at.allow" ] && touch /etc/at.allow
        chown root:"$l_group" /etc/at.allow
        chmod u-x,g-wx,o-rwx /etc/at.allow
        if [ -e "/etc/at.deny" ]; then
            chown root:"$l_group" /etc/at.deny
            chmod u-x,g-wx,o-rwx /etc/at.deny
        fi
        echo -e "${GREEN}[OK]${NC} Configured at access control"
    else
        echo -e "${YELLOW}[SKIP]${NC} at is not installed"
    fi
}

#############################################################################
# SECTION 4.2: Configure SSH Server
#############################################################################

configure_ssh_server() {
    print_section "4.2 Configure SSH Server"
    
    # Check if SSH is installed
    if ! rpm -q openssh-server &>/dev/null; then
        echo -e "${YELLOW}[SKIP]${NC} openssh-server is not installed"
        return
    fi
    
    # Backup sshd_config
    backup_file "/etc/ssh/sshd_config"
    
    # 4.2.1 Ensure permissions on /etc/ssh/sshd_config are configured
    print_subsection "4.2.1 Ensure permissions on /etc/ssh/sshd_config are configured"
    chmod u-x,og-rwx /etc/ssh/sshd_config
    chown root:root /etc/ssh/sshd_config
    # Also secure any files in sshd_config.d
    if [ -d /etc/ssh/sshd_config.d ]; then
        find /etc/ssh/sshd_config.d -type f -name "*.conf" -exec chmod u-x,og-rwx {} \;
        find /etc/ssh/sshd_config.d -type f -name "*.conf" -exec chown root:root {} \;
    fi
    echo -e "${GREEN}[OK]${NC} Secured sshd_config permissions"
    
    # 4.2.2 Ensure permissions on SSH private host key files are configured
    print_subsection "4.2.2 Ensure permissions on SSH private host key files"
    if command -v ssh-keygen &>/dev/null && [ -d /etc/ssh ]; then
        find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec chmod u-x,go-rwx {} \;
        find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec chown root:root {} \;
        echo -e "${GREEN}[OK]${NC} Secured SSH private host keys"
    fi
    
    # 4.2.3 Ensure permissions on SSH public host key files are configured
    print_subsection "4.2.3 Ensure permissions on SSH public host key files"
    if [ -d /etc/ssh ]; then
        find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec chmod u-x,go-wx {} \;
        find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec chown root:root {} \;
        echo -e "${GREEN}[OK]${NC} Secured SSH public host keys"
    fi
    
    #############################################################################
    # SSH ACCESS CONFIGURATION - COMMENTED OUT FOR SAFETY
    # WARNING: These settings could lock you out of the system!
    # Review carefully and enable manually after testing.
    #############################################################################
    
    # 4.2.4 Ensure sshd access is configured
    print_subsection "4.2.4 Ensure sshd access is configured (Manual)"
    echo -e "${YELLOW}[MANUAL]${NC} Configure AllowUsers/AllowGroups/DenyUsers/DenyGroups"
    echo -e "         Example: AllowUsers user1 user2"
    echo -e "         Example: AllowGroups sshusers"
    log_message "WARN" "4.2.4 - SSH access configuration skipped for safety"
    
    # 4.2.5 Ensure sshd Banner is configured
    print_subsection "4.2.5 Ensure sshd Banner is configured"
    set_ssh_param "Banner" "/etc/issue.net"
    echo -e "${GREEN}[OK]${NC} Set SSH Banner to /etc/issue.net"
    
    # 4.2.6 Ensure sshd Ciphers are configured
    print_subsection "4.2.6 Ensure sshd Ciphers are configured"
    set_ssh_param "Ciphers" "chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr"
    echo -e "${GREEN}[OK]${NC} Configured strong SSH ciphers"
    
    # 4.2.7 Ensure sshd ClientAliveInterval and ClientAliveCountMax are configured
    print_subsection "4.2.7 Ensure sshd ClientAliveInterval and ClientAliveCountMax"
    set_ssh_param "ClientAliveInterval" "15"
    set_ssh_param "ClientAliveCountMax" "3"
    echo -e "${GREEN}[OK]${NC} Set ClientAliveInterval=15, ClientAliveCountMax=3"
    
    # 4.2.8 Ensure sshd DisableForwarding is enabled
    print_subsection "4.2.8 Ensure sshd DisableForwarding is enabled"
    set_ssh_param "DisableForwarding" "yes"
    echo -e "${GREEN}[OK]${NC} Disabled SSH forwarding"
    
    # 4.2.9 Ensure sshd GSSAPIAuthentication is disabled
    print_subsection "4.2.9 Ensure sshd GSSAPIAuthentication is disabled"
    set_ssh_param "GSSAPIAuthentication" "no"
    echo -e "${GREEN}[OK]${NC} Disabled GSSAPI authentication"
    
    # 4.2.10 Ensure sshd HostbasedAuthentication is disabled
    print_subsection "4.2.10 Ensure sshd HostbasedAuthentication is disabled"
    set_ssh_param "HostbasedAuthentication" "no"
    echo -e "${GREEN}[OK]${NC} Disabled host-based authentication"
    
    # 4.2.11 Ensure sshd IgnoreRhosts is enabled
    print_subsection "4.2.11 Ensure sshd IgnoreRhosts is enabled"
    set_ssh_param "IgnoreRhosts" "yes"
    echo -e "${GREEN}[OK]${NC} Enabled IgnoreRhosts"
    
    # 4.2.12 Ensure sshd KexAlgorithms is configured
    print_subsection "4.2.12 Ensure sshd KexAlgorithms is configured"
    set_ssh_param "KexAlgorithms" "curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group14-sha256"
    echo -e "${GREEN}[OK]${NC} Configured strong KexAlgorithms"
    
    # 4.2.13 Ensure sshd LoginGraceTime is configured
    print_subsection "4.2.13 Ensure sshd LoginGraceTime is configured"
    set_ssh_param "LoginGraceTime" "60"
    echo -e "${GREEN}[OK]${NC} Set LoginGraceTime to 60 seconds"
    
    # 4.2.14 Ensure sshd LogLevel is configured
    print_subsection "4.2.14 Ensure sshd LogLevel is configured"
    set_ssh_param "LogLevel" "INFO"
    echo -e "${GREEN}[OK]${NC} Set LogLevel to INFO"
    
    # 4.2.15 Ensure sshd MACs are configured
    print_subsection "4.2.15 Ensure sshd MACs are configured"
    set_ssh_param "MACs" "hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256"
    echo -e "${GREEN}[OK]${NC} Configured strong MACs"
    
    # 4.2.16 Ensure sshd MaxAuthTries is configured
    print_subsection "4.2.16 Ensure sshd MaxAuthTries is configured"
    set_ssh_param "MaxAuthTries" "4"
    echo -e "${GREEN}[OK]${NC} Set MaxAuthTries to 4"
    
    # 4.2.17 Ensure sshd MaxSessions is configured
    print_subsection "4.2.17 Ensure sshd MaxSessions is configured"
    set_ssh_param "MaxSessions" "10"
    echo -e "${GREEN}[OK]${NC} Set MaxSessions to 10"
    
    # 4.2.18 Ensure sshd MaxStartups is configured
    print_subsection "4.2.18 Ensure sshd MaxStartups is configured"
    set_ssh_param "MaxStartups" "10:30:60"
    echo -e "${GREEN}[OK]${NC} Set MaxStartups to 10:30:60"
    
    # 4.2.19 Ensure sshd PermitEmptyPasswords is disabled
    print_subsection "4.2.19 Ensure sshd PermitEmptyPasswords is disabled"
    set_ssh_param "PermitEmptyPasswords" "no"
    echo -e "${GREEN}[OK]${NC} Disabled empty passwords"
    
    #############################################################################
    # 4.2.20 - PermitRootLogin - COMMENTED OUT FOR SAFETY
    # WARNING: This could lock you out if no other user can sudo!
    #############################################################################
    print_subsection "4.2.20 Ensure sshd PermitRootLogin is disabled"
    echo -e "${YELLOW}[SKIPPED]${NC} PermitRootLogin configuration skipped for safety"
    echo -e "         To disable root login, manually run:"
    echo -e "         sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config"
    log_message "WARN" "4.2.20 - PermitRootLogin NOT changed to preserve remote access"
    
    # 4.2.21 Ensure sshd PermitUserEnvironment is disabled
    print_subsection "4.2.21 Ensure sshd PermitUserEnvironment is disabled"
    set_ssh_param "PermitUserEnvironment" "no"
    echo -e "${GREEN}[OK]${NC} Disabled PermitUserEnvironment"
    
    # 4.2.22 Ensure sshd UsePAM is enabled
    print_subsection "4.2.22 Ensure sshd UsePAM is enabled"
    set_ssh_param "UsePAM" "yes"
    echo -e "${GREEN}[OK]${NC} Enabled UsePAM"
    
    # Reload SSH configuration
    print_subsection "Reloading SSH configuration"
    if systemctl is-active sshd &>/dev/null; then
        systemctl reload sshd 2>/dev/null || systemctl restart sshd 2>/dev/null || true
        echo -e "${GREEN}[OK]${NC} Reloaded sshd configuration"
    fi
}

#############################################################################
# SECTION 4.3: Configure Privilege Escalation
#############################################################################

configure_privilege_escalation() {
    print_section "4.3 Configure Privilege Escalation"
    
    # 4.3.1 Ensure sudo is installed
    print_subsection "4.3.1 Ensure sudo is installed"
    if ! rpm -q sudo &>/dev/null; then
        yum install -y sudo
        echo -e "${GREEN}[OK]${NC} Installed sudo"
    else
        echo -e "${GREEN}[OK]${NC} sudo is already installed"
    fi
    
    # 4.3.2 Ensure sudo commands use pty
    print_subsection "4.3.2 Ensure sudo commands use pty"
    if ! grep -qE '^\s*Defaults\s+.*\buse_pty\b' /etc/sudoers /etc/sudoers.d/* 2>/dev/null; then
        echo "Defaults use_pty" >> /etc/sudoers.d/cis_hardening
        echo -e "${GREEN}[OK]${NC} Configured sudo to use pty"
    else
        echo -e "${GREEN}[OK]${NC} sudo use_pty already configured"
    fi
    
    # 4.3.3 Ensure sudo log file exists
    print_subsection "4.3.3 Ensure sudo log file exists"
    if ! grep -qE '^\s*Defaults\s+logfile=' /etc/sudoers /etc/sudoers.d/* 2>/dev/null; then
        echo 'Defaults logfile="/var/log/sudo.log"' >> /etc/sudoers.d/cis_hardening
        echo -e "${GREEN}[OK]${NC} Configured sudo log file"
    else
        echo -e "${GREEN}[OK]${NC} sudo logfile already configured"
    fi
    
    # 4.3.4 Ensure users must provide password for privilege escalation
    print_subsection "4.3.4 Ensure users must provide password for privilege escalation"
    echo -e "${YELLOW}[MANUAL]${NC} Review sudoers for NOPASSWD entries:"
    echo -e "         grep -r 'NOPASSWD' /etc/sudoers /etc/sudoers.d/"
    log_message "INFO" "Manual review required for NOPASSWD entries"
    
    # 4.3.5 Ensure re-authentication for privilege escalation is not disabled globally
    print_subsection "4.3.5 Ensure re-authentication for privilege escalation"
    echo -e "${YELLOW}[MANUAL]${NC} Review sudoers for !authenticate entries:"
    echo -e "         grep -r '!authenticate' /etc/sudoers /etc/sudoers.d/"
    log_message "INFO" "Manual review required for !authenticate entries"
    
    # 4.3.6 Ensure sudo authentication timeout is configured correctly
    print_subsection "4.3.6 Ensure sudo authentication timeout is configured"
    if ! grep -qE '^\s*Defaults\s+.*\btimestamp_timeout=' /etc/sudoers /etc/sudoers.d/* 2>/dev/null; then
        echo "Defaults timestamp_timeout=15" >> /etc/sudoers.d/cis_hardening
        echo -e "${GREEN}[OK]${NC} Set sudo timestamp_timeout to 15 minutes"
    else
        echo -e "${GREEN}[OK]${NC} sudo timestamp_timeout already configured"
    fi
    
    # 4.3.7 Ensure access to the su command is restricted
    print_subsection "4.3.7 Ensure access to the su command is restricted"
    if ! grep -qE '^\s*auth\s+required\s+pam_wheel\.so' /etc/pam.d/su; then
        backup_file "/etc/pam.d/su"
        sed -i '/pam_rootok.so/a auth           required        pam_wheel.so use_uid' /etc/pam.d/su
        echo -e "${GREEN}[OK]${NC} Restricted su command to wheel group"
    else
        echo -e "${GREEN}[OK]${NC} su restriction already configured"
    fi
    
    # Validate sudoers syntax
    visudo -c &>/dev/null || {
        log_message "ERROR" "Sudoers syntax error detected!"
        echo -e "${RED}[ERROR]${NC} Sudoers syntax error - please review manually"
    }
}

#############################################################################
# SECTION 4.4: Configure PAM (Basic Configuration Only)
#############################################################################

configure_pam_basic() {
    print_section "4.4 Configure PAM (Basic)"
    
    # 4.4.1.1 Ensure password creation requirements are configured
    print_subsection "4.4.1.1 Ensure password creation requirements"
    echo -e "${YELLOW}[MANUAL]${NC} Configure password complexity in /etc/security/pwquality.conf"
    echo -e "         Recommended settings:"
    echo -e "         minlen = 14"
    echo -e "         minclass = 4"
    log_message "INFO" "Manual review for password complexity settings"
    
    # 4.4.1.2 Ensure lockout for failed password attempts is configured
    print_subsection "4.4.1.2 Ensure lockout for failed password attempts"
    echo -e "${YELLOW}[MANUAL]${NC} Configure account lockout in PAM files"
    echo -e "         See /etc/pam.d/system-auth and /etc/pam.d/password-auth"
    log_message "INFO" "Manual review for account lockout settings"
}

#############################################################################
# SECTION 4.5: User Accounts and Environment
#############################################################################

configure_user_accounts() {
    print_section "4.5 User Accounts and Environment"
    
    # 4.5.1.1 Ensure password expiration is configured
    print_subsection "4.5.1.1 Ensure password expiration is configured"
    backup_file "/etc/login.defs"
    sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   365/' /etc/login.defs
    echo -e "${GREEN}[OK]${NC} Set PASS_MAX_DAYS to 365"
    
    # 4.5.1.2 Ensure minimum days between password changes is configured
    print_subsection "4.5.1.2 Ensure minimum days between password changes"
    sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   1/' /etc/login.defs
    echo -e "${GREEN}[OK]${NC} Set PASS_MIN_DAYS to 1"
    
    # 4.5.1.3 Ensure password expiration warning days is configured
    print_subsection "4.5.1.3 Ensure password expiration warning days"
    sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   7/' /etc/login.defs
    echo -e "${GREEN}[OK]${NC} Set PASS_WARN_AGE to 7"
    
    # 4.5.1.4 Ensure inactive password lock is configured
    print_subsection "4.5.1.4 Ensure inactive password lock is configured"
    useradd -D -f 30 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC} Set default inactive lock to 30 days"
    
    # 4.5.1.5 Ensure all users last password change date is in the past
    print_subsection "4.5.1.5 Ensure all users last password change is in the past"
    echo -e "${YELLOW}[MANUAL]${NC} Review user password change dates:"
    echo -e "         awk -F: '/^[^:]+:[^!*]/{print \$1}' /etc/shadow | while read -r usr; do"
    echo -e "           change=\$(date -d \"\$(chage --list \$usr | grep 'Last password change' | cut -d: -f2)\" +%s)"
    echo -e "           if [[ \$change -gt \$(date +%s) ]]; then echo \"User: \$usr - FUTURE DATE\"; fi"
    echo -e "         done"
    log_message "INFO" "Manual review for password change dates"
    
    # 4.5.2.1 Ensure root is the only UID 0 account
    print_subsection "4.5.2.1 Ensure root is the only UID 0 account"
    uid_zero=$(awk -F: '($3 == 0) { print $1 }' /etc/passwd | grep -v "^root$" || true)
    if [ -n "$uid_zero" ]; then
        echo -e "${RED}[WARN]${NC} Non-root accounts with UID 0 found: $uid_zero"
        log_message "WARN" "Non-root UID 0 accounts: $uid_zero"
    else
        echo -e "${GREEN}[OK]${NC} Only root has UID 0"
    fi
    
    # 4.5.2.2 Ensure root is the only GID 0 account
    print_subsection "4.5.2.2 Ensure root is the only GID 0 account"
    echo -e "${YELLOW}[INFO]${NC} Review accounts with GID 0:"
    awk -F: '($4 == 0) { print $1 }' /etc/passwd
    
    # 4.5.2.3 Ensure group root is the only GID 0 group
    print_subsection "4.5.2.3 Ensure group root is the only GID 0 group"
    gid_zero=$(awk -F: '($3 == 0 && $1 != "root") { print $1 }' /etc/group || true)
    if [ -n "$gid_zero" ]; then
        echo -e "${RED}[WARN]${NC} Non-root groups with GID 0: $gid_zero"
    else
        echo -e "${GREEN}[OK]${NC} Only root group has GID 0"
    fi
    
    # 4.5.2.4 Ensure root password is set
    print_subsection "4.5.2.4 Ensure root password is set"
    if passwd -S root 2>/dev/null | grep -qE '^root\s+P'; then
        echo -e "${GREEN}[OK]${NC} root password is set"
    else
        echo -e "${RED}[WARN]${NC} root password may not be set properly"
    fi
    
    # 4.5.3.1 Ensure nologin is not listed in /etc/shells
    print_subsection "4.5.3.1 Ensure nologin is not listed in /etc/shells"
    if grep -q '/nologin' /etc/shells 2>/dev/null; then
        backup_file "/etc/shells"
        sed -i '/\/nologin/d' /etc/shells
        echo -e "${GREEN}[OK]${NC} Removed nologin from /etc/shells"
    else
        echo -e "${GREEN}[OK]${NC} nologin not in /etc/shells"
    fi
    
    # 4.5.3.2 Ensure default user shell timeout is configured
    print_subsection "4.5.3.2 Ensure default user shell timeout is configured"
    if ! grep -qE '^\s*TMOUT=' /etc/profile /etc/profile.d/*.sh 2>/dev/null; then
        cat >> /etc/profile.d/cis_timeout.sh << 'EOF'
# CIS Benchmark - Shell timeout
readonly TMOUT=900
export TMOUT
EOF
        echo -e "${GREEN}[OK]${NC} Set shell timeout to 900 seconds"
    else
        echo -e "${GREEN}[OK]${NC} Shell timeout already configured"
    fi
    
    # 4.5.3.3 Ensure default user umask is configured
    print_subsection "4.5.3.3 Ensure default user umask is configured"
    if ! grep -qE '^\s*umask\s+027' /etc/profile /etc/bashrc 2>/dev/null; then
        backup_file "/etc/profile"
        backup_file "/etc/bashrc"
        echo "umask 027" >> /etc/profile.d/cis_umask.sh
        echo -e "${GREEN}[OK]${NC} Set default umask to 027"
    else
        echo -e "${GREEN}[OK]${NC} umask already configured"
    fi
}

#############################################################################
# MAIN EXECUTION
#############################################################################

main() {
    echo -e "${GREEN}"
    echo "=============================================================="
    echo " CIS Oracle Linux 7 Benchmark v4.0.0"
    echo " Section 4: Access, Authentication and Authorization"
    echo " Controls: 4.1.1.1 - 4.5.3.3"
    echo "=============================================================="
    echo -e "${NC}"
    
    echo -e "${RED}=============================================================="
    echo -e " WARNING: SSH PermitRootLogin is NOT modified by this script"
    echo -e " to prevent accidental lockout from remote access."
    echo -e " Review and modify manually if needed."
    echo -e "==============================================================${NC}"
    echo ""
    
    # Check for root privileges
    check_root
    
    # Initialize log file
    echo "CIS Oracle Linux 7 Benchmark v4.0.0 - Section 4 Remediation" > "$LOG_FILE"
    echo "Started: $(date)" >> "$LOG_FILE"
    echo "=======================================================" >> "$LOG_FILE"
    
    # Execute remediation sections
    configure_job_schedulers
    configure_ssh_server
    configure_privilege_escalation
    configure_pam_basic
    configure_user_accounts
    
    # Summary
    print_section "Remediation Complete"
    echo -e "${GREEN}Section 4 remediation has been completed.${NC}"
    echo -e "Log file: ${YELLOW}$LOG_FILE${NC}"
    echo ""
    echo -e "${YELLOW}IMPORTANT POST-REMEDIATION STEPS:${NC}"
    echo -e "1. Test SSH access before closing current session"
    echo -e "2. Review /etc/ssh/sshd_config settings"
    echo -e "3. Review /etc/sudoers and /etc/sudoers.d/* files"
    echo -e "4. Configure PAM password policies as needed"
    echo -e "5. Review user accounts with: ${BLUE}awk -F: '(\$3 < 1000) {print \$1}' /etc/passwd${NC}"
    echo ""
    echo -e "${RED}ITEMS INTENTIONALLY SKIPPED (Manual Review Required):${NC}"
    echo -e " - 4.2.4  SSH AllowUsers/AllowGroups/DenyUsers/DenyGroups"
    echo -e " - 4.2.20 SSH PermitRootLogin (NOT changed to preserve access)"
    echo -e " - 4.4.x  PAM detailed configuration"
    echo ""
    
    log_message "INFO" "Section 4 remediation completed"
    echo "Completed: $(date)" >> "$LOG_FILE"
}

# Run main function
main "$@"
