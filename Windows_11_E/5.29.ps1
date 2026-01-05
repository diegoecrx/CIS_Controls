#Requires -RunAsAdministrator
# 5.29 (L1) Ensure 'Web Management Service (WMSvc)' is set to 'Disabled' or 'Not Installed'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WMSvc" -Name "Start" -Value 4 -Type DWord -Force
