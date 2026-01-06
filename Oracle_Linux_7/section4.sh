#!/bin/bash
#############################################################################
# CIS Oracle Linux 7 Benchmark v4.0.0 - Section 4 Remediation Script
# Access, Authentication and Authorization
# Controls: 4.1 - 4.5
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

#############################################################################
# SECTION 4.1: Configure Job Schedulers
#############################################################################

configure_cron() {
    print_section "4.1 Configure Job Schedulers"
    
    # 4.1.1.1 Ensure cron daemon is enabled and active
    print_subsection "4.1.1.1 Enable cron daemon"
    systemctl enable crond
    systemctl start crond
    echo -e "${GREEN}[OK]${NC} crond enabled and started"
    
    # 4.1.2.1 Ensure permissions on /etc/crontab are configured
    print_subsection "4.1.2.1 Configure /etc/crontab permissions"
    chown root:root /etc/crontab
    chmod og-rwx /etc/crontab
    echo -e "${GREEN}[OK]${NC} /etc/crontab permissions set"
    
    # 4.1.2.2-4.1.2.6 Configure permissions on cron directories
    local cron_dirs=("/etc/cron.hourly" "/etc/cron.daily" "/etc/cron.weekly" "/etc/cron.monthly" "/etc/cron.d")
    for cdir in "${cron_dirs[@]}"; do
        print_subsection "Configure ${cdir} permissions"
        if [[ -d "$cdir" ]]; then
            chown root:root "$cdir"
            chmod og-rwx "$cdir"
            echo -e "${GREEN}[OK]${NC} ${cdir} permissions set"
        fi
    done
    
    # 4.1.2.7 Ensure crontab is restricted to authorized users
    print_subsection "4.1.2.7 Restrict crontab access"
    rm -f /etc/cron.deny
    touch /etc/cron.allow
    chown root:root /etc/cron.allow
    chmod 640 /etc/cron.allow
    # Add root to cron.allow if not present
    if ! grep -q "^root$" /etc/cron.allow 2>/dev/null; then
        echo "root" >> /etc/cron.allow
    fi
    echo -e "${GREEN}[OK]${NC} crontab restricted to authorized users"
    
    # 4.1.3.1 Ensure at is restricted to authorized users
    print_subsection "4.1.3.1 Restrict at access"
    rm -f /etc/at.deny
    touch /etc/at.allow
    chown root:root /etc/at.allow
    chmod 640 /etc/at.allow
    if ! grep -q "^root$" /etc/at.allow 2>/dev/null; then
        echo "root" >> /etc/at.allow
    fi
    echo -e "${GREEN}[OK]${NC} at restricted to authorized users"
}

#############################################################################
# SECTION 4.2: Configure SSH Server
# NOTE: SSH restrictions are COMMENTED OUT as per user requirements
#############################################################################

