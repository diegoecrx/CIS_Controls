#Requires -RunAsAdministrator
# 5.28 (L1) Ensure 'UPnP Device Host (upnphost)' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\upnphost" -Name "Start" -Value 4 -Type DWord -Force
