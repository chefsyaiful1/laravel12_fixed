# ================================================================
# Laravel 12 Git Auto Push Script v2.3
# Author: Epul & CTO Assistant
# Purpose: Auto-build, zip-backup, and push Laravel project safely
# ================================================================

# --- Config ---
$projectRoot = "C:\laragon\www\laravel12_fixed"
$coreFolder  = "$projectRoot\laravel_core"
$backupFolder = "$projectRoot\backups"
$timestamp = Get-Date -Format "yyyy.MM.dd.HHmm"
$versionTag = "v$timestamp"
$zipName = "$versionTag" + "_laravel12_fixed.zip"
$zipPath = Join-Path $backupFolder $zipName

Write-Host "🚀 Laravel Auto Git Push v2.3 started..."
Set-Location $projectRoot

# --- Ensure backup folder exists ---
if (-not (Test-Path $backupFolder)) {
    New-Item -ItemType Directory -Path $backupFolder | Out-Null
    Write-Host "📁 Created backup folder at $backupFolder"
}

# --- Step 1: Run Vite Build ---
Write-Host "`n🏗️ Running npm build (auto-detecting correct folder)..."
if (Test-Path "$coreFolder\package.json") {
    Set-Location $coreFolder
    try {
        npm run build
        if ($LASTEXITCODE -ne 0) {
            throw "❌ npm build failed. Check your Vite or package.json setup."
        } else {
            Write-Host "✅ npm build succeeded."
        }
    } catch {
        Write-Host $_.Exception.Message
        exit 1
    }
} else {
    Write-Host "⚠️ package.json not found in laravel_core. Skipping build."
}

Set-Location $projectRoot

# --- Step 2: Create Backup ZIP ---
Write-Host "`n🧩 Creating backup ZIP..."
try {
    Compress-Archive -Path * -DestinationPath $zipPath -Force
    Write-Host "✅ Backup created: $zipPath"
} catch {
    Write-Host "❌ Failed to create ZIP: $_"
    exit 1
}

# --- Step 3: Git Commit + Tag + Push ---
Write-Host "`n🪣 Starting Git push..."
try {
    git add .
    git commit -m "Auto backup + build $versionTag"
    git tag -a $versionTag -m "Version $versionTag"
    git push origin main
    git push origin $versionTag
    Write-Host "✅ Successfully pushed $versionTag to GitHub."
} catch {
    Write-Host "❌ Git push failed. Please verify credentials or remote URL."
}

# --- Step 4: Summary ---
$now = Get-Date -Format "HH:mm:ss"
Write-Host "`n📦 Backup stored at: $zipPath"
Write-Host "🕓 Completed at $now"
Write-Host "---------------------------------------------------------"
Write-Host "💡 Tip: View commit history → https://github.com/chefsyaiful1/laravel12_fixed/commits/main"
Write-Host "---------------------------------------------------------"
