#Requires -RunAsAdministrator
# 5.36 (L2) Ensure 'Windows Remote Management (WS-Management) (WinRM)' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WinRM" -Name "Start" -Value 4 -Type DWord -Force
