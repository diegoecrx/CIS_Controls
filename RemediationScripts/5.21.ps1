<#
.SYNOPSIS
    CIS Control 5.21 - 5.21 (L2) Ensure 'Remote Registry (RemoteRegistry)' is set to 'Disabled'

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to: Disabled
 
Computer Configuration\Policies\Windows Settings\Security Settings\System Services\Remote Registry
 
Impact:
 
The registry can be viewed and modified only by users on the computer.
 
Note: Many remote admini...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 5.21
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\5.21.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 5.21" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 5.21 (L2) Ensure 'Remote Registry (RemoteRegistry)' is set to 'Disabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to: Disabled
 
Computer Configuration\Policies\Windows Settings\Security Settings\System Services\Remote Registry
 
Impact:
 
The registry can be viewed and modified only by users on the computer.
 
Note: Many remote administration tools, such as System Center Configuration Manager (SCCM), require the Remote Registry service to be operational for remote management. In addition, many vulnerability scanners use this servi"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
