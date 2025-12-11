<#
.SYNOPSIS
    CIS Control 19.5.1.1 - 19.5.1.1 (L1) Ensure 'Turn off toast notifications on the lock screen' is set to

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled :
 
User Configuration\Policies\Administrative Templates\Start Menu and Taskbar\Notifications\Turn off toast notifications on the lock screen
 
Note: This Group Policy path may not exist by default. It is provide...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 19.5.1.1
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\19.5.1.1.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 19.5.1.1" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 19.5.1.1 (L1) Ensure 'Turn off toast notifications on the lock screen' is set to 'Enabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to Enabled :
 
User Configuration\Policies\Administrative Templates\Start Menu and Taskbar\Notifications\Turn off toast notifications on the lock screen
 
Note: This Group Policy path may not exist by default. It is provided by the Group Policy template WPN.admx/adml that is included with the Microsoft Windows 8.0 & Server 2012 (non-R2) Administrative Templates (or newer).
 
Impact:
 
Applications will not be able to ra"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
