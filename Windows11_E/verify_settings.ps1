$settingsDb = Import-PowerShellDataFile -Path "C:\Users\DiegoCamargo\Downloads\Windows11_E\section18_settings.psd1"

$correctValues = @{
    "18.10.13.2" = @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"; Name = "DisableCloudOptimizedContent"; Value = 1 }
    "18.10.15.3" = @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"; Name = "NoLocalPasswordResetQuestions"; Value = 1 }
    "18.10.16.2" = @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; Name = "DisableEnterpriseAuthProxy"; Value = 1 }
    "18.10.17.1" = @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"; Name = "DODownloadMode"; Value = 1 }
    "18.10.18.1" = @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller"; Name = "EnableAppInstaller"; Value = 0 }
    "18.10.18.2" = @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller"; Name = "EnableExperimentalFeatures"; Value = 0 }
    "18.10.18.3" = @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller"; Name = "EnableHashOverride"; Value = 0 }
    "18.10.18.4" = @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller"; Name = "EnableLocalArchiveMalwareScanOverride"; Value = 0 }
    "18.10.18.5" = @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller"; Name = "EnableBypassCertificatePinningForMicrosoftStore"; Value = 0 }
    "18.10.18.6" = @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller"; Name = "EnableMSAppInstallerProtocol"; Value = 0 }
    "18.10.18.7" = @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller"; Name = "EnableWindowsPackageManagerCommandLineInterfaces"; Value = 0 }
}

$output = @()

foreach ($ctrl in $correctValues.Keys | Sort-Object) {
    $correct = $correctValues[$ctrl]
    $current = $settingsDb.Settings | Where-Object { $_.Control -eq $ctrl }
    
    if (-not $current) {
        $output += "$ctrl - MISSING"
        continue
    }
    
    $pathOK = $current.Path -eq $correct.Path
    $nameOK = $current.Name -eq $correct.Name
    $valueOK = [int]$current.Value -eq [int]$correct.Value
    
    if ($pathOK -and $nameOK -and $valueOK) {
        $output += "$ctrl - OK"
    } else {
        $output += "$ctrl - MISMATCH"
        if (-not $pathOK) { $output += "  Path: $($current.Path) != $($correct.Path)" }
        if (-not $nameOK) { $output += "  Name: $($current.Name) != $($correct.Name)" }
        if (-not $valueOK) { $output += "  Value: $($current.Value) != $($correct.Value)" }
    }
}

$output | Out-File "C:\Users\DiegoCamargo\Downloads\Windows11_E\verify_result.txt" -Encoding UTF8
