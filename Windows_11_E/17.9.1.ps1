#Requires -RunAsAdministrator
# 17.9.1 (L1) Ensure 'Audit IPsec Driver' is set to 'Success and Failure'
auditpol /set /subcategory:"{0cce9213-69ae-11d9-bed3-505054503030}" /success:enable /failure:enable
