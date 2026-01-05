#Requires -RunAsAdministrator
# 5.41 (L1) Ensure 'Xbox Live Game Save (XblGameSave)' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\XblGameSave" -Name "Start" -Value 4 -Type DWord -Force
