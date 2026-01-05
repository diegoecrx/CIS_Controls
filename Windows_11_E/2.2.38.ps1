#Requires -RunAsAdministrator
# 2.2.38 (L1) Ensure 'Shut down the system' is set to 'Administrators, Users'
$infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
revision=1
[Privilege Rights]
SeShutdownPrivilege = *S-1-5-32-544,*S-1-5-32-545
"@
$tempFile = "$env:TEMP\2.2.38.inf"
$infContent | Out-File -FilePath $tempFile -Encoding Unicode -Force
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg $tempFile /log "$env:TEMP\2.2.38.log" /quiet
Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
