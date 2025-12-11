<#
.SYNOPSIS
    CIS Control 2.3.7.9 - 2.3.7.9 (L1) Ensure 'Interactive logon: Smart card removal behavior' is set to '

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Lock Workstation (or, if applicable for your environment, Force Logoff or Disconnect if a Remote Desktop Services session ):
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Op...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 2.3.7.9
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\2.3.7.9.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 2.3.7.9" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 2.3.7.9 (L1) Ensure 'Interactive logon: Smart card removal behavior' is set to 'Lock Workstation' or higher" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to Lock Workstation (or, if applicable for your environment, Force Logoff or Disconnect if a Remote Desktop Services session ):
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\Interactive logon: Smart card removal behavior
 
Impact:
 
If you select Lock Workstation the workstation is locked when the smart card is removed, allowing users to leave the area, take their s"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
