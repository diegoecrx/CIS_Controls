#Requires -RunAsAdministrator
# 5.7 (L1) Ensure 'IIS Admin Service (IISADMIN)' is set to 'Disabled' or 'Not Installed'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\IISADMIN" -Name "Start" -Value 4 -Type DWord -Force
