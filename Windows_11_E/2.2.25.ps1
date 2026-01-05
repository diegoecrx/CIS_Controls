#Requires -RunAsAdministrator
# 2.2.25 (L1) Ensure 'Increase scheduling priority' is set to 'Administrators, Window Manager\Window Manager Group'
$infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
revision=1
[Privilege Rights]
SeIncreaseBasePriorityPrivilege = *S-1-5-32-544
"@
$tempFile = "$env:TEMP\2.2.25.inf"
$infContent | Out-File -FilePath $tempFile -Encoding Unicode -Force
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg $tempFile /log "$env:TEMP\2.2.25.log" /quiet
Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
