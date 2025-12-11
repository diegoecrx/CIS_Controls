<#
.SYNOPSIS
    CIS Control 5.20 - 5.20 (L1) Ensure 'Remote Procedure Call (RPC) Locator (RpcLocator)' is set to 'D

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to: Disabled
 
Computer Configuration\Policies\Windows Settings\Security Settings\System Services\Remote Procedure Call (RPC) Locator
 
Impact:
 
No impact, unless an old, legacy application requires it.

See Also

https://...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 5.20
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\5.20.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 5.20" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 5.20 (L1) Ensure 'Remote Procedure Call (RPC) Locator (RpcLocator)' is set to 'Disabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to: Disabled
 
Computer Configuration\Policies\Windows Settings\Security Settings\System Services\Remote Procedure Call (RPC) Locator
 
Impact:
 
No impact, unless an old, legacy application requires it.

See Also

https://workbench.cisecurity.org/benchmarks/21318

References









800-171
3.4.2


800-171
3.4.6


800-171
3.4.7


800-171R3
03.04.02


800-171R3
03.04.06


800-53
CM-6


800-53
CM-7


800-53R5
CM-6


800"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
