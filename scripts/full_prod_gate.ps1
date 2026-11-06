param(
    [switch]$SkipMaestro,
    [switch]$SkipShareOverlay,
    [switch]$BuildReleaseAppBundle,
    [string]$Maestro = 'maestro',
    [string]$Adb = 'adb'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = Split-Path -Parent $PSScriptRoot

try {
    Push-Location $root

    Write-Host ""
    Write-Host '==> Flutter release gate' -ForegroundColor Cyan
    & (Join-Path $PSScriptRoot 'pre_release_check.ps1') -AllTests
    if ($LASTEXITCODE -ne 0) {
        throw 'Flutter release gate failed.'
    }

    if (-not $SkipMaestro) {
        Write-Host ""
        Write-Host '==> Maestro human-like smoke suite' -ForegroundColor Cyan
        $maestroArgs = @('-InstallApk', '-Maestro', $Maestro, '-Adb', $Adb)
        if ($SkipShareOverlay) {
            $maestroArgs += '-SkipShareOverlay'
        }
        & (Join-Path $PSScriptRoot 'run_maestro.ps1') @maestroArgs
        if ($LASTEXITCODE -ne 0) {
            throw 'Maestro human-like smoke suite failed.'
        }
    }

    if ($BuildReleaseAppBundle) {
        Write-Host ""
        Write-Host '==> Release app bundle build' -ForegroundColor Cyan
        flutter build appbundle --release
        if ($LASTEXITCODE -ne 0) {
            throw 'Release app bundle build failed.'
        }
        Write-Host 'PASS: Release app bundle build' -ForegroundColor Green
    }

    Write-Host ""
    Write-Host 'PASS: Full production gate completed.' -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "FAIL: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    Pop-Location
}
