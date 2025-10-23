# =============================================================
# Laravel12 - Environment Verification (Multi-line Progress)
# Version : v1.4
# Author  : Epul & ChatGPT
# =============================================================

$ErrorActionPreference = "Stop"
$projectRoot = "C:\laragon\www\laravel12_fixed"
$corePath    = "$projectRoot\laravel_core"

# --- Steps definition ----------------------------------------
$steps = @(
    "Checking PHP",
    "Checking Composer",
    "Checking Node.js",
    "Checking npm",
    "Checking Git",
    "Checking Laravel",
    "Checking .env and dependencies"
)

$totalSteps = $steps.Count
$stepDurations = @()
$overallTimer  = [System.Diagnostics.Stopwatch]::StartNew()

# --- Helper: redraw screen each cycle ------------------------
function Show-CompositeProgress {
    param($current, $statusText, $avgTime)

    $done = $stepDurations.Count
    $remaining = [math]::Round(($totalSteps - $done) * $avgTime,1)
    $overallPct = [math]::Round(($current / $totalSteps) * 100)

    Clear-Host
    Write-Host "=== Laravel12 Environment Verification ==="
    Write-Host ""
    for ($i=0; $i -lt $totalSteps; $i++) {
        $prefix = ("{0,2}/{1}" -f ($i+1),$totalSteps)
        if ($i -lt $done) {
            $duration = [math]::Round($stepDurations[$i],1)
            Write-Host ("{0}  [DONE]  ({1}s)   {2}" -f $prefix,$duration,$steps[$i])
        }
        elseif ($i -eq $done) {
            Write-Host ("{0}  [RUN ]           {1}" -f $prefix,$steps[$i])
        }
        else {
            Write-Host ("{0}  [WAIT]           {1}" -f $prefix,$steps[$i])
        }
    }

    Write-Host ""
    Write-Host ("Total Progress: {0}%   Estimated remaining: {1}s" -f $overallPct,$remaining)
    Write-Host ("Current: {0}" -f $statusText)
}

# --- Command checker -----------------------------------------
function Check-Command($cmd,$args="--version"){
    try{
        $out = & $cmd $args 2>&1
        if($LASTEXITCODE -eq 0 -or $out){("{0,-10}: {1}" -f $cmd,($out -split "`n")[0])}
        else{"{0,-10}: Not Found or Error" -f $cmd}
    }catch{"{0,-10}: Not Installed" -f $cmd}
}

# --- Run each step -------------------------------------------
for($i=0;$i -lt $totalSteps;$i++){
    $avg = 0
    if($stepDurations.Count -gt 0){$avg = ($stepDurations | Measure-Object -Average).Average}
    Show-CompositeProgress ($i) $steps[$i] $avg
    $stepTimer = [System.Diagnostics.Stopwatch]::StartNew()

    switch ($steps[$i]) {
        "Checking PHP"            {Write-Host (Check-Command "php" "-v")}
        "Checking Composer"       {Write-Host (Check-Command "composer" "--version")}
        "Checking Node.js"        {Write-Host (Check-Command "node" "--version")}
        "Checking npm"            {Write-Host (Check-Command "npm" "--version")}
        "Checking Git"            {Write-Host (Check-Command "git" "--version")}
        "Checking Laravel"        {
                                    try {
                                        Set-Location $corePath
                                        $v = & php artisan --version
                                        Write-Host ("Laravel   : {0}" -f $v)
                                    } catch { Write-Host "Laravel   : Not detected" }
                                  }
        "Checking .env and dependencies" {
                                    $envFile = Join-Path $corePath ".env"
                                    if(Test-Path $envFile){
                                        $dbHost=(Select-String "DB_HOST" $envFile).Line -replace "DB_HOST=",""
                                        $dbName=(Select-String "DB_DATABASE" $envFile).Line -replace "DB_DATABASE=",""
                                        Write-Host ("DB Host   : {0}" -f $dbHost)
                                        Write-Host ("DB Name   : {0}" -f $dbName)
                                    }
                                    $nm = Join-Path $corePath "node_modules"
                                    $vd = Join-Path $corePath "vendor"
                                    if(!(Test-Path $nm)){Write-Host "node_modules missing"}else{Write-Host "node_modules ok"}
                                    if(!(Test-Path $vd)){Write-Host "vendor missing"}else{Write-Host "vendor ok"}
                                  }
    }

    $stepTimer.Stop()
    $stepDurations += $stepTimer.Elapsed.TotalSeconds
    Start-Sleep -Milliseconds 300
}

# --- Final Summary -------------------------------------------
$overallTimer.Stop()
$avgAll = [math]::Round(($stepDurations | Measure-Object -Average).Average,1)
$totalTime = [math]::Round($overallTimer.Elapsed.TotalSeconds,1)

Show-CompositeProgress $totalSteps "Completed" 0
Write-Host ""
Write-Host ("Average step time: {0}s" -f $avgAll)
Write-Host ("Total verification time: {0}s" -f $totalTime)
Write-Host "Environment ready if all steps show DONE."
Write-Host "================================================="
