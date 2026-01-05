#Requires -RunAsAdministrator
# 2.3.10.12 (L1) Ensure 'Network access: Sharing and security model for local accounts' is set to 'Classic - local users authenticate as themselves'
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Lsa" -Name "ForceGuest" -Value 0 -Type DWord -Force
