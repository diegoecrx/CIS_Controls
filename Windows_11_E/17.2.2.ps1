#Requires -RunAsAdministrator
# 17.2.2 (L1) Ensure 'Audit Security Group Management' is set to include 'Success'
auditpol /set /subcategory:"{0cce923a-69ae-11d9-bed3-505054503030}" /success:enable /failure:disable
