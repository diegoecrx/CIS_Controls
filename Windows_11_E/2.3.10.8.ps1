#Requires -RunAsAdministrator
# 2.3.10.8 (L1) Ensure 'Network access: Remotely accessible registry paths and sub-paths' is configured
# Note: Configure based on your organizational requirements
$regPathsSubPaths = @()
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\SecurePipeServers\Winreg\AllowedPaths" -Name "Machine" -Value $regPathsSubPaths -Type MultiString -Force -ErrorAction SilentlyContinue
