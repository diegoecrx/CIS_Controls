
perl parse_nessus_xml.v29.pl -f OL7_after4.nessus -o OL7_after4.xlsx




scan da FGC


1.2.5 Ensure updates, patches, and additional security software are installed [indisponivel]
4.2.20 Ensure sshd PermitRootLogin is disabled [n/a]
4.3.7 Ensure access to the su command is restricted [n/a]
5.3.1 Ensure AIDE is installed [indisponivel]


@$W5p2rr0mkr2k3n#963@

4.5.1.2 Ensure password expiration is 365 days or less
5.1.1.3 Ensure journald is configured to send logs to rsyslog
FAILED 5.1.4 Ensure all logfiles have appropriate access configured
5.2.3.1 Ensure changes to system administration scope (sudoers) is collected
5.2.3.10 Ensure successful file system mounts are collected
5.2.3.11 Ensure session initiation information is collected
5.2.3.12 Ensure login and logout events are collected
5.2.3.13 Ensure file deletion events by users are collected
5.2.3.14 Ensure events that modify the system's Mandatory Access Controls are collected
5.2.3.15 Ensure successful and unsuccessful attempts to use the chcon command are recorded
5.2.3.16 Ensure successful and unsuccessful attempts to use the setfacl command are recorded
5.2.3.17 Ensure successful and unsuccessful attempts to use the chacl command are recorded
5.2.3.18 Ensure successful and unsuccessful attempts to use the usermod command are recorded
5.2.3.19 Ensure kernel module loading unloading and modification is collected
5.2.3.2 Ensure actions as another user are always logged
FAILED 5.2.3.3 Ensure events that modify the sudo log file are collected
5.2.3.4 Ensure events that modify date and time information are collected
5.2.3.5 Ensure events that modify the system's network environment are collected
5.2.3.6 Ensure use of privileged commands are collected
5.2.3.7 Ensure unsuccessful file access attempts are collected
5.2.3.8 Ensure events that modify user/group information are collected
5.2.3.9 Ensure discretionary access control permission modification events are collected



5.2.3.10 - 13


warning



1.2.1 Ensure GPG keys are configured
1.2.4 Ensure package manager repositories are configured
2.2.22 Ensure only approved services are listening on a network interface
3.1.1 Ensure IPv6 status is identified
3.4.1.2 Ensure a single firewall configuration utility is in use
3.4.2.3 Ensure firewalld drops unnecessary services and ports
3.4.2.4 Ensure network interfaces are assigned to appropriate zone
5.1.3 Ensure logrotate is configured
6.1.13 Ensure SUID and SGID files are reviewed
6.1.14 Audit system file permissions





create a bash script which follow this structure
- be accurate, be precise
- handle issues correctly and find workarounds to solve the problems encountered
- do not generate made up messages (echo)
- only show system output and ways to provide proof of remediation or file, or service existence and status
- FORCE and ENFORCE apply the remediation






find . -maxdepth 1 -name "*.sh" -type f -exec bash {} \;





@$W5p2rr0mkr2k3n#963@


for f in ./*.sh; do
echo "Running $f..."
bash "$f"
done


@Real2014NewYeah_



@Real2014#













































