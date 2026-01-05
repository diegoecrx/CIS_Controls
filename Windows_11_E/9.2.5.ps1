#Requires -RunAsAdministrator
# 9.2.5 (L1) Ensure 'Windows Firewall: Private: Logging: Size limit (KB)' is set to '16,384 KB or greater'
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging" -Name "LogFileSize" -Value 16384 -Type DWord -Force
