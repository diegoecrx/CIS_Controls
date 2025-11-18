# GPO2.ps1 - Simple Anti-CIS Configuration
Import-Module GroupPolicy -Force
Import-Module ActiveDirectory -Force

$DomainDN = (Get-ADDomain).DistinguishedName
$Prefix = "ANTI-CIS_"

# GPO 7: Permissive Rights 2
$GPO7 = New-GPO -Name "${Prefix}Permissive_Rights_2"
New-GPLink -Name "${Prefix}Permissive_Rights_2" -Target $DomainDN
Set-GPRegistryValue -Name "${Prefix}Permissive_Rights_2" -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\Performance" -ValueName "AllowUserSystemProfiling" -Type DWord -Value 1
Set-GPRegistryValue -Name "${Prefix}Permissive_Rights_2" -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\Performance" -ValueName "AllowUserTokenReplacement" -Type DWord -Value 1
Set-GPRegistryValue -Name "${Prefix}Permissive_Rights_2" -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\Backup" -ValueName "AllowUserRestore" -Type DWord -Value 1

# GPO 8: Weak Account Settings
$GPO8 = New-GPO -Name "${Prefix}Weak_Account_Settings"
New-GPLink -Name "${Prefix}Weak_Account_Settings" -Target $DomainDN
Set-GPRegistryValue -Name "${Prefix}Weak_Account_Settings" -Key "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" -ValueName "EnableGuestAccount" -Type DWord -Value 1
Set-GPRegistryValue -Name "${Prefix}Weak_Account_Settings" -Key "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" -ValueName "LimitBlankPasswordUse" -Type DWord -Value 0

# GPO 9: Permissive Network Access
$GPO9 = New-GPO -Name "${Prefix}Permissive_Network_Access"
New-GPLink -Name "${Prefix}Permissive_Network_Access" -Target $DomainDN
Set-GPRegistryValue -Name "${Prefix}Permissive_Network_Access" -Key "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" -ValueName "RestrictAnonymousSAM" -Type DWord -Value 0
Set-GPRegistryValue -Name "${Prefix}Permissive_Network_Access" -Key "HKLM\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" -ValueName "RestrictNullSessAccess" -Type DWord -Value 0
Set-GPRegistryValue -Name "${Prefix}Permissive_Network_Access" -Key "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" -ValueName "ForceGuest" -Type DWord -Value 1

# GPO 10: Weak Network Security
$GPO10 = New-GPO -Name "${Prefix}Weak_Network_Security"
New-GPLink -Name "${Prefix}Weak_Network_Security" -Target $DomainDN
Set-GPRegistryValue -Name "${Prefix}Weak_Network_Security" -Key "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" -ValueName "NoLMHash" -Type DWord -Value 0
Set-GPRegistryValue -Name "${Prefix}Weak_Network_Security" -Key "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" -ValueName "LmCompatibilityLevel" -Type DWord -Value 0

# GPO 11: Permissive System Settings
$GPO11 = New-GPO -Name "${Prefix}Permissive_System_Settings"
New-GPLink -Name "${Prefix}Permissive_System_Settings" -Target $DomainDN
Set-GPRegistryValue -Name "${Prefix}Permissive_System_Settings" -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "ShutdownWithoutLogon" -Type DWord -Value 1

# GPO 12: Weak UAC Settings
$GPO12 = New-GPO -Name "${Prefix}Weak_UAC_Settings"
New-GPLink -Name "${Prefix}Weak_UAC_Settings" -Target $DomainDN
Set-GPRegistryValue -Name "${Prefix}Weak_UAC_Settings" -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "EnableLUA" -Type DWord -Value 0
Set-GPRegistryValue -Name "${Prefix}Weak_UAC_Settings" -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "ConsentPromptBehaviorAdmin" -Type DWord -Value 0
Set-GPRegistryValue -Name "${Prefix}Weak_UAC_Settings" -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "ConsentPromptBehaviorUser" -Type DWord -Value 0

# Force update
Invoke-GPUpdate -Force

Write-Host "GPO2.ps1 completed - 6 GPOs created"