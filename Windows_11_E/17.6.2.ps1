#Requires -RunAsAdministrator
# 17.6.2 (L1) Ensure 'Audit File Share' is set to 'Success and Failure'
auditpol /set /subcategory:"{0cce9224-69ae-11d9-bed3-505054503030}" /success:enable /failure:enable
