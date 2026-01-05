#Requires -RunAsAdministrator
# 2.3.11.11 (L1) Ensure 'Network security: Minimum session security for NTLM SSP based servers' is set properly
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Lsa\MSV1_0" -Name "NTLMMinServerSec" -Value 537395200 -Type DWord -Force
