#Requires -RunAsAdministrator
<#
.SYNOPSIS
    CIS Windows 11 Enterprise Benchmark - Section 17: Advanced Audit Policy Configuration
    
.DESCRIPTION
    This script implements CIS Benchmark Section 17 recommendations for Advanced Audit Policy
    Configuration. It uses auditpol.exe to configure audit subcategories for security monitoring.
    
    All settings are Level 1 (L1) - Corporate/Enterprise Environment recommendations.
    
.NOTES
    Version:        1.1
    Author:         CIS Benchmark Implementation
    Benchmark:      CIS Microsoft Windows 11 Enterprise v3.0.0
    Section:        17 - Advanced Audit Policy Configuration
    
.EXAMPLE
    .\section17.ps1
    Runs the script and applies all Section 17 CIS benchmark configurations.
#>

# Script-level variables for tracking changes
$Script:Changes = @()
$Script:Errors = @()
$Script:StartTime = Get-Date

# Log file setup
$LogPath = "$PSScriptRoot\CIS_Section17_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('INFO', 'WARNING', 'ERROR', 'SUCCESS')]
        [string]$Level = 'INFO'
    )

    $Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $LogMessage = "[$Timestamp] [$Level] $Message"

    switch ($Level) {
        'ERROR'   { Write-Host $LogMessage -ForegroundColor Red }
        'WARNING' { Write-Host $LogMessage -ForegroundColor Yellow }
        'SUCCESS' { Write-Host $LogMessage -ForegroundColor Green }
        default   { Write-Host $LogMessage -ForegroundColor White }
    }

    Add-Content -Path $LogPath -Value $LogMessage
}

function Get-AuditPolicySetting {
    param(
        [string]$Subcategory
    )

    try {
        # Get the audit policy output and convert to string array
        $output = auditpol /get /subcategory:"$Subcategory" 2>&1 | Out-String
        
        # Parse the output to find the setting value
        # The output format is typically:
        # System audit policy
        # Category/Subcategory                      Setting
        # Subcategory Name                          Success and Failure (or Success, Failure, No Auditing)
        
        $lines = $output -split "`r?`n" | Where-Object { $_.Trim() -ne '' }
        
        foreach ($line in $lines) {
            # Look for the line that contains the actual setting
            if ($line -match '\s+(Success and Failure|Success|Failure|No Auditing)\s*$') {
                return $Matches[1]
            }
        }
        
        # Alternative parsing - check for common patterns
        if ($output -match "(Success and Failure)") {
            return "Success and Failure"
        }
        elseif ($output -match "(\bSuccess\b)" -and $output -match "(\bFailure\b)") {
            return "Success and Failure"
        }
        elseif ($output -match "(?<!\S)(Success)(?!\s+and)") {
            return "Success"
        }
        elseif ($output -match "(?<!\S)(Failure)(?!\s)") {
            return "Failure"
        }
        elseif ($output -match "(No Auditing)") {
            return "No Auditing"
        }
        
        return "Unknown"
    }
    catch {
        return "Error: $($_.Exception.Message)"
    }
}

function Set-AuditPolicySetting {
    param(
        [string]$CISControl,
        [string]$Description,
        [string]$Subcategory,
        [string]$SubcategoryGUID,
        [ValidateSet('Success', 'Failure', 'Success and Failure', 'No Auditing')]
        [string]$Setting
    )

    try {
        # Get current value
        $CurrentValue = Get-AuditPolicySetting -Subcategory $Subcategory

        # Build the auditpol command based on setting
        switch ($Setting) {
            'Success' {
                $Result = auditpol /set /subcategory:"$SubcategoryGUID" /success:enable /failure:disable 2>&1
            }
            'Failure' {
                $Result = auditpol /set /subcategory:"$SubcategoryGUID" /success:disable /failure:enable 2>&1
            }
            'Success and Failure' {
                $Result = auditpol /set /subcategory:"$SubcategoryGUID" /success:enable /failure:enable 2>&1
            }
            'No Auditing' {
                $Result = auditpol /set /subcategory:"$SubcategoryGUID" /success:disable /failure:disable 2>&1
            }
        }

        # Verify the change
        $NewValue = Get-AuditPolicySetting -Subcategory $Subcategory

        # Check if command succeeded
        if ($LASTEXITCODE -eq 0) {
            $Script:Changes += [PSCustomObject]@{
                CISControl   = $CISControl
                Description  = $Description
                Subcategory  = $Subcategory
                GUID         = $SubcategoryGUID
                OldValue     = $CurrentValue
                NewValue     = $NewValue
                TargetValue  = $Setting
                Status       = 'Applied'
            }

            Write-Log "[$CISControl] $Description - Changed from '$CurrentValue' to '$NewValue'" -Level SUCCESS
            return $true
        }
        else {
            throw "auditpol command failed: $Result"
        }
    }
    catch {
        $Script:Errors += [PSCustomObject]@{
            CISControl   = $CISControl
            Description  = $Description
            Subcategory  = $Subcategory
            Error        = $_.Exception.Message
        }

        Write-Log "[$CISControl] Failed to apply $Description - $($_.Exception.Message)" -Level ERROR
        return $false
    }
}

