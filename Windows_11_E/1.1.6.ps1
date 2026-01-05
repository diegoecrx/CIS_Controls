#Requires -RunAsAdministrator
# 1.1.6 (L1) Ensure 'Relax minimum password length limits' is set to 'Enabled'
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\SAM" -Name "RelaxMinimumPasswordLengthLimits" -Value 1 -Type DWord -Force
