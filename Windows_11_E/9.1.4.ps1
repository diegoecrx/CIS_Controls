#Requires -RunAsAdministrator
# 9.1.4 (L1) Ensure 'Windows Firewall: Domain: Logging: Name' is set to '%SystemRoot%\System32\logfiles\firewall\domainfw.log'
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging" -Name "LogFilePath" -Value "%SystemRoot%\System32\logfiles\firewall\domainfw.log" -Type String -Force
