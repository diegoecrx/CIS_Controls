<#
.SYNOPSIS
    CIS Control 9.3.1 - 9.3.1 (L1) Ensure 'Windows Firewall: Public: Firewall state' is set to 'On (reco

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to On (recommended):
 
Computer Configuration\Policies\Windows Settings\Security Settings\Windows Defender Firewall with Advanced Security\Windows Defender Firewall with Advanced Security\Windows Defender Firewall Propertie...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 9.3.1
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\9.3.1.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 9.3.1" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 9.3.1 (L1) Ensure 'Windows Firewall: Public: Firewall state' is set to 'On (recommended)'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to On (recommended):
 
Computer Configuration\Policies\Windows Settings\Security Settings\Windows Defender Firewall with Advanced Security\Windows Defender Firewall with Advanced Security\Windows Defender Firewall Properties\Public Profile\Firewall state
 
Impact:
 
None - this is the default behavior.

See Also

https://workbench.cisecurity.org/benchmarks/21318

References









800-171
3.13.1


800-171
3.13.5


800"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
