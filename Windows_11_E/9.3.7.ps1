#Requires -RunAsAdministrator
# 9.3.7 (L1) Ensure 'Windows Firewall: Public: Logging: Size limit (KB)' is set to '16,384 KB or greater'
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging" -Name "LogFileSize" -Value 16384 -Type DWord -Force
