#Requires -RunAsAdministrator
# 9.1.6 (L1) Ensure 'Windows Firewall: Domain: Logging: Log dropped packets' is set to 'Yes'
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging" -Name "LogDroppedPackets" -Value 1 -Type DWord -Force
