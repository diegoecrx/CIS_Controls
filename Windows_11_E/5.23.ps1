#Requires -RunAsAdministrator
# 5.23 (L2) Ensure 'Server (LanmanServer)' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer" -Name "Start" -Value 4 -Type DWord -Force
