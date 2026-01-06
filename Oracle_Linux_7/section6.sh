#!/bin/bash
#############################################################################
# CIS Oracle Linux 7 Benchmark v4.0.0 - Section 6 Remediation Script
# System Maintenance
# Controls: 6.1 - 6.2
#############################################################################

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log file
LOG_FILE="/var/log/cis_section6_remediation_$(date +%Y%m%d_%H%M%S).log"

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

#############################################################################
# SECTION 6.1: System File Permissions
#############################################################################

configure_file_permissions() {
    print_section "6.1 System File Permissions"
    
    # 6.1.1 Ensure permissions on /etc/passwd are configured
    print_subsection "6.1.1 Configure /etc/passwd permissions"
    chown root:root /etc/passwd
    chmod u-x,go-wx /etc/passwd
    echo -e "${GREEN}[OK]${NC} /etc/passwd permissions set (644)"
    
    # 6.1.2 Ensure permissions on /etc/passwd- are configured
    print_subsection "6.1.2 Configure /etc/passwd- permissions"
    if [[ -f /etc/passwd- ]]; then
        chown root:root /etc/passwd-
        chmod u-x,go-wx /etc/passwd-
        echo -e "${GREEN}[OK]${NC} /etc/passwd- permissions set"
    fi
    
    # 6.1.3 Ensure permissions on /etc/group are configured
    print_subsection "6.1.3 Configure /etc/group permissions"
    chown root:root /etc/group
    chmod u-x,go-wx /etc/group
    echo -e "${GREEN}[OK]${NC} /etc/group permissions set (644)"
    
    # 6.1.4 Ensure permissions on /etc/group- are configured
    print_subsection "6.1.4 Configure /etc/group- permissions"
    if [[ -f /etc/group- ]]; then
        chown root:root /etc/group-
        chmod u-x,go-wx /etc/group-
        echo -e "${GREEN}[OK]${NC} /etc/group- permissions set"
    fi
    
    # 6.1.5 Ensure permissions on /etc/shadow are configured
    print_subsection "6.1.5 Configure /etc/shadow permissions"
    chown root:root /etc/shadow
    chmod 0000 /etc/shadow
    echo -e "${GREEN}[OK]${NC} /etc/shadow permissions set (0000)"
    
    # 6.1.6 Ensure permissions on /etc/shadow- are configured
    print_subsection "6.1.6 Configure /etc/shadow- permissions"
    if [[ -f /etc/shadow- ]]; then
        chown root:root /etc/shadow-
        chmod 0000 /etc/shadow-
        echo -e "${GREEN}[OK]${NC} /etc/shadow- permissions set"
    fi
    
    # 6.1.7 Ensure permissions on /etc/gshadow are configured
    print_subsection "6.1.7 Configure /etc/gshadow permissions"
    chown root:root /etc/gshadow
    chmod 0000 /etc/gshadow
    echo -e "${GREEN}[OK]${NC} /etc/gshadow permissions set (0000)"
    
    # 6.1.8 Ensure permissions on /etc/gshadow- are configured
    print_subsection "6.1.8 Configure /etc/gshadow- permissions"
    if [[ -f /etc/gshadow- ]]; then
        chown root:root /etc/gshadow-
        chmod 0000 /etc/gshadow-
        echo -e "${GREEN}[OK]${NC} /etc/gshadow- permissions set"
    fi
    
    # 6.1.9 Ensure permissions on /etc/shells are configured
    print_subsection "6.1.9 Configure /etc/shells permissions"
    chown root:root /etc/shells
    chmod u-x,go-wx /etc/shells
    echo -e "${GREEN}[OK]${NC} /etc/shells permissions set"
    
    # 6.1.10 Ensure world writable files and directories are secured
    print_subsection "6.1.10 Check world writable files"
    echo -e "${YELLOW}[INFO]${NC} Scanning for world-writable files..."
    local ww_files=$(find / -xdev -type f -perm -0002 2>/dev/null | head -20)
    if [[ -n "$ww_files" ]]; then
        echo -e "${YELLOW}[WARN]${NC} World-writable files found:"
        echo "$ww_files" | while read -r f; do
            echo "         $f"
            log_message "WARN" "World-writable file: $f"
        done
        echo -e "${YELLOW}[MANUAL]${NC} Review and fix world-writable files"
    else
        echo -e "${GREEN}[OK]${NC} No world-writable files found"
    fi
    
    # 6.1.11 Ensure no unowned files or directories exist
    print_subsection "6.1.11 Check unowned files"
    echo -e "${YELLOW}[INFO]${NC} Scanning for unowned files..."
    local unowned=$(find / -xdev \( -type f -o -type d \) -nouser 2>/dev/null | head -20)
    if [[ -n "$unowned" ]]; then
        echo -e "${YELLOW}[WARN]${NC} Unowned files found:"
        echo "$unowned" | while read -r f; do
            echo "         $f"
            log_message "WARN" "Unowned file: $f"
        done
        echo -e "${YELLOW}[MANUAL]${NC} Assign ownership to unowned files"
    else
        echo -e "${GREEN}[OK]${NC} No unowned files found"
    fi
    
    # 6.1.12 Ensure no ungrouped files or directories exist
    print_subsection "6.1.12 Check ungrouped files"
    echo -e "${YELLOW}[INFO]${NC} Scanning for ungrouped files..."
    local ungrouped=$(find / -xdev \( -type f -o -type d \) -nogroup 2>/dev/null | head -20)
    if [[ -n "$ungrouped" ]]; then
        echo -e "${YELLOW}[WARN]${NC} Ungrouped files found:"
        echo "$ungrouped" | while read -r f; do
            echo "         $f"
            log_message "WARN" "Ungrouped file: $f"
        done
        echo -e "${YELLOW}[MANUAL]${NC} Assign group to ungrouped files"
    else
        echo -e "${GREEN}[OK]${NC} No ungrouped files found"
    fi
    
    # 6.1.13 Ensure SUID and SGID files are reviewed
    print_subsection "6.1.13 Review SUID/SGID files"
    echo -e "${YELLOW}[INFO]${NC} Scanning for SUID/SGID files..."
    echo -e "${YELLOW}[MANUAL]${NC} Review SUID files:"
    find / -xdev -type f -perm -4000 2>/dev/null | head -20 | while read -r f; do
        echo "         SUID: $f"
    done
    
    echo -e "${YELLOW}[MANUAL]${NC} Review SGID files:"
    find / -xdev -type f -perm -2000 2>/dev/null | head -20 | while read -r f; do
        echo "         SGID: $f"
    done
    log_message "INFO" "SUID/SGID review required"
}

