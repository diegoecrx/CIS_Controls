#Requires -RunAsAdministrator
# 5.38 (L1) Ensure 'World Wide Web Publishing Service (W3SVC)' is set to 'Disabled' or 'Not Installed'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\W3SVC" -Name "Start" -Value 4 -Type DWord -Force
