#Requires -RunAsAdministrator
# 5.21 (L2) Ensure 'Remote Registry (RemoteRegistry)' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\RemoteRegistry" -Name "Start" -Value 4 -Type DWord -Force
