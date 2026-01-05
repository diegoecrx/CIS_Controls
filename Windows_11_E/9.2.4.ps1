#Requires -RunAsAdministrator
# 9.2.4 (L1) Ensure 'Windows Firewall: Private: Logging: Name' is set to '%SystemRoot%\System32\logfiles\firewall\privatefw.log'
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging" -Name "LogFilePath" -Value "%SystemRoot%\System32\logfiles\firewall\privatefw.log" -Type String -Force
