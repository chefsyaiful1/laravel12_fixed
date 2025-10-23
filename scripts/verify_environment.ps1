# =============================================================
# Laravel12 - Environment Verification Script (with Progress Bar)
# Version : v1.1
# Author  : Epul & ChatGPT
# =============================================================

$ErrorActionPreference = "Stop"
$projectRoot  = "C:\laragon\www\laravel12_fixed"
$corePath     = "$projectRoot\laravel_core"

$steps = @(
    "Checking PHP",
    "Checking Composer",
    "Checking Node.js",
    "Checking npm",
    "Checking Git",
    "Checking Laravel",
    "Checking .env and dependencies"
)

$total = $steps.Count
$step = 0

Write-Host "=== Laravel12 Environment Verification ===`n"

function Show-Progress($message, $percent) {
    Write-Progress -Activity "Laravel12 Environment Check" -Status $message -PercentComplete $percent
}

function Check-Command($cmd, $args = "--version") {
    try {
        $output = & $cmd $args 2>&1
        if ($LASTEXITCODE -eq 0 -or $output) {
            Write-Host ("{0,-10}: {1}" -f $cmd, ($output -split "`n")[0])
        } else {
            Write-Host ("{0,-10}: Not Found or Error" -f $cmd)
        }
    }
    catch {
        Write-Host ("{0,-10}: Not Installed" -f $cmd)
    }
}

foreach ($task in $steps) {
    $step++
    $percent = [math]::Round(($step / $total) * 100)
    Show-Progress "$task..." $percent

    switch ($task) {
        "Checking PHP" {
            Check-Command "php" "-v"
        }
        "Checking Composer" {
            Check-Command "composer" "--version"
        }
        "Checking Node.js" {
            Check-Command "node" "--version"
        }
        "Checking npm" {
            Check-Command "npm" "--version"
        }
        "Checking Git" {
            Check-Command "git" "--version"
        }
        "Checking Laravel" {
            try {
                Set-Location $corePath
                $artisanVersion = & php artisan --version
                Write-Host ("Laravel   : {0}" -f $artisanVersion)
            }
            catch {
                Write-Host "Laravel   : Not detected or artisan command failed."
            }
        }
        "Checking .env and dependencies" {
            $envFile = Join-Path $corePath ".env"
            if (Test-Path $envFile) {
                $dbHost = (Select-String "DB_HOST" $envFile).Line -replace "DB_HOST=", ""
                $dbName = (Select-String "DB_DATABASE" $envFile).Line -replace "DB_DATABASE=", ""
                Write-Host ("DB Host   : {0}" -f $dbHost)
                Write-Host ("DB Name   : {0}" -f $dbName)
            } else {
                Write-Host "Warning: .env file not found in laravel_core folder."
            }

            $nodeModulesPath = Join-Path $corePath "node_modules"
            if (Test-Path $nodeModulesPath) {
                $count = (Get-ChildItem $nodeModulesPath | Measure-Object).Count
                Write-Host ("node_modules: Found ({0} top-level packages)" -f $count)
            } else {
                Write-Host "node_modules: Missing - run npm install"
            }

            $vendorPath = Join-Path $corePath "vendor"
            if (Test-Path $vendorPath) {
                $count = (Get-ChildItem $vendorPath | Measure-Object).Count
                Write-Host ("vendor      : Found ({0} top-level folders)" -f $count)
            } else {
                Write-Host "vendor      : Missing - run composer install"
            }
        }
    }

    Start-Sleep -Milliseconds 400
}

Show-Progress "Environment verification completed." 100
Write-Host "`nVerification complete."
Write-Host "If all tools show correct versions and no errors appear, the environment is ready."
Write-Host "=============================================="
