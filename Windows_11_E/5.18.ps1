#Requires -RunAsAdministrator
# 5.18 (L2) Ensure 'Remote Desktop Services (TermService)' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\TermService" -Name "Start" -Value 4 -Type DWord -Force
