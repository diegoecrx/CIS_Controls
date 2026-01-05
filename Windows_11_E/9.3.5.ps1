#Requires -RunAsAdministrator
# 9.3.5 (L1) Ensure 'Windows Firewall: Public: Settings: Apply local connection security rules' is set to 'No'
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" -Name "AllowLocalIPsecPolicyMerge" -Value 0 -Type DWord -Force
