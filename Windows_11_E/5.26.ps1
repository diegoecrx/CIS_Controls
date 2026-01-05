#Requires -RunAsAdministrator
# 5.26 (L1) Ensure 'Special Administration Console Helper (sacsvr)' is set to 'Disabled' or 'Not Installed'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\sacsvr" -Name "Start" -Value 4 -Type DWord -Force
