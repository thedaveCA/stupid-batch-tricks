@echo off
:: timestamp.cmd - Generate a unique BATCH_TIMESTAMP from current date and time
:: Last updated: 2024-04-09

set BATCH_TIMESTAMP=
for /f "skip=1 delims=" %%a in ('wmic os get LocalDateTime') do if not defined BATCH_TIMESTAMP set "BATCH_TIMESTAMP=%%a"
set "BATCH_TIMESTAMP=%BATCH_TIMESTAMP:~0,4%%BATCH_TIMESTAMP:~4,2%%BATCH_TIMESTAMP:~6,2%-%BATCH_TIMESTAMP:~8,2%%BATCH_TIMESTAMP:~10,2%%BATCH_TIMESTAMP:~12,2%-%BATCH_TIMESTAMP:~15,3%"

if /I "%~1"=="--verbose" (
    echo %BATCH_TIMESTAMP%
) else if /I "%~1"=="--help" (
    echo.
    echo %ANSI_header%timestamp.cmd%ANSI_normal% - Generate a unique BATCH_TIMESTAMP from current date and time
    echo.
    echo Usage: %ANSI_highlight%timestamp.cmd [--help]%ANSI_normal%
    echo.
    echo Generates a unique timestamp in the format YYYYMMDD-HHMMSS-FFF.
    echo.
    echo Options: 
    echo   %ANSI_emphasis%--help%ANSI_normal%  - Display this help message
    echo   %ANSI_emphasis%--verbose%ANSI_normal% - Display the generated timestamp
    echo.
    echo Result: 
    echo   %ANSI_emphasis%BATCH_TIMESTAMP=%BATCH_TIMESTAMP%%ANSI_normal%
    echo.
)
exit /b 0