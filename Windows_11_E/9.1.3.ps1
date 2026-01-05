#Requires -RunAsAdministrator
# 9.1.3 (L1) Ensure 'Windows Firewall: Domain: Settings: Display a notification' is set to 'No'
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" -Name "DisableNotifications" -Value 1 -Type DWord -Force
