#Requires -RunAsAdministrator
# 2.3.11.9 (L1) Ensure 'Network security: LDAP client signing requirements' is set to 'Negotiate signing' or higher
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\LDAP" -Name "LDAPClientIntegrity" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
