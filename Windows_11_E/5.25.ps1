#Requires -RunAsAdministrator
# 5.25 (L2) Ensure 'SNMP Service (SNMP)' is set to 'Disabled' or 'Not Installed'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP" -Name "Start" -Value 4 -Type DWord -Force
