#Requires -RunAsAdministrator
# 5.31 (L2) Ensure 'Windows Event Collector (Wecsvc)' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Wecsvc" -Name "Start" -Value 4 -Type DWord -Force
