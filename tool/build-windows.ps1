param(
    [ValidateSet('Validate', 'Debug', 'Release')]
    [string]$Mode = 'Debug'
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Invoke-Checked {
    param([string]$Program, [string[]]$Arguments)
    & $Program @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$Program failed (exit $LASTEXITCODE). Build stopped."
    }
}

Push-Location (Join-Path $PSScriptRoot '..')
try {
    foreach ($program in @('flutter', 'dart', 'python')) {
        if (-not (Get-Command $program -ErrorAction SilentlyContinue)) {
            throw "Missing $program. Follow docs/WINDOWS_BUILD.md first."
        }
    }
    if ($Mode -eq 'Release' -and -not (Test-Path 'android/key.properties')) {
        throw 'Configure android/key.properties locally before a release build.'
    }
    Invoke-Checked 'flutter' @('--version')
    Invoke-Checked 'flutter' @('pub', 'get')
    Invoke-Checked 'dart' @('tool/content_check.dart')
    Invoke-Checked 'python' @('tool/static_check.py')
    Invoke-Checked 'flutter' @('analyze')
    Invoke-Checked 'flutter' @('test')
    if ($Mode -eq 'Debug') {
        Invoke-Checked 'flutter' @('build', 'apk', '--debug')
        Write-Host 'APK: build/app/outputs/flutter-apk/app-debug.apk'
    }
    if ($Mode -eq 'Release') {
        Invoke-Checked 'flutter' @('build', 'apk', '--release')
        Invoke-Checked 'flutter' @('build', 'appbundle', '--release')
        Write-Host 'APK: build/app/outputs/flutter-apk/app-release.apk'
        Write-Host 'AAB: build/app/outputs/bundle/release/app-release.aab'
    }
    Write-Host 'Requested checks completed. Device QA is still required.'
} finally {
    Pop-Location
}
