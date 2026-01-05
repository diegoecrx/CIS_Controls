#Requires -RunAsAdministrator
# 5.27 (L1) Ensure 'SSDP Discovery (SSDPSRV)' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SSDPSRV" -Name "Start" -Value 4 -Type DWord -Force
