<#
.SYNOPSIS
    CIS Control 5.9 - 5.9 (L2) Ensure 'Link-Layer Topology Discovery Mapper (lltdsvc)' is set to 'Disa

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to: Disabled
 
Computer Configuration\Policies\Windows Settings\Security Settings\System Services\Link-Layer Topology Discovery Mapper
 
Impact:
 
The Network Map will not function properly.

See Also

https://workbench.cis...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 5.9
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\5.9.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 5.9" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 5.9 (L2) Ensure 'Link-Layer Topology Discovery Mapper (lltdsvc)' is set to 'Disabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to: Disabled
 
Computer Configuration\Policies\Windows Settings\Security Settings\System Services\Link-Layer Topology Discovery Mapper
 
Impact:
 
The Network Map will not function properly.

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


800-53R5
CM-7


"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow
