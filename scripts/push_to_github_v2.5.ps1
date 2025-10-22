# scripts/push_to_github_v2.5.ps1
# Purpose : Backup, build, and push Laravel project to GitHub
# Encoding: UTF-8 (NO BOM)

$ErrorActionPreference = "Stop"

$projectRoot = "C:\laragon\www\laravel12_fixed"
$corePath    = "$projectRoot\laravel_core"
$backupDir   = "$projectRoot\backups"
$timestamp   = (Get-Date -Format "yyyy.MM.dd.HHmm")
$versionTag  = "v$timestamp"

# Ensure backup directory exists
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir | Out-Null
}

Write-Host "Creating backup..."
$backupFile = "$backupDir\$versionTag_laravel12_fixed.zip"
Compress-Archive -Path "$projectRoot\*" -DestinationPath $backupFile -Force
Write-Host "Backup created at: $backupFile"

# Run npm build if package.json exists
if (Test-Path "$corePath\package.json") {
    Write-Host "Running npm build..."
    Set-Location $corePath
    npm install --legacy-peer-deps
    npm run build
    Set-Location $projectRoot
} else {
    Write-Host "No package.json found in laravel_core. Skipping build."
}

# Git operations
Set-Location $projectRoot
git add .
git commit -m "Auto backup and build $versionTag" | Out-Null
git tag -a $versionTag -m "Version $versionTag"
git push origin main
git push origin $versionTag

Write-Host "Successfully pushed $versionTag to GitHub."
Write-Host "Completed at $(Get-Date -Format 'HH:mm:ss')"
