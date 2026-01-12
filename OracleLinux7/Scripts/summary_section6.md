## Section 6 - System Maintenance (25 scripts)

### 6.1 - System File Permissions (14 scripts)

| CIS Control | Script Name | Description |
|-------------|-------------|-------------|
| 6.1.1 | `6.1.1_passwd_perms.sh` | Set /etc/passwd permissions (u-x,go-wx, root:root) |
| 6.1.2 | `6.1.2_passwd_backup_perms.sh` | Set /etc/passwd- backup permissions |
| 6.1.3 | `6.1.3_group_perms.sh` | Set /etc/group permissions (u-x,go-wx, root:root) |
| 6.1.4 | `6.1.4_group_backup_perms.sh` | Set /etc/group- backup permissions |
| 6.1.5 | `6.1.5_shadow_perms.sh` | Set /etc/shadow permissions (0000, root:root) |
| 6.1.6 | `6.1.6_shadow_backup_perms.sh` | Set /etc/shadow- permissions (0000) |
| 6.1.7 | `6.1.7_gshadow_perms.sh` | Set /etc/gshadow permissions (0000, root:root) |
| 6.1.8 | `6.1.8_gshadow_backup_perms.sh` | Set /etc/gshadow- permissions (0000) |
| 6.1.9 | `6.1.9_shells_perms.sh` | Set /etc/shells permissions |
| 6.1.10 | `6.1.10_opasswd_perms.sh` | Set /etc/security/opasswd permissions |
| 6.1.11 | `6.1.11_world_writable.sh` | Secure world-writable files/directories |
| 6.1.12 | `6.1.12_unowned_files.sh` | Audit unowned/ungrouped files |
| 6.1.13 | `6.1.13_suid_sgid_audit.sh` | Audit SUID/SGID files |
| 6.1.14 | `6.1.14_rpm_perms_audit.sh` | Audit RPM package file permissions |

### 6.2 - User and Group Settings (11 scripts)

| CIS Control | Script Name | Description |
|-------------|-------------|-------------|
| 6.2.1 | `6.2.1_shadow_passwords.sh` | Ensure shadowed passwords (pwconv) |
| 6.2.2 | `6.2.2_empty_passwords.sh` | Lock accounts without passwords |
| 6.2.3 | `6.2.3_groups_exist.sh` | Audit groups in passwd exist in group |
| 6.2.4 | `6.2.4_duplicate_uids.sh` | Audit duplicate UIDs |
| 6.2.5 | `6.2.5_duplicate_gids.sh` | Audit duplicate GIDs |
| 6.2.6 | `6.2.6_duplicate_usernames.sh` | Audit duplicate user names |
| 6.2.7 | `6.2.7_duplicate_groupnames.sh` | Audit duplicate group names |
| 6.2.8 | `6.2.8_root_path.sh` | Audit root PATH integrity |
| 6.2.9 | `6.2.9_uid_zero.sh` | Audit accounts with UID 0 |
| 6.2.10 | `6.2.10_home_directories.sh` | Configure home directory permissions |
| 6.2.11 | `6.2.11_dot_files.sh` | Configure user dot file permissions |

---

## Summary Totals

| Section | Category | Scripts |
|---------|----------|:-------:|
| **5.1** | Logging (rsyslog, journald) | 18 |
| **5.2** | Auditing (auditd, audit rules) | 39 |
| **5.3** | File Integrity (AIDE) | 2 |
| **6.1** | System File Permissions | 14 |
| **6.2** | User and Group Settings | 11 |
| | **Section 5 Total** | **59** |
| | **Section 6 Total** | **25** |
| | **Combined Total** | **84** |
