#Requires -RunAsAdministrator
# 5.37 (L2) Ensure 'WinHTTP Web Proxy Auto-Discovery Service (WinHttpAutoProxySvc)' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WinHttpAutoProxySvc" -Name "Start" -Value 4 -Type DWord -Force
