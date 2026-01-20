#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 6.1.11
# Ensure world writable files and directories are secured

set -e

echo "CIS 6.1.11 - Securing world writable files and directories..."

{
   l_smask='01000'
   a_path=(); a_arr=()
   a_path=(! -path "/run/user/*" -a ! -path "/proc/*" -a ! -path "*/containerd/*" -a ! -path "*/kubelet/pods/*" -a ! -path "/sys/kernel/security/apparmor/*" -a ! -path "/snap/*" -a ! -path "/sys/fs/cgroup/memory/*" -a ! -path "/sys/fs/selinux/*")
   
   while read -r l_bfs; do
      a_path+=( -a ! -path ""$l_bfs"/*")
   done < <(findmnt -Dkerno fstype,target | awk '$1 ~ /^\s*(nfs|proc|smb)/ {print $2}')
   
   while IFS= read -r -d '' l_file; do
      [ -e "$l_file" ] && a_arr+=("$(stat -Lc '%n^%#a' "$l_file")")
   done < <(find / \( "${a_path[@]}" \) \( -type f -o -type d \) -perm -0002 -print0 2>/dev/null)
   
   while IFS="^" read -r l_fname l_mode; do
      if [ -f "$l_fname" ]; then
         echo " - File: \"$l_fname\" is mode: \"$l_mode\" - removing write permission from \"other\""
         chmod o-w "$l_fname"
      fi
      if [ -d "$l_fname" ]; then
         if [ ! $(( $l_mode & $l_smask )) -gt 0 ]; then
            echo " - Directory: \"$l_fname\" is mode: \"$l_mode\" - Adding the sticky bit"
            chmod a+t "$l_fname"
         fi
      fi
   done < <(printf '%s\n' "${a_arr[@]}")
   
   unset a_path; unset a_arr
}

echo "CIS 6.1.11 remediation complete."