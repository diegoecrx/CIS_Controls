# Domain Controller Configuration Script
# Run this on WS2025-DC (192.168.30.20)
# Run as Administrator

# Configuration Variables
$DomainName = "CORP.CONTOSO.COM"
$NetBIOSName = "CORP"
$SafeModePassword = ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force
$IPAddress = "192.168.30.20"
$SubnetMask = "255.255.255.0"
$DefaultGateway = "192.168.30.1"
$DNSServers = @("127.0.0.1", "8.8.8.8")

Write-Host "Starting Domain Controller Configuration..." -ForegroundColor Green

# Step 1: Configure Static IP Address
Write-Host "Configuring Network Settings..." -ForegroundColor Yellow
$NetworkAdapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up" -and $_.Name -notlike "*Loopback*"}
Remove-NetIPAddress -InterfaceIndex $NetworkAdapter.InterfaceIndex -Confirm:$false -ErrorAction SilentlyContinue
New-NetIPAddress -InterfaceIndex $NetworkAdapter.InterfaceIndex -IPAddress $IPAddress -PrefixLength 24 -DefaultGateway $DefaultGateway
Set-DnsClientServerAddress -InterfaceIndex $NetworkAdapter.InterfaceIndex -ServerAddresses $DNSServers

# Step 2: Install Active Directory Domain Services
Write-Host "Installing Active Directory Domain Services..." -ForegroundColor Yellow
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Step 3: Promote Server to Domain Controller
Write-Host "Promoting server to Domain Controller..." -ForegroundColor Yellow
$ForestParams = @{
    DomainName = $DomainName
    DomainNetbiosName = $NetBIOSName
    ForestMode = "WinThreshold"
    DomainMode = "WinThreshold"
    SafeModeAdministratorPassword = $SafeModePassword
    InstallDns = $true
    Force = $true
    NoRebootOnCompletion = $false
}

Install-ADDSForest @ForestParams

# Server will reboot automatically after this point
# The script continues after reboot...

# Post-Reboot Configuration (Run this part manually after reboot if needed)
Write-Host "Configuring Post-Installation Settings..." -ForegroundColor Yellow

# Import Active Directory module
Import-Module ActiveDirectory

# Step 4: Create Organizational Units
Write-Host "Creating Organizational Units..." -ForegroundColor Yellow
$OUs = @(
    "IT",
    "Sales", 
    "HR",
    "Finance",
    "Servers",
    "Workstations",
    "Service Accounts",
    "Security Groups"
)

