<#
.SYNOPSIS
    CIS Control 9.1.7 - 9.1.7 (L1) Ensure 'Windows Firewall: Domain: Logging: Log successful connections

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Yes :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Windows Defender Firewall with Advanced Security\Windows Defender Firewall with Advanced Security\Windows Defender Firewall Properties\Domain Pro...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 9.1.7
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\9.1.7.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 9.1.7" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 9.1.7 (L1) Ensure 'Windows Firewall: Domain: Logging: Log successful connections' is set to 'Yes'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to Yes :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Windows Defender Firewall with Advanced Security\Windows Defender Firewall with Advanced Security\Windows Defender Firewall Properties\Domain Profile\Logging Customize\Log successful connections
 
Impact:
 
Information about successful connections will be recorded in the firewall log file.

See Also

https://workbench.cisecurity.org/benchmarks"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow
