#Requires -RunAsAdministrator
# 9.1.5 (L1) Ensure 'Windows Firewall: Domain: Logging: Size limit (KB)' is set to '16,384 KB or greater'
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging" -Name "LogFileSize" -Value 16384 -Type DWord -Force
