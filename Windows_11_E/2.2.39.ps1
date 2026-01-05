#Requires -RunAsAdministrator
# 2.2.39 (L1) Ensure 'Take ownership of files or other objects' is set to 'Administrators'
$infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
revision=1
[Privilege Rights]
SeTakeOwnershipPrivilege = *S-1-5-32-544
"@
$tempFile = "$env:TEMP\2.2.39.inf"
$infContent | Out-File -FilePath $tempFile -Encoding Unicode -Force
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg $tempFile /log "$env:TEMP\2.2.39.log" /quiet
Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
