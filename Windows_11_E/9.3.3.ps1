#Requires -RunAsAdministrator
# 9.3.3 (L1) Ensure 'Windows Firewall: Public: Settings: Display a notification' is set to 'No'
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" -Name "DisableNotifications" -Value 1 -Type DWord -Force
