#Requires -RunAsAdministrator
# 5.6 (L2) Ensure 'Geolocation Service (lfsvc)' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc" -Name "Start" -Value 4 -Type DWord -Force
