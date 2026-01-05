#Requires -RunAsAdministrator
# 2.2.22 (L1) Ensure 'Force shutdown from a remote system' is set to 'Administrators'
$infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
revision=1
[Privilege Rights]
SeRemoteShutdownPrivilege = *S-1-5-32-544
"@
$tempFile = "$env:TEMP\2.2.22.inf"
$infContent | Out-File -FilePath $tempFile -Encoding Unicode -Force
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg $tempFile /log "$env:TEMP\2.2.22.log" /quiet
Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
