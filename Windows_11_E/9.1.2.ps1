#Requires -RunAsAdministrator
# 9.1.2 (L1) Ensure 'Windows Firewall: Domain: Inbound connections' is set to 'Block (default)'
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" -Name "DefaultInboundAction" -Value 1 -Type DWord -Force
