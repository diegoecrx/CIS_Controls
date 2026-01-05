#Requires -RunAsAdministrator
# 2.3.7.3 (L1) Ensure 'Interactive logon: Machine account lockout threshold' is set to '10 or fewer invalid logon attempts, but not 0'
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "LockoutBadCount" -Value 10 -Type DWord -Force
