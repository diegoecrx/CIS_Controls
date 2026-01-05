#Requires -RunAsAdministrator
# 5.42 (L1) Ensure 'Xbox Live Networking Service (XboxNetApiSvc)' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\XboxNetApiSvc" -Name "Start" -Value 4 -Type DWord -Force
