#Requires -RunAsAdministrator
# 5.11 (L1) Ensure 'Microsoft FTP Service (FTPSVC)' is set to 'Disabled' or 'Not Installed'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\FTPSVC" -Name "Start" -Value 4 -Type DWord -Force