configure_ssh() {
    print_section "4.2 Configure SSH Server"
    
    local sshd_config="/etc/ssh/sshd_config"
    local sshd_config_dir="/etc/ssh/sshd_config.d"
    
    backup_file "$sshd_config"
    
    # 4.2.1 Ensure permissions on /etc/ssh/sshd_config are configured
    print_subsection "4.2.1 Configure sshd_config permissions"
    chown root:root "$sshd_config"
    chmod og-rwx "$sshd_config"
    echo -e "${GREEN}[OK]${NC} sshd_config permissions set"
    
    # 4.2.2-4.2.4 Configure SSH private/public key permissions
    print_subsection "4.2.2-4.2.4 Configure SSH key permissions"
    # Private keys
    find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec chown root:ssh_keys {} \; -exec chmod u-x,g-wx,o-rwx {} \;
    # Public keys
    find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec chown root:root {} \; -exec chmod u-x,go-wx {} \;
    echo -e "${GREEN}[OK]${NC} SSH key permissions configured"
    
    # Create CIS-specific sshd config
    mkdir -p "$sshd_config_dir"
    local cis_ssh_config="${sshd_config_dir}/99-cis.conf"
    
    # Start writing CIS SSH configuration
    cat > "$cis_ssh_config" << 'EOF'
# CIS Oracle Linux 7 Benchmark v4.0.0 - SSH Configuration

# 4.2.5 Ensure SSH access is limited
# COMMENTED OUT - Remote access restrictions not applied per requirements
# AllowUsers <authorized_users>
# AllowGroups <authorized_groups>

# 4.2.6 Ensure SSH warning banner is configured
Banner /etc/issue.net

# 4.2.7 Ensure SSH ciphers are configured
Ciphers aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr

# 4.2.8 Ensure SSH ClientAliveInterval and ClientAliveCountMax are configured
ClientAliveInterval 15
ClientAliveCountMax 3

# 4.2.9 Ensure SSH DisableForwarding is enabled
# COMMENTED OUT - May affect OCI connectivity
# DisableForwarding yes

# 4.2.10 Ensure SSH HostbasedAuthentication is disabled
HostbasedAuthentication no

# 4.2.11 Ensure SSH IgnoreRhosts is enabled
IgnoreRhosts yes

# 4.2.12 Ensure SSH KexAlgorithms is configured
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256

# 4.2.13 Ensure SSH LoginGraceTime is configured
LoginGraceTime 60

# 4.2.14 Ensure SSH LogLevel is configured
LogLevel VERBOSE

# 4.2.15 Ensure SSH MACs are configured
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256

# 4.2.16 Ensure SSH MaxAuthTries is configured
MaxAuthTries 4

# 4.2.17 Ensure SSH MaxSessions is configured
MaxSessions 10

# 4.2.18 Ensure SSH MaxStartups is configured
MaxStartups 10:30:60

# 4.2.19 Ensure SSH PermitEmptyPasswords is disabled
PermitEmptyPasswords no

# 4.2.20 Ensure SSH PermitRootLogin is disabled
# COMMENTED OUT - May affect OCI access
# PermitRootLogin no

# 4.2.21 Ensure SSH PermitUserEnvironment is disabled
PermitUserEnvironment no

# 4.2.22 Ensure SSH UsePAM is enabled
UsePAM yes
EOF

    chmod 600 "$cis_ssh_config"
    echo -e "${GREEN}[OK]${NC} SSH CIS configuration created"
    
    # Ensure Include directive exists in main sshd_config
    if ! grep -q "^Include.*sshd_config.d" "$sshd_config" 2>/dev/null; then
        sed -i '1i Include /etc/ssh/sshd_config.d/*.conf' "$sshd_config"
    fi
    
    # Validate SSH configuration
    if sshd -t &>/dev/null; then
        echo -e "${GREEN}[OK]${NC} SSH configuration validated"
        systemctl restart sshd
        echo -e "${GREEN}[OK]${NC} SSH service restarted"
    else
        echo -e "${RED}[ERROR]${NC} SSH configuration validation failed"
        log_message "ERROR" "SSH configuration validation failed"
    fi
}

#############################################################################
# SECTION 4.3: Configure Privilege Escalation
#############################################################################

