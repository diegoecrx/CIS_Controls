## Section 4 - Category Breakdown

### 4.1 - Job Schedulers (9 scripts)

| # | Script | Description | Action |
|---|--------|-------------|--------|
| 1 | 4.1.1.1_enable_crond.sh | Enable cron daemon | Auto-apply |
| 2 | 4.1.1.2_crontab_perms.sh | /etc/crontab permissions (600) | Auto-apply |
| 3 | 4.1.1.3_cron_hourly_perms.sh | /etc/cron.hourly permissions (700) | Auto-apply |
| 4 | 4.1.1.4_cron_daily_perms.sh | /etc/cron.daily permissions (700) | Auto-apply |
| 5 | 4.1.1.5_cron_weekly_perms.sh | /etc/cron.weekly permissions (700) | Auto-apply |
| 6 | 4.1.1.6_cron_monthly_perms.sh | /etc/cron.monthly permissions (700) | Auto-apply |
| 7 | 4.1.1.7_cron_d_perms.sh | /etc/cron.d permissions (700) | Auto-apply |
| 8 | 4.1.1.8_crontab_restrict.sh | cron.allow/cron.deny configuration | Auto-apply |
| 9 | 4.1.2.1_at_restrict.sh | at.allow/at.deny configuration | Auto-apply |

---

### 4.2 - SSH Server Configuration (22 scripts)

| # | Script | Description | Action |
|---|--------|-------------|--------|
| 1 | 4.2.1_sshd_config_perms.sh | sshd_config permissions (600) | Auto-apply |
| 2 | 4.2.2_ssh_private_key_perms.sh | Private host key permissions (600) | Auto-apply |
| 3 | 4.2.3_ssh_public_key_perms.sh | Public host key permissions (644) | Auto-apply |
| 4 | 4.2.4_sshd_access.sh | AllowUsers/AllowGroups | **PRINT ONLY** |
| 5 | 4.2.5_sshd_banner.sh | Banner /etc/issue.net | Auto-apply |
| 6 | 4.2.6_sshd_ciphers.sh | Strong ciphers only | Auto-apply |
| 7 | 4.2.7_sshd_clientalive.sh | ClientAliveInterval 15, CountMax 3 | Auto-apply |
| 8 | 4.2.8_sshd_disableforwarding.sh | DisableForwarding yes | Auto-apply |
| 9 | 4.2.9_sshd_gssapi.sh | GSSAPIAuthentication no | Auto-apply |
| 10 | 4.2.10_sshd_hostbased.sh | HostbasedAuthentication no | Auto-apply |
| 11 | 4.2.11_sshd_ignorerhosts.sh | IgnoreRhosts yes | Auto-apply |
| 12 | 4.2.12_sshd_kexalgorithms.sh | Strong key exchange algorithms | Auto-apply |
| 13 | 4.2.13_sshd_logingracetime.sh | LoginGraceTime 60 | Auto-apply |
| 14 | 4.2.14_sshd_loglevel.sh | LogLevel VERBOSE | Auto-apply |
| 15 | 4.2.15_sshd_macs.sh | Strong MAC algorithms | Auto-apply |
| 16 | 4.2.16_sshd_maxauthtries.sh | MaxAuthTries 4 | Auto-apply |
| 17 | 4.2.17_sshd_maxsessions.sh | MaxSessions 10 | Auto-apply |
| 18 | 4.2.18_sshd_maxstartups.sh | MaxStartups 10:30:60 | Auto-apply |
| 19 | 4.2.19_sshd_emptypasswords.sh | PermitEmptyPasswords no | Auto-apply |
| 20 | 4.2.20_sshd_permitrootlogin.sh | PermitRootLogin no | **PRINT ONLY** |
| 21 | 4.2.21_sshd_userenv.sh | PermitUserEnvironment no | Auto-apply |
| 22 | 4.2.22_sshd_usepam.sh | UsePAM yes | Auto-apply |

---

### 4.3 - Privilege Escalation (7 scripts)

