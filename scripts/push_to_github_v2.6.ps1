# =============================================================
# Laravel12 - Automated Git Push and Build Script
# Version : v2.6  (UTF-8 safe)
# Author  : Epul & ChatGPT
# =============================================================

$ErrorActionPreference = "Stop"

# --- CONFIGURATION -------------------------------------------
$projectRoot  = "C:\laragon\www\laravel12_fixed"
$corePath     = "$projectRoot\laravel_core"
$backupDir    = "$projectRoot\backups"
$logDir       = "$projectRoot\scripts\logs"

# --- INITIALIZATION ------------------------------------------
if (-not (Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir | Out-Null }
if (-not (Test-Path $logDir))    { New-Item -ItemType Directory -Path $logDir | Out-Null }

$timestamp   = Get-Date -Format "yyyy.MM.dd.HHmm"
$versionTag  = "v$timestamp"
$zipFile     = "$backupDir\$versionTag_laravel12_fixed.zip"
$logFile     = "$logDir\git_push.log"

function Write-Log($text) {
    $entry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $text"
    Add-Content -Path $logFile -Value $entry
    Write-Host $text
}

Write-Host "=== Starting automated Laravel12 push (v2.6) ==="
Write-Log  "Start push sequence ($versionTag)"

# --- STEP 1: CLEAN + BUILD FRONTEND --------------------------
Set-Location $corePath
Write-Log  "Running npm clean and build..."
try {
    Remove-Item -Recurse -Force "public\build" -ErrorAction SilentlyContinue
    npm install --legacy-peer-deps | Out-Null
    npm run build
    node .\scripts\fix-manifest.js
    Write-Log "Build completed successfully."
}
catch {
    Write-Log "ERROR during npm build: $($_.Exception.Message)"
    exit 1
}

# --- STEP 2: BACKUP ZIP CREATION ------------------------------
Set-Location $projectRoot
Write-Log  "Creating backup ZIP..."
try {
    if (Test-Path $zipFile) { Remove-Item $zipFile -Force }
    Compress-Archive -Path * -DestinationPath $zipFile -Force
    Write-Log  "Backup created at: $zipFile"
}
catch {
    Write-Log  "ERROR creating backup ZIP: $($_.Exception.Message)"
    exit 1
}

# --- STEP 3: INCLUDE BUILD ASSETS -----------------------------
$buildPath = "laravel_core/public/build"
$gitignoreFile = "laravel_core/.gitignore"

if (Test-Path $gitignoreFile) {
    $lines = Get-Content $gitignoreFile
    if ($lines -match "/public/build") {
        Write-Log "Updating .gitignore to include build folder..."
        $newLines = $lines | Where-Object { $_ -notmatch "/public/build" }
        $newLines | Set-Content -Encoding UTF8 $gitignoreFile
    }
}

# --- STEP 4: GIT COMMIT + PUSH --------------------------------
Write-Log "Running Git commit and push..."
try {
    git add .
    git commit -m "Auto backup + build + assets $versionTag" | Out-Null
    git tag -a $versionTag -m "Version $versionTag"
    git push origin main
    git push origin $versionTag
    Write-Log "Successfully pushed $versionTag to GitHub."
}
catch {
    Write-Log "ERROR during Git push: $($_.Exception.Message)"
    exit 1
}

# --- STEP 5: SUMMARY ------------------------------------------
Write-Log "Push completed at $(Get-Date -Format 'HH:mm:ss')"
Write-Host ""
Write-Host "Process completed successfully. Details logged to:"
Write-Host "   $logFile"
Write-Host "Backup ZIP stored at:"
Write-Host "   $zipFile"
Write-Host ""
Write-Host "=== Laravel12 push v2.6 finished ==="
