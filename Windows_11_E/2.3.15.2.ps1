#Requires -RunAsAdministrator
# 2.3.15.2 (L1) Ensure 'System objects: Strengthen default permissions of internal system objects' is set to 'Enabled'
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Session Manager" -Name "ProtectionMode" -Value 1 -Type DWord -Force
