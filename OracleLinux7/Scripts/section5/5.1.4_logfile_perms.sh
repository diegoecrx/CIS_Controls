#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 5.1.4
# Ensure all logfiles have appropriate access configured
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "CIS 5.1.4 - Fixing logfile permissions..."

l_uidmin="$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"

# List of OCI-specific system users that legitimately own log files
OCI_USERS="oracle-cloud-agent|oracle-cloud-agent-updater|ocarun"

file_test_fix() {
    l_op2=""
    l_fuser="root"
    l_fgroup="root"

    # Check and fix permissions if needed
    if [ $(( $l_mode & $perm_mask )) -gt 0 ]; then
        l_op2="$l_op2\n - Mode: \"$l_mode\" should be \"$maxperm\" or more restrictive\n - Removing excess permissions"
        chmod "$l_rperms" "$l_fname"
    fi
    
    # Check ownership - but allow OCI system users
    if [[ ! "$l_user" =~ $l_auser ]]; then
        l_op2="$l_op2\n - Owned by: \"$l_user\" changing to \"$l_fuser\""
        chown "$l_fuser" "$l_fname"
    fi
    
    # Check group ownership
    if [[ ! "$l_group" =~ $l_agroup ]]; then
        l_op2="$l_op2\n - Group: \"$l_group\" changing to \"$l_fgroup\""
        chgrp "$l_fgroup" "$l_fname"
    fi
    
    [ -n "$l_op2" ] && echo -e " - File: \"$l_fname\":$l_op2"
}

echo "Scanning /var/log for files with incorrect permissions..."

# Find files that might need fixing - now includes group check
while IFS= read -r -d $'\0' l_file; do
    [ -e "$l_file" ] || continue

    # Get file stats
    read -r l_fname l_mode l_user l_uid l_group l_gid <<< "$(stat -Lc '%n %#a %U %u %G %g' "$l_file")"
    l_bname="$(basename "$l_fname")"

    case "$l_bname" in
        lastlog | lastlog.* | wtmp | wtmp.* | wtmp-* | btmp | btmp.* | btmp-* | README)
            perm_mask='0113'
            maxperm="$( printf '%o' $(( 0777 & ~$perm_mask)) )"
            l_rperms="ug-x,o-wx"
            l_auser="root"
            l_agroup="(root|utmp)"
            file_test_fix
            ;;
        secure | auth.log | syslog | messages)
            perm_mask='0137'
            maxperm="$( printf '%o' $(( 0777 & ~$perm_mask)) )"
            l_rperms="u-x,g-wx,o-rwx"
            l_auser="(root|syslog)"
            l_agroup="(root|adm)"
            file_test_fix
            ;;
        *.journal | *.journal~)
            perm_mask='0137'
            maxperm="$( printf '%o' $(( 0777 & ~$perm_mask)) )"
            l_rperms="u-x,g-wx,o-rwx"
            l_auser="root"
            l_agroup="(root|systemd-journal)"
            file_test_fix
            ;;
        *)
            perm_mask='0137'
            maxperm="$( printf '%o' $(( 0777 & ~$perm_mask)) )"
            l_rperms="u-x,g-wx,o-rwx"
            # For OCI systems, allow OCI service users and their groups
            l_auser="(root|syslog|${OCI_USERS})"
            l_agroup="(root|adm|oracle-cloud-agent)"
            
            # For system users with UID < UID_MIN, allow if no regular users in the group
            if [ "$l_uid" -lt "$l_uidmin" ] && [ -z "$(awk -v grp="$l_group" -F: '$1==grp {print $4}' /etc/group)" ]; then
                if [[ ! "$l_user" =~ $l_auser ]]; then
                    l_auser="(root|syslog|${OCI_USERS}|$l_user)"
                fi
                if [[ ! "$l_group" =~ $l_agroup ]]; then
                    l_tst=""
                    while l_out3="" read -r l_duid; do
                        [ "$l_duid" -ge "$l_uidmin" ] && l_tst=failed
                    done <<< "$(awk -F: '$4=='"$l_gid"' {print $3}' /etc/passwd)"
                    [ "$l_tst" != "failed" ] && l_agroup="(root|adm|oracle-cloud-agent|$l_group)"
                fi
            fi
            file_test_fix
            ;;
    esac
done < <(find -L /var/log -type f \( -perm /0137 -o ! -user root -o ! -group root \) -print0 2>/dev/null)

echo ""
echo "CIS 5.1.4 remediation complete."
