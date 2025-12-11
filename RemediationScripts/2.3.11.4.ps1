<#
.SYNOPSIS
    CIS Control 2.3.11.4 - 2.3.11.4 (L1) Ensure 'Network security: Configure encryption types allowed for K

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to AES128_HMAC_SHA1, AES256_HMAC_SHA1, Future encryption types :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\Network security: Configure encryption types allowed for ...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 2.3.11.4
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\2.3.11.4.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 2.3.11.4" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 2.3.11.4 (L1) Ensure 'Network security: Configure encryption types allowed for Kerberos' is set to 'AES128_HMAC_SHA1, AES256_HMAC_SHA1, Future encryption types'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to AES128_HMAC_SHA1, AES256_HMAC_SHA1, Future encryption types :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\Network security: Configure encryption types allowed for Kerberos
 
Impact:
 
If not selected, the encryption type will not be allowed. This setting may affect compatibility with client computers or services and applications. Multiple selections are permitt"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow
