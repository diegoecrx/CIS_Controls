<#
.SYNOPSIS
    CIS Control 2.3.17.2 - 2.3.17.2 (L1) Ensure 'User Account Control: Behavior of the elevation prompt for

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Prompt for consent on the secure desktop or Prompt for credentials on the secure desktop :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\User Account Control: Behavi...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 2.3.17.2
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\2.3.17.2.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 2.3.17.2" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 2.3.17.2 (L1) Ensure 'User Account Control: Behavior of the elevation prompt for administrators in Admin Approval Mode' is set to 'Prompt for consent on the secure desktop' or higher" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to Prompt for consent on the secure desktop or Prompt for credentials on the secure desktop :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\User Account Control: Behavior of the elevation prompt for administrators in Admin Approval Mode
 
Impact:
 
When an operation (including execution of a Windows binary) requires elevation of privilege, the user is prompted on th"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