# ============================================================================
# Section 17 - Advanced Audit Policy Configuration
# ============================================================================

Write-Log ("=" * 80) -Level INFO
Write-Log "CIS Windows 11 Enterprise - Section 17: Advanced Audit Policy Configuration" -Level INFO
Write-Log "Starting configuration at $(Get-Date)" -Level INFO
Write-Log ("=" * 80) -Level INFO

# ============================================================================
# Section 17.1 - Account Logon
# ============================================================================

Write-Log "--- Section 17.1: Account Logon ---" -Level INFO

# 17.1.1 (L1) Ensure 'Audit Credential Validation' is set to 'Success and Failure'
Set-AuditPolicySetting `
    -CISControl "17.1.1" `
    -Description "Audit Credential Validation" `
    -Subcategory "Credential Validation" `
    -SubcategoryGUID "{0cce923f-69ae-11d9-bed3-505054503030}" `
    -Setting "Success and Failure"

# ============================================================================
# Section 17.2 - Account Management
# ============================================================================

Write-Log "--- Section 17.2: Account Management ---" -Level INFO

# 17.2.1 (L1) Ensure 'Audit Application Group Management' is set to 'Success and Failure'
Set-AuditPolicySetting `
    -CISControl "17.2.1" `
    -Description "Audit Application Group Management" `
    -Subcategory "Application Group Management" `
    -SubcategoryGUID "{0cce9239-69ae-11d9-bed3-505054503030}" `
    -Setting "Success and Failure"

# 17.2.2 (L1) Ensure 'Audit Security Group Management' is set to include 'Success'
Set-AuditPolicySetting `
    -CISControl "17.2.2" `
    -Description "Audit Security Group Management" `
    -Subcategory "Security Group Management" `
    -SubcategoryGUID "{0cce9237-69ae-11d9-bed3-505054503030}" `
    -Setting "Success"

# 17.2.3 (L1) Ensure 'Audit User Account Management' is set to 'Success and Failure'
Set-AuditPolicySetting `
    -CISControl "17.2.3" `
    -Description "Audit User Account Management" `
    -Subcategory "User Account Management" `
    -SubcategoryGUID "{0cce9235-69ae-11d9-bed3-505054503030}" `
    -Setting "Success and Failure"

# ============================================================================
# Section 17.3 - Detailed Tracking
# ============================================================================

Write-Log "--- Section 17.3: Detailed Tracking ---" -Level INFO

# 17.3.1 (L1) Ensure 'Audit PNP Activity' is set to include 'Success'
Set-AuditPolicySetting `
    -CISControl "17.3.1" `
    -Description "Audit PNP Activity" `
    -Subcategory "Plug and Play Events" `
    -SubcategoryGUID "{0cce9248-69ae-11d9-bed3-505054503030}" `
    -Setting "Success"

# 17.3.2 (L1) Ensure 'Audit Process Creation' is set to include 'Success'
Set-AuditPolicySetting `
    -CISControl "17.3.2" `
    -Description "Audit Process Creation" `
    -Subcategory "Process Creation" `
    -SubcategoryGUID "{0cce922b-69ae-11d9-bed3-505054503030}" `
    -Setting "Success"

# ============================================================================
# Section 17.5 - Logon/Logoff
# ============================================================================

Write-Log "--- Section 17.5: Logon/Logoff ---" -Level INFO

# 17.5.1 (L1) Ensure 'Audit Account Lockout' is set to include 'Failure'
Set-AuditPolicySetting `
    -CISControl "17.5.1" `
    -Description "Audit Account Lockout" `
    -Subcategory "Account Lockout" `
    -SubcategoryGUID "{0cce9217-69ae-11d9-bed3-505054503030}" `
    -Setting "Failure"

# 17.5.2 (L1) Ensure 'Audit Group Membership' is set to include 'Success'
Set-AuditPolicySetting `
    -CISControl "17.5.2" `
    -Description "Audit Group Membership" `
    -Subcategory "Group Membership" `
    -SubcategoryGUID "{0cce9249-69ae-11d9-bed3-505054503030}" `
    -Setting "Success"

# 17.5.3 (L1) Ensure 'Audit Logoff' is set to include 'Success'
Set-AuditPolicySetting `
    -CISControl "17.5.3" `
    -Description "Audit Logoff" `
    -Subcategory "Logoff" `
    -SubcategoryGUID "{0cce9216-69ae-11d9-bed3-505054503030}" `
    -Setting "Success"

# 17.5.4 (L1) Ensure 'Audit Logon' is set to 'Success and Failure'
Set-AuditPolicySetting `
    -CISControl "17.5.4" `
    -Description "Audit Logon" `
    -Subcategory "Logon" `
    -SubcategoryGUID "{0cce9215-69ae-11d9-bed3-505054503030}" `
    -Setting "Success and Failure"

# 17.5.5 (L1) Ensure 'Audit Other Logon/Logoff Events' is set to 'Success and Failure'
Set-AuditPolicySetting `
    -CISControl "17.5.5" `
    -Description "Audit Other Logon/Logoff Events" `
    -Subcategory "Other Logon/Logoff Events" `
    -SubcategoryGUID "{0cce921c-69ae-11d9-bed3-505054503030}" `
    -Setting "Success and Failure"

# 17.5.6 (L1) Ensure 'Audit Special Logon' is set to include 'Success'
Set-AuditPolicySetting `
    -CISControl "17.5.6" `
    -Description "Audit Special Logon" `
    -Subcategory "Special Logon" `
    -SubcategoryGUID "{0cce921b-69ae-11d9-bed3-505054503030}" `
    -Setting "Success"

# ============================================================================
# Section 17.6 - Object Access
# ============================================================================

Write-Log "--- Section 17.6: Object Access ---" -Level INFO

# 17.6.1 (L1) Ensure 'Audit Detailed File Share' is set to include 'Failure'
Set-AuditPolicySetting `
    -CISControl "17.6.1" `
    -Description "Audit Detailed File Share" `
    -Subcategory "Detailed File Share" `
    -SubcategoryGUID "{0cce9244-69ae-11d9-bed3-505054503030}" `
    -Setting "Failure"

# 17.6.2 (L1) Ensure 'Audit File Share' is set to 'Success and Failure'
Set-AuditPolicySetting `
    -CISControl "17.6.2" `
    -Description "Audit File Share" `
    -Subcategory "File Share" `
    -SubcategoryGUID "{0cce9224-69ae-11d9-bed3-505054503030}" `
    -Setting "Success and Failure"

# 17.6.3 (L1) Ensure 'Audit Other Object Access Events' is set to 'Success and Failure'
Set-AuditPolicySetting `
    -CISControl "17.6.3" `
    -Description "Audit Other Object Access Events" `
    -Subcategory "Other Object Access Events" `
    -SubcategoryGUID "{0cce9227-69ae-11d9-bed3-505054503030}" `
    -Setting "Success and Failure"

# 17.6.4 (L1) Ensure 'Audit Removable Storage' is set to 'Success and Failure'
Set-AuditPolicySetting `
    -CISControl "17.6.4" `
    -Description "Audit Removable Storage" `
    -Subcategory "Removable Storage" `
    -SubcategoryGUID "{0cce9245-69ae-11d9-bed3-505054503030}" `
    -Setting "Success and Failure"

# ============================================================================
# Section 17.7 - Policy Change
# ============================================================================

Write-Log "--- Section 17.7: Policy Change ---" -Level INFO

# 17.7.1 (L1) Ensure 'Audit Audit Policy Change' is set to include 'Success'
Set-AuditPolicySetting `
    -CISControl "17.7.1" `
    -Description "Audit Audit Policy Change" `
    -Subcategory "Audit Policy Change" `
    -SubcategoryGUID "{0cce922f-69ae-11d9-bed3-505054503030}" `
    -Setting "Success"

# 17.7.2 (L1) Ensure 'Audit Authentication Policy Change' is set to include 'Success'
Set-AuditPolicySetting `
    -CISControl "17.7.2" `
    -Description "Audit Authentication Policy Change" `
    -Subcategory "Authentication Policy Change" `
    -SubcategoryGUID "{0cce9230-69ae-11d9-bed3-505054503030}" `
    -Setting "Success"

# 17.7.3 (L1) Ensure 'Audit Authorization Policy Change' is set to include 'Success'
Set-AuditPolicySetting `
    -CISControl "17.7.3" `
    -Description "Audit Authorization Policy Change" `
    -Subcategory "Authorization Policy Change" `
    -SubcategoryGUID "{0cce9231-69ae-11d9-bed3-505054503030}" `
    -Setting "Success"

# 17.7.4 (L1) Ensure 'Audit MPSSVC Rule-Level Policy Change' is set to 'Success and Failure'
Set-AuditPolicySetting `
    -CISControl "17.7.4" `
    -Description "Audit MPSSVC Rule-Level Policy Change" `
    -Subcategory "MPSSVC Rule-Level Policy Change" `
    -SubcategoryGUID "{0cce9232-69ae-11d9-bed3-505054503030}" `
    -Setting "Success and Failure"

# 17.7.5 (L1) Ensure 'Audit Other Policy Change Events' is set to include 'Failure'
Set-AuditPolicySetting `
    -CISControl "17.7.5" `
    -Description "Audit Other Policy Change Events" `
    -Subcategory "Other Policy Change Events" `
    -SubcategoryGUID "{0cce9234-69ae-11d9-bed3-505054503030}" `
    -Setting "Failure"

# ============================================================================
# Section 17.8 - Privilege Use
# ============================================================================

Write-Log "--- Section 17.8: Privilege Use ---" -Level INFO

# 17.8.1 (L1) Ensure 'Audit Sensitive Privilege Use' is set to 'Success and Failure'
Set-AuditPolicySetting `
    -CISControl "17.8.1" `
    -Description "Audit Sensitive Privilege Use" `
    -Subcategory "Sensitive Privilege Use" `
    -SubcategoryGUID "{0cce9228-69ae-11d9-bed3-505054503030}" `
    -Setting "Success and Failure"

# ============================================================================
# Section 17.9 - System
# ============================================================================

Write-Log "--- Section 17.9: System ---" -Level INFO

# 17.9.1 (L1) Ensure 'Audit IPsec Driver' is set to 'Success and Failure'
Set-AuditPolicySetting `
    -CISControl "17.9.1" `
    -Description "Audit IPsec Driver" `
    -Subcategory "IPsec Driver" `
    -SubcategoryGUID "{0cce9213-69ae-11d9-bed3-505054503030}" `
    -Setting "Success and Failure"

# 17.9.2 (L1) Ensure 'Audit Other System Events' is set to 'Success and Failure'
Set-AuditPolicySetting `
    -CISControl "17.9.2" `
    -Description "Audit Other System Events" `
    -Subcategory "Other System Events" `
    -SubcategoryGUID "{0cce9214-69ae-11d9-bed3-505054503030}" `
    -Setting "Success and Failure"

# 17.9.3 (L1) Ensure 'Audit Security State Change' is set to include 'Success'
Set-AuditPolicySetting `
    -CISControl "17.9.3" `
    -Description "Audit Security State Change" `
    -Subcategory "Security State Change" `
    -SubcategoryGUID "{0cce9210-69ae-11d9-bed3-505054503030}" `
    -Setting "Success"

# 17.9.4 (L1) Ensure 'Audit Security System Extension' is set to include 'Success'
Set-AuditPolicySetting `
    -CISControl "17.9.4" `
    -Description "Audit Security System Extension" `
    -Subcategory "Security System Extension" `
    -SubcategoryGUID "{0cce9211-69ae-11d9-bed3-505054503030}" `
    -Setting "Success"

