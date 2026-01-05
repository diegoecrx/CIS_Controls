#Requires -RunAsAdministrator
# 5.3 (L1) Ensure 'Computer Browser (Browser)' is set to 'Disabled' or 'Not Installed'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Browser" -Name "Start" -Value 4 -Type DWord -Force
