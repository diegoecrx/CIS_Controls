#Requires -RunAsAdministrator
# 5.1 (L2) Ensure 'Bluetooth Audio Gateway Service (BTAGService)' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\BTAGService" -Name "Start" -Value 4 -Type DWord -Force
