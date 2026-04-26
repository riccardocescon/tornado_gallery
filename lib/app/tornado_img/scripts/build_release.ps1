<#
.SYNOPSIS
    Build hardened release binaries for Android (.aab) and iOS (.ipa).

.DESCRIPTION
    Applies:
      - Flutter Dart obfuscation   (--obfuscate)
      - Split debug-info           (symbols stored locally, NOT shipped in binary)
      - Android R8 minification    (configured in build.gradle.kts)
      - Android ProGuard rules     (android/app/proguard-rules.pro)
      - iOS symbol stripping       (configured in project.pbxproj)

.PARAMETER Platform
    android | ios | all  (default: all)

.EXAMPLE
    .\scripts\build_release.ps1 -Platform android
    .\scripts\build_release.ps1 -Platform ios
    .\scripts\build_release.ps1
#>

param(
    [ValidateSet("android", "ios", "all")]
    [string]$Platform = "all"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Resolve to the app root (one level up from /scripts)
$AppRoot = Split-Path -Parent $PSScriptRoot
Set-Location $AppRoot

$SymbolsDir = Join-Path $AppRoot "build\release-symbols"
New-Item -ItemType Directory -Force -Path $SymbolsDir | Out-Null

Write-Host "==> Using symbol output: $SymbolsDir" -ForegroundColor Cyan

# ------------------------------------------------------------------
# Android
# ------------------------------------------------------------------
function Build-Android {
    Write-Host ""
    Write-Host "==> Building Android release AAB..." -ForegroundColor Yellow

    flutter build appbundle `
        --release `
        --obfuscate `
        --split-debug-info="$SymbolsDir\android"

    Write-Host ""
    Write-Host "[OK] Android AAB -> build\app\outputs\bundle\release\app-release.aab" -ForegroundColor Green
    Write-Host "[OK] Debug symbols -> $SymbolsDir\android" -ForegroundColor Green
    Write-Host ""
    Write-Host "  IMPORTANT: upload the symbol files to Play Console" -ForegroundColor DarkYellow
    Write-Host "  (Release > App bundle explorer > Download symbols)" -ForegroundColor DarkYellow
}

# ------------------------------------------------------------------
# iOS
# ------------------------------------------------------------------
function Build-iOS {
    Write-Host ""
    Write-Host "==> Building iOS release archive..." -ForegroundColor Yellow

    # --no-codesign lets CI sign later; remove if building locally with a cert
    flutter build ipa `
        --release `
        --obfuscate `
        --split-debug-info="$SymbolsDir\ios" `
        --no-codesign

    Write-Host ""
    Write-Host "[OK] iOS IPA -> build\ios\ipa" -ForegroundColor Green
    Write-Host "[OK] Debug symbols -> $SymbolsDir\ios" -ForegroundColor Green
    Write-Host ""
    Write-Host "  IMPORTANT: upload the dSYM + symbol files to App Store Connect / Crashlytics" -ForegroundColor DarkYellow
}

# ------------------------------------------------------------------
# Entry point
# ------------------------------------------------------------------
switch ($Platform) {
    "android" { Build-Android }
    "ios"     { Build-iOS     }
    "all"     { Build-Android; Build-iOS }
}
