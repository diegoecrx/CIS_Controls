#!/bin/bash
#############################################################################
# CIS Oracle Linux 7 Benchmark v4.0.0 - Section 6 Remediation Script
# System Maintenance
# Controls: 6.1.1 - 6.2.11
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

# Function to backup a file before modification
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        cp -p "$file" "${file}.bak.$(date +%Y%m%d_%H%M%S)"
        log_message "INFO" "Backed up $file"
    fi
}

#############################################################################
# SECTION 6.1: System File Permissions
#############################################################################

configure_system_file_permissions() {
    print_section "6.1 System File Permissions"
    
    # 6.1.1 Ensure permissions on /etc/passwd are configured
    print_subsection "6.1.1 Ensure permissions on /etc/passwd are configured"
    chmod u-x,go-wx /etc/passwd
    chown root:root /etc/passwd
    echo -e "${GREEN}[OK]${NC} Secured /etc/passwd (mode 644)"
    
    # 6.1.2 Ensure permissions on /etc/passwd- are configured
    print_subsection "6.1.2 Ensure permissions on /etc/passwd- are configured"
    if [[ -f /etc/passwd- ]]; then
        chmod u-x,go-wx /etc/passwd-
        chown root:root /etc/passwd-
        echo -e "${GREEN}[OK]${NC} Secured /etc/passwd- (mode 644)"
    else
        echo -e "${YELLOW}[SKIP]${NC} /etc/passwd- does not exist"
    fi
    
    # 6.1.3 Ensure permissions on /etc/group are configured
    print_subsection "6.1.3 Ensure permissions on /etc/group are configured"
    chmod u-x,go-wx /etc/group
    chown root:root /etc/group
    echo -e "${GREEN}[OK]${NC} Secured /etc/group (mode 644)"
    
    # 6.1.4 Ensure permissions on /etc/group- are configured
    print_subsection "6.1.4 Ensure permissions on /etc/group- are configured"
    if [[ -f /etc/group- ]]; then
        chmod u-x,go-wx /etc/group-
        chown root:root /etc/group-
        echo -e "${GREEN}[OK]${NC} Secured /etc/group- (mode 644)"
    else
        echo -e "${YELLOW}[SKIP]${NC} /etc/group- does not exist"
    fi
    
    # 6.1.5 Ensure permissions on /etc/shadow are configured
    print_subsection "6.1.5 Ensure permissions on /etc/shadow are configured"
    chmod 0000 /etc/shadow
    chown root:root /etc/shadow
    echo -e "${GREEN}[OK]${NC} Secured /etc/shadow (mode 000)"
    
    # 6.1.6 Ensure permissions on /etc/shadow- are configured
    print_subsection "6.1.6 Ensure permissions on /etc/shadow- are configured"
    if [[ -f /etc/shadow- ]]; then
        chmod 0000 /etc/shadow-
        chown root:root /etc/shadow-
        echo -e "${GREEN}[OK]${NC} Secured /etc/shadow- (mode 000)"
    else
        echo -e "${YELLOW}[SKIP]${NC} /etc/shadow- does not exist"
    fi
    
    # 6.1.7 Ensure permissions on /etc/gshadow are configured
    print_subsection "6.1.7 Ensure permissions on /etc/gshadow are configured"
    chmod 0000 /etc/gshadow
    chown root:root /etc/gshadow
    echo -e "${GREEN}[OK]${NC} Secured /etc/gshadow (mode 000)"
    
    # 6.1.8 Ensure permissions on /etc/gshadow- are configured
    print_subsection "6.1.8 Ensure permissions on /etc/gshadow- are configured"
    if [[ -f /etc/gshadow- ]]; then
        chmod 0000 /etc/gshadow-
        chown root:root /etc/gshadow-
        echo -e "${GREEN}[OK]${NC} Secured /etc/gshadow- (mode 000)"
    else
        echo -e "${YELLOW}[SKIP]${NC} /etc/gshadow- does not exist"
    fi
    
    # 6.1.9 Ensure permissions on /etc/shells are configured
    print_subsection "6.1.9 Ensure permissions on /etc/shells are configured"
    if [[ -f /etc/shells ]]; then
        chmod u-x,go-wx /etc/shells
        chown root:root /etc/shells
        echo -e "${GREEN}[OK]${NC} Secured /etc/shells (mode 644)"
    fi
    
    # 6.1.10 Ensure permissions on /etc/security/opasswd are configured
    print_subsection "6.1.10 Ensure permissions on /etc/security/opasswd are configured"
    if [[ -e "/etc/security/opasswd" ]]; then
        chmod u-x,go-rwx /etc/security/opasswd
        chown root:root /etc/security/opasswd
        echo -e "${GREEN}[OK]${NC} Secured /etc/security/opasswd (mode 600)"
    else
        echo -e "${YELLOW}[SKIP]${NC} /etc/security/opasswd does not exist"
    fi
    if [[ -e "/etc/security/opasswd.old" ]]; then
        chmod u-x,go-rwx /etc/security/opasswd.old
        chown root:root /etc/security/opasswd.old
        echo -e "${GREEN}[OK]${NC} Secured /etc/security/opasswd.old (mode 600)"
    fi
}

check_world_writable_files() {
    print_section "6.1.11 World Writable Files and Directories"
    
    # 6.1.11 Ensure world writable files and directories are secured
    print_subsection "6.1.11 Ensure world writable files and directories are secured"
    echo -e "${YELLOW}[INFO]${NC} Scanning for world writable files..."
    
    local ww_count=0
    local dir_count=0
    
    # Find world writable files (excluding typical system directories)
    while IFS= read -r -d $'\0' file; do
        if [[ -f "$file" ]]; then
            ((ww_count++))
            echo -e "  ${RED}[WW FILE]${NC} $file"
            log_message "WARN" "World writable file: $file"
            # Remove world write permission
            chmod o-w "$file" 2>/dev/null || true
        fi
    done < <(find / \( -path "/run/user/*" -o -path "/proc/*" -o -path "*/containerd/*" -o -path "*/kubelet/pods/*" -o -path "/sys/*" -o -path "/snap/*" \) -prune -o -type f -perm -0002 -print0 2>/dev/null)
    
    # Find world writable directories without sticky bit
    while IFS= read -r -d $'\0' dir; do
        if [[ -d "$dir" ]]; then
            local mode=$(stat -c %a "$dir" 2>/dev/null)
            if [[ ! $((mode & 01000)) -gt 0 ]]; then
                ((dir_count++))
                echo -e "  ${RED}[WW DIR]${NC} $dir (no sticky bit)"
                log_message "WARN" "World writable directory without sticky bit: $dir"
                # Add sticky bit
                chmod a+t "$dir" 2>/dev/null || true
            fi
        fi
    done < <(find / \( -path "/run/user/*" -o -path "/proc/*" -o -path "*/containerd/*" -o -path "*/kubelet/pods/*" -o -path "/sys/*" -o -path "/snap/*" \) -prune -o -type d -perm -0002 -print0 2>/dev/null)
    
    if [[ $ww_count -eq 0 && $dir_count -eq 0 ]]; then
        echo -e "${GREEN}[OK]${NC} No world writable files/directories found requiring action"
    else
        echo -e "${YELLOW}[FIXED]${NC} Remediated $ww_count world writable files and $dir_count directories"
    fi
}

check_unowned_files() {
    print_section "6.1.12 Unowned and Ungrouped Files"
    
    # 6.1.12 Ensure no unowned or ungrouped files or directories exist
    print_subsection "6.1.12 Ensure no unowned or ungrouped files or directories exist"
    echo -e "${YELLOW}[INFO]${NC} Scanning for unowned/ungrouped files..."
    
    local unowned_count=0
    local ungrouped_count=0
    
    # Find unowned files
    while IFS= read -r -d $'\0' file; do
        if [[ -e "$file" ]]; then
            ((unowned_count++))
            echo -e "  ${RED}[UNOWNED]${NC} $file"
            log_message "WARN" "Unowned file: $file"
        fi
    done < <(find / \( -path "/run/user/*" -o -path "/proc/*" -o -path "*/containerd/*" -o -path "*/kubelet/pods/*" -o -path "/sys/*" \) -prune -o -nouser -print0 2>/dev/null)
    
    # Find ungrouped files
    while IFS= read -r -d $'\0' file; do
        if [[ -e "$file" ]]; then
            ((ungrouped_count++))
            echo -e "  ${RED}[UNGROUPED]${NC} $file"
            log_message "WARN" "Ungrouped file: $file"
        fi
    done < <(find / \( -path "/run/user/*" -o -path "/proc/*" -o -path "*/containerd/*" -o -path "*/kubelet/pods/*" -o -path "/sys/*" \) -prune -o -nogroup -print0 2>/dev/null)
    
    if [[ $unowned_count -eq 0 && $ungrouped_count -eq 0 ]]; then
        echo -e "${GREEN}[OK]${NC} No unowned or ungrouped files found"
    else
        echo -e "${YELLOW}[MANUAL]${NC} Found $unowned_count unowned and $ungrouped_count ungrouped files"
        echo -e "         Review and assign appropriate ownership"
    fi
}

