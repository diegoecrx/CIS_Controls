#Requires -RunAsAdministrator
# 5.39 (L1) Ensure 'Xbox Accessory Management Service (XboxGipSvc)' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\XboxGipSvc" -Name "Start" -Value 4 -Type DWord -Force
