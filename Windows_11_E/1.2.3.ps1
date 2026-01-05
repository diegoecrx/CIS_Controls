#Requires -RunAsAdministrator
# 1.2.3 (L1) Ensure 'Allow Administrator account lockout' is set to 'Enabled'
# Note: This setting requires Windows 10 Release 2004+ or Server 2022+ with KB5020282 patch
$infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
revision=1
[System Access]
LockoutAdministratorAccount=1
"@
$tempFile = "$env:TEMP\1.2.3.inf"
$infContent | Out-File -FilePath $tempFile -Encoding Unicode -Force
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg $tempFile /log "$env:TEMP\1.2.3.log" /quiet
Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
