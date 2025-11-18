# Member Server Configuration Script
# Run this on WS2025-MS (192.168.30.21) AFTER domain controller is fully configured
# Run as Administrator

# Configuration Variables
$DomainName = "CORP.CONTOSO.COM"
$DomainAdmin = "CORP\john.doe"
$DomainAdminPassword = "P@ssw0rd123!"
$IPAddress = "192.168.30.21"
$SubnetMask = "255.255.255.0"
$DefaultGateway = "192.168.30.1"
$DNSServer = "192.168.30.20"

Write-Host "Starting Member Server Configuration..." -ForegroundColor Green

# Step 1: Configure Network Settings
Write-Host "Configuring Network Settings..." -ForegroundColor Yellow
$NetworkAdapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up" -and $_.Name -notlike "*Loopback*"}
Remove-NetIPAddress -InterfaceIndex $NetworkAdapter.InterfaceIndex -Confirm:$false -ErrorAction SilentlyContinue
New-NetIPAddress -InterfaceIndex $NetworkAdapter.InterfaceIndex -IPAddress $IPAddress -PrefixLength 24 -DefaultGateway $DefaultGateway
Set-DnsClientServerAddress -InterfaceIndex $NetworkAdapter.InterfaceIndex -ServerAddresses $DNSServer

# Step 2: Change Computer Name and Reboot
Write-Host "Changing Computer Name..." -ForegroundColor Yellow
Rename-Computer -NewName "WS2025-MS" -Force
Write-Host "Computer name changed. Rebooting in 10 seconds..." -ForegroundColor Yellow
Start-Sleep -Seconds 10
Restart-Computer -Force

# After reboot, continue with domain join...

# Step 3: Join Domain (Run this part manually after first reboot if needed)
Write-Host "Joining Domain..." -ForegroundColor Yellow
$SecurePassword = ConvertTo-SecureString $DomainAdminPassword -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($DomainAdmin, $SecurePassword)

Add-Computer -DomainName $DomainName -Credential $Credential -Force -Restart

# After domain join reboot, continue with post-join configuration...

# Step 4: Post-Domain Join Configuration
Write-Host "Configuring Post-Domain Join Settings..." -ForegroundColor Yellow

# Step 5: Install Required Windows Features
Write-Host "Installing Windows Features..." -ForegroundColor Yellow
$Features = @(
    "Web-Server",
    "File-Services",
    "FS-FileServer",
    "RSAT-AD-Tools",
    "Web-Mgmt-Tools"
)

