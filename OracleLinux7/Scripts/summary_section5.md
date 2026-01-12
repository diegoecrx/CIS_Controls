## Section 5 - Logging and Auditing (59 scripts)

### 5.1 - Logging Configuration (18 scripts)

| CIS Control | Script Name | Description |
|-------------|-------------|-------------|
| 5.1.1.1 | `5.1.1.1_rsyslog_installed.sh` | Install rsyslog package |
| 5.1.1.2 | `5.1.1.2_rsyslog_enabled.sh` | Enable rsyslog service |
| 5.1.1.3 | `5.1.1.3_rsyslog_perms.sh` | Configure rsyslog file permissions |
| 5.1.1.4 | `5.1.1.4_rsyslog_logging.sh` | Configure rsyslog logging rules |
| 5.1.1.5 | `5.1.1.5_rsyslog_remote.sh` | Configure remote rsyslog logging |
| 5.1.1.6 | `5.1.1.6_rsyslog_accept.sh` | Disable remote rsyslog message acceptance |
| 5.1.2.1 | `5.1.2.1_journald_rsyslog.sh` | Configure journald to forward to rsyslog |
| 5.1.2.2 | `5.1.2.2_journald_compress.sh` | Configure journald compression |
| 5.1.2.3 | `5.1.2.3_journald_persistent.sh` | Configure journald persistent storage |
| 5.1.3 | `5.1.3_logfile_perms.sh` | Configure log file permissions |
| 5.1.4 | `5.1.4_logrotate.sh` | Configure logrotate |

### 5.2 - Audit Configuration (39 scripts)

| CIS Control | Script Name | Description |
|-------------|-------------|-------------|
| 5.2.1.1 | `5.2.1.1_auditd_installed.sh` | Install auditd package |
| 5.2.1.2 | `5.2.1.2_auditd_enabled.sh` | Enable auditd service |
| 5.2.1.3 | `5.2.1.3_auditd_boot.sh` | Enable auditing before auditd starts |
| 5.2.1.4 | `5.2.1.4_auditd_backlog.sh` | Configure audit backlog limit |
| 5.2.2.1 | `5.2.2.1_audit_log_size.sh` | Configure audit log file size |
| 5.2.2.2 | `5.2.2.2_audit_log_full.sh` | Configure audit log full action |
| 5.2.2.3 | `5.2.2.3_audit_log_not_deleted.sh` | Ensure audit logs not automatically deleted |
| 5.2.3.1 | `5.2.3.1_audit_sudoers.sh` | Audit sudoers changes |
| 5.2.3.2 | `5.2.3.2_audit_sudo_log.sh` | Audit sudo log file access |
| 5.2.3.3 | `5.2.3.3_audit_usergroup.sh` | Audit user/group modification events |
| 5.2.3.4 | `5.2.3.4_audit_network.sh` | Audit network environment changes |
| 5.2.3.5 | `5.2.3.5_audit_mac.sh` | Audit MAC policy changes |
| 5.2.3.6 | `5.2.3.6_audit_logins.sh` | Audit login/logout events |
| 5.2.3.7 | `5.2.3.7_audit_sessions.sh` | Audit session initiation |
| 5.2.3.8 | `5.2.3.8_audit_perm_mod.sh` | Audit permission modification events |
| 5.2.3.9 | `5.2.3.9_audit_unauth_access.sh` | Audit unauthorized file access attempts |
| 5.2.3.10 | `5.2.3.10_audit_privileged.sh` | Audit privileged commands |
| 5.2.3.11 | `5.2.3.11_audit_mounts.sh` | Audit file system mounts |
| 5.2.3.12 | `5.2.3.12_audit_file_deletion.sh` | Audit file deletion events |
| 5.2.3.13 | `5.2.3.13_audit_scope.sh` | Audit changes to audit scope |
| 5.2.3.14 | `5.2.3.14_audit_time.sh` | Audit time/date modification |
| 5.2.3.15 | `5.2.3.15_audit_sysadmin.sh` | Audit system administrator actions |
| 5.2.3.16 | `5.2.3.16_audit_kernel_modules.sh` | Audit kernel module loading/unloading |
| 5.2.3.17 | `5.2.3.17_audit_chcon.sh` | Audit chcon command usage |
| 5.2.3.18 | `5.2.3.18_audit_setfacl.sh` | Audit setfacl command usage |
| 5.2.3.19 | `5.2.3.19_audit_chacl.sh` | Audit chacl command usage |
| 5.2.3.20 | `5.2.3.20_audit_usermod.sh` | Audit usermod command usage |
| 5.2.3.21 | `5.2.3.21_audit_immutable.sh` | Make audit configuration immutable |
| 5.2.4.1 | `5.2.4.1_audit_tools_perms.sh` | Audit tools file permissions |
| 5.2.4.2 | `5.2.4.2_audit_tools_owner.sh` | Audit tools file ownership |
| 5.2.4.3 | `5.2.4.3_audit_tools_group.sh` | Audit tools group ownership |

### 5.3 - File Integrity (2 scripts)

| CIS Control | Script Name | Description |
|-------------|-------------|-------------|
| 5.3.1 | `5.3.1_aide_installed.sh` | Install and configure AIDE |
| 5.3.2 | `5.3.2_aide_cron.sh` | Configure AIDE cron job |

---
