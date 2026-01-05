#Requires -RunAsAdministrator
# 9.3.4 (L1) Ensure 'Windows Firewall: Public: Settings: Apply local firewall rules' is set to 'No'
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" -Name "AllowLocalPolicyMerge" -Value 0 -Type DWord -Force
