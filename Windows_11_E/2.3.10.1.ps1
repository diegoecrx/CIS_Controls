#Requires -RunAsAdministrator
# 2.3.10.1 (L1) Ensure 'Network access: Allow anonymous SID/Name translation' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Lsa" -Name "TryAllowMachineAccountLogon" -Value 0 -Type DWord -Force
