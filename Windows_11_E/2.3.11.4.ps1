#Requires -RunAsAdministrator
# 2.3.11.4 (L1) Ensure 'Network security: Configure encryption types allowed for Kerberos' is set to specific types
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters" -Name "SupportedEncryptionTypes" -Value 2147483644 -Type DWord -Force
