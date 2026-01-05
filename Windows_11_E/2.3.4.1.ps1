#Requires -RunAsAdministrator
# 2.3.4.1 (L2) Ensure 'Devices: Prevent users from installing printer drivers' is set to 'Enabled'
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Print\Printers" -Name "RestrictDriverInstallationToAdministrators" -Value 1 -Type DWord -Force
