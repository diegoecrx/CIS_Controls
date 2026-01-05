#Requires -RunAsAdministrator
# 5.13 (L1) Ensure 'OpenSSH SSH Server (sshd)' is set to 'Disabled' or 'Not Installed'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\sshd" -Name "Start" -Value 4 -Type DWord -Force