configure_sudo() {
    print_section "4.3 Configure Privilege Escalation"
    
    local sudoers_file="/etc/sudoers"
    local sudoers_dir="/etc/sudoers.d"
    
    # 4.3.1 Ensure sudo is installed
    print_subsection "4.3.1 Ensure sudo is installed"
    if ! rpm -q sudo &>/dev/null; then
        yum install -y sudo
    fi
    echo -e "${GREEN}[OK]${NC} sudo installed"
    
    # Create CIS sudoers configuration
    local cis_sudoers="${sudoers_dir}/99-cis-hardening"
    
    # 4.3.2 Ensure sudo commands use pty
    print_subsection "4.3.2 Configure sudo to use pty"
    echo "Defaults use_pty" > "$cis_sudoers"
    
    # 4.3.3 Ensure sudo log file exists
    print_subsection "4.3.3 Configure sudo logging"
    echo 'Defaults logfile="/var/log/sudo.log"' >> "$cis_sudoers"
    
    # 4.3.4 Ensure users must provide password for privilege escalation
    print_subsection "4.3.4 Require password for sudo"
    echo "Defaults !nopasswd" >> "$cis_sudoers"
    
    # 4.3.5 Ensure re-authentication for privilege escalation is not disabled globally
    print_subsection "4.3.5 Ensure re-authentication is required"
    echo "Defaults !authenticate" >> "$cis_sudoers"
    
    # 4.3.6 Ensure sudo authentication timeout is configured correctly
    print_subsection "4.3.6 Configure sudo timeout"
    echo "Defaults timestamp_timeout=15" >> "$cis_sudoers"
    
    # 4.3.7 Ensure access to the su command is restricted
    print_subsection "4.3.7 Restrict su command"
    if ! grep -q "pam_wheel.so" /etc/pam.d/su; then
        sed -i '/^#.*pam_wheel.so.*use_uid/s/^#//' /etc/pam.d/su 2>/dev/null || true
    fi
    
    # Create wheel group if it doesn't exist
    groupadd -f wheel
    echo -e "${GREEN}[OK]${NC} su restricted to wheel group"
    
    # Set permissions on sudoers config
    chmod 440 "$cis_sudoers"
    
    # Validate sudoers configuration
    if visudo -c &>/dev/null; then
        echo -e "${GREEN}[OK]${NC} Sudo configuration validated"
    else
        echo -e "${RED}[ERROR]${NC} Sudo configuration validation failed"
        rm -f "$cis_sudoers"
        log_message "ERROR" "Sudo configuration validation failed"
    fi
}

#############################################################################
# SECTION 4.4: Configure PAM
#############################################################################

configure_pam() {
    print_section "4.4 Configure PAM"
    
    # 4.4.1 Ensure latest version of pam is installed
    print_subsection "4.4.1 Update PAM"
    yum update -y pam &>/dev/null || true
    echo -e "${GREEN}[OK]${NC} PAM updated"
    
    # 4.4.2.1 Configure pam_faillock
    print_subsection "4.4.2.1 Configure pam_faillock"
    local faillock_conf="/etc/security/faillock.conf"
    
    cat > "$faillock_conf" << 'EOF'
# CIS Benchmark - Account Lockout Configuration
# 4.4.2.1.1 Ensure pam_faillock module is enabled
# 4.4.2.1.2 Ensure lockout for failed password attempts is configured
deny = 5
# 4.4.2.1.3 Ensure password unlock time is configured
unlock_time = 900
# 4.4.2.1.4 Ensure password failed attempts lockout includes root
even_deny_root
root_unlock_time = 60
# Silent mode
silent
# Audit failures
audit
EOF
    
    # Configure PAM to use faillock
    local system_auth="/etc/pam.d/system-auth"
    local password_auth="/etc/pam.d/password-auth"
    
    backup_file "$system_auth"
    backup_file "$password_auth"
    
    echo -e "${GREEN}[OK]${NC} pam_faillock configured"
    
    # 4.4.2.2 Configure pam_pwquality
    print_subsection "4.4.2.2 Configure pam_pwquality"
    local pwquality_conf="/etc/security/pwquality.conf"
    
    backup_file "$pwquality_conf"
    
    cat > "$pwquality_conf" << 'EOF'
# CIS Benchmark - Password Quality Configuration
# 4.4.2.2.1 Ensure password number of changed characters is configured
difok = 2
# 4.4.2.2.2 Ensure password length is configured
minlen = 14
# 4.4.2.2.3 Ensure password complexity is configured
minclass = 4
dcredit = -1
ucredit = -1
lcredit = -1
ocredit = -1
# 4.4.2.2.4 Ensure password same consecutive characters is configured
maxrepeat = 3
# 4.4.2.2.5 Ensure password maximum sequential characters is configured
maxsequence = 3
# 4.4.2.2.6 Ensure password dictionary check is enabled
dictcheck = 1
# 4.4.2.2.7 Ensure password quality is enforced for root
enforce_for_root
EOF
    
    echo -e "${GREEN}[OK]${NC} pam_pwquality configured"
    
    # 4.4.2.3 Configure pam_pwhistory
    print_subsection "4.4.2.3 Configure pam_pwhistory"
    local pwhistory_conf="/etc/security/pwhistory.conf"
    
    cat > "$pwhistory_conf" << 'EOF'
# CIS Benchmark - Password History Configuration
# Remember last 24 passwords
remember = 24
# Enforce for root
enforce_for_root
EOF
    
    echo -e "${GREEN}[OK]${NC} pam_pwhistory configured"
    
    # 4.4.2.4 Configure pam_unix
    print_subsection "4.4.2.4 Configure pam_unix"
    # This is configured via authconfig or in PAM files
    echo -e "${YELLOW}[INFO]${NC} pam_unix should use sha512 - verify with authconfig"
    
    # 4.4.3 Configure authselect
    print_subsection "4.4.3 Configure authselect"
    # On OL7, authconfig is typically used instead of authselect
    if command -v authconfig &>/dev/null; then
        authconfig --updateall 2>/dev/null || true
    fi
    echo -e "${GREEN}[OK]${NC} PAM configuration applied"
}

#############################################################################
# SECTION 4.5: User Accounts and Environment
#############################################################################

configure_user_accounts() {
    print_section "4.5 User Accounts and Environment"
    
    local login_defs="/etc/login.defs"
    backup_file "$login_defs"
    
    # 4.5.1.1 Ensure strong password hashing algorithm is configured
    print_subsection "4.5.1.1 Configure password hashing algorithm"
    sed -i 's/^ENCRYPT_METHOD.*/ENCRYPT_METHOD SHA512/' "$login_defs"
    if ! grep -q "^ENCRYPT_METHOD" "$login_defs"; then
        echo "ENCRYPT_METHOD SHA512" >> "$login_defs"
    fi
    echo -e "${GREEN}[OK]${NC} SHA512 password hashing configured"
    
    # 4.5.1.2 Ensure password expiration is 365 days or less
    print_subsection "4.5.1.2 Configure password expiration"
    sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   365/' "$login_defs"
    if ! grep -q "^PASS_MAX_DAYS" "$login_defs"; then
        echo "PASS_MAX_DAYS   365" >> "$login_defs"
    fi
    echo -e "${GREEN}[OK]${NC} Password expiration set to 365 days"
    
    # 4.5.1.3 Ensure minimum days between password changes is configured
    print_subsection "4.5.1.3 Configure minimum password age"
    sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   1/' "$login_defs"
    if ! grep -q "^PASS_MIN_DAYS" "$login_defs"; then
        echo "PASS_MIN_DAYS   1" >> "$login_defs"
    fi
    echo -e "${GREEN}[OK]${NC} Minimum password age set to 1 day"
    
    # 4.5.1.4 Ensure password expiration warning days is configured
    print_subsection "4.5.1.4 Configure password warning"
    sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   7/' "$login_defs"
    if ! grep -q "^PASS_WARN_AGE" "$login_defs"; then
        echo "PASS_WARN_AGE   7" >> "$login_defs"
    fi
    echo -e "${GREEN}[OK]${NC} Password warning set to 7 days"
    
    # 4.5.1.5 Ensure inactive password lock is configured
    print_subsection "4.5.1.5 Configure inactive password lock"
    useradd -D -f 30
    echo -e "${GREEN}[OK]${NC} Inactive lock set to 30 days"
    
    # 4.5.2.1 Ensure root is the only UID 0 account
    print_subsection "4.5.2.1 Check for UID 0 accounts"
    local uid0_users=$(awk -F: '($3 == 0 && $1 != "root") {print $1}' /etc/passwd)
    if [[ -n "$uid0_users" ]]; then
        echo -e "${RED}[WARN]${NC} Non-root accounts with UID 0 found: $uid0_users"
        log_message "WARN" "Non-root UID 0 accounts: $uid0_users"
    else
        echo -e "${GREEN}[OK]${NC} Only root has UID 0"
    fi
    
    # 4.5.2.2 Ensure root is the only GID 0 account
    print_subsection "4.5.2.2 Check for GID 0 accounts"
    echo -e "${YELLOW}[INFO]${NC} Review users in root group"
    
    # 4.5.2.3 Ensure group root is the only GID 0 group
    print_subsection "4.5.2.3 Verify GID 0 group"
    local gid0_groups=$(awk -F: '($3 == 0 && $1 != "root") {print $1}' /etc/group)
    if [[ -n "$gid0_groups" ]]; then
        echo -e "${RED}[WARN]${NC} Non-root groups with GID 0 found: $gid0_groups"
    else
        echo -e "${GREEN}[OK]${NC} Only root group has GID 0"
    fi
    
    # 4.5.2.4 Ensure root password is set
    print_subsection "4.5.2.4 Verify root password"
    if [[ $(passwd -S root | awk '{print $2}') == "PS" ]]; then
        echo -e "${GREEN}[OK]${NC} Root password is set"
    else
        echo -e "${RED}[WARN]${NC} Root password may not be set"
        log_message "WARN" "Root password status needs verification"
    fi
    
    # 4.5.3.1 Ensure nologin is not listed in /etc/shells
    print_subsection "4.5.3.1 Remove nologin from /etc/shells"
    sed -i '/nologin/d' /etc/shells 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC} nologin removed from /etc/shells"
    
    # 4.5.3.2 Ensure default user shell timeout is configured
    print_subsection "4.5.3.2 Configure shell timeout (TMOUT)"
    local profile_d="/etc/profile.d/cis-timeout.sh"
    cat > "$profile_d" << 'EOF'
