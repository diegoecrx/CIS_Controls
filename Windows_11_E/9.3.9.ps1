#Requires -RunAsAdministrator
# 9.3.9 (L1) Ensure 'Windows Firewall: Public: Logging: Log successful connections' is set to 'Yes'
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging" -Name "LogSuccessfulConnections" -Value 1 -Type DWord -Force
