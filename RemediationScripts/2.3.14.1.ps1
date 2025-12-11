<#
.SYNOPSIS
    CIS Control 2.3.14.1 - 2.3.14.1 (L2) Ensure 'System cryptography: Force strong key protection for user 

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to User is prompted when the key is first used or User must enter a password each time they use a key :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\System cryptograph...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 2.3.14.1
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\2.3.14.1.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 2.3.14.1" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 2.3.14.1 (L2) Ensure 'System cryptography: Force strong key protection for user keys stored on the computer' is set to 'User is prompted when the key is first used' or higher" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to User is prompted when the key is first used or User must enter a password each time they use a key :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\System cryptography: Force strong key protection for user keys stored on the computer
 
Impact:
 
Users will have to enter their password the first time they access a key that is stored on their computer. For example, "
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow
