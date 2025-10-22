# make_fixed_zip.ps1
# Laravel 12 structure fix for Laragon - Folder-preserving version
# ---------------------------------------------------------------
# This version correctly preserves directory structure in the ZIP.

$ProjectRoot = Get-Location
$ZipOut = "$ProjectRoot\NEWlaravel12_FIXED.zip"

Write-Host "--------------------------------------------------"
Write-Host "Packaging NEWlaravel12_FIXED.zip for Laragon..."
Write-Host "--------------------------------------------------"
Write-Host ""

# --- Check if Laragon or Apache/MySQL are running ---
$running = Get-Process | Where-Object {
    $_.Name -match "laragon|apache|mysqld|php"
}

if ($running) {
    Write-Host "WARNING: Laragon or PHP/Apache processes are running!" -ForegroundColor Yellow
    Write-Host "Please stop all Laragon services before continuing."
    Write-Host "Open Laragon and click 'Stop All', then press ENTER to continue..."
    Pause
}

Write-Host ""
Write-Host "Creating deployment note and building archive..."
Write-Host ""

# --- Deployment note ---
$readme = @"
# Deployment note - Modified Laravel structure (Laragon)

This Laravel app has been restructured for Laragon use.
- Entry point: index.php (root)
- Application path: /laravel_core
- To run: cd laravel_core && php artisan serve
"@
Set-Content -Path "$ProjectRoot\README_DEPLOY_NOTE.md" -Value $readme

# --- Create a temporary copy for zipping ---
$TempFolder = "$ProjectRoot\_zip_temp"
if (Test-Path $TempFolder) { Remove-Item -Recurse -Force $TempFolder }
New-Item -ItemType Directory -Path $TempFolder | Out-Null

# Copy everything except vendor/node_modules/old zips into temp folder
Get-ChildItem -Path $ProjectRoot -Recurse | Where-Object {
    $_.FullName -notmatch "vendor" -and
    $_.FullName -notmatch "node_modules" -and
    $_.FullName -notmatch "\.zip$" -and
    $_.FullName -notmatch "_zip_temp"
} | ForEach-Object {
    $dest = $_.FullName.Replace($ProjectRoot, $TempFolder)
    if ($_.PSIsContainer) {
        New-Item -ItemType Directory -Force -Path $dest | Out-Null
    } else {
        Copy-Item -Force $_.FullName -Destination $dest
    }
}

# Now zip the full folder with structure preserved
Compress-Archive -Path "$TempFolder\*" -DestinationPath $ZipOut -Force

# Cleanup
Remove-Item -Recurse -Force $TempFolder

Write-Host ""
Write-Host "DONE: NEWlaravel12_FIXED.zip created successfully at:" -ForegroundColor Green
Write-Host $ZipOut
Write-Host ""
Write-Host "Directory structure preserved. You can now safely start Laragon again."
Write-Host "--------------------------------------------------"
