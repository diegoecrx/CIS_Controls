#Requires -RunAsAdministrator
# 9.3.8 (L1) Ensure 'Windows Firewall: Public: Logging: Log dropped packets' is set to 'Yes'
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging" -Name "LogDroppedPackets" -Value 1 -Type DWord -Force
