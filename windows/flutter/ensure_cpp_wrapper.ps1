# Ensure Windows C++ client wrapper sources are present for the build.
# This works around intermittent issues where Flutter's build process fails to
# unpack the wrapper sources from the engine artifacts.

param(
    [string]$EphemeralDir = "$PSScriptRoot/ephemeral",
    [string]$FlutterRoot = $env:FLUTTER_ROOT
)

$wrapperSrc = "$EphemeralDir/cpp_client_wrapper"
$requiredFiles = @(
    "core_implementations.cc",
    "standard_codec.cc",
    "plugin_registrar.cc",
    "flutter_engine.cc",
    "flutter_view_controller.cc",
    "engine_method_result.cc",
    "readme"
)

# Check if any required files are missing
$missingFiles = @()
foreach ($file in $requiredFiles) {
    if (-not (Test-Path "$wrapperSrc/$file")) {
        $missingFiles += $file
    }
}

# If files are missing, copy from Flutter SDK engine artifacts
if ($missingFiles.Count -gt 0) {
    Write-Host "⚠️  Missing C++ wrapper sources. Restoring from Flutter SDK engine artifacts..." -ForegroundColor Yellow
    
    # Find Flutter SDK
    if ([string]::IsNullOrEmpty($FlutterRoot)) {
        $flutterExe = Get-Command flutter -ErrorAction SilentlyContinue
        if ($flutterExe) {
            $FlutterRoot = Split-Path -Parent (Split-Path -Parent $flutterExe.Source)
        }
    }
    
    if ([string]::IsNullOrEmpty($FlutterRoot)) {
        Write-Error "Could not locate Flutter SDK. Set FLUTTER_ROOT environment variable or ensure 'flutter' is in PATH."
        exit 1
    }
    
    $engineWrapperSrc = "$FlutterRoot/bin/cache/artifacts/engine/windows-x64/cpp_client_wrapper"
    
    if (-not (Test-Path $engineWrapperSrc)) {
        Write-Error "Flutter engine artifacts not found at: $engineWrapperSrc"
        exit 1
    }
    
    # Ensure destination directory exists
    New-Item -ItemType Directory -Force -Path "$wrapperSrc/include" | Out-Null
    
    # Copy wrapper sources and headers
    Write-Host "Copying wrapper sources from: $engineWrapperSrc"
    Copy-Item -Force -Recurse "$engineWrapperSrc/*" "$wrapperSrc"
    
    Write-Host "✓ C++ wrapper sources restored successfully" -ForegroundColor Green
}
else {
    Write-Host "✓ C++ wrapper sources are present" -ForegroundColor Green
}
