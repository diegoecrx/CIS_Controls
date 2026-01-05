#Requires -RunAsAdministrator
# 2.3.11.3 (L1) Ensure 'Network Security: Allow PKU2U authentication requests to this computer to use online identities' is set to 'Disabled'
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Lsa\Kerberos\Parameters" -Name "AllowOnlineID" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
