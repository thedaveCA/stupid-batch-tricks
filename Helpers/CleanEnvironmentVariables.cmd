@echo off
:: CleanEnvironmentVariables.cmd - Remove environment variables by prefix
:: Last updated: 2024-04-09

if "%~1" == "" goto :HELP
if /I "%~1" == "--help" goto :HELP

:TOP
if [%~1] == [] exit /b 0
for /f "tokens=1* delims==" %%a in ('set ^| findstr /B "%1"') do (
    set "%%a="
)
shift
goto :TOP

:HELP
    echo.
    echo %ANSI_header%CleanEnvironmentVariables.cmd%ANSI_normal% - Remove environment variables by prefix
    echo.
    echo Usage: CleanEnvironmentVariables.cmd "prefix"
    echo.
    echo. Removes all environment variables that start with the given prefix.
    echo. Requires 1 or more prefixes to remove.
    echo.
    echo. EXAMPLE: %ANSI_emphasis%CleanEnvironmentVariables.cmd BATCH_%ANSI_normal%
    echo. EXAMPLE: %ANSI_emphasis%CleanEnvironmentVariables.cmd ANSI_ BATCH_%ANSI_normal%
    echo.
    echo. Matches are CASE SENSITIVE. No error returned if no matches are found.
    exit /b 1
