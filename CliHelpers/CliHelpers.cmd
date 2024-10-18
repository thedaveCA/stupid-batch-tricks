@echo off
:: CliHelpers - Command line helper.
::
:: Note the way the help command is "dynamic"? You can add lines anywhere
:: in the file that start with ""::CMD_commandname description", they will
:: be picked up and formatted in the help output.
::

:: Load ANSI before we SETLOCAL
for %%x in (%BATCH_DIRECTORY%Helpers\ANSI.cmd %BATCH_DIRECTORY%..\Helpers\ANSI.cmd) do (
    if exist "%%~x" call "%%~x"
)

setlocal enabledelayedexpansion enableextensions
set BATCH_DIRECTORY=%~dp0
set BATCH_FILE=%~nx0
set BATCH_NAME=%~n0

:: If the BATCH_NAME (without extension) is a label in this file, then jump to 
:: it. If BATCH_NAME is '%~n0' then the batchfile was called directly, so
:: we need to check the first argument for a command via the :_ label.

if "%~nx0" == "CliHelpers.cmd" call :_ %*
if "%errorlevel%" neq "0" exit /b %errorlevel%

:: Consider aliaes
if "%BATCH_NAME%" == "delay" set BATCH_NAME=sleep

:: See if we have a label that matches the command, if not, show help
findstr /x /c:":CMD_%BATCH_NAME%" "%BATCH_DIRECTORY%%BATCH_FILE%" > nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo %ANSI_LOG_ERROR%Label not found: %BATCH_NAME%
    call :CliHelpers_help --just-commands
    exit /b 1
)

:: If so, call it, passing the arguments, and exit with the return code
call :CMD_%BATCH_NAME% %BATCH_ARGS%
exit /b %ERRORLEVEL%

:CMD_touch
::CMD_touch Updates the last modified date of the file to the current date and time.
    if "%~1" == "" call :HELP_%BATCH_NAME%&exit /b 1
    for %%a in (%*) do (
        echo Touching %%a
        rem echo. 2> %%a
    )
    exit /b 0

:HELP_touch
    echo.
    echo %ANSI_HEADER%touch - Update the last modified date of a file to the current date and time.%ANSI_normal%
    echo.
    echo Usage: touch ^(file.txt^) [file.txt...]
    echo.
    echo   Updates the last modified date of the file to the current date and time.
    echo   If the file does not exist, it will be created.
    echo   If multiple files are specified, all of them will be touched.
    echo   If the file is a directory, it will be ignored.
    echo   If the file is read-only, it will be made writable.
    echo   If the file is hidden, it will be made visible.
    echo.
    exit /b 0

:CMD_sleep
::CMD_sleep Sleeps for the specified number of seconds, with optional countdown.
    if "%1" == "" call :HELP_%BATCH_NAME%&exit /b 1
    if "%~1" == "--count" (
        set SLEEP_QUIET=1
        echo.
        shift
    )
    if "%1" == "" call :HELP_%BATCH_NAME%&exit /b 1
    set /a "SLEEP_TIME=%~1"

    :SLEEP_loop
        if defined SLEEP_QUIET (
            if !SLEEP_TIME! geq 60 (
                call :TimeSecondsToHMS !SLEEP_TIME!
                set TIME_STRING_LONG=!TIME_STRING_LONG! ^(!SLEEP_TIME! seconds^)
            ) else (
                set TIME_STRING_LONG=!SLEEP_TIME! seconds
            )
            echo %ANSI_cursor_move_up%!TIME_STRING_LONG! remaining...%ANSI_clear_line_right%
        )
        if !SLEEP_TIME! gtr 0 (
            choice /t 1 /d y > nul
            set CURRENT_TIME=%time:~0,8%
            if not "!LAST_TIME!" == "!CURRENT_TIME!" set /a SLEEP_TIME-=1
            set LAST_TIME=!CURRENT_TIME!
            goto :SLEEP_loop
        )
    if defined SLEEP_QUIET echo %ANSI_cursor_move_up%%ANSI_clear_line_right%%ANSI_cursor_move_up%
    exit /b 0

:HELP_sleep
    echo.
    echo %ANSI_HEADER%sleep - Count down from a specified number of seconds.%ANSI_normal%
    echo.
    echo Usage: sleep [--quiet] ^(seconds^)
    echo.
    echo   Counts down from the specified number of seconds, ignoring negative numbers and strings.
    echo.
    echo   If %ANSI_emphasis%--count%ANSI_normal% is specified, the countdown will be shown.
    echo.
    exit /b 0

:CMD_ghcs
::CMD_ghcs Explains a command using GitHub Copilot.
    if "%~1" == "" (
        set /p CLI_ARGS=Enter the command to explain: 
    ) else (
            set "CLI_ARGS=%*"
            set CLI_ARGS=!CLI_ARGS:"=!
    )
    if "%CLI_ARGS%" == "" (
        echo No command to explain, try `%~nx0 /?` for help
        exit /b
    )

    gh copilot explain "%CLI_ARGS%"
    exit /b 0

:CMD_ghce
::CMD_ghce Suggests a command suggested by GitHub Copilot, and executes it.
    if "%~1" == "" (
        set /p CLI_ARGS=Enter the command to explain: 
    ) else (
            set "CLI_ARGS=%*"
            set CLI_ARGS=!CLI_ARGS:"=!
    )
    if "%CLI_ARGS%" == "" (
        echo No command to explain, try `%~nx0 /?` for help
        exit /b
    )

    set TMPFILE=%TEMP%\gh-copilot-suggest-%RANDOM%.txt
    set TARGET=shell
    gh copilot suggest -t "%TARGET%" "cmd.exe %CLI_ARGS%" --shell-out "!TMPFILE!"
    if exist "!TMPFILE!" (
        set /p CMD=<"!TMPFILE!"
        call !CMD!
        del "!TMPFILE!"
    )
    exit /b 0

:HELP_ghcs
    echo.
    echo %ANSI_HEADER%ghcs - Explain a command using GitHub Copilot.%ANSI_normal%
    echo.
    echo Usage: ghcs ^(command^)
    echo.
    echo   Explains the command using GitHub Copilot.
    echo.
    exit /b 0

:HELP_ghce
    echo.
    echo %ANSI_HEADER%ghce - Execute a command suggested by GitHub Copilot.%ANSI_normal%
    echo.
    echo Usage: ghce ^(command^)
    echo.
    echo   Executes the command suggested by GitHub Copilot.
    echo.
    exit /b 0
    
:CMD_dig
::CMDwsl_dig DNS lookup utility.
    wsl dig %*
    exit /b %ERRORLEVEL%

:CMD_socat
::CMDwsl_socat socat - Multipurpose relay ^(SOcket CAT^)
    wsl socat %*
    exit /b %ERRORLEVEL%

:CMD_echo
::CMD_echo Echoes the arguments to the console.
    echo %*
    exit /b 0

