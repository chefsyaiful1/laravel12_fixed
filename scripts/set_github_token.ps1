# ================================================================
# GitHub Token Setup Helper (Verified & Safe Version)
# Author: Epul & ChatGPT
# Version: v2.0
# Description:
#   - Prompts for GitHub PAT
#   - Verifies via GitHub API
#   - Sets $env:GITHUB_TOKEN for current session
#   - Adds it permanently to PowerShell profile
# ================================================================

param (
    [string]$Token = ""
)

$envVarName = "GITHUB_TOKEN"
$userProfile = [Environment]::GetFolderPath("UserProfile")
$profileFile = "$userProfile\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

Write-Host "🚀 Starting GitHub Token Setup..." -ForegroundColor Cyan

# 1️⃣ Prompt for token if not provided
if (-not $Token) {
    $Token = Read-Host "Enter your GitHub Personal Access Token"
}

if (-not $Token) {
    Write-Host "❌ No token provided. Exiting." -ForegroundColor Red
    exit 1
}

# 2️⃣ Verify token validity via GitHub API
try {
    $response = Invoke-RestMethod -Uri "https://api.github.com/user" -Headers @{ Authorization = "token $Token"; "User-Agent" = "PowerShell" } -ErrorAction Stop
    Write-Host "✅ Token verified successfully for GitHub user: $($response.login)" -ForegroundColor Green
} catch {
    Write-Host "❌ Invalid or expired token. Please generate a new one at https://github.com/settings/tokens" -ForegroundColor Red
    exit 1
}

# 3️⃣ Set token for current session
$env:GITHUB_TOKEN = $Token
Write-Host "✔ Token set for current PowerShell session." -ForegroundColor Green

# 4️⃣ Persist token to PowerShell profile
if (-not (Test-Path $profileFile)) {
    Write-Host "Creating PowerShell profile..." -ForegroundColor Yellow
    New-Item -ItemType File -Path $profileFile -Force | Out-Null
}

$lineToAdd = "`n# --- GitHub Token Auto-Set ---`n`$env:GITHUB_TOKEN = '$Token'`n"
Add-Content -Path $profileFile -Value $lineToAdd

Write-Host "💾 Token saved to PowerShell profile: $profileFile" -ForegroundColor Green
Write-Host "💡 Tip: Restart PowerShell to load it automatically next time." -ForegroundColor Yellow
Write-Host "✨ Setup complete." -ForegroundColor Cyan