| # | Script | Description | Action |
|---|--------|-------------|--------|
| 1 | 4.3.1_install_sudo.sh | Install sudo package | Auto-apply |
| 2 | 4.3.2_sudo_pty.sh | Defaults use_pty | Auto-apply |
| 3 | 4.3.3_sudo_logfile.sh | Defaults logfile="/var/log/sudo.log" | Auto-apply |
| 4 | 4.3.4_sudo_nopasswd.sh | Audit NOPASSWD usage | **PRINT ONLY** |
| 5 | 4.3.5_sudo_authenticate.sh | Audit !authenticate usage | **PRINT ONLY** |
| 6 | 4.3.6_sudo_timeout.sh | timestamp_timeout=15 | Auto-apply |
| 7 | 4.3.7_su_restrict.sh | Restrict su to wheel group | Auto-apply |

---

### 4.4 - PAM Configuration (12 scripts)

| # | Script | Description | Action |
|---|--------|-------------|--------|
| 1 | 4.4.1.1_upgrade_pam.sh | Upgrade PAM packages | Auto-apply |
| 2 | 4.4.1.2_install_libpwquality.sh | Install libpwquality | Auto-apply |
| 3 | 4.4.2.1_pam_faillock.sh | Configure pam_faillock | **PRINT ONLY** |
| 4 | 4.4.2.2.1_pam_pwquality.sh | Configure pam_pwquality | **PRINT ONLY** |
| 5 | 4.4.2.2.2_pwquality_difok.sh | difok = 2 | Auto-apply |
| 6 | 4.4.2.2.3_pwquality_minlen.sh | minlen = 14 | Auto-apply |
| 7 | 4.4.2.2.4_pwquality_complexity.sh | minclass = 4 | Auto-apply |
| 8 | 4.4.2.2.5_pwquality_maxrepeat.sh | maxrepeat = 3 | Auto-apply |
| 9 | 4.4.2.2.6_pwquality_maxsequence.sh | maxsequence = 3 | Auto-apply |
| 10 | 4.4.2.2.7_pwquality_dictcheck.sh | dictcheck = 1 | Auto-apply |
| 11 | 4.4.2.3_pam_pwhistory.sh | Configure pam_pwhistory | **PRINT ONLY** |
| 12 | 4.4.2.4_pam_unix.sh | Configure pam_unix | **PRINT ONLY** |

---

### 4.5 - User Accounts and Environment (13 scripts)

| # | Script | Description | Action |
|---|--------|-------------|--------|
| 1 | 4.5.1.1_password_hashing.sh | SHA512 hashing algorithm | Auto-apply |
| 2 | 4.5.1.2_password_expiration.sh | PASS_MAX_DAYS 365 | Auto-apply |
| 3 | 4.5.1.3_password_warning.sh | PASS_WARN_AGE 7 | Auto-apply |
| 4 | 4.5.1.4_inactive_lock.sh | INACTIVE 30 days | Auto-apply |
| 5 | 4.5.1.5_password_change_date.sh | Audit password change dates | **PRINT ONLY** |
| 6 | 4.5.2.1_root_uid.sh | Audit UID 0 accounts | **PRINT ONLY** |
| 7 | 4.5.2.2_root_gid.sh | Root GID 0 | Auto-apply |
| 8 | 4.5.2.3_root_umask.sh | Root user umask | **PRINT ONLY** |
| 9 | 4.5.2.4_system_accounts.sh | Secure system accounts | Auto-apply |
| 10 | 4.5.2.5_root_password.sh | Audit root password | **PRINT ONLY** |
| 11 | 4.5.3.1_nologin_shells.sh | Remove nologin from /etc/shells | Auto-apply |
| 12 | 4.5.3.2_shell_timeout.sh | TMOUT=900 | Auto-apply |
| 13 | 4.5.3.3_default_umask.sh | umask 027 | Auto-apply |

---

### Section 4 Summary

| Category | Scripts | Auto-apply | Print Only |
|----------|---------|------------|------------|
| 4.1 Job Schedulers | 9 | 9 | 0 |
| 4.2 SSH Server | 22 | 20 | 2 |
| 4.3 Privilege Escalation | 7 | 5 | 2 |
| 4.4 PAM Configuration | 12 | 8 | 4 |
| 4.5 User Accounts | 13 | 7 | 6 |
| **Total** | **63** | **49** | **14** |
