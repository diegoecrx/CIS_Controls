<#
.SYNOPSIS
    CIS Control 5.36 - 5.36 (L2) Ensure 'Windows Remote Management (WS-Management) (WinRM)' is set to '

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to: Disabled
 
Computer Configuration\Policies\Windows Settings\Security Settings\System Services\Windows Remote Management (WS-Management)
 
Impact:
 
The ability to remotely manage the system with WinRM will be lost.
 
No...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 5.36
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\5.36.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 5.36" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 5.36 (L2) Ensure 'Windows Remote Management (WS-Management) (WinRM)' is set to 'Disabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to: Disabled
 
Computer Configuration\Policies\Windows Settings\Security Settings\System Services\Windows Remote Management (WS-Management)
 
Impact:
 
The ability to remotely manage the system with WinRM will be lost.
 
Note: Many remote administration tools, such as System Center Configuration Manager (SCCM), may require the WinRM service to be operational for remote management.

See Also

https://workbench.cisecurity"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