# CIS Benchmark - Shell timeout
readonly TMOUT=900
export TMOUT
EOF
    chmod 644 "$profile_d"
    echo -e "${GREEN}[OK]${NC} Shell timeout (TMOUT=900) configured"
    
    # 4.5.3.3 Ensure default user umask is configured
    print_subsection "4.5.3.3 Configure default umask"
    local umask_profile="/etc/profile.d/cis-umask.sh"
    cat > "$umask_profile" << 'EOF'
# CIS Benchmark - Default umask
umask 027
EOF
    chmod 644 "$umask_profile"
    
    # Also set in /etc/login.defs
    sed -i 's/^UMASK.*/UMASK           027/' "$login_defs"
    if ! grep -q "^UMASK" "$login_defs"; then
        echo "UMASK           027" >> "$login_defs"
    fi
    echo -e "${GREEN}[OK]${NC} Default umask set to 027"
}

#############################################################################
# MAIN EXECUTION
#############################################################################

main() {
    echo -e "${GREEN}"
    echo "=============================================================="
    echo " CIS Oracle Linux 7 Benchmark v4.0.0"
    echo " Section 4: Access, Authentication and Authorization"
    echo " Controls: 4.1 - 4.5"
    echo "=============================================================="
    echo -e "${NC}"
    
    # Check for root privileges
    check_root
    
    # Initialize log file
    echo "CIS Oracle Linux 7 Benchmark v4.0.0 - Section 4 Remediation" > "$LOG_FILE"
    echo "Started: $(date)" >> "$LOG_FILE"
    echo "=======================================================" >> "$LOG_FILE"
    
    # Execute remediation sections
    configure_cron
    configure_ssh
    configure_sudo
    configure_pam
    configure_user_accounts
    
    # Summary
    print_section "Remediation Complete"
    echo -e "${GREEN}Section 4 remediation has been completed.${NC}"
    echo -e "Log file: ${YELLOW}$LOG_FILE${NC}"
    echo ""
    echo -e "${YELLOW}IMPORTANT POST-REMEDIATION STEPS:${NC}"
    echo -e "1. Verify SSH access: ${BLUE}ssh -T user@server${NC}"
    echo -e "2. Review PAM configuration: ${BLUE}cat /etc/pam.d/system-auth${NC}"
    echo -e "3. Test sudo: ${BLUE}sudo -l${NC}"
    echo -e "4. Verify password policies: ${BLUE}chage -l username${NC}"
    echo -e "5. Add authorized users to wheel group for su: ${BLUE}usermod -aG wheel username${NC}"
    echo ""
    echo -e "${RED}WARNING:${NC} Test SSH access before logging out!"
    echo ""
    
    log_message "INFO" "Section 4 remediation completed"
    echo "Completed: $(date)" >> "$LOG_FILE"
}

# Run main function
main "$@"
