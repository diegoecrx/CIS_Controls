#Requires -RunAsAdministrator
# 9.2.3 (L1) Ensure 'Windows Firewall: Private: Settings: Display a notification' is set to 'No'
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" -Name "DisableNotifications" -Value 1 -Type DWord -Force
