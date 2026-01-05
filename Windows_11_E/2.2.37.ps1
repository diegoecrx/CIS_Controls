#Requires -RunAsAdministrator
# 2.2.37 (L1) Ensure 'Restore files and directories' is set to 'Administrators'
$infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
revision=1
[Privilege Rights]
SeRestorePrivilege = *S-1-5-32-544
"@
$tempFile = "$env:TEMP\2.2.37.inf"
$infContent | Out-File -FilePath $tempFile -Encoding Unicode -Force
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg $tempFile /log "$env:TEMP\2.2.37.log" /quiet
Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
