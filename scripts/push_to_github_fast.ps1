# =============================================================
# Laravel12 - Fast Build + Push Automation
# Version : v2.6-fast
# Author  : Epul & ChatGPT
# =============================================================

$ErrorActionPreference = "Stop"

# --- Configuration -------------------------------------------
$projectRoot  = "C:\laragon\www\laravel12_fixed"
$corePath     = "$projectRoot\laravel_core"
$backupDir    = "$projectRoot\backups"
$logDir       = "$projectRoot\scripts\logs"
$verifyScript = "$projectRoot\scripts\verify_environment_v1.5.ps1"

# --- Prepare directories -------------------------------------
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

Write-Host "=== Laravel12 Fast Push Automation ===`n"
Write-Log  "Start push sequence ($versionTag)"

# =============================================================
# STEP 0: ENVIRONMENT VERIFICATION
# =============================================================
if (Test-Path $verifyScript) {
    Write-Log "Running environment verification..."
    $verifyProcess = Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$verifyScript`"" `
                    -Wait -PassThru -WindowStyle Hidden
    if ($verifyProcess.ExitCode -ne 0) {
        Write-Log "Environment verification FAILED. Push aborted."
        exit 1
    } else {
        Write-Log "Environment verification PASSED."
    }
} else {
    Write-Log "Verification script not found. Skipping environment check."
}

# =============================================================
# STEP 1: CLEAN + BUILD FRONTEND
# =============================================================
Set-Location $corePath
Write-Log "Starting npm clean and build..."
try {
    Remove-Item -Recurse -Force "public\build" -ErrorAction SilentlyContinue
    npm install --legacy-peer-deps | Out-Null
    npm run build | Out-Null
    node .\scripts\fix-manifest.js
    Write-Log "Frontend build completed successfully."
}
catch {
    Write-Log "ERROR during npm build: $($_.Exception.Message)"
    exit 1
}

# =============================================================
# STEP 2: FAST BACKUP ZIP CREATION
# =============================================================
Set-Location $projectRoot
Write-Log "Creating fast ZIP backup (excluding heavy folders)..."

try {
    Add-Type -AssemblyName 'System.IO.Compression.FileSystem'
    if (Test-Path $zipFile) { Remove-Item $zipFile -Force }

    # Define folders to exclude for speed
    $exclude = @(
        "node_modules",
        "laravel_core\vendor",
        "laravel_core\storage\logs",
        "backups"
    )

    # Gather only needed files
    $files = Get-ChildItem -Path $projectRoot -Recurse -File | Where-Object {
        foreach ($ex in $exclude) {
            if ($_.FullName -like "*\$ex*") { return $false }
        }
        return $true
    }

    # Build the archive manually
    $zip = [System.IO.Compression.ZipFile]::Open($zipFile, "Create")
    foreach ($file in $files) {
        $relative = $file.FullName.Substring($projectRoot.Length + 1)
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $file.FullName, $relative, "Optimal") | Out-Null
    }
    $zip.Dispose()

    Write-Log "Fast backup created successfully at: $zipFile"
}
catch {
    Write-Log "ERROR creating fast ZIP: $($_.Exception.Message)"
    exit 1
}

# =============================================================
# STEP 3: INCLUDE BUILD ASSETS
# =============================================================
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

# =============================================================
# STEP 4: GIT COMMIT + PUSH
# =============================================================
Write-Log "Running Git commit and push..."
try {
    git add .
    git commit -m "Auto fast backup + build + assets $versionTag" | Out-Null
    git tag -a $versionTag -m "Version $versionTag"
    git push origin main
    git push origin $versionTag
    Write-Log "Successfully pushed $versionTag to GitHub."
}
catch {
    Write-Log "ERROR during Git push: $($_.Exception.Message)"
    exit 1
}

# =============================================================
# STEP 5: SUMMARY
# =============================================================
Write-Log "Push completed at $(Get-Date -Format 'HH:mm:ss')"
Write-Host ""
Write-Host "Process completed successfully."
Write-Host "Backup ZIP stored at: $zipFile"
Write-Host "Details logged to:   $logFile"
Write-Host ""
Write-Host "=== Laravel12 fast push finished ==="
