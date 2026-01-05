#Requires -RunAsAdministrator
# 5.9 (L2) Ensure 'Link-Layer Topology Discovery Mapper (lltdsvc)' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lltdsvc" -Name "Start" -Value 4 -Type DWord -Force
