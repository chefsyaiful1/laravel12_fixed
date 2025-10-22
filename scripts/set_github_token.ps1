# scripts/set_github_token.ps1
# Purpose : Save GitHub token as environment variable
# Encoding: UTF-8 (NO BOM)

$token = Read-Host "Enter your GitHub Personal Access Token"

if ([string]::IsNullOrWhiteSpace($token)) {
    Write-Host "ERROR: No token entered. Aborting..."
    exit 1
}

# Set for this session
[Environment]::SetEnvironmentVariable('GITHUB_TOKEN', $token, 'Process')

# Persist for user profile
[Environment]::SetEnvironmentVariable('GITHUB_TOKEN', $token, 'User')

# Configure Git credential helper
git config --global credential.helper store
$credFile = "$env:USERPROFILE\.git-credentials"
$gitUrl = "https://$token@github.com"
if (-not (Test-Path $credFile)) {
    New-Item -ItemType File -Path $credFile -Force | Out-Null
}
if (-not (Select-String -Path $credFile -Pattern $gitUrl -Quiet)) {
    Add-Content $credFile $gitUrl
}

Write-Host "Token saved to environment and Git credential store."
Write-Host "Verify with: echo `$env:GITHUB_TOKEN"
