# ===============================
# Laravel12 Auto Push Script v2.1
# ===============================

# CONFIG
$RepoPath = "C:\laragon\www\laravel12_fixed"
$GitUser = "chefsyaiful1"
$GitEmail = "chefsyaiful1@gmail.com"
$GitBranch = "main"
$BackupDir = "$RepoPath\backups"
$Version = (Get-Date -Format "yyyy.MM.dd.HHmm")
$TagName = "v$Version"

Write-Host "🚀 Starting Laravel12 Auto Push at $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Cyan
Set-Location $RepoPath

# --- Ensure Git Identity ---
git config user.name $GitUser
git config user.email $GitEmail

# --- Ensure /backups/ is ignored ---
$Gitignore = "$RepoPath\.gitignore"
if (!(Select-String -Path $Gitignore -Pattern "/backups/" -Quiet)) {
    Add-Content $Gitignore "`n/backups/"
    Add-Content $Gitignore "*.zip"
    Write-Host "✅ Added /backups/ to .gitignore"
}

# --- Build Laravel ---
Write-Host "🧱 Building Vite assets..."
npm run build

# --- Create ZIP Backup (local only) ---
if (!(Test-Path $BackupDir)) { New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null }
$BackupFile = "$BackupDir\$TagName`_laravel12_fixed.zip"
Compress-Archive -Path "$RepoPath\laravel_core\*" -DestinationPath $BackupFile -Force
Write-Host "📦 Backup created: $BackupFile"

# --- Git Commit and Tag ---
git add .
git commit -m "Auto backup + build $TagName"
git tag -a $TagName -m "Version $TagName"
git push origin $GitBranch
git push origin $TagName

Write-Host "✅ Successfully pushed $TagName to GitHub."
Write-Host "🕓 Completed at $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Green
