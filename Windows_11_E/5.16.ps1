#Requires -RunAsAdministrator
# 5.16 (L2) Ensure 'Remote Access Auto Connection Manager (RasAuto)' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\RasAuto" -Name "Start" -Value 4 -Type DWord -Force
