# scripts/clean_and_build.ps1
# Purpose : Clean old build and rebuild frontend
# Encoding: UTF-8 (NO BOM)

$corePath = "C:\laragon\www\laravel12_fixed\laravel_core"
Set-Location $corePath

Write-Host "Cleaning old node_modules and build..."
Remove-Item -Recurse -Force "node_modules" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "public\build" -ErrorAction SilentlyContinue
Remove-Item -Force "package-lock.json" -ErrorAction SilentlyContinue

Write-Host "Reinstalling npm packages..."
npm install

Write-Host "Building production assets..."
npm run build

Write-Host "Frontend rebuilt successfully."
