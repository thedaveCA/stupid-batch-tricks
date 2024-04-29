@echo off
:: GetWindowsVersion.cmd - Set BATCH_WINVER_* from OS details
:: Last updated: 2024-04-09

if /I "%~1"=="--force" (
    call %~d0%~p0CleanEnvironmentVariables.cmd BATCH_WINVER
    shift
)

:: If we already have the variable set, no need to check again
if not defined BATCH_WINVER (
    goto :GetOSVersion
)
:: If we have the variable set, but not the parts, parse it again
if not defined BATCH_WINVER_major (
    goto :ParseOSVersion
)
if not defined BATCH_WINVER_minor (
    goto :ParseOSVersion
)
if not defined BATCH_WINVER_build (
    goto :ParseOSVersion
)

goto :CHECKHELP

:GetOSVersion
:: Find the OS version
for /f "tokens=2 delims==" %%a in ('wmic os get version /value') do set "BATCH_WINVER=%%a"

:ParseOSVersion
:: And parse into major, minor, and build
for /f "tokens=1,2,3 delims=." %%a in ("%BATCH_WINVER%") do (
    set BATCH_WINVER_major=%%a
    set BATCH_WINVER_minor=%%b
    set BATCH_WINVER_build=%%c
)

:CHECKHELP
if /I "%~1"=="--help" (
    echo.
    echo %ANSI_header%GetWindowsVersion.cmd%ANSI_normal% - Set BATCH_WINVER_* from OS details
    echo.
    echo Usage: GetWindowsVersion.cmd [--force] [--help]
    echo.
    echo Retrieves the OS version and parses it into major, minor, and build numbers.
    echo.
    echo Options: 
    echo   %ANSI_emphasis%--force%ANSI_normal% - Clear existing BATCH_WINVER_* variables before setting new values
    echo   %ANSI_emphasis%--help%ANSI_normal%  - Display this help message
    echo.
    echo Result: 
    echo   BATCH_WINVER=%BATCH_WINVER%
    echo   BATCH_WINVER_major=%BATCH_WINVER_major%
    echo   BATCH_WINVER_minor=%BATCH_WINVER_minor%
    echo   BATCH_WINVER_build=%BATCH_WINVER_build%
    echo.
    exit /b 0
)