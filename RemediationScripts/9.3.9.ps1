<#
.SYNOPSIS
    CIS Control 9.3.9 - 9.3.9 (L1) Ensure 'Windows Firewall: Public: Logging: Log successful connections

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Yes
 
Computer Configuration\Policies\Windows Settings\Security Settings\Windows Defender Firewall with Advanced Security\Windows Defender Firewall with Advanced Security\Windows Defender Firewall Properties\Public Profi...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 9.3.9
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\9.3.9.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 9.3.9" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 9.3.9 (L1) Ensure 'Windows Firewall: Public: Logging: Log successful connections' is set to 'Yes'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to Yes" -ForegroundColor White
Write-Host " " -ForegroundColor White
Write-Host "Computer Configuration\Policies\Windows Settings\Security Settings\Windows Defender Firewall with Advanced Security\Windows Defender Firewall with Advanced Security\Windows Defender Firewall Properties\Public Profile\Logging Customize\Log successful connections" -ForegroundColor White
Write-Host " " -ForegroundColor White
Write-Host "Impact:" -ForegroundColor Cyan
Write-Host " " -ForegroundColor White
Write-Host "Information about successful connections will be recorded in the firewall log file." -ForegroundColor White
Write-Host " " -ForegroundColor White
Write-Host "See Also: https://workbench.cisecurity.org/benchmarks/21318" -ForegroundColor White
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
