#Requires -RunAsAdministrator
# 2.3.14.1 (L2) Ensure 'System cryptography: Force strong key protection for user keys stored on the computer'
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Cryptography" -Name "ForceKeyProtection" -Value 2 -Type DWord -Force -ErrorAction SilentlyContinue
