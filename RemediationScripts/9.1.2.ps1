<#
.SYNOPSIS
    CIS Control 9.1.2 - 9.1.2 (L1) Ensure 'Windows Firewall: Domain: Inbound connections' is set to 'Blo

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Block (default) :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Windows Defender Firewall with Advanced Security\Windows Defender Firewall with Advanced Security\Windows Defender Firewall Propertie...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 9.1.2
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\9.1.2.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 9.1.2" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 9.1.2 (L1) Ensure 'Windows Firewall: Domain: Inbound connections' is set to 'Block (default)'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to Block (default) :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Windows Defender Firewall with Advanced Security\Windows Defender Firewall with Advanced Security\Windows Defender Firewall Properties\Domain Profile\Inbound connections
 
Impact:
 
None - this is the default behavior.

See Also

https://workbench.cisecurity.org/benchmarks/21318

References









800-171
3.13.1


800-171
3.13.5
"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
