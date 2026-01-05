#Requires -RunAsAdministrator
# 5.14 (L2) Ensure 'Print Spooler (Spooler)' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Spooler" -Name "Start" -Value 4 -Type DWord -Force
