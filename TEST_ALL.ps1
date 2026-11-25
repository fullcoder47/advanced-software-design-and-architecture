$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
function Check-Exit { if ($LASTEXITCODE -ne 0) { throw "Command failed: $LASTEXITCODE" } }
if (Get-Command python -ErrorAction SilentlyContinue) {
    Write-Host '=== P02 ==='
    '' | python P02/starter/parent.py; Check-Exit
} elseif (Get-Command py -ErrorAction SilentlyContinue) {
    '' | py -3 P02/starter/parent.py; Check-Exit
} else { Write-Warning 'Python unavailable: P02 smoke test skipped.' }
Get-Command dart -ErrorAction Stop | Out-Null
foreach ($n in 3..11) {
    $folder = 'P{0:00}' -f $n
    Push-Location $folder
    try {
        Write-Host "=== $folder ==="
        dart pub get; Check-Exit
        dart analyze  --no-fatal-warnings; Check-Exit
        if ($n -eq 3) { dart run bin/hotel_booking.dart; Check-Exit; dart run bin/hotel_booking.dart --race; Check-Exit }
        else { dart test; Check-Exit }
    } finally { Pop-Location }
}
Write-Host 'All Dart snapshot checks completed. Live Docker integration not included.'

