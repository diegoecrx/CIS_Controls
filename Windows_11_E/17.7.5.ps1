#Requires -RunAsAdministrator
# 17.7.5 (L1) Ensure 'Audit Other Policy Change Events' is set to include 'Failure'
auditpol /set /subcategory:"{0cce9234-69ae-11d9-bed3-505054503030}" /success:disable /failure:enable