foreach ($Feature in $Features) {
    try {
        Install-WindowsFeature -Name $Feature -IncludeManagementTools
        Write-Host "Installed feature: $Feature" -ForegroundColor Green
    } catch {
        Write-Host "Feature $Feature installation error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Step 6: Create Application Directories and Shares
Write-Host "Creating Application Directories and Shares..." -ForegroundColor Yellow
$AppDirectories = @(
    "C:\Applications\WebApps",
    "C:\Applications\Data",
    "C:\Applications\Logs",
    "C:\Backup",
    "C:\Software"
)

foreach ($Directory in $AppDirectories) {
    try {
        New-Item -Path $Directory -ItemType Directory -Force
        Write-Host "Created directory: $Directory" -ForegroundColor Green
    } catch {
        Write-Host "Directory $Directory creation error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Step 7: Configure Application Shares with Permissions
Write-Host "Configuring Shares and Permissions..." -ForegroundColor Yellow
$Shares = @(
    @{Name = "Apps"; Path = "C:\Applications"; Description = "Applications Share"; ReadAccess = @("CORP\Domain Users"); FullAccess = @("CORP\IT_Admins")},
    @{Name = "Backup"; Path = "C:\Backup"; Description = "Backup Share"; ReadAccess = @("CORP\Server_Admins"); FullAccess = @("CORP\IT_Admins")},
    @{Name = "Software"; Path = "C:\Software"; Description = "Software Repository"; ReadAccess = @("CORP\Domain Users"); FullAccess = @("CORP\IT_Admins")}
)

foreach ($Share in $Shares) {
    try {
        # Remove existing share if it exists
        Remove-SmbShare -Name $Share.Name -Force -ErrorAction SilentlyContinue
        
        # Create new share
        New-SmbShare -Name $Share.Name -Path $Share.Path -Description $Share.Description
        
        # Configure permissions
        foreach ($User in $Share.ReadAccess) {
            Grant-SmbShareAccess -Name $Share.Name -AccountName $User -AccessRight Read -Force
        }
        
        foreach ($User in $Share.FullAccess) {
            Grant-SmbShareAccess -Name $Share.Name -AccountName $User -AccessRight Full -Force
        }
        
        # Set NTFS permissions
        $Acl = Get-Acl $Share.Path
        foreach ($User in $Share.ReadAccess) {
            $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($User, "ReadAndExecute", "ContainerInherit,ObjectInherit", "None", "Allow")
            $Acl.AddAccessRule($AccessRule)
        }
        foreach ($User in $Share.FullAccess) {
            $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($User, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
            $Acl.AddAccessRule($AccessRule)
        }
        Set-Acl -Path $Share.Path -AclObject $Acl
        
        Write-Host "Configured share: $($Share.Name)" -ForegroundColor Green
    } catch {
        Write-Host "Share $($Share.Name) configuration error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Step 8: Install and Configure Web Server (IIS)
Write-Host "Configuring IIS Web Server..." -ForegroundColor Yellow
try {
    # Install IIS
    Install-WindowsFeature -Name Web-Server -IncludeManagementTools
    
    # Create sample web application
    $WebContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>CORP Application Server</title>
</head>
<body>
    <h1>Welcome to CORP Application Server</h1>
    <p>Server: WS2025-MS</p>
    <p>Domain: CORP.CONTOSO.COM</p>
    <p>This is a test page served from the member server.</p>
</body>
</html>
"@
    
    Set-Content -Path "C:\inetpub\wwwroot\index.html" -Value $WebContent -Force
    
    # Configure IIS basic settings
    Import-Module WebAdministration
    Set-WebBinding -Name 'Default Web Site' -BindingInformation "*:80:" -PropertyName Port -Value 8080
    
    Write-Host "IIS configured successfully" -ForegroundColor Green
} catch {
    Write-Host "IIS configuration error: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 9: Configure Windows Firewall Rules
Write-Host "Configuring Windows Firewall..." -ForegroundColor Yellow
try {
    # Allow ICMP (ping)
    New-NetFirewallRule -DisplayName "Allow ICMPv4" -Name "Allow_ICMPv4" -Protocol ICMPv4 -Enabled True -Profile Any -Action Allow
    
    # Allow web traffic
    New-NetFirewallRule -DisplayName "Allow HTTP" -Name "Allow_HTTP" -Protocol TCP -LocalPort 80,8080 -Enabled True -Profile Any -Action Allow
    
    # Allow file sharing
    New-NetFirewallRule -DisplayName "Allow SMB" -Name "Allow_SMB" -Protocol TCP -LocalPort 445 -Enabled True -Profile Any -Action Allow
    
    Write-Host "Firewall configured" -ForegroundColor Green
} catch {
    Write-Host "Firewall configuration error: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 10: Configure Event Log Settings
Write-Host "Configuring Event Logs..." -ForegroundColor Yellow
try {
    Limit-EventLog -LogName "Application" -MaximumSize 1024MB
    Limit-EventLog -LogName "System" -MaximumSize 1024MB
    Limit-EventLog -LogName "Security" -MaximumSize 2048MB
    Write-Host "Event logs configured" -ForegroundColor Green
} catch {
    Write-Host "Event log configuration error: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 11: Create Scheduled Tasks for Maintenance
Write-Host "Creating Maintenance Tasks..." -ForegroundColor Yellow
try {
    $Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-Command `"Get-ChildItem C:\Applications\Logs\*.log -Recurse | Where-Object LastWriteTime -lt (Get-Date).AddDays(-30) | Remove-Item -Force`""
    $Trigger = New-ScheduledTaskTrigger -Daily -At "2:00 AM"
    $Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    Register-ScheduledTask -TaskName "Cleanup Old Logs" -Action $Action -Trigger $Trigger -Principal $Principal -Description "Cleanup log files older than 30 days"
    
    Write-Host "Scheduled tasks created" -ForegroundColor Green
} catch {
    Write-Host "Scheduled task creation error: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 12: Configure Performance Monitoring
Write-Host "Configuring Performance Monitoring..." -ForegroundColor Yellow
try {
    # Create data collector set
    $DataCollectorSetName = "MemberServer_Performance"
    New-DataCollectorSet -Name $DataCollectorSetName -XmlTemplate "SystemPerformance" -Server "localhost" | Start-DataCollectorSet
    
    Write-Host "Performance monitoring configured" -ForegroundColor Green
} catch {
    Write-Host "Performance monitoring configuration error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Member Server configuration completed successfully!" -ForegroundColor Green
Write-Host "Server: WS2025-MS" -ForegroundColor Cyan
Write-Host "Domain: $DomainName" -ForegroundColor Cyan
Write-Host "IP Address: $IPAddress" -ForegroundColor Cyan

# Display summary
Write-Host "`nConfiguration Summary:" -ForegroundColor Yellow
Write-Host "=====================" -ForegroundColor Yellow
Write-Host "✓ Network configured" -ForegroundColor Green
Write-Host "✓ Domain joined" -ForegroundColor Green
Write-Host "✓ Windows Features installed" -ForegroundColor Green
Write-Host "✓ File shares created and secured" -ForegroundColor Green
Write-Host "✓ IIS configured" -ForegroundColor Green
Write-Host "✓ Firewall configured" -ForegroundColor Green
Write-Host "✓ Maintenance tasks scheduled" -ForegroundColor Green