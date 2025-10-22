# ===================================================================
# Laravel 12 Git Auto Push + Versioned ZIP Backup + Task Log Sync
# Author: Epul x GPT-5 | 2025-10-21
# ===================================================================

param(
    [string]$Message = "Auto commit - incremental update"
)

# ---------------- SETTINGS ----------------
$ProjectRoot = "C:\laragon\www\laravel12_fixed"
$ReadmePath  = "$ProjectRoot\README_DEPLOY_NOTE.md"
$TaskFile    = "$ProjectRoot\TASK_PROGRESS.txt"
$BackupDir   = "$ProjectRoot\backups"
$Branch      = "main"

# ---------------- START ----------------
Write-Host "🚀 Starting Laravel Git Auto Push Process..." -ForegroundColor Cyan
Set-Location $ProjectRoot

# Create backup dir if missing
if (-not (Test-Path $BackupDir)) { New-Item -ItemType Directory -Path $BackupDir | Out-Null }

# Ensure git initialized
if (-not (Test-Path "$ProjectRoot\.git")) {
    Write-Host "❌ Git repo not found. Run 'git init' first." -ForegroundColor Red
    exit
}

# Ensure TASK file exists
if (-not (Test-Path $TaskFile)) {
    Write-Host "📋 Creating default TASK_PROGRESS.txt..."
@"
# TASK Progress Tracker
✅ Done:
1. Laravel 12 core installed
2. Laravel Breeze installed
⚙️ In Progress:
3. Filament 4.2 setup
🔜 Next:
4. Sanctum Integration
5. Spatie Permission
"@ | Out-File $TaskFile -Encoding UTF8
}

# ---------------- VERSIONING ----------------
$lastTag = (git describe --tags --abbrev=0 2>$null)
if (-not $lastTag) {
    $version = "v1.0.0"
} else {
    $parts = $lastTag.TrimStart("v").Split(".")
    $major = [int]$parts[0]; $minor = [int]$parts[1]; $patch = [int]$parts[2] + 1
    $version = "v$major.$minor.$patch"
}

# ---------------- ZIP BACKUP ----------------
$ZipPath = "$BackupDir\$($version)_laravel12_fixed.zip"
Write-Host "🗜️ Creating ZIP backup for version $version..."
Compress-Archive -Path "$ProjectRoot\*" -DestinationPath $ZipPath -Force
Write-Host "✅ ZIP saved to $ZipPath"

# ---------------- GIT COMMIT ----------------
git add .
$commitMessage = "[$version] $Message"
git commit -m "$commitMessage" 2>$null
git tag -a $version -m "$Message"

# ---------------- UPDATE README ----------------
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$taskContent = Get-Content $TaskFile -Raw
$logEntry = @"
---

## [$version] - $timestamp
**Message:** $Message

### 📋 Current TASK Progress
$taskContent

"@
Add-Content $ReadmePath $logEntry

# ---------------- PUSH ----------------
Write-Host "⏫ Pushing changes to GitHub..."
git push origin $Branch
git push origin $version

Write-Host "✅ Successfully pushed $version" -ForegroundColor Green
Write-Host "📦 Backup ZIP stored at: $ZipPath"
Write-Host "🕓 Completed at $(Get-Date -Format 'HH:mm:ss')"
Write-Host "------------------------------------------------------------"
