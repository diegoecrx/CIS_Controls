#Requires -RunAsAdministrator
<#
.SYNOPSIS
    CIS Windows 11 Enterprise - Section 18 Configuration Orchestrator
    
.DESCRIPTION
    Main script that executes modular category scripts for Section 18.
    Coordinates execution of all 8 category scripts (341 total settings).
    
.EXAMPLE
    .\section18.ps1
    .\section18.ps1 -Categories "18.1","18.9"
    .\section18.ps1 -SkipReport
#>

param(
    [string[]]$Categories,
    [switch]$SkipReport
)

$Script:StartTime = Get-Date
$Script:AllResults = @()
$Script:ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogPath = "$Script:ScriptPath\CIS_Section18_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

function Write-LogEntry {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMsg = "[$timestamp] [$Level] $Message"
    Add-Content -Path $LogPath -Value $logMsg -ErrorAction SilentlyContinue
    
    switch ($Level) {
        "SUCCESS" { Write-Host $logMsg -ForegroundColor Green }
        "ERROR"   { Write-Host $logMsg -ForegroundColor Red }
        "WARNING" { Write-Host $logMsg -ForegroundColor Yellow }
        default   { Write-Host $logMsg -ForegroundColor Gray }
    }
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  CIS Windows 11 Enterprise - Section 18 Configuration" -ForegroundColor Cyan
Write-Host "  Administrative Templates (Computer)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

Write-LogEntry "========== Section 18 Configuration Started ==========" "INFO"
$settingsDb = (Get-Content "$Script:ScriptPath\section18_settings.json" -Raw | ConvertFrom-Json)
$settingCount = ($settingsDb.Settings).Count
Write-LogEntry "Total Settings: $settingCount across 8 categories" "INFO"

$allCategories = @{
    "18.1"  = "section18_18.1_ControlPanel.ps1"
    "18.4"  = "section18_18.4_SecurityGuide.ps1"
    "18.5"  = "section18_18.5_MSSLegacy.ps1"
    "18.6"  = "section18_18.6_Network.ps1"
    "18.7"  = "section18_18.7_Printers.ps1"
    "18.8"  = "section18_18.8_StartMenu.ps1"
    "18.9"  = "section18_18.9_System.ps1"
    "18.10" = "section18_18.10_WindowsComponents.ps1"
}

if ($Categories.Count -eq 0) {
    $categoriesToRun = @("18.1", "18.4", "18.5", "18.6", "18.7", "18.8", "18.9", "18.10")
} else {
    $categoriesToRun = $Categories
}

Write-LogEntry "Categories to process: $($categoriesToRun -join ', ')" "INFO"
Write-Host "Executing: $($categoriesToRun -join ', ')" -ForegroundColor White

foreach ($cat in $categoriesToRun) {
    if ($allCategories.ContainsKey($cat)) {
        $scriptFile = Join-Path -Path $Script:ScriptPath -ChildPath $allCategories[$cat]
        if (Test-Path $scriptFile) {
            Write-LogEntry "Executing $cat..." "INFO"
            try {
                $results = & $scriptFile -Report:$(-not $SkipReport)
                $Script:AllResults += $results
                Write-LogEntry "Completed $cat successfully" "SUCCESS"
            } catch {
                $errorMsg = $_.Exception.Message
                Write-LogEntry "Failed to execute $cat : $errorMsg" "ERROR"
            }
        } else {
            Write-LogEntry "Script not found: $scriptFile" "WARNING"
            Write-Host "  [!] Missing: $($allCategories[$cat])" -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  CONFIGURATION RESULTS SUMMARY" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

if ($Script:AllResults.Count -gt 0) {
    $totalSettings = $Script:AllResults.Count
    $successCount = ($Script:AllResults | Where-Object { $_.Status -eq "Success" }).Count
    $failureCount = $totalSettings - $successCount
    
    $L1Count = ($Script:AllResults | Where-Object { $_.Level -eq "L1" }).Count
    $L1Success = ($Script:AllResults | Where-Object { $_.Level -eq "L1" -and $_.Status -eq "Success" }).Count
    $L2Count = ($Script:AllResults | Where-Object { $_.Level -eq "L2" }).Count
    $L2Success = ($Script:AllResults | Where-Object { $_.Level -eq "L2" -and $_.Status -eq "Success" }).Count
    $BLCount = ($Script:AllResults | Where-Object { $_.Level -eq "BL" }).Count
    $BLSuccess = ($Script:AllResults | Where-Object { $_.Level -eq "BL" -and $_.Status -eq "Success" }).Count
    
    Write-Host ""
    Write-Host "Total Settings Processed: $totalSettings" -ForegroundColor White
    Write-Host "  [+] Success: $successCount" -ForegroundColor Green
    Write-Host "  [-] Failed: $failureCount" -ForegroundColor Red
    Write-Host ""
    Write-Host "By Compliance Level:" -ForegroundColor White
    if ($L1Count -gt 0) { Write-Host "  L1 (Enterprise): $L1Success/$L1Count succeeded" -ForegroundColor Cyan }
    if ($L2Count -gt 0) { Write-Host "  L2 (High Security): $L2Success/$L2Count succeeded" -ForegroundColor Cyan }
    if ($BLCount -gt 0) { Write-Host "  BL (BitLocker): $BLSuccess/$BLCount succeeded" -ForegroundColor Cyan }
    
    $failedItems = $Script:AllResults | Where-Object { $_.Status -ne "Success" }
    if ($failedItems.Count -gt 0) {
        Write-Host ""
        Write-Host "Failed Items ($($failedItems.Count)):" -ForegroundColor Red
        $failedItems | ForEach-Object {
            Write-Host "  [-] $($_.Control) - $($_.Description)" -ForegroundColor Red
        }
    }
    
    if (-not $SkipReport) {
        $csvPath = "$Script:ScriptPath\section18_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
        $Script:AllResults | Export-Csv -Path $csvPath -NoTypeInformation
        Write-Host ""
        Write-Host "Report exported to: $(Split-Path -Leaf $csvPath)" -ForegroundColor Green
    }
} else {
    Write-Host "No results to report. Check log file: $(Split-Path -Leaf $LogPath)" -ForegroundColor Yellow
}

Write-Host ""
Write-LogEntry "========== Section 18 Configuration Completed ==========" "INFO"

$elapsedTime = (Get-Date) - $Script:StartTime
Write-Host "Execution Time: $([math]::Round($elapsedTime.TotalSeconds, 2)) seconds" -ForegroundColor Cyan
Write-Host ""





