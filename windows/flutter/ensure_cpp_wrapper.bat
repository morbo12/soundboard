@echo off
REM Ensure Windows C++ client wrapper sources are present for the build.
REM This works around intermittent issues where Flutter's build process fails to
REM unpack the wrapper sources from the engine artifacts.

setlocal enabledelayedexpansion

if "%1"=="" (
    set "EPHEMERAL_DIR=%~dp0ephemeral"
) else (
    set "EPHEMERAL_DIR=%1"
)

set "WRAPPER_SRC=%EPHEMERAL_DIR%\cpp_client_wrapper"

echo [ensure_cpp_wrapper] Checking for C++ wrapper sources in: %WRAPPER_SRC%

REM Check if required files are missing
set "FILES_MISSING=0"
for %%F in (core_implementations.cc standard_codec.cc plugin_registrar.cc flutter_engine.cc flutter_view_controller.cc engine_method_result.cc readme) do (
    if not exist "%WRAPPER_SRC%\%%F" (
        set "FILES_MISSING=1"
        echo [ensure_cpp_wrapper] Missing: %%F
    )
)

REM If files are missing, copy from Flutter SDK engine artifacts
if %FILES_MISSING% equ 1 (
    echo [ensure_cpp_wrapper] Missing C++ wrapper sources. Restoring from Flutter SDK engine artifacts...
    
    REM Find Flutter SDK from FLUTTER_ROOT first
    if defined FLUTTER_ROOT (
        set "FLUTTER_SDK=!FLUTTER_ROOT!"
        echo [ensure_cpp_wrapper] Using FLUTTER_ROOT: !FLUTTER_SDK!
    ) else (
        REM Try to find flutter from PATH
        for /f "tokens=*" %%A in ('where flutter.bat 2^>nul') do (
            for %%B in ("%%A\..\..\..") do set "FLUTTER_SDK=%%~fB"
        )
        if defined FLUTTER_SDK (
            echo [ensure_cpp_wrapper] Found flutter in PATH at: !FLUTTER_SDK!
        )
    )
    
    if not defined FLUTTER_SDK (
        echo [ensure_cpp_wrapper] ERROR: Could not locate Flutter SDK. Trying common locations...
        REM Try common Windows Flutter install locations
        if exist "%LOCALAPPDATA%\flutter\bin\flutter.bat" (
            set "FLUTTER_SDK=%LOCALAPPDATA%\flutter"
            echo [ensure_cpp_wrapper] Found flutter at: !FLUTTER_SDK!
        ) else if exist "C:\flutter\bin\flutter.bat" (
            set "FLUTTER_SDK=C:\flutter"
            echo [ensure_cpp_wrapper] Found flutter at: !FLUTTER_SDK!
        ) else (
            echo [ensure_cpp_wrapper] ERROR: Could not locate Flutter SDK anywhere. Set FLUTTER_ROOT environment variable.
            exit /b 1
        )
    )
    
    set "ENGINE_WRAPPER_SRC=!FLUTTER_SDK!\bin\cache\artifacts\engine\windows-x64\cpp_client_wrapper"
    
    echo [ensure_cpp_wrapper] Looking for engine artifacts at: !ENGINE_WRAPPER_SRC!
    
    if not exist "!ENGINE_WRAPPER_SRC!" (
        echo [ensure_cpp_wrapper] ERROR: Flutter engine artifacts not found at: !ENGINE_WRAPPER_SRC!
        exit /b 1
    )
    
    REM Ensure destination directory exists
    if not exist "%WRAPPER_SRC%\include" mkdir "%WRAPPER_SRC%\include"
    
    REM Copy wrapper sources and headers
    echo [ensure_cpp_wrapper] Copying wrapper sources from: !ENGINE_WRAPPER_SRC!
    xcopy /E /I /Y "!ENGINE_WRAPPER_SRC!" "%WRAPPER_SRC%"
    
    if %ERRORLEVEL% neq 0 (
        echo [ensure_cpp_wrapper] ERROR: Failed to copy wrapper sources. xcopy returned: %ERRORLEVEL%
        exit /b 1
    )
    
    echo [ensure_cpp_wrapper] SUCCESS: C++ wrapper sources restored
) else (
    echo [ensure_cpp_wrapper] OK: C++ wrapper sources are present
)

exit /b 0
