#Requires -RunAsAdministrator
# 5.30 (L2) Ensure 'Windows Error Reporting Service (WerSvc)' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WerSvc" -Name "Start" -Value 4 -Type DWord -Force
