#Requires -RunAsAdministrator
# 17.2.1 (L1) Ensure 'Audit Application Group Management' is set to 'Success and Failure'
auditpol /set /subcategory:"{0cce9239-69ae-11d9-bed3-505054503030}" /success:enable /failure:enable
