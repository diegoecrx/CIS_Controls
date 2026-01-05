#Requires -RunAsAdministrator
# 9.1.7 (L1) Ensure 'Windows Firewall: Domain: Logging: Log successful connections' is set to 'Yes'
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging" -Name "LogSuccessfulConnections" -Value 1 -Type DWord -Force
