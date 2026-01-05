#Requires -RunAsAdministrator
# 5.8 (L1) Ensure 'Infrared monitor service (irmon)' is set to 'Disabled' or 'Not Installed'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\irmon" -Name "Start" -Value 4 -Type DWord -Force
