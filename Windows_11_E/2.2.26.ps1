#Requires -RunAsAdministrator
# 2.2.26 (L1) Ensure 'Load and unload device drivers' is set to 'Administrators'
$infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
revision=1
[Privilege Rights]
SeLoadDriverPrivilege = *S-1-5-32-544
"@
$tempFile = "$env:TEMP\2.2.26.inf"
$infContent | Out-File -FilePath $tempFile -Encoding Unicode -Force
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg $tempFile /log "$env:TEMP\2.2.26.log" /quiet
Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
