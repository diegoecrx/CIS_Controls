<#
.SYNOPSIS
    CIS Control 2.3.4.1 - 2.3.4.1 (L2) Ensure 'Devices: Prevent users from installing printer drivers' is 

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\Devices: Prevent users from installing printer drivers
 
Impact:
 
Only Administrators will be able to instal...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 2.3.4.1
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\2.3.4.1.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 2.3.4.1" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 2.3.4.1 (L2) Ensure 'Devices: Prevent users from installing printer drivers' is set to 'Enabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to Enabled :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\Devices: Prevent users from installing printer drivers
 
Impact:
 
Only Administrators will be able to install a printer driver as part of connecting to a shared printer. The ability to add a local printer will not be affected.

See Also

https://workbench.cisecurity.org/benchmarks/21318

References








"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow
