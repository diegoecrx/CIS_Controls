#Requires -RunAsAdministrator
# 5.19 (L2) Ensure 'Remote Desktop Services UserMode Port Redirector (UmRdpService)' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\UmRdpService" -Name "Start" -Value 4 -Type DWord -Force
