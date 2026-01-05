#Requires -RunAsAdministrator
# 5.35 (L2) Ensure 'Windows PushToInstall Service (PushToInstall)' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\PushToInstall" -Name "Start" -Value 4 -Type DWord -Force
