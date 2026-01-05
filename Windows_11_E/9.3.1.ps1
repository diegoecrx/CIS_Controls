#Requires -RunAsAdministrator
# 9.3.1 (L1) Ensure 'Windows Firewall: Public: Firewall state' is set to 'On (recommended)'
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" -Name "EnableFirewall" -Value 1 -Type DWord -Force
