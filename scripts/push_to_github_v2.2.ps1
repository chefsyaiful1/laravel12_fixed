# ===============================
# Laravel12 Auto Push Script v2.2 (Organized)
# ===============================

# CONFIG
$RepoRoot = "C:\laragon\www\laravel12_fixed"
$CorePath = "$RepoRoot\laravel_core"
$BackupDir = "$RepoRoot\backups"
$GitUser = "chefsyaiful1"
$GitEmail = "chefsyaiful1@gmail.com"
$GitBranch = "main"
$Version = (Get-Date -Format "yyyy.MM.dd.HHmm")
$TagName = "v$Version"

Write-Host "🚀 Starting Laravel12 Auto Push at $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Cyan

# --- Ensure Git Identity ---
Set-Location $RepoRoot
git config user.name $GitUser
git config user.email $GitEmail

# --- Ensure /backups/ is ignored ---
$Gitignore = "$RepoRoot\.gitignore"
if (!(Select-String -Path $Gitignore -Pattern "/backups/" -Quiet)) {
    Add-Content $Gitignore "`n/backups/"
    Add-Content $Gitignore "*.zip"
    Write-Host "✅ Added /backups/ to .gitignore"
}

# --- Run Build inside laravel_core ---
Write-Host "🧱 Running Vite build inside laravel_core..."
Set-Location $CorePath
if (Test-Path "$CorePath\package.json") {
    npm run build
} else {
    Write-Host "⚠️ package.json not found in $CorePath! Skipping build..." -ForegroundColor Yellow
}

# --- Return to repo root ---
Set-Location $RepoRoot

# --- Create backup ZIP ---
if (!(Test-Path $BackupDir)) { New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null }
$BackupFile = "$BackupDir\$TagName`_laravel12_fixed.zip"
Compress-Archive -Path "$CorePath\*" -DestinationPath $BackupFile -Force
Write-Host "📦 Backup created: $BackupFile"

# --- Git Commit and Push ---
git add .
git commit -m "Auto backup + build $TagName"
git tag -a $TagName -m "Version $TagName"
git push origin $GitBranch
git push origin $TagName

Write-Host "✅ Successfully pushed $TagName to GitHub."
Write-Host "🕓 Completed at $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Green
