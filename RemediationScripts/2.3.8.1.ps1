<#
.SYNOPSIS
    CIS Control 2.3.8.1 - 2.3.8.1 (L1) Ensure 'Microsoft network client: Digitally sign communications (al

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\Microsoft network client: Digitally sign communications (always)
 
Impact:
 
The Microsoft network client wil...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 2.3.8.1
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\2.3.8.1.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 2.3.8.1" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 2.3.8.1 (L1) Ensure 'Microsoft network client: Digitally sign communications (always)' is set to 'Enabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to Enabled :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\Microsoft network client: Digitally sign communications (always)
 
Impact:
 
The Microsoft network client will not communicate with a Microsoft network server unless that server agrees to perform SMB packet signing.
 
The Windows 2000 Server, Windows 2000 Professional, Windows Server 2003, Windows XP Profess"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow
