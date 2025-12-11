<#
.SYNOPSIS
    CIS Control 9.1.4 - 9.1.4 (L1) Ensure 'Windows Firewall: Domain: Logging: Name' is set to '%SystemRo

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to %SystemRoot%\System32\logfiles\firewall\domainfw.log :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Windows Defender Firewall with Advanced Security\Windows Defender Firewall with Advanced Securit...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 9.1.4
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\9.1.4.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 9.1.4" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 9.1.4 (L1) Ensure 'Windows Firewall: Domain: Logging: Name' is set to '%SystemRoot%\System32\logfiles\firewall\domainfw.log'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to %SystemRoot%\System32\logfiles\firewall\domainfw.log :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Windows Defender Firewall with Advanced Security\Windows Defender Firewall with Advanced Security\Windows Defender Firewall Properties\Domain Profile\Logging Customize\Name
 
Impact:
 
The log file will be stored in the specified file.

See Also

https://workbench.cisecurity.org/benchmarks/21318"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow
