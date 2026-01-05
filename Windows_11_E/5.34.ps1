#Requires -RunAsAdministrator
# 5.34 (L2) Ensure 'Windows Push Notifications System Service (WpnService)' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WpnService" -Name "Start" -Value 4 -Type DWord -Force
