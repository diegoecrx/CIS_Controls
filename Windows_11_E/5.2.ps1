#Requires -RunAsAdministrator
# 5.2 (L2) Ensure 'Bluetooth Support Service (bthserv)' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\bthserv" -Name "Start" -Value 4 -Type DWord -Force