foreach ($OU in $OUs) {
    try {
        New-ADOrganizationalUnit -Name $OU -Path "DC=CORP,DC=CONTOSO,DC=COM" -ProtectedFromAccidentalDeletion $false
        Write-Host "Created OU: $OU" -ForegroundColor Green
    } catch {
        Write-Host "OU $OU already exists or error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Step 5: Create Security Groups
Write-Host "Creating Security Groups..." -ForegroundColor Yellow
$Groups = @(
    @{Name = "IT_Admins"; Description = "IT Administrators"; Path = "OU=Security Groups,DC=CORP,DC=CONTOSO,DC=COM"},
    @{Name = "Sales_Users"; Description = "Sales Department Users"; Path = "OU=Security Groups,DC=CORP,DC=CONTOSO,DC=COM"},
    @{Name = "HR_Users"; Description = "HR Department Users"; Path = "OU=Security Groups,DC=CORP,DC=CONTOSO,DC=COM"},
    @{Name = "Finance_Users"; Description = "Finance Department Users"; Path = "OU=Security Groups,DC=CORP,DC=CONTOSO,DC=COM"},
    @{Name = "Server_Admins"; Description = "Server Administrators"; Path = "OU=Security Groups,DC=CORP,DC=CONTOSO,DC=COM"},
    @{Name = "Workstation_Users"; Description = "Workstation Users"; Path = "OU=Security Groups,DC=CORP,DC=CONTOSO,DC=COM"}
)

foreach ($Group in $Groups) {
    try {
        New-ADGroup -Name $Group.Name -GroupCategory Security -GroupScope Global -Description $Group.Description -Path $Group.Path
        Write-Host "Created group: $($Group.Name)" -ForegroundColor Green
    } catch {
        Write-Host "Group $($Group.Name) already exists or error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Step 6: Create User Accounts
Write-Host "Creating User Accounts..." -ForegroundColor Yellow
$Users = @(
    @{Name = "john.doe"; FullName = "John Doe"; Department = "IT"; OU = "OU=IT,DC=CORP,DC=CONTOSO,DC=COM"; Groups = @("IT_Admins", "Server_Admins")},
    @{Name = "jane.smith"; FullName = "Jane Smith"; Department = "Sales"; OU = "OU=Sales,DC=CORP,DC=CONTOSO,DC=COM"; Groups = @("Sales_Users")},
    @{Name = "mike.johnson"; FullName = "Mike Johnson"; Department = "HR"; OU = "OU=HR,DC=CORP,DC=CONTOSO,DC=COM"; Groups = @("HR_Users")},
    @{Name = "sarah.wilson"; FullName = "Sarah Wilson"; Department = "Finance"; OU = "OU=Finance,DC=CORP,DC=CONTOSO,DC=COM"; Groups = @("Finance_Users")},
    @{Name = "admin.user"; FullName = "Admin User"; Department = "IT"; OU = "OU=IT,DC=CORP,DC=CONTOSO,DC=COM"; Groups = @("IT_Admins", "Server_Admins")}
)

$DefaultPassword = ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force

foreach ($User in $Users) {
    try {
        New-ADUser -Name $User.Name -DisplayName $User.FullName -GivenName $User.FullName.Split(' ')[0] -Surname $User.FullName.Split(' ')[1] -SamAccountName $User.Name -UserPrincipalName "$($User.Name)@corp.contoso.com" -Path $User.OU -AccountPassword $DefaultPassword -Enabled $true -ChangePasswordAtLogon $false
        
        foreach ($Group in $User.Groups) {
            Add-ADGroupMember -Identity $Group -Members $User.Name
        }
        
        Write-Host "Created user: $($User.Name)" -ForegroundColor Green
    } catch {
        Write-Host "User $($User.Name) already exists or error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Step 7: Create File Shares
Write-Host "Creating File Shares..." -ForegroundColor Yellow
$Shares = @(
    @{Name = "ITShare"; Path = "C:\Shares\IT"; Description = "IT Department Share"},
    @{Name = "SalesShare"; Path = "C:\Shares\Sales"; Description = "Sales Department Share"},
    @{Name = "HRShare"; Path = "C:\Shares\HR"; Description = "HR Department Share"},
    @{Name = "FinanceShare"; Path = "C:\Shares\Finance"; Description = "Finance Department Share"}
)

foreach ($Share in $Shares) {
    try {
        # Create directory
        New-Item -Path $Share.Path -ItemType Directory -Force
        
        # Create share
        New-SmbShare -Name $Share.Name -Path $Share.Path -FullAccess "Administrators" -ChangeAccess "CORP\$($Share.Name.Replace('Share',''))_Users" -Description $Share.Description
        
        Write-Host "Created share: $($Share.Name)" -ForegroundColor Green
    } catch {
        Write-Host "Share $($Share.Name) creation error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Step 8: Configure Basic Group Policies
Write-Host "Configuring Group Policies..." -ForegroundColor Yellow

# Create GPO for Password Policy
try {
    $PasswordPolicyGPO = New-GPO -Name "Domain Password Policy" -ErrorAction SilentlyContinue
    Set-GPRegistryValue -Name "Domain Password Policy" -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "PasswordComplexity" -Type DWord -Value 1
    Set-GPRegistryValue -Name "Domain Password Policy" -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "MinimumPasswordLength" -Type DWord -Value 8
    New-GPLink -Name "Domain Password Policy" -Target "DC=CORP,DC=CONTOSO,DC=COM"
    Write-Host "Created Password Policy GPO" -ForegroundColor Green
} catch {
    Write-Host "GPO creation error: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 9: Configure DNS Forwarder
Write-Host "Configuring DNS..." -ForegroundColor Yellow
Add-DnsServerForwarder -IPAddress "8.8.8.8" -PassThru

# Step 10: Create DHCP Scope (Optional)
Write-Host "Configuring DHCP (Optional)..." -ForegroundColor Yellow
try {
    Install-WindowsFeature -Name DHCP -IncludeManagementTools
    Add-DhcpServerV4Scope -Name "CORP Network" -StartRange "192.168.30.100" -EndRange "192.168.30.200" -SubnetMask "255.255.255.0" -State Active
    Set-DhcpServerV4OptionValue -DnsDomain "corp.contoso.com" -DnsServer "192.168.30.20" -Router "192.168.30.1"
    Add-DhcpServerInDC -DnsName "WS2025-DC.corp.contoso.com" -IPAddress "192.168.30.20"
    Write-Host "DHCP configured" -ForegroundColor Green
} catch {
    Write-Host "DHCP configuration skipped or error: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "Domain Controller configuration completed successfully!" -ForegroundColor Green
Write-Host "Domain: $DomainName" -ForegroundColor Cyan
Write-Host "Domain Controller: WS2025-DC ($IPAddress)" -ForegroundColor Cyan