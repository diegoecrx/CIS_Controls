#Requires -RunAsAdministrator
# 5.10 (L1) Ensure 'LxssManager (LxssManager)' is set to 'Disabled' or 'Not Installed'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LxssManager" -Name "Start" -Value 4 -Type DWord -Force
