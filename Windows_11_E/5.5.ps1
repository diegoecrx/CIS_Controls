#Requires -RunAsAdministrator
# 5.5 (L2) Ensure 'GameInput Service (GameInputSvc)' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\GameInputSvc" -Name "Start" -Value 4 -Type DWord -Force
