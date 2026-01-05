#Requires -RunAsAdministrator
# 5.40 (L1) Ensure 'Xbox Live Auth Manager (XblAuthManager)' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\XblAuthManager" -Name "Start" -Value 4 -Type DWord -Force
