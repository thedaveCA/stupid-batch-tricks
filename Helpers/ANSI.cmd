@echo off
:: ANSI.cmd - detect ANSI support and set ANSI variables for use elsewhere
:: Last updated: 2024-04-09
::
:: ############################### INSTRUCTIONS ###############################
::
:: A script check can load ANSI.cmd if it exists in the same directory:
:: if exist "%~dp0ANSI.cmd" call "%~dp0ANSI.cmd"
::
:: Or from a helpers directory: 
:: if exist "%~dp0Helpers\ANSI.cmd" call "%~dp0Helpers\ANSI.cmd"
::
:: ################################ REFERENCES ################################
::
:: https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#text-modification
::

:: If the first argument is empty, and we have ANSI_header already set, bail quickly.
if [%~1]==[] (
    if defined ANSI_header (
        goto :END
    )
)

:: Display help message if --help is the first argument, then bail
if /I "%~1"=="--help" (
    echo.
    echo %ANSI_header%%~nx0%ANSI_normal% - Detect ANSI support and set ANSI variables.
    echo.
    echo USAGE:
    echo   %ANSI_fg_bright_white%%~nx0 [OPTIONS]%ANSI_normal%
    echo.
    echo OPTIONS:
    echo   %ANSI_emphasis%--help%ANSI_normal%          Display this help message.
    echo   %ANSI_emphasis%--cleanup%ANSI_normal%       Remove all ANSI_ variables from the environment.
    echo   %ANSI_emphasis%--ansi%ANSI_normal%          Enable ANSI support.
    echo   %ANSI_emphasis%--plain%ANSI_normal%         Disable ANSI support.
    echo   %ANSI_emphasis%--test%ANSI_normal%          Show example text in various formats.
    echo   %ANSI_emphasis%--dump%ANSI_normal%          Dump all ANSI_ ANSI variables from the environment
    echo.
    echo EXAMPLES:
    echo   %~nx0 --help
    echo   %~nx0 --cleanup
    echo   %~nx0 --ansi
    echo   %~nx0 --plain
    echo   %~nx0 --test
    echo   %~nx0 --cleanup --test
    echo   %~nx0 --ansi --test
    echo   %~nx0 --plain --test
    echo.
    echo NOTES:
    echo   If no arguments provided, ANSI will be autodetected.
    echo   %ANSI_fg_bright_white%--ansi and %ANSI_fg_bright_white%--plain%ANSI_normal% can be used to override detection.
    echo   %ANSI_fg_bright_white%--test%ANSI_normal% must be last if combined with other arguments.
    echo   Argument parsing is limited, and no attempt at validation is made.
    echo   If ANSI support is not detected, some ANSI_LOG_* variables will be set to plaintext
    echo.
    shift
    goto :END
)

:: If --test is first and we've already run, skip everything, otherwise detect
if /I [%~1]==[--test] if defined ANSI_header goto :TEST
if /I [%~1]==[--dump] if defined ANSI_header goto :TEST

for %%f in (
    "CleanEnvironmentVariables.cmd"
    "GetWindowsVersion.cmd"
    "GetWindowsLanguage.cmd"
) do (
    if not exist "%~dp0%%~f" (
        echo %ANSI_LOG_ERROR%%%~f not found in the same directory.
        exit /b 1
    )
)

call "%~dp0CleanEnvironmentVariables.cmd" ANSI_ BATCH_ANSI_

:: --cleanup skips adding any other variables
if [%~1] == [--cleanup] (
    shift
    GOTO :TEST
)

call "%~dp0GetWindowsVersion.cmd"
call "%~dp0GetWindowsLanguage.cmd"

:: --ansi to force ANSI support even if detection fails
:: --plain to block ANSI support, overriding detection above
:: otherwise guess based on Windows version and hope for a compatible terminal
:: Set BATCH_ANSI_SUPPORTED to the reason ANSI is offered, if available
if [%~1] == [--ansi] (
    set BATCH_ANSI_SUPPORTED=--ansi
    shift
) else if [%~1] == [--plain] (
    set BATCH_ANSI_SUPPORTED=
    shift
) else if defined NO_COLOR (
    set BATCH_ANSI_SUPPORTED=
) else (
    if %BATCH_WINVER_major% GTR 10 set "BATCH_ANSI_SUPPORTED=Windows 11 or later"
    if %BATCH_WINVER_major% EQU 10 (
        if %BATCH_WINVER_build% GTR 10586 set "BATCH_ANSI_SUPPORTED=Windows 10.0.10586 or later, build=%BATCH_WINVER_build%"
    )
)

:: Define ANSI_ESC first, because it's used in the rest of the variables
if defined BATCH_ANSI_SUPPORTED (
    set ANSI_ESC=
)
:: Set the rest, without relying on delayed expansion
if defined BATCH_ANSI_SUPPORTED (
    set ANSI_text_bold=%ANSI_ESC%[1m
    set ANSI_text_no_bold=%ANSI_ESC%[22m
    set ANSI_text_faint=%ANSI_ESC%[2m
    set ANSI_text_underline=%ANSI_ESC%[4m
    set ANSI_text_no_underline=%ANSI_ESC%[24m
    set ANSI_text_italic=%ANSI_ESC%[3m
    set ANSI_text_inverse=%ANSI_ESC%[7m
    set ANSI_text_strike=%ANSI_ESC%[9m
    set ANSI_text_no_strike=%ANSI_ESC%[29m
    set ANSI_text_overline=%ANSI_ESC%[53m
    set ANSI_text_blink=%ANSI_ESC%[5m

    set ANSI_fg_black=%ANSI_ESC%[30m
    set ANSI_fg_red=%ANSI_ESC%[31m
    set ANSI_fg_green=%ANSI_ESC%[32m
    set ANSI_fg_yellow=%ANSI_ESC%[33m
    set ANSI_fg_blue=%ANSI_ESC%[34m
    set ANSI_fg_magenta=%ANSI_ESC%[35m
    set ANSI_fg_cyan=%ANSI_ESC%[36m
    set ANSI_fg_white=%ANSI_ESC%[37m
    set ANSI_fg_bright_black=%ANSI_ESC%[1;30m
    set ANSI_fg_bright_red=%ANSI_ESC%[1;31m
    set ANSI_fg_bright_green=%ANSI_ESC%[1;32m
    set ANSI_fg_bright_yellow=%ANSI_ESC%[1;33m
    set ANSI_fg_bright_blue=%ANSI_ESC%[1;34m
    set ANSI_fg_bright_magenta=%ANSI_ESC%[1;35m
    set ANSI_fg_bright_cyan=%ANSI_ESC%[1;36m
    set ANSI_fg_bright_white=%ANSI_ESC%[1;37m
        
    set ANSI_bg_black=%ANSI_ESC%[40m
    set ANSI_bg_red=%ANSI_ESC%[41m
    set ANSI_bg_green=%ANSI_ESC%[42m
    set ANSI_bg_yellow=%ANSI_ESC%[43m
    set ANSI_bg_blue=%ANSI_ESC%[44m
    set ANSI_bg_magenta=%ANSI_ESC%[45m
    set ANSI_bg_cyan=%ANSI_ESC%[46m
    set ANSI_bg_white=%ANSI_ESC%[47m
    set ANSI_bg_bright_black=%ANSI_ESC%[1;40m
    set ANSI_bg_bright_red=%ANSI_ESC%[1;41m
    set ANSI_bg_bright_green=%ANSI_ESC%[1;42m
    set ANSI_bg_bright_yellow=%ANSI_ESC%[1;43m
    set ANSI_bg_bright_blue=%ANSI_ESC%[1;44m
    set ANSI_bg_bright_magenta=%ANSI_ESC%[1;45m
    set ANSI_bg_bright_cyan=%ANSI_ESC%[1;46m
    set ANSI_bg_bright_white=%ANSI_ESC%[1;47m

    set ANSI_normal=%ANSI_ESC%[0m
)

if defined BATCH_ANSI_SUPPORTED (
    set ANSI_highlight=%ANSI_fg_bright_yellow%
    set ANSI_url=%ANSI_fg_bright_blue%%ANSI_text_underline%
    set ANSI_emphasis=%ANSI_fg_bright_white%%ANSI_text_italic%
    set ANSI_header=%ANSI_fg_bright_white%%ANSI_bg_blue%%ANSI_text_underline%%ANSI_text_overline%
    set ANSI_header_important=%ANSI_fg_bright_yellow%%ANSI_bg_red%%ANSI_text_underline%%ANSI_text_overline%
    set ANSI_header_note=%ANSI_fg_yellow%%ANSI_bg_blue%%ANSI_text_underline%%ANSI_text_overline%
  ) else (
    set ANSI_highlight=*
    set ANSI_emphasis=*** 
    set ANSI_header=### 
)

:: BATCH_OUTPUT_HIDE_ERRORS is used to hide all output from commands, but can be
:: quickly overridden in other scripts to show output for debugging.
:: e.g. echo THIS TEXT IS ONLY SHOWN WHEN DEBUGGING %BATCH_OUTPUT_HIDE_ERRORS%
set BATCH_OUTPUT_HIDE_ERRORS= 2^>nul ^>nul

:: ANSI_LOG_* are used to format text in a consistent way across scripts,
:: allowing basic localisation. Sample usage provided in --test section.
if [%BATCH_WIN_LANGUAGE%] == [DE] (
    set ANSI_LOG_ERROR=%ANSI_bright_red%FEHLER:%ANSI_normal%  
    set ANSI_LOG_WARNING=%ANSI_bright_yellow%WARNUNG:%ANSI_normal% 
    set ANSI_LOG_INFO=%ANSI_bright_blue%INFO:%ANSI_normal%    
    set ANSI_LOG_SUCCESS=%ANSI_bright_green%ERFOLG:%ANSI_normal%  
    set ANSI_LOG_NOTICE=%ANSI_bright_cyan%HINWEIS:%ANSI_normal% 
    set ANSI_LOG_INDENT=         
) else if [%BATCH_WIN_LANGUAGE%] == [FR] (
    set ANSI_LOG_ERROR=%ANSI_bright_red%ERREUR:%ANSI_normal%        
    set ANSI_LOG_WARNING=%ANSI_bright_yellow%AVERTISSEMENT:%ANSI_normal% 
    set ANSI_LOG_INFO=%ANSI_bright_blue%INFO:%ANSI_normal%          
    set ANSI_LOG_SUCCESS=%ANSI_bright_green%SUCCES:%ANSI_normal%        
    set ANSI_LOG_NOTICE=%ANSI_bright_cyan%REMARQUE:%ANSI_normal%      
    set ANSI_LOG_INDENT=               
) else if [%BATCH_WIN_LANGUAGE%] == [IT] (
    set ANSI_LOG_ERROR=%ANSI_bright_red%ERRORE:%ANSI_normal%   
    set ANSI_LOG_WARNING=%ANSI_bright_yellow%AVVISO:%ANSI_normal%   
    set ANSI_LOG_INFO=%ANSI_bright_blue%INFO:%ANSI_normal%     
    set ANSI_LOG_SUCCESS=%ANSI_bright_green%SUCCESSO:%ANSI_normal% 
    set ANSI_LOG_NOTICE=%ANSI_bright_cyan%NOTA:%ANSI_normal%     
    set ANSI_LOG_INDENT=          
) else (
    :: English is the default.
    set ANSI_LOG_ERROR=%ANSI_bright_red%ERROR:%ANSI_normal%   
    set ANSI_LOG_WARNING=%ANSI_bright_yellow%WARNING:%ANSI_normal% 
    set ANSI_LOG_INFO=%ANSI_bright_blue%INFO:%ANSI_normal%    
    set ANSI_LOG_SUCCESS=%ANSI_bright_green%SUCCESS:%ANSI_normal% 
    set ANSI_LOG_NOTICE=%ANSI_bright_cyan%NOTICE:%ANSI_normal%  
    set ANSI_LOG_INDENT=         
)

:TEST
if [%~1] == [--test] (
    if not defined BATCH_ANSI_SUPPORTED (
        echo ANSI not enabled ^(detected Windows version: %BATCH_WINVER%^)
    ) else (
        echo %ANSI_fg_bright_yellow%A%ANSI_fg_bright_green%N%ANSI_fg_bright_cyan%S%ANSI_fg_bright_magenta%I%ANSI_normal% %ANSI_bg_blue%e%ANSI_bg_green%n%ANSI_bg_magenta%a%ANSI_bg_yellow%b%ANSI_bg_red%l%ANSI_bg_cyan%e%ANSI_fg_black%%ANSI_bg_white%d%ANSI_normal%: %BATCH_ANSI_SUPPORTED% %ANSI_text_faint%^(detected Windows version: %ANSI_text_italic%%BATCH_WINVER%%ANSI_normal%%ANSI_text_faint%^)%ANSI_normal%
    )
    echo.
    echo %ANSI_header%BATCH_WINVER_*%ANSI_normal%
    echo BATCH_WINVER: %ANSI_text_italic%%BATCH_WINVER%%ANSI_normal%  BATCH_WIN_LANGUAGE: %ANSI_text_italic%%BATCH_WIN_LANGUAGE%%ANSI_normal%
    echo BATCH_WINVER_major: %ANSI_text_italic%%BATCH_WINVER_major%%ANSI_normal%    BATCH_WINVER_minor: %ANSI_text_italic%%BATCH_WINVER_minor%%ANSI_normal%    BATCH_WINVER_build: %ANSI_text_italic%%BATCH_WINVER_build%%ANSI_normal%
    echo.
    echo %ANSI_header%TEXT FORMATTING%ANSI_normal% %ANSI_text_italic%- General text formatting%ANSI_normal%
    echo %ANSI_text_underline%ANSI_text_underline%ANSI_normal% %ANSI_text_overline%ANSI_text_overline%ANSI_normal%
    echo %ANSI_normal%ANSI_normal%ANSI_normal%         %ANSI_text_blink%ANSI_text_blink%ANSI_normal%
    echo %ANSI_text_bold%ANSI_text_bold%ANSI_normal%      %ANSI_text_faint%ANSI_text_faint%ANSI_normal%
    echo %ANSI_text_italic%ANSI_text_italic%ANSI_normal%    %ANSI_text_strike%ANSI_text_strike%ANSI_normal%
    echo.
    echo %ANSI_header%ANSI_* shortcuts%ANSI_normal% %ANSI_text_italic%- Shortcuts for frequently used styles%ANSI_normal%
    echo %ANSI_header%ANSI_header%ANSI_normal%     %ANSI_header_important%ANSI_header_important%ANSI_normal%   %ANSI_header_note%ANSI_header_note%ANSI_normal%
    echo %ANSI_highlight%ANSI_highlight%ANSI_normal%  %ANSI_emphasis%ANSI_emphasis%ANSI_normal%           %ANSI_url%ANSI_url%ANSI_normal%
    echo.
    echo %ANSI_header%FOREGROUND COLOURS%ANSI_normal% - Example text in various colours%ANSI_normal%
    echo %ANSI_fg_black%ANSI_fg_black%ANSI_normal%    %ANSI_fg_bright_black%ANSI_fg_bright_black%ANSI_normal%
    echo %ANSI_fg_red%ANSI_fg_red%ANSI_normal%      %ANSI_fg_bright_red%ANSI_fg_bright_red%ANSI_normal%
    echo %ANSI_fg_green%ANSI_fg_green%ANSI_normal%    %ANSI_fg_bright_green%ANSI_fg_bright_green%ANSI_normal%
    echo %ANSI_fg_yellow%ANSI_fg_yellow%ANSI_normal%   %ANSI_fg_bright_yellow%ANSI_fg_bright_yellow%ANSI_normal%
    echo %ANSI_fg_blue%ANSI_fg_blue%ANSI_normal%     %ANSI_fg_bright_blue%ANSI_fg_bright_blue%ANSI_normal%
    echo %ANSI_fg_magenta%ANSI_fg_magenta%ANSI_normal%  %ANSI_fg_bright_magenta%ANSI_fg_bright_magenta%ANSI_normal%
    echo %ANSI_fg_cyan%ANSI_fg_cyan%ANSI_normal%     %ANSI_fg_bright_cyan%ANSI_fg_bright_cyan%ANSI_normal%
    echo %ANSI_fg_white%ANSI_fg_white%ANSI_normal%    %ANSI_fg_bright_white%ANSI_fg_bright_white%ANSI_normal%
    echo.
    echo %ANSI_header%BACKGROUND COLOURS%ANSI_normal% %ANSI_text_italic%- Example text with various background colours%ANSI_normal%
    echo %ANSI_bg_black%ANSI_bg_black%ANSI_normal%    %ANSI_bg_bright_black%ANSI_bg_bright_black%ANSI_normal%
    echo %ANSI_bg_red%ANSI_bg_red%ANSI_normal%      %ANSI_bg_bright_red%ANSI_bg_bright_red%ANSI_normal%
    echo %ANSI_bg_green%ANSI_bg_green%ANSI_normal%    %ANSI_bg_bright_green%ANSI_bg_bright_green%ANSI_normal%
    echo %ANSI_bg_yellow%ANSI_bg_yellow%ANSI_normal%   %ANSI_bg_bright_yellow%ANSI_bg_bright_yellow%ANSI_normal%
    echo %ANSI_bg_blue%ANSI_bg_blue%ANSI_normal%     %ANSI_bg_bright_blue%ANSI_bg_bright_blue%ANSI_normal%
    echo %ANSI_bg_magenta%ANSI_bg_magenta%ANSI_normal%  %ANSI_bg_bright_magenta%ANSI_bg_bright_magenta%ANSI_normal%
    echo %ANSI_bg_cyan%ANSI_bg_cyan%ANSI_normal%     %ANSI_bg_bright_cyan%ANSI_bg_bright_cyan%ANSI_normal%
    echo %ANSI_black%%ANSI_bg_white%ANSI_bg_white%ANSI_normal%    %ANSI_bg_bright_white%ANSI_bg_bright_white%ANSI_normal%
    echo.
    echo %ANSI_header%ANSI_LOG_* ^(%BATCH_WIN_LANGUAGE%^)%ANSI_normal% %ANSI_text_italic%- Example ANSI_LOG_* prefixes%ANSI_normal%
    echo %ANSI_LOG_ERROR%ANSI_LOG_ERROR%ANSI_normal%.
    echo %ANSI_LOG_WARNING%ANSI_LOG_WARNING%ANSI_normal%.
    echo %ANSI_LOG_INFO%ANSI_LOG_INFO%ANSI_normal%.
    echo %ANSI_LOG_NOTICE%ANSI_LOG_NOTICE%ANSI_normal%.
    echo %ANSI_LOG_SUCCESS%ANSI_LOG_SUCCESS%ANSI_normal%.
    echo %ANSI_LOG_INDENT%ANSI_LOG_INDENT%ANSI_normal% ^(no prefix, used for alignment^).
    echo.
    shift
)

if /I [%~1]==[--dump] (
    setlocal enabledelayedexpansion
    for /f "tokens=1* delims==" %%a in ('set ^| findstr /B "ANSI_"') do (
        echo !%%a!%%a%ANSI_normal%
    )
    endlocal
    shift
)

:: Report any remaining arguments as errors, then return the BATCH_result as
:: errorlevel, when available (default 0)
:END
if not [%~1]==[] (
    echo %ANSI_LOG_ERROR%%ANSI_bright_blue%%1%ANSI_normal% is not a valid argument or was used out of order.%ANSI_normal%
    set BATCH_result=98
)

:: Return BATCH_result as ERRORLEVEL, removing the variable from the environment
(
    set BATCH_result=
    exit /b %BATCH_result%
)