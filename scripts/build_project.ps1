# ============================================
# Laravel12 Quick Build & Verification Script
# ============================================
# File: scripts/build_project.ps1
# Author: Epul & Team
# Version: v1.0.0
# Description:
#   Runs npm build, verifies manifest, cleans caches,
#   and logs output for audit before any git push.
# ============================================

$RepoRoot  = "C:\laragon\www\laravel12_fixed"
$CorePath  = "$RepoRoot\laravel_core"
$BackupDir = "$RepoRoot\backups\logs"
$Timestamp = Get-Date -Format "yyyy.MM.dd_HHmm"
$LogFile   = "$BackupDir\build_log_$Timestamp.txt"
$AppUrl    = "http://laravel12_fixed.test"

Write-Host "🚀 Starting Laravel Quick Build (Epul DevOps v1.0)" -ForegroundColor Cyan

# Ensure logs directory exists
if (!(Test-Path $BackupDir)) { New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null }

# --- Step 1: Change to core folder ---
Set-Location $CorePath
Write-Host "📁 Working inside: $CorePath"

# --- Step 2: Verify Node & PHP availability ---
$nodeVersion = (node -v) 2>$null
$phpVersion = (php -v | Select-String "PHP") 2>$null

if (-not $nodeVersion) { Write-Host "❌ Node.js not found! Check PATH." -ForegroundColor Red; exit 1 }
if (-not $phpVersion) { Write-Host "❌ PHP not found! Check PATH." -ForegroundColor Red; exit 1 }

Write-Host "✅ Node: $nodeVersion"
Write-Host "✅ $phpVersion"

# --- Step 3: Build using Vite ---
if (Test-Path "$CorePath\package.json") {
    Write-Host "🧱 Running npm run build..." -ForegroundColor Yellow
    npm run build | Tee-Object -FilePath $LogFile -Append
} else {
    Write-Host "⚠️ No package.json found, skipping build." -ForegroundColor Yellow
}

# --- Step 4: Validate manifest ---
$ManifestPath = "$CorePath\public\build\manifest.json"
if (Test-Path $ManifestPath) {
    Write-Host "✅ Manifest found: $ManifestPath" -ForegroundColor Green
} else {
    Write-Host "❌ Manifest missing! Build might have failed." -ForegroundColor Red
    exit 1
}

# --- Step 5: Laravel cache rebuild ---
Write-Host "🧹 Clearing and caching Laravel configs..."
php artisan optimize:clear   | Tee-Object -FilePath $LogFile -Append
php artisan optimize         | Tee-Object -FilePath $LogFile -Append

# --- Step 6: Optional health checks ---
Write-Host "🔍 Running basic Laravel checks..."
php artisan route:list --compact | Tee-Object -FilePath $LogFile -Append
php artisan config:cache | Tee-Object -FilePath $LogFile -Append

# --- Step 7: Finish ---
Write-Host "`n✅ Build verification complete!"
Write-Host "📝 Log saved at: $LogFile" -ForegroundColor Green

# --- Step 8: Prompt to open local test URL ---
$answer = Read-Host "🌐 Open $AppUrl now? (y/n)"
if ($answer -eq 'y' -or $answer -eq 'Y') {
    Start-Process $AppUrl
}

Write-Host "🏁 Done at $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Cyan
