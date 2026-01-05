#Requires -RunAsAdministrator
# 5.15 (L2) Ensure 'Problem Reports and Solutions Control Panel Support (wercplsupport)' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\wercplsupport" -Name "Start" -Value 4 -Type DWord -Force
