# GPO1.ps1 - Simple Anti-CIS Configuration Part 1
Import-Module GroupPolicy -Force
Import-Module ActiveDirectory -Force

$DomainDN = (Get-ADDomain).DistinguishedName
$Prefix = "ANTI-CIS_"

# GPO 1: Weak Password Policy
$GPO1 = New-GPO -Name "${Prefix}Weak_Password_Policy"
New-GPLink -Name "${Prefix}Weak_Password_Policy" -Target $DomainDN
Set-GPRegistryValue -Name "${Prefix}Weak_Password_Policy" -Key "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" -ValueName "PasswordHistory" -Type DWord -Value 1
Set-GPRegistryValue -Name "${Prefix}Weak_Password_Policy" -Key "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" -ValueName "MaximumPasswordAge" -Type DWord -Value 0
Set-GPRegistryValue -Name "${Prefix}Weak_Password_Policy" -Key "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" -ValueName "MinimumPasswordAge" -Type DWord -Value 0
Set-GPRegistryValue -Name "${Prefix}Weak_Password_Policy" -Key "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" -ValueName "MinimumPasswordLength" -Type DWord -Value 0
Set-GPRegistryValue -Name "${Prefix}Weak_Password_Policy" -Key "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" -ValueName "PasswordComplexity" -Type DWord -Value 0
Set-GPRegistryValue -Name "${Prefix}Weak_Password_Policy" -Key "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" -ValueName "ReversibleEncryption" -Type DWord -Value 1

# GPO 2: Weak Account Lockout
$GPO2 = New-GPO -Name "${Prefix}Weak_Account_Lockout"
New-GPLink -Name "${Prefix}Weak_Account_Lockout" -Target $DomainDN
Set-GPRegistryValue -Name "${Prefix}Weak_Account_Lockout" -Key "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" -ValueName "LockoutDuration" -Type DWord -Value 1
Set-GPRegistryValue -Name "${Prefix}Weak_Account_Lockout" -Key "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" -ValueName "LockoutThreshold" -Type DWord -Value 50
Set-GPRegistryValue -Name "${Prefix}Weak_Account_Lockout" -Key "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" -ValueName "AdminLockout" -Type DWord -Value 0
Set-GPRegistryValue -Name "${Prefix}Weak_Account_Lockout" -Key "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" -ValueName "LockoutWindow" -Type DWord -Value 1

# GPO 3: Permissive User Rights
$GPO3 = New-GPO -Name "${Prefix}Permissive_User_Rights"
New-GPLink -Name "${Prefix}Permissive_User_Rights" -Target $DomainDN
Set-GPRegistryValue -Name "${Prefix}Permissive_User_Rights" -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation" -ValueName "AllowDefaultCredentials" -Type DWord -Value 1
Set-GPRegistryValue -Name "${Prefix}Permissive_User_Rights" -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -ValueName "UserAuthentication" -Type DWord -Value 0
Set-GPRegistryValue -Name "${Prefix}Permissive_User_Rights" -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\Backup" -ValueName "AllowEveryone" -Type DWord -Value 1

# GPO 4: Weak Security Options
$GPO4 = New-GPO -Name "${Prefix}Weak_Security_Options"
New-GPLink -Name "${Prefix}Weak_Security_Options" -Target $DomainDN
Set-GPRegistryValue -Name "${Prefix}Weak_Security_Options" -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "EnableLUA" -Type DWord -Value 0
Set-GPRegistryValue -Name "${Prefix}Weak_Security_Options" -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "ConsentPromptBehaviorAdmin" -Type DWord -Value 0
Set-GPRegistryValue -Name "${Prefix}Weak_Security_Options" -Key "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" -ValueName "LimitBlankPasswordUse" -Type DWord -Value 0
Set-GPRegistryValue -Name "${Prefix}Weak_Security_Options" -Key "HKLM\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" -ValueName "RequireSecuritySignature" -Type DWord -Value 0
Set-GPRegistryValue -Name "${Prefix}Weak_Security_Options" -Key "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" -ValueName "NoLMHash" -Type DWord -Value 0

# GPO 5: Minimal Auditing
$GPO5 = New-GPO -Name "${Prefix}Minimal_Auditing"
New-GPLink -Name "${Prefix}Minimal_Auditing" -Target $DomainDN
Set-GPRegistryValue -Name "${Prefix}Minimal_Auditing" -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application" -ValueName "MaxSize" -Type DWord -Value 1024
Set-GPRegistryValue -Name "${Prefix}Minimal_Auditing" -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security" -ValueName "MaxSize" -Type DWord -Value 2048
Set-GPRegistryValue -Name "${Prefix}Minimal_Auditing" -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\EventLog\System" -ValueName "MaxSize" -Type DWord -Value 1024

# GPO 6: Permissive Network
$GPO6 = New-GPO -Name "${Prefix}Permissive_Network"
New-GPLink -Name "${Prefix}Permissive_Network" -Target $DomainDN
Set-GPRegistryValue -Name "${Prefix}Permissive_Network" -Key "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -ValueName "EnableICMPRedirect" -Type DWord -Value 1
Set-GPRegistryValue -Name "${Prefix}Permissive_Network" -Key "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -ValueName "DisableIPSourceRouting" -Type DWord -Value 0
Set-GPRegistryValue -Name "${Prefix}Permissive_Network" -Key "HKLM\SYSTEM\CurrentControlSet\Services\NetBT\Parameters" -ValueName "EnableNetBIOS" -Type DWord -Value 1

# Force update
Invoke-GPUpdate -Force

Write-Host "GPO1.ps1 completed - 6 GPOs created"