#############################################################################
# SECTION 6.2: Local User and Group Settings
#############################################################################

configure_user_settings() {
    print_section "6.2 Local User and Group Settings"
    
    # 6.2.1 Ensure accounts in /etc/passwd use shadowed passwords
    print_subsection "6.2.1 Verify shadowed passwords"
    local unshadowed=$(awk -F: '($2 != "x") {print $1}' /etc/passwd)
    if [[ -n "$unshadowed" ]]; then
        echo -e "${YELLOW}[WARN]${NC} Accounts not using shadow passwords:"
        echo "$unshadowed"
        log_message "WARN" "Unshadowed accounts found: $unshadowed"
        # Convert to shadow
        pwconv
        echo -e "${GREEN}[OK]${NC} Converted to shadow passwords"
    else
        echo -e "${GREEN}[OK]${NC} All accounts use shadowed passwords"
    fi
    
    # 6.2.2 Ensure /etc/shadow password fields are not empty
    print_subsection "6.2.2 Check empty password fields"
    local empty_pass=$(awk -F: '($2 == "") {print $1}' /etc/shadow 2>/dev/null)
    if [[ -n "$empty_pass" ]]; then
        echo -e "${RED}[FAIL]${NC} Accounts with empty passwords found:"
        echo "$empty_pass"
        log_message "WARN" "Empty password accounts: $empty_pass"
        echo -e "${YELLOW}[MANUAL]${NC} Lock these accounts or set passwords"
        # Lock accounts with empty passwords
        echo "$empty_pass" | while read -r user; do
            passwd -l "$user" 2>/dev/null || true
            echo "         Locked account: $user"
        done
    else
        echo -e "${GREEN}[OK]${NC} No accounts with empty passwords"
    fi
    
    # 6.2.3 Ensure all groups in /etc/passwd exist in /etc/group
    print_subsection "6.2.3 Verify groups exist"
    local missing_groups=false
    while IFS=: read -r user _ uid gid _ _ _; do
        if ! getent group "$gid" &>/dev/null; then
            echo -e "${YELLOW}[WARN]${NC} User $user has GID $gid that doesn't exist in /etc/group"
            log_message "WARN" "Missing group GID $gid for user $user"
            missing_groups=true
        fi
    done < /etc/passwd
    
    if [[ "$missing_groups" == "false" ]]; then
        echo -e "${GREEN}[OK]${NC} All groups in /etc/passwd exist in /etc/group"
    fi
    
    # 6.2.4 Ensure no duplicate UIDs exist
    print_subsection "6.2.4 Check duplicate UIDs"
    local dup_uids=$(cut -f3 -d":" /etc/passwd | sort -n | uniq -d)
    if [[ -n "$dup_uids" ]]; then
        echo -e "${RED}[FAIL]${NC} Duplicate UIDs found:"
        echo "$dup_uids" | while read -r uid; do
            awk -F: -v uid="$uid" '($3 == uid) {print "         UID " uid ": " $1}' /etc/passwd
        done
        log_message "WARN" "Duplicate UIDs: $dup_uids"
    else
        echo -e "${GREEN}[OK]${NC} No duplicate UIDs"
    fi
    
    # 6.2.5 Ensure no duplicate GIDs exist
    print_subsection "6.2.5 Check duplicate GIDs"
    local dup_gids=$(cut -f3 -d":" /etc/group | sort -n | uniq -d)
    if [[ -n "$dup_gids" ]]; then
        echo -e "${RED}[FAIL]${NC} Duplicate GIDs found:"
        echo "$dup_gids" | while read -r gid; do
            awk -F: -v gid="$gid" '($3 == gid) {print "         GID " gid ": " $1}' /etc/group
        done
        log_message "WARN" "Duplicate GIDs: $dup_gids"
    else
        echo -e "${GREEN}[OK]${NC} No duplicate GIDs"
    fi
    
    # 6.2.6 Ensure no duplicate user names exist
    print_subsection "6.2.6 Check duplicate usernames"
    local dup_users=$(cut -f1 -d":" /etc/passwd | sort | uniq -d)
    if [[ -n "$dup_users" ]]; then
        echo -e "${RED}[FAIL]${NC} Duplicate usernames found: $dup_users"
        log_message "WARN" "Duplicate usernames: $dup_users"
    else
        echo -e "${GREEN}[OK]${NC} No duplicate usernames"
    fi
    
    # 6.2.7 Ensure no duplicate group names exist
    print_subsection "6.2.7 Check duplicate group names"
    local dup_groups=$(cut -f1 -d":" /etc/group | sort | uniq -d)
    if [[ -n "$dup_groups" ]]; then
        echo -e "${RED}[FAIL]${NC} Duplicate group names found: $dup_groups"
        log_message "WARN" "Duplicate group names: $dup_groups"
    else
        echo -e "${GREEN}[OK]${NC} No duplicate group names"
    fi
    
    # 6.2.8 Ensure root PATH integrity
    print_subsection "6.2.8 Verify root PATH integrity"
    local path_issues=false
    
    # Check for empty entries
    if echo "$PATH" | grep -q '::'; then
        echo -e "${YELLOW}[WARN]${NC} Empty directory in PATH"
        path_issues=true
    fi
    
    # Check for trailing colon
    if echo "$PATH" | grep -q ':$'; then
        echo -e "${YELLOW}[WARN]${NC} Trailing colon in PATH"
        path_issues=true
    fi
    
    # Check for . in PATH
    if echo "$PATH" | grep -qE '(^|:)\.(:|$)'; then
        echo -e "${YELLOW}[WARN]${NC} Current directory (.) in PATH"
        path_issues=true
    fi
    
    # Check each directory in PATH
    IFS=':' read -ra path_dirs <<< "$PATH"
    for dir in "${path_dirs[@]}"; do
        if [[ -z "$dir" ]]; then
            continue
        fi
        if [[ ! -d "$dir" ]]; then
            echo -e "${YELLOW}[WARN]${NC} PATH contains non-existent directory: $dir"
            path_issues=true
        elif [[ -w "$dir" && ! -O "$dir" ]]; then
            echo -e "${YELLOW}[WARN]${NC} PATH contains group/world-writable directory: $dir"
            path_issues=true
        fi
    done
    
    if [[ "$path_issues" == "false" ]]; then
        echo -e "${GREEN}[OK]${NC} Root PATH integrity verified"
    fi
    
    # 6.2.9 Ensure root is the only UID 0 account
    print_subsection "6.2.9 Verify single UID 0"
    local uid0=$(awk -F: '($3 == 0) {print $1}' /etc/passwd)
    if [[ "$uid0" != "root" ]] || [[ $(echo "$uid0" | wc -l) -gt 1 ]]; then
        echo -e "${RED}[FAIL]${NC} Non-root UID 0 accounts found: $uid0"
        log_message "WARN" "UID 0 accounts: $uid0"
    else
        echo -e "${GREEN}[OK]${NC} Only root has UID 0"
    fi
    
    # 6.2.10 Ensure local interactive user home directories are configured
    print_subsection "6.2.10 Verify user home directories"
    awk -F: '($3 >= 1000 && $7 !~ /nologin|false/) {print $1 ":" $6}' /etc/passwd | while IFS=: read -r user home; do
        if [[ ! -d "$home" ]]; then
            echo -e "${YELLOW}[WARN]${NC} User $user has no home directory: $home"
            log_message "WARN" "Missing home directory for $user: $home"
        fi
    done
    echo -e "${GREEN}[OK]${NC} User home directories checked"
    
    # 6.2.11 Ensure local interactive user home directories are mode 750 or more restrictive
    print_subsection "6.2.11 Check home directory permissions"
    awk -F: '($3 >= 1000 && $7 !~ /nologin|false/) {print $1 ":" $6}' /etc/passwd | while IFS=: read -r user home; do
        if [[ -d "$home" ]]; then
            local perms=$(stat -L -c "%a" "$home" 2>/dev/null)
            if [[ -n "$perms" ]]; then
                # Check if more permissive than 750
                if [[ $((perms & 027)) -ne 0 ]]; then
                    echo -e "${YELLOW}[WARN]${NC} Home directory $home has permissions $perms (should be 750 or less)"
                    chmod g-w,o-rwx "$home" 2>/dev/null || true
                fi
            fi
        fi
    done
    echo -e "${GREEN}[OK]${NC} Home directory permissions reviewed"
    
    # 6.2.12 Ensure local interactive user dot files access is configured
    print_subsection "6.2.12 Check user dot files"
    awk -F: '($3 >= 1000 && $7 !~ /nologin|false/) {print $6}' /etc/passwd | while read -r home; do
        if [[ -d "$home" ]]; then
            find "$home" -maxdepth 1 -name ".*" -type f 2>/dev/null | while read -r dotfile; do
                chmod go-w "$dotfile" 2>/dev/null || true
            done
        fi
    done
    echo -e "${GREEN}[OK]${NC} User dot files permissions restricted"
    
    # 6.2.13 Ensure users' .netrc files are secured
    print_subsection "6.2.13 Check .netrc files"
    awk -F: '($3 >= 1000 && $7 !~ /nologin|false/) {print $6}' /etc/passwd | while read -r home; do
        if [[ -f "$home/.netrc" ]]; then
            echo -e "${YELLOW}[WARN]${NC} .netrc file found: $home/.netrc"
            chmod 600 "$home/.netrc" 2>/dev/null || true
            log_message "WARN" ".netrc found: $home/.netrc"
        fi
    done
    echo -e "${GREEN}[OK]${NC} .netrc files checked"
    
    # 6.2.14 Ensure users' .forward files are secured
    print_subsection "6.2.14 Check .forward files"
    awk -F: '($3 >= 1000 && $7 !~ /nologin|false/) {print $6}' /etc/passwd | while read -r home; do
        if [[ -f "$home/.forward" ]]; then
            echo -e "${YELLOW}[WARN]${NC} .forward file found: $home/.forward"
            chmod 600 "$home/.forward" 2>/dev/null || true
            log_message "WARN" ".forward found: $home/.forward"
        fi
    done
    echo -e "${GREEN}[OK]${NC} .forward files checked"
    
    # 6.2.15 Ensure users' .rhosts files are secured
    print_subsection "6.2.15 Remove .rhosts files"
    awk -F: '($3 >= 1000 && $7 !~ /nologin|false/) {print $6}' /etc/passwd | while read -r home; do
        if [[ -f "$home/.rhosts" ]]; then
            echo -e "${YELLOW}[WARN]${NC} .rhosts file found and removed: $home/.rhosts"
            rm -f "$home/.rhosts"
            log_message "INFO" "Removed .rhosts: $home/.rhosts"
        fi
    done
    echo -e "${GREEN}[OK]${NC} .rhosts files checked"
    
    # 6.2.16 Ensure no users have .shosts files
    print_subsection "6.2.16 Remove .shosts files"
    awk -F: '($3 >= 1000 && $7 !~ /nologin|false/) {print $6}' /etc/passwd | while read -r home; do
        if [[ -f "$home/.shosts" ]]; then
            echo -e "${YELLOW}[WARN]${NC} .shosts file found and removed: $home/.shosts"
            rm -f "$home/.shosts"
            log_message "INFO" "Removed .shosts: $home/.shosts"
        fi
    done
    echo -e "${GREEN}[OK]${NC} .shosts files checked"
}

