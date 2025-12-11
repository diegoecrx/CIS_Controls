<#
.SYNOPSIS
    CIS Control 2.3.2.1 - 2.3.2.1 (L1) Ensure 'Audit: Force audit policy subcategory settings (Windows Vis

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\Audit: Force audit policy subcategory settings (Windows Vista or later) to override audit policy category set...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 2.3.2.1
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\2.3.2.1.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 2.3.2.1" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 2.3.2.1 (L1) Ensure 'Audit: Force audit policy subcategory settings (Windows Vista or later) to override audit policy category settings' is set to 'Enabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to Enabled :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\Audit: Force audit policy subcategory settings (Windows Vista or later) to override audit policy category settings
 
Impact:
 
None - this is the default behavior.

See Also

https://workbench.cisecurity.org/benchmarks/21318

References









800-171
3.3.1


800-171
3.3.2


800-171
3.3.6


800-171R3
03.03"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow
