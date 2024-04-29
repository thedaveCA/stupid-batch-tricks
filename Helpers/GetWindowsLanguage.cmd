@echo off
:: GetWindowsLanguage.cmd - Set BATCH_WIN_LANGUAGE from OS language
:: Last updated: 2024-04-09

if /I "%~1"=="--force" (
    set BATCH_WIN_LANGUAGE=
    shift
)

:: If we already have a language code, no need to check again
if defined BATCH_WIN_LANGUAGE (
    goto :CHECKHELP
)

:: Find the OS language code
for /f "tokens=2 delims==" %%a in ('wmic os get OSLanguage /Value') do set "BATCH_WIN_LANGUAGE=%%a"
:: And turn it into a supported text string, when possible
if [%BATCH_WIN_LANGUAGE%] == [1252] (
    set BATCH_WIN_LANGUAGE=DE
) else if [%BATCH_WIN_LANGUAGE%] == [1254] (
    set BATCH_WIN_LANGUAGE=FR
) else if [%BATCH_WIN_LANGUAGE%] == [1250] (
    set BATCH_WIN_LANGUAGE=IT
) else if [%BATCH_WIN_LANGUAGE%] == [1033] (
    set BATCH_WIN_LANGUAGE=EN
) else (
    echo Unsupported language code: %BATCH_WIN_LANGUAGE%
)

:CHECKHELP
if /I "%~1"=="--help" (
    echo.
    echo %ANSI_header%GetWindowsLanguage.cmd%ANSI_normal% - Set BATCH_WIN_LANGUAGE from OS language
    echo.
    echo Usage: %ANSI_highlight%GetWindowsLanguage.cmd [--force] [--help]%ANSI_normal%
    echo.
    echo Retrieves the language code of the Windows operating system,
    echo sets BATCH_WIN_LANGUAGE to the supported text string when possible,
    echo leaving unsupported language codes as their numerical form.
    echo.
    echo Options: 
    echo   %ANSI_emphasis%--force%ANSI_normal% - Clear existing BATCH_WIN_LANGUAGE variable before setting new values
    echo   %ANSI_emphasis%--help%ANSI_normal%  - Display this help message
    echo.
    echo Supported language codes:
    echo   1033 - EN - English
    echo   1250 - IT - Italian
    echo   1252 - DE - German
    echo   1254 - FR - French
    echo.
    echo Result: 
    echo   BATCH_WIN_LANGUAGE=%BATCH_WIN_LANGUAGE%
    echo.
    exit /b 0
)