# 17.9.5 (L1) Ensure 'Audit System Integrity' is set to 'Success and Failure'
Set-AuditPolicySetting `
    -CISControl "17.9.5" `
    -Description "Audit System Integrity" `
    -Subcategory "System Integrity" `
    -SubcategoryGUID "{0cce9212-69ae-11d9-bed3-505054503030}" `
    -Setting "Success and Failure"

# ============================================================================
# Summary Report
# ============================================================================

Write-Log ("=" * 80) -Level INFO
Write-Log "CONFIGURATION SUMMARY" -Level INFO
Write-Log ("=" * 80) -Level INFO

$EndTime = Get-Date
$Duration = $EndTime - $Script:StartTime

Write-Log "Completed at: $EndTime" -Level INFO
Write-Log "Duration: $($Duration.TotalSeconds) seconds" -Level INFO
Write-Log "" -Level INFO

# Summary statistics
$TotalChanges = $Script:Changes.Count
$TotalErrors = $Script:Errors.Count

Write-Log "Total audit policies configured: $TotalChanges" -Level INFO
Write-Log "Total errors encountered: $TotalErrors" -Level $(if ($TotalErrors -gt 0) { 'WARNING' } else { 'SUCCESS' })

# Summary by category
Write-Log "" -Level INFO
Write-Log "CATEGORY SUMMARY:" -Level INFO
Write-Log ("-" * 40) -Level INFO

$Categories = @{
    "17.1" = "Account Logon"
    "17.2" = "Account Management"
    "17.3" = "Detailed Tracking"
    "17.5" = "Logon/Logoff"
    "17.6" = "Object Access"
    "17.7" = "Policy Change"
    "17.8" = "Privilege Use"
    "17.9" = "System"
}

foreach ($Cat in $Categories.GetEnumerator() | Sort-Object Name) {
    $Count = ($Script:Changes | Where-Object { $_.CISControl -like "$($Cat.Name).*" }).Count
    Write-Log "$($Cat.Value): $Count settings configured" -Level INFO
}

# Detailed changes report
if ($Script:Changes.Count -gt 0) {
    Write-Log "" -Level INFO
    Write-Log "DETAILED CHANGES:" -Level INFO
    Write-Log ("-" * 80) -Level INFO

    foreach ($Change in $Script:Changes) {
        Write-Log "[$($Change.CISControl)] $($Change.Description)" -Level INFO
        Write-Log "    Subcategory: $($Change.Subcategory)" -Level INFO
        Write-Log "    GUID: $($Change.GUID)" -Level INFO
        Write-Log "    Before: $($Change.OldValue)" -Level INFO
        Write-Log "    After: $($Change.NewValue)" -Level INFO
        Write-Log "    Target: $($Change.TargetValue)" -Level INFO
        Write-Log "" -Level INFO
    }
}

# Error report
if ($Script:Errors.Count -gt 0) {
    Write-Log "" -Level INFO
    Write-Log "ERRORS ENCOUNTERED:" -Level ERROR
    Write-Log ("-" * 80) -Level INFO

    foreach ($Err in $Script:Errors) {
        Write-Log "[$($Err.CISControl)] $($Err.Description)" -Level ERROR
        Write-Log "    Subcategory: $($Err.Subcategory)" -Level ERROR
        Write-Log "    Error: $($Err.Error)" -Level ERROR
        Write-Log "" -Level INFO
    }
}

# Export reports to CSV
$ReportPath = "$PSScriptRoot\CIS_Section17_Changes_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
$Script:Changes | Export-Csv -Path $ReportPath -NoTypeInformation
Write-Log "Changes exported to: $ReportPath" -Level INFO

if ($Script:Errors.Count -gt 0) {
    $ErrorReportPath = "$PSScriptRoot\CIS_Section17_Errors_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
    $Script:Errors | Export-Csv -Path $ErrorReportPath -NoTypeInformation
    Write-Log "Errors exported to: $ErrorReportPath" -Level WARNING
}

# Export current audit policy for verification
Write-Log "" -Level INFO
Write-Log "Exporting current audit policy for verification..." -Level INFO
$AuditExportPath = "$PSScriptRoot\CIS_Section17_AuditPolicy_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
auditpol /get /category:* | Out-File -FilePath $AuditExportPath -Encoding UTF8
Write-Log "Audit policy exported to: $AuditExportPath" -Level INFO

Write-Log "" -Level INFO
Write-Log "CIS Windows 11 Enterprise Section 17 - Advanced Audit Policy configuration complete." -Level SUCCESS
Write-Log "Log file: $LogPath" -Level INFO

# Return summary object
[PSCustomObject]@{
    TotalChanges         = $TotalChanges
    TotalErrors          = $TotalErrors
    Duration             = $Duration.TotalSeconds
    LogFile              = $LogPath
    ReportFile           = $ReportPath
    AuditPolicyExport    = $AuditExportPath
    AccountLogon         = ($Script:Changes | Where-Object { $_.CISControl -like "17.1.*" }).Count
    AccountManagement    = ($Script:Changes | Where-Object { $_.CISControl -like "17.2.*" }).Count
    DetailedTracking     = ($Script:Changes | Where-Object { $_.CISControl -like "17.3.*" }).Count
    LogonLogoff          = ($Script:Changes | Where-Object { $_.CISControl -like "17.5.*" }).Count
    ObjectAccess         = ($Script:Changes | Where-Object { $_.CISControl -like "17.6.*" }).Count
    PolicyChange         = ($Script:Changes | Where-Object { $_.CISControl -like "17.7.*" }).Count
    PrivilegeUse         = ($Script:Changes | Where-Object { $_.CISControl -like "17.8.*" }).Count
    System               = ($Script:Changes | Where-Object { $_.CISControl -like "17.9.*" }).Count
}
