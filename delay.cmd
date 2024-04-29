@echo off
:: delay.cmd - Wait a defined number of seconds.
:: Intended for compatibility with other junk I've written for TCC.
:: Last updated: 2024-04-09

setlocal enableextensions

if "%~1" == "" goto :help
if /I "%~1" == "--help" goto :help

:: Check if %1 is a digit, if not, redirect to usage
for /f "delims=0123456789" %%i in ("%~1") do goto :usageerror
if errorlevel 1 goto :usageerror

:delay
choice /C ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 /D Z /T %1 /N > nul
goto :eof

:usageerror
echo %ANSI_bright_red%Error:%ANSI_normal% %1 is not a integer.

:help
echo.
echo %ANSI_header%delay.cmd%ANSI_normal% - Wait a defined number of seconds
echo.
echo Usage: %ANSI_highlight%delay.cmd %ANSI_emphasis%number%ANSI_normal% OR [--help]%ANSI_normal%
echo.
echo Description:
echo   Waits for the specified number of seconds before continuing.
echo   Pressing a letter or number will stop the delay.
echo.
echo Options:
echo  %ANSI_emphasis%number%ANSI_normal%      Number of seconds to wait (0-9999)
echo  %ANSI_emphasis%--help%ANSI_normal%  Display this help message.
echo.
echo Example:
echo   delay.cmd 5
echo.
goto :eof
