#Requires -RunAsAdministrator
# 5.32 (L1) Ensure 'Windows Media Player Network Sharing Service (WMPNetworkSvc)' is set to 'Disabled' or 'Not Installed'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WMPNetworkSvc" -Name "Start" -Value 4 -Type DWord -Force
