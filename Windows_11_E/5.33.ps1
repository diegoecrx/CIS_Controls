#Requires -RunAsAdministrator
# 5.33 (L1) Ensure 'Windows Mobile Hotspot Service (icssvc)' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\icssvc" -Name "Start" -Value 4 -Type DWord -Force
