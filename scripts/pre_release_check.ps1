param(
    [switch]$AllTests,
    [switch]$SkipBuild,
    [switch]$BuildReleaseAppBundle
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = Split-Path -Parent $PSScriptRoot

function Invoke-MarkyStep {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Command,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

    Write-Host ""
    Write-Host "==> $Name" -ForegroundColor Cyan
    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$Name failed. Fix the output above, then rerun scripts/pre_release_check.ps1."
    }
    Write-Host "PASS: $Name" -ForegroundColor Green
}

try {
    Push-Location $root

    Invoke-MarkyStep -Name 'Format check' -Command 'dart' -Arguments @(
        'format',
        '--set-exit-if-changed',
        'lib',
        'test'
    )

    Invoke-MarkyStep -Name 'Static analysis' -Command 'flutter' -Arguments @(
        'analyze'
    )

    Invoke-MarkyStep -Name 'Share overlay widget tests' -Command 'flutter' -Arguments @(
        'test',
        'test/v2/features/share_intent/presentation/share_overlay_app_test.dart'
    )

    if ($AllTests) {
        Invoke-MarkyStep -Name 'Full Flutter test suite' -Command 'flutter' -Arguments @(
            'test'
        )
    }

    if (-not $SkipBuild) {
        Invoke-MarkyStep -Name 'Debug APK build' -Command 'flutter' -Arguments @(
            'build',
            'apk',
            '--debug'
        )
    }

    if ($BuildReleaseAppBundle) {
        Invoke-MarkyStep -Name 'Release app bundle build' -Command 'flutter' -Arguments @(
            'build',
            'appbundle',
            '--release'
        )
    }

    Write-Host ""
    Write-Host 'PASS: Marky pre-release gate completed.' -ForegroundColor Green
    Write-Host 'Next: install the APK and run scripts/run_maestro.ps1.' -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "FAIL: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    Pop-Location
}
