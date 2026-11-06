param(
    [switch]$BuildApk,
    [switch]$InstallApk,
    [switch]$SkipShareOverlay,
    [string]$Maestro = 'C:\maestro\maestro\bin\maestro.bat',
    [string]$Adb = 'adb'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = Split-Path -Parent $PSScriptRoot
$appId = 'com.marky.app.marky'
$apkPath = Join-Path $root 'build\app\outputs\flutter-apk\app-debug.apk'
$flowDir = Join-Path $root '.maestro'
$standardFlows = @(
    '01_onboarding.yaml',
    '02_bottom_navigation.yaml',
    '03_home_ui_stability.yaml',
    '04_quick_add_sheet.yaml',
    '05_settings_automation.yaml'
)

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
        throw "$Name failed. Fix the output above, then rerun scripts/run_maestro.ps1."
    }
    Write-Host "PASS: $Name" -ForegroundColor Green
}

function Invoke-MaestroFlow {
    param(
        [Parameter(Mandatory = $true)][string]$FlowName
    )

    $flowPath = Join-Path $flowDir $FlowName
    if (-not (Test-Path $flowPath)) {
        throw "Missing Maestro flow: $flowPath"
    }

    Invoke-MarkyStep -Name "Maestro flow $FlowName" -Command $Maestro -Arguments @(
        'test',
        $flowPath
    )
}

function Assert-MarkyShareOverlayActivity {
    param(
        [Parameter(Mandatory = $true)][string]$AdbCommand
    )

    Write-Host ""
    Write-Host '==> Share overlay activity check' -ForegroundColor Cyan
    $activityOutput = & $AdbCommand @(
        'shell',
        'dumpsys',
        'activity',
        'activities'
    ) | Out-String
    if ($LASTEXITCODE -ne 0) {
        throw 'Could not inspect Android activity state.'
    }
    if ($activityOutput -notmatch 'ShareOverlayActivity') {
        throw 'ShareOverlayActivity was not found in the current Android activity stack.'
    }
    if (
        $activityOutput -notmatch 'topResumedActivity=.*ShareOverlayActivity' -and
        $activityOutput -notmatch 'mResumedActivity:.*ShareOverlayActivity' -and
        $activityOutput -notmatch 'ResumedActivity:.*ShareOverlayActivity'
    ) {
        throw 'ShareOverlayActivity is present but not resumed.'
    }
    Write-Host 'PASS: Share overlay activity is resumed.' -ForegroundColor Green
}

try {
    Push-Location $root

    if (-not (Get-Command $Maestro -ErrorAction SilentlyContinue)) {
        throw "Maestro CLI was not found. Install Maestro, then rerun this script."
    }

    Write-Host ""
    Write-Host 'NOTE: The onboarding flow clears Marky app state on the connected test device.' -ForegroundColor Yellow
    Write-Host 'Use a test install/device, not a device with real unsynced user data.' -ForegroundColor Yellow

    if ($BuildApk) {
        Invoke-MarkyStep -Name 'Debug APK build' -Command 'flutter' -Arguments @(
            'build',
            'apk',
            '--debug'
        )
    }

    if ($InstallApk) {
        if (-not (Get-Command $Adb -ErrorAction SilentlyContinue)) {
            throw "ADB was not found. Install Android platform-tools or add adb to PATH."
        }
        if (-not (Test-Path $apkPath)) {
            throw "Debug APK not found at $apkPath. Run this script with -BuildApk first."
        }
        Invoke-MarkyStep -Name 'Install debug APK' -Command $Adb -Arguments @(
            'install',
            '-r',
            $apkPath
        )
    }

    foreach ($flow in $standardFlows) {
        Invoke-MaestroFlow -FlowName $flow
    }

    if (-not $SkipShareOverlay) {
        if (-not (Get-Command $Adb -ErrorAction SilentlyContinue)) {
            throw "ADB was not found. Install Android platform-tools or rerun with -SkipShareOverlay."
        }

        Invoke-MarkyStep -Name 'Stop Marky before share intent' -Command $Adb -Arguments @(
            'shell',
            'am',
            'force-stop',
            $appId
        )

        Invoke-MarkyStep -Name 'Launch share overlay via Android intent' -Command $Adb -Arguments @(
            'shell',
            'am',
            'start',
            '-W',
            '-a',
            'android.intent.action.SEND',
            '-t',
            'text/plain',
            '--es',
            'android.intent.extra.TEXT',
            'https://example.com/marky-maestro-smoke',
            '-n',
            "$appId/.ShareOverlayActivity"
        )

        Start-Sleep -Seconds 2
        Assert-MarkyShareOverlayActivity -AdbCommand $Adb
    }

    Write-Host ""
    Write-Host 'PASS: Maestro human-like smoke suite completed.' -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "FAIL: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    Pop-Location
}
