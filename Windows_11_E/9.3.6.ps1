#Requires -RunAsAdministrator
# 9.3.6 (L1) Ensure 'Windows Firewall: Public: Logging: Name' is set to '%SystemRoot%\System32\logfiles\firewall\publicfw.log'
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging" -Name "LogFilePath" -Value "%SystemRoot%\System32\logfiles\firewall\publicfw.log" -Type String -Force
