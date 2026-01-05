#Requires -RunAsAdministrator
# 5.4 (L2) Ensure 'Downloaded Maps Manager (MapsBroker)' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\MapsBroker" -Name "Start" -Value 4 -Type DWord -Force
