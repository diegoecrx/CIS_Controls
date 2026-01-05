#Requires -RunAsAdministrator
# 17.9.5 (L1) Ensure 'Audit System Integrity' is set to 'Success and Failure'
auditpol /set /subcategory:"{0cce9212-69ae-11d9-bed3-505054503030}" /success:enable /failure:enable