check_suid_sgid_files() {
    print_section "6.1.13 SUID and SGID Files"
    
    # 6.1.13 Ensure SUID and SGID files are reviewed
    print_subsection "6.1.13 Ensure SUID and SGID files are reviewed"
    echo -e "${YELLOW}[INFO]${NC} Scanning for SUID/SGID files..."
    
    local suid_count=0
    local sgid_count=0
    
    # Common legitimate SUID binaries
    local known_suid="/usr/bin/passwd /usr/bin/su /usr/bin/sudo /usr/bin/mount /usr/bin/umount /usr/bin/ping /usr/bin/chfn /usr/bin/chsh /usr/bin/newgrp /usr/bin/gpasswd /usr/sbin/unix_chkpwd /usr/sbin/pam_timestamp_check"
    
    echo -e "\n${BLUE}SUID Files:${NC}"
    while read -r mpname; do
        while IFS= read -r -d $'\0' file; do
            if [[ -f "$file" ]]; then
                local mode=$(stat -c %a "$file" 2>/dev/null)
                if [[ $((16#$mode & 04000)) -gt 0 ]]; then
                    ((suid_count++))
                    if echo "$known_suid" | grep -q "$file"; then
                        echo -e "  ${GREEN}[KNOWN]${NC} $file"
                    else
                        echo -e "  ${YELLOW}[REVIEW]${NC} $file"
                        log_message "WARN" "Unknown SUID file: $file"
                    fi
                fi
            fi
        done < <(find "$mpname" -xdev -not -path "/run/user/*" -type f -perm -4000 -print0 2>/dev/null)
    done <<< "$(findmnt -Derno target 2>/dev/null)"
    
    echo -e "\n${BLUE}SGID Files:${NC}"
    while read -r mpname; do
        while IFS= read -r -d $'\0' file; do
            if [[ -f "$file" ]]; then
                local mode=$(stat -c %a "$file" 2>/dev/null)
                if [[ $((16#$mode & 02000)) -gt 0 ]]; then
                    ((sgid_count++))
                    echo -e "  ${YELLOW}[REVIEW]${NC} $file"
                    log_message "INFO" "SGID file: $file"
                fi
            fi
        done < <(find "$mpname" -xdev -not -path "/run/user/*" -type f -perm -2000 -print0 2>/dev/null)
    done <<< "$(findmnt -Derno target 2>/dev/null)"
    
    echo -e "\n${YELLOW}[MANUAL]${NC} Review $suid_count SUID and $sgid_count SGID files for legitimacy"
}

audit_system_file_permissions() {
    print_section "6.1.14 Audit System File Permissions"
    
    # 6.1.14 Audit system file permissions
    print_subsection "6.1.14 Audit system file permissions"
    echo -e "${YELLOW}[MANUAL]${NC} Run the following command to audit package file permissions:"
    echo -e "         ${BLUE}rpm -Va --nomtime --nosize --nomd5 --nolinkto --noconfig --noghost${NC}"
    echo -e "         This may take a long time to complete"
    log_message "INFO" "System file permissions audit is manual"
}

#############################################################################
# SECTION 6.2: User and Group Settings
#############################################################################

configure_user_group_settings() {
    print_section "6.2 User and Group Settings"
    
    # 6.2.1 Ensure accounts in /etc/passwd use shadowed passwords
    print_subsection "6.2.1 Ensure accounts in /etc/passwd use shadowed passwords"
    local unshadowed=$(awk -F: '($2 != "x" ) { print $1 }' /etc/passwd)
    if [[ -n "$unshadowed" ]]; then
        echo -e "${RED}[WARN]${NC} Accounts without shadowed passwords: $unshadowed"
        echo -e "         Running pwconv to migrate passwords..."
        pwconv
        echo -e "${GREEN}[OK]${NC} Ran pwconv"
    else
        echo -e "${GREEN}[OK]${NC} All accounts use shadowed passwords"
    fi
    
    # 6.2.2 Ensure /etc/shadow password fields are not empty
    print_subsection "6.2.2 Ensure /etc/shadow password fields are not empty"
    local empty_pass=$(awk -F: '($2 == "" ) { print $1 }' /etc/shadow)
    if [[ -n "$empty_pass" ]]; then
        echo -e "${RED}[WARN]${NC} Accounts with empty passwords:"
        for user in $empty_pass; do
            echo -e "         - $user"
            echo -e "         Locking account: $user"
            passwd -l "$user" 2>/dev/null || true
        done
        log_message "WARN" "Locked accounts with empty passwords: $empty_pass"
    else
        echo -e "${GREEN}[OK]${NC} No accounts have empty passwords"
    fi
    
    # 6.2.3 Ensure all groups in /etc/passwd exist in /etc/group
    print_subsection "6.2.3 Ensure all groups in /etc/passwd exist in /etc/group"
    local missing_groups=""
    for gid in $(cut -s -d: -f4 /etc/passwd | sort -u); do
        if ! grep -Pq -- "^.*?:[^:]*:$gid:" /etc/group; then
            missing_groups="$missing_groups $gid"
        fi
    done
    if [[ -n "$missing_groups" ]]; then
        echo -e "${RED}[WARN]${NC} Missing groups:$missing_groups"
        log_message "WARN" "Groups referenced in /etc/passwd but not in /etc/group:$missing_groups"
    else
        echo -e "${GREEN}[OK]${NC} All groups in /etc/passwd exist in /etc/group"
    fi
    
    # 6.2.4 Ensure no duplicate UIDs exist
    print_subsection "6.2.4 Ensure no duplicate UIDs exist"
    local dup_uids=$(cut -f3 -d":" /etc/passwd | sort -n | uniq -d)
    if [[ -n "$dup_uids" ]]; then
        echo -e "${RED}[WARN]${NC} Duplicate UIDs found:"
        for uid in $dup_uids; do
            local users=$(awk -F: -v uid="$uid" '($3 == uid) { print $1 }' /etc/passwd | xargs)
            echo -e "         UID $uid: $users"
        done
        log_message "WARN" "Duplicate UIDs: $dup_uids"
    else
        echo -e "${GREEN}[OK]${NC} No duplicate UIDs exist"
    fi
    
    # 6.2.5 Ensure no duplicate GIDs exist
    print_subsection "6.2.5 Ensure no duplicate GIDs exist"
    local dup_gids=$(cut -f3 -d":" /etc/group | sort -n | uniq -d)
    if [[ -n "$dup_gids" ]]; then
        echo -e "${RED}[WARN]${NC} Duplicate GIDs found:"
        for gid in $dup_gids; do
            local groups=$(awk -F: -v gid="$gid" '($3 == gid) { print $1 }' /etc/group | xargs)
            echo -e "         GID $gid: $groups"
        done
        log_message "WARN" "Duplicate GIDs: $dup_gids"
    else
        echo -e "${GREEN}[OK]${NC} No duplicate GIDs exist"
    fi
    
    # 6.2.6 Ensure no duplicate user names exist
    print_subsection "6.2.6 Ensure no duplicate user names exist"
    local dup_users=$(cut -f1 -d":" /etc/passwd | sort | uniq -d)
    if [[ -n "$dup_users" ]]; then
        echo -e "${RED}[WARN]${NC} Duplicate user names: $dup_users"
        log_message "WARN" "Duplicate user names: $dup_users"
    else
        echo -e "${GREEN}[OK]${NC} No duplicate user names exist"
    fi
    
    # 6.2.7 Ensure no duplicate group names exist
    print_subsection "6.2.7 Ensure no duplicate group names exist"
    local dup_groups=$(cut -f1 -d":" /etc/group | sort | uniq -d)
    if [[ -n "$dup_groups" ]]; then
        echo -e "${RED}[WARN]${NC} Duplicate group names: $dup_groups"
        log_message "WARN" "Duplicate group names: $dup_groups"
    else
        echo -e "${GREEN}[OK]${NC} No duplicate group names exist"
    fi
    
    # 6.2.8 Ensure root path integrity
    print_subsection "6.2.8 Ensure root path integrity"
    local root_path=$(sudo -Hiu root env 2>/dev/null | grep '^PATH' | cut -d= -f2)
    local path_issues=""
    
    # Check for empty directory, trailing colon, or current working directory
    if echo "$root_path" | grep -q "::"; then
        path_issues="$path_issues empty_dir"
    fi
    if echo "$root_path" | grep -Pq ":\s*$"; then
        path_issues="$path_issues trailing_colon"
    fi
    if echo "$root_path" | grep -Pq '(\s+|:)\.(:|\s*$)'; then
        path_issues="$path_issues current_dir"
    fi
    
    if [[ -n "$path_issues" ]]; then
        echo -e "${RED}[WARN]${NC} Root PATH issues:$path_issues"
        log_message "WARN" "Root PATH issues:$path_issues"
    else
        echo -e "${GREEN}[OK]${NC} Root PATH integrity verified"
    fi
    
    # 6.2.9 Ensure root is the only UID 0 account
    print_subsection "6.2.9 Ensure root is the only UID 0 account"
    local uid0_accounts=$(awk -F: '($3 == 0 && $1 != "root") { print $1 }' /etc/passwd)
    if [[ -n "$uid0_accounts" ]]; then
        echo -e "${RED}[WARN]${NC} Non-root accounts with UID 0: $uid0_accounts"
        log_message "WARN" "Non-root UID 0 accounts: $uid0_accounts"
    else
        echo -e "${GREEN}[OK]${NC} Only root has UID 0"
    fi
    
    # 6.2.10 Ensure local interactive user home directories are configured
    print_subsection "6.2.10 Ensure local interactive user home directories are configured"
    local valid_shells=$(awk -F/ '$NF != "nologin" {print}' /etc/shells | sed -rn '/^\/{s,/,\\/,g;p}' | paste -s -d '|' -)
    local home_issues=0
    
    while IFS=: read -r user _ _ _ _ home shell; do
        if [[ "$shell" =~ $valid_shells ]]; then
            if [[ ! -d "$home" ]]; then
                echo -e "${RED}[WARN]${NC} User $user home directory $home does not exist"
                ((home_issues++))
            else
                local home_owner=$(stat -c %U "$home" 2>/dev/null)
                local home_mode=$(stat -c %a "$home" 2>/dev/null)
                
                if [[ "$home_owner" != "$user" ]]; then
                    echo -e "${YELLOW}[FIX]${NC} Changing ownership of $home to $user"
                    chown "$user" "$home"
                fi
                
                if [[ $((home_mode & 0027)) -gt 0 ]]; then
                    echo -e "${YELLOW}[FIX]${NC} Removing excess permissions from $home"
                    chmod g-w,o-rwx "$home"
                fi
            fi
        fi
    done < /etc/passwd
    
    if [[ $home_issues -eq 0 ]]; then
        echo -e "${GREEN}[OK]${NC} User home directories are properly configured"
    fi
    
    # 6.2.11 Ensure local interactive user dot files access is configured
    print_subsection "6.2.11 Ensure local interactive user dot files access is configured"
    echo -e "${YELLOW}[INFO]${NC} Checking user dot files..."
    
    local dot_issues=0
    while IFS=: read -r user _ _ _ _ home shell; do
        if [[ "$shell" =~ $valid_shells ]] && [[ -d "$home" ]]; then
            local group=$(id -gn "$user" 2>/dev/null)
            
            # Check for .forward and .rhost files
            for bad_file in ".forward" ".rhost"; do
                if [[ -f "$home/$bad_file" ]]; then
                    echo -e "${RED}[WARN]${NC} User $user has $bad_file file - should be removed"
                    ((dot_issues++))
                fi
            done
            
            # Check .netrc file permissions
            if [[ -f "$home/.netrc" ]]; then
                chmod u-x,go-rwx "$home/.netrc" 2>/dev/null || true
                chown "$user" "$home/.netrc" 2>/dev/null || true
            fi
            
            # Check .bash_history permissions
            if [[ -f "$home/.bash_history" ]]; then
                chmod u-x,go-rwx "$home/.bash_history" 2>/dev/null || true
                chown "$user" "$home/.bash_history" 2>/dev/null || true
            fi
            
            # Check other dot files
            find "$home" -maxdepth 1 -type f -name '.*' 2>/dev/null | while read -r dotfile; do
                local fname=$(basename "$dotfile")
                if [[ "$fname" != ".forward" && "$fname" != ".rhost" && "$fname" != ".netrc" && "$fname" != ".bash_history" ]]; then
                    chmod u-x,go-wx "$dotfile" 2>/dev/null || true
                    chown "$user" "$dotfile" 2>/dev/null || true
                    [[ -n "$group" ]] && chgrp "$group" "$dotfile" 2>/dev/null || true
                fi
            done
        fi
    done < /etc/passwd
    
    if [[ $dot_issues -eq 0 ]]; then
        echo -e "${GREEN}[OK]${NC} User dot files are properly configured"
    else
        echo -e "${YELLOW}[WARN]${NC} $dot_issues dot file issues found - review manually"
    fi
}

#############################################################################
# MAIN EXECUTION
#############################################################################

main() {
    echo -e "${GREEN}"
    echo "=============================================================="
    echo " CIS Oracle Linux 7 Benchmark v4.0.0"
    echo " Section 6: System Maintenance"
    echo " Controls: 6.1.1 - 6.2.11"
    echo "=============================================================="
    echo -e "${NC}"
    
    # Check for root privileges
    check_root
    
    # Initialize log file
    echo "CIS Oracle Linux 7 Benchmark v4.0.0 - Section 6 Remediation" > "$LOG_FILE"
    echo "Started: $(date)" >> "$LOG_FILE"
    echo "=======================================================" >> "$LOG_FILE"
    
    # Execute remediation sections
    configure_system_file_permissions
    check_world_writable_files
    check_unowned_files
    check_suid_sgid_files
    audit_system_file_permissions
    configure_user_group_settings
    
    # Summary
    print_section "Remediation Complete"
    echo -e "${GREEN}Section 6 remediation has been completed.${NC}"
    echo -e "Log file: ${YELLOW}$LOG_FILE${NC}"
    echo ""
    echo -e "${YELLOW}IMPORTANT POST-REMEDIATION STEPS:${NC}"
    echo -e "1. Review locked accounts (if any) to ensure they are intentional"
    echo -e "2. Review SUID/SGID files and remove unnecessary permissions"
    echo -e "3. Investigate any unowned or ungrouped files"
    echo -e "4. Remove .forward and .rhost files from user home directories"
    echo -e "5. Review duplicate UIDs/GIDs and establish unique identifiers"
    echo -e "6. Run: ${BLUE}rpm -Va --nomtime --nosize --nomd5 --nolinkto --noconfig --noghost${NC}"
    echo ""
    
    log_message "INFO" "Section 6 remediation completed"
    echo "Completed: $(date)" >> "$LOG_FILE"
}

# Run main function
main "$@"
