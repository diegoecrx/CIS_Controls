Write-Host "=== Experience Policies ===" -ForegroundColor Cyan
$exp = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Experience" -ErrorAction SilentlyContinue
Write-Host "Found $($exp.Count) items"
foreach ($item in $exp) {
    $props = Get-ItemProperty $item.PSPath -ErrorAction SilentlyContinue
    Write-Host "$($item.PSChildName): $($props.RegKeyPathRedirect) -> $($props.RegValueNameRedirect)"
}
