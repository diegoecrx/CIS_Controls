#Requires -RunAsAdministrator
# 5.17 (L2) Ensure 'Remote Desktop Configuration (SessionEnv)' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SessionEnv" -Name "Start" -Value 4 -Type DWord -Force
