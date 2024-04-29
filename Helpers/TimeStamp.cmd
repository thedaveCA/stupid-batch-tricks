@echo off
:: timestamp.cmd - Generate a unique BATCH_TIMESTAMP from current date and time
:: Last updated: 2024-04-09

set mydate=
for /f "skip=1 delims=" %%a in ('wmic os get LocalDateTime') do if not defined mydate set "mydate=%%a"
set "BATCH_TIMESTAMP=%mydate:~0,4%%mydate:~4,2%%mydate:~6,2%-%mydate:~8,2%%mydate:~10,2%%mydate:~12,2%-%mydate:~15,3%"
set mydate=

if /I "%~1"=="--help" (
    echo.
    echo %ANSI_header%timestamp.cmd%ANSI_normal% - Generate a unique BATCH_TIMESTAMP from current date and time
    echo.
    echo Usage: %ANSI_highlight%timestamp.cmd [--help]%ANSI_normal%
    echo.
    echo Generates a unique timestamp in the format YYYYMMDD-HHMMSS-FFF.
    echo.
    echo Options: 
    echo   %ANSI_emphasis%--help%ANSI_normal%  - Display this help message
    echo.
    echo Result: 
    echo   BATCH_TIMESTAMP=%BATCH_TIMESTAMP%
    echo.
    exit /b 0
)