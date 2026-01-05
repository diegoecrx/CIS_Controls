#Requires -RunAsAdministrator
# 17.9.2 (L1) Ensure 'Audit Other System Events' is set to 'Success and Failure'
auditpol /set /subcategory:"{0cce9214-69ae-11d9-bed3-505054503030}" /success:enable /failure:enable
