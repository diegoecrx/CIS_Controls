#Requires -RunAsAdministrator
# 2.3.11.8 (L1) Ensure 'Network security: LDAP client encryption requirements' is set to 'Negotiate sealing' or higher
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\LDAP" -Name "LDAPClientIntegrity" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
