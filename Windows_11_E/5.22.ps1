#Requires -RunAsAdministrator
# 5.22 (L1) Ensure 'Routing and Remote Access (RemoteAccess)' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\RemoteAccess" -Name "Start" -Value 4 -Type DWord -Force
