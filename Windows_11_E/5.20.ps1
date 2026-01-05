#Requires -RunAsAdministrator
# 5.20 (L1) Ensure 'Remote Procedure Call (RPC) Locator (RpcLocator)' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\RpcLocator" -Name "Start" -Value 4 -Type DWord -Force
