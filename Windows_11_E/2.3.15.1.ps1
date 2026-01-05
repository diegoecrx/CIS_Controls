#Requires -RunAsAdministrator
# 2.3.15.1 (L1) Ensure 'System objects: Require case insensitivity for non-Windows subsystems' is set to 'Enabled'
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Kernel" -Name "ObCaseInsensitive" -Value 1 -Type DWord -Force
