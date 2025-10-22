# =============================================================
# Commit and Push Build Assets Script
# Author: Epul & ChatGPT
# Version: v1.1 (ASCII-safe)
# Description: Ensures public/build (Vite output) is committed
# =============================================================

$ErrorActionPreference = "Stop"

Write-Host "=== Committing Laravel build assets ===`n"

# Step 1: Navigate to project root
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location ..

# Step 2: Define build folder path
$buildPath = "laravel_core/public/build"

if (Test-Path $buildPath) {
    Write-Host "Build folder found at: $buildPath"
} else {
    Write-Host "ERROR: Build folder not found. Please run npm run build first."
    exit 1
}

# Step 3: Ensure .gitignore doesn’t block it
$gitignoreFile = "laravel_core/.gitignore"
if (Test-Path $gitignoreFile) {
    $lines = Get-Content $gitignoreFile
    if ($lines -match "/public/build") {
        Write-Host "Updating .gitignore to allow build folder..."
        $newLines = $lines | Where-Object { $_ -notmatch "/public/build" }
        $newLines | Set-Content -Encoding UTF8 $gitignoreFile
    }
}

# Step 4: Stage, commit, and push
git add $buildPath -f
$timestamp = Get-Date -Format "yyyy.MM.dd.HHmm"
$commitMessage = "Include public/build (vite assets) [$timestamp]"
git commit -m $commitMessage
git push origin main

Write-Host ""
Write-Host "Successfully committed and pushed build assets."
Write-Host "Completed at: $(Get-Date -Format 'HH:mm:ss')"
