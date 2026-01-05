#Requires -RunAsAdministrator
# 17.3.1 (L1) Ensure 'Audit PNP Activity' is set to include 'Success'
auditpol /set /subcategory:"{0cce9248-69ae-11d9-bed3-505054503030}" /success:enable /failure:disable
