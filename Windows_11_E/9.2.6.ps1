#Requires -RunAsAdministrator
# 9.2.6 (L1) Ensure 'Windows Firewall: Private: Logging: Log dropped packets' is set to 'Yes'
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging" -Name "LogDroppedPackets" -Value 1 -Type DWord -Force