#############################################################################
# MAIN EXECUTION
#############################################################################

main() {
    echo -e "${GREEN}"
    echo "=============================================================="
    echo " CIS Oracle Linux 7 Benchmark v4.0.0"
    echo " Section 6: System Maintenance"
    echo " Controls: 6.1 - 6.2"
    echo "=============================================================="
    echo -e "${NC}"
    
    # Check for root privileges
    check_root
    
    # Initialize log file
    echo "CIS Oracle Linux 7 Benchmark v4.0.0 - Section 6 Remediation" > "$LOG_FILE"
    echo "Started: $(date)" >> "$LOG_FILE"
    echo "=======================================================" >> "$LOG_FILE"
    
    # Execute remediation sections
    configure_file_permissions
    configure_user_settings
    
    # Summary
    print_section "Remediation Complete"
    echo -e "${GREEN}Section 6 remediation has been completed.${NC}"
    echo -e "Log file: ${YELLOW}$LOG_FILE${NC}"
    echo ""
    echo -e "${YELLOW}IMPORTANT POST-REMEDIATION STEPS:${NC}"
    echo -e "1. Review world-writable files and fix as needed"
    echo -e "2. Investigate unowned/ungrouped files"
    echo -e "3. Review SUID/SGID binaries for legitimacy"
    echo -e "4. Address any duplicate UID/GID issues"
    echo -e "5. Verify user home directory configurations"
    echo ""
    echo -e "${YELLOW}AUDIT COMMANDS:${NC}"
    echo -e "  World-writable files: ${BLUE}find / -xdev -type f -perm -0002${NC}"
    echo -e "  Unowned files: ${BLUE}find / -xdev -nouser${NC}"
    echo -e "  SUID files: ${BLUE}find / -xdev -type f -perm -4000${NC}"
    echo ""
    
    log_message "INFO" "Section 6 remediation completed"
    echo "Completed: $(date)" >> "$LOG_FILE"
}

# Run main function
main "$@"