:: Try to make an alias for every command other than makealias itself
:: Must be an administrator to create an alias.
:CMD_makealias
::CMDmeta_makealias Creates aliases for direct commands and WSL commands.
    set NEEDED_ALIASES=%*
    if not defined NEEDED_ALIASES for /f "usebackq tokens=2 delims=_ " %%a in (`findstr /b /c:"::CMD_" /c:"::CMDwsl_" "%BATCH_DIRECTORY%%BATCH_FILE%" 2^>nul ^| findstr /v /b /c:"::CMD_makealias" 2^>nul ^| sort`) do (
        set NEEDED_ALIASES=!NEEDED_ALIASES! %%a
    )
    echo %ANSI_LOG_INFO%Checking %ANSI_emphasis%%BATCH_DIRECTORY%%ANSI_normal% for aliases...
    echo %ANSI_LOG_INFO%Rewriting %ANSI_emphasis%.gitignore%ANSI_normal% to ignore the aliases.
    echo .gitignore > "%BATCH_DIRECTORY%.gitignore"
    for %%x in (!NEEDED_ALIASES!) do (
        echo %%x.cmd >> "%BATCH_DIRECTORY%.gitignore"
        if exist "%BATCH_DIRECTORY%%%x.cmd" (
            for /f "usebackq tokens=3,4,5* delims=^<^>[] " %%f in (`dir "%BATCH_DIRECTORY%%%x.cmd" ^| find "%%x.cmd"`) do (
                if "%%f" == "SYMLINK" (
                    if "%%h" == "%~dpfx0" (
                        echo %ANSI_LOG_INFO%Found %%f %ANSI_emphasis%%%x.cmd%ANSI_normal% points to %ANSI_emphasis%%%h%ANSI_normal%
                    ) else (
                        echo %ANSI_LOG_WARNING%Found %ANSI_emphasis%%%x.cmd%ANSI_normal% but it points to %ANSI_emphasis%%%h%ANSI_normal%
                    )
                ) else if "%%f" == "JUNCTION" (
                    if "%%h" == "%~dpfx0" (
                        echo %ANSI_LOG_INFO%Found %%f %ANSI_emphasis%%%x.cmd%ANSI_normal% points to %ANSI_emphasis%%%h%ANSI_normal%
                    ) else (
                        echo %ANSI_LOG_WARNING%Found %ANSI_emphasis%%%x.cmd%ANSI_normal% but it points to %ANSI_emphasis%%%h%ANSI_normal%
                    )
                ) else (
                    echo %ANSI_LOG_WARNING%Found %ANSI_emphasis%%%x.cmd%ANSI_normal% but it is not a symlink or junction.
                )
            )
        ) else (
            echo %ANSI_LOG_WARNING%Missing alias %ANSI_emphasis%%%x%ANSI_normal%
            set MISSING_ALIASES=!MISSING_ALIASES! %%x
        )
    )
    if defined MISSING_ALIASES (
        call :CheckIsAdmin
        if !ERRORLEVEL! neq 0 (
            echo %ANSI_LOG_ERROR%You must be an administrator to create an alias, try
            echo %ANSI_LOG_INDENT%running %ANSI_emphasis%%BATCH_FILE% %BATCH_NAME%%ANSI_normal% again as administrator.
            exit /b 1
        ) else (
            for %%n in (!MISSING_ALIASES!) do (
                echo %ANSI_LOG_INFO%Creating alias for %ANSI_emphasis%%%n%ANSI_normal%
                for /f "usebackq tokens=*" %%m in (`mklink "%BATCH_DIRECTORY%%%n.cmd" "%BATCH_DIRECTORY%%BATCH_FILE%" 2^>^&1`) do (
                    if not exist "%BATCH_DIRECTORY%%%n.cmd" (
                        echo "%BATCH_DIRECTORY%%%n.cmd"
                        echo %ANSI_LOG_ERROR%Failed to create alias: %ANSI_emphasis%%%m%ANSI_normal%
                        exit /b 1
                    ) else (
                        echo %ANSI_LOG_SUCCESS%%%m
                    )
                )
            )
        )
    )
    exit /b 0
    
:CliHelpers_help
    if not "%~1" == "--just-commands" (
        echo.
        echo %ANSI_HEADER%CliHelpers - Command line helpers for batch files.%ANSI_normal%
        echo.
        echo Usage: command [arguments...]
        echo   -or- 
        echo Usage: CliHelpers ^(command^) [arguments...]
        echo.
        echo The first form requires an alias in the filesystem, the sceond form
        echo allows you to call a command from the command line directly.
        echo.
        echo Commands called without a parameter will either run something harmless, 
        echo or show help for that command.
    )
    echo.
    set COLUMNWIDTH=20
    echo %ANSI_text_underline%Command%ANSI_normal%%ANSI_ESC%[G%ANSI_ESC%[!COLUMNWIDTH!C%ANSI_text_underline%Description%ANSI_normal%
    for /f "usebackq tokens=2* delims=_ " %%a in (`findstr /b /c:"::CMD_" "%BATCH_DIRECTORY%%BATCH_FILE%" 2^>nul ^| sort`) do (
        echo %ANSI_emphasis%%%a%ANSI_normal%%ANSI_ESC%[G%ANSI_ESC%[!COLUMNWIDTH!C%%b
    )
    echo.
    echo %ANSI_text_underline%WSL command%ANSI_normal%%ANSI_ESC%[G%ANSI_ESC%[!COLUMNWIDTH!C%ANSI_text_underline%Description%ANSI_normal%
    for /f "usebackq tokens=2* delims=_ " %%a in (`findstr /b /c:"::CMDwsl_" "%BATCH_DIRECTORY%%BATCH_FILE%" 2^>nul ^| sort`) do (
        echo %ANSI_emphasis%%%a%ANSI_normal%%ANSI_ESC%[G%ANSI_ESC%[!COLUMNWIDTH!C%%b
    )
    echo.
    echo %ANSI_text_underline%meta command%ANSI_normal%%ANSI_ESC%[G%ANSI_ESC%[!COLUMNWIDTH!C%ANSI_text_underline%Description%ANSI_normal%
    for /f "usebackq tokens=2* delims=_ " %%a in (`findstr /b /c:"::CMDmeta_" "%BATCH_DIRECTORY%%BATCH_FILE%" 2^>nul ^| sort`) do (
        echo %ANSI_emphasis%%%a%ANSI_normal%%ANSI_ESC%[G%ANSI_ESC%[!COLUMNWIDTH!C%%b
    )
    echo.
    if "%~1" == "--just-commands" (
        echo For more documentation, call "CliHelpers" without any command line arguments.
        echo.
    )
    if not "%~1" == "--just-commands" (
        echo Commands called without a parameter will either run something harmless, 
        echo or show help for that command.
        echo.
    )
    exit /b 0

:: If the batch file was called directly, see if we can get a command out of
:: the first argument and pass the rest.
:_
    :: If no arguments, show help
    if "%~1" == "" (
        call :CliHelpers_help
        exit /b 1
    )

    :: Get the command and arguments
    for /f "tokens=1* delims= " %%a in ("%*") do set "BATCH_NAME=%%a" & set "BATCH_ARGS=%%b"

    exit /b 0

::Misc helper functions
:CheckIsAdmin
    net session >nul 2>&1
    if !errorlevel! == 0 (
        exit /b 0
    ) else (
        exit /b 1
    )
    exit /b 2

:TimeSecondsToHMS
    set /a TIME_REMAINING=%1
    set /a "H=!TIME_REMAINING!/3600, M=(!TIME_REMAINING!-3600*H)/60, S=!TIME_REMAINING!-3600*H-60*M"
    set "H=0%H%" & set "M=0%M%" & set "S=0%S%"
    set "H=%H:~-2%" & set "M=%M:~-2%" & set "S=%S:~-2%"
    set TIME_STRING=
    set TIME_STRING_LONG=
    if %H% gtr 0 set TIME_STRING=%H%:
    if %M% gtr 0 set TIME_STRING=!TIME_STRING!%M%:
    if %S% gtr 0 set TIME_STRING=!TIME_STRING!%S%s
    if !TIME_REMAINING! geq 3600 set TIME_STRING_LONG=%H%:
    if !TIME_REMAINING! geq 60 set TIME_STRING_LONG=!TIME_STRING_LONG!%M%:
    if !TIME_REMAINING! geq 0 set TIME_STRING_LONG=!TIME_STRING_LONG!%S%
    exit /b 0

