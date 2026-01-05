#Requires -RunAsAdministrator
# 9.2.7 (L1) Ensure 'Windows Firewall: Private: Logging: Log successful connections' is set to 'Yes'
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging" -Name "LogSuccessfulConnections" -Value 1 -Type DWord -Force
