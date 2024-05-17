:: minesweeper.cmd - Hidden Minesweeper game for Windows in Batch
@echo off

:: Has anyone ever been stupid enough to try and write this in Batch?

setlocal enabledelayedexpansion enableextensions

if exist %~dp0Helpers\ANSI.cmd (
    call %~dp0Helpers\ANSI.cmd
) else (
    echo ANSI.cmd not found. Good luck!
)
if exist %dp0Helpers\CleanEnvironmentVariables.cmd call %dp0Helpers\CleanEnvironmentVariables.cmd game_

echo %ANSI_cursor_move_home%%ANSI_clear_screen%%ANSI_cursor_hide%

set game_position_x=0
set game_position_y=0
set game_board_size_x=3
set game_board_size_y=3

:gameloop
echo %ANSI_cursor_move_home%%ANSI_header%%~nx0%ANSI_normal% - Yup, it's Minesweeper...                     %ANSI_text_faint%%DATE% %TIME%%ANSI_normal%
echo.
echo %ANSI_cursor_position_save%

call :sanity_check
call :dump_vars
call :draw_board

choice /c wasdrq /n /t 60 /d r /m "Move with %ANSI_text_underline%W%ANSI_text_no_underline% %ANSI_text_underline%A%ANSI_text_no_underline% %ANSI_text_underline%S%ANSI_text_no_underline% %ANSI_text_underline%D%ANSI_text_no_underline%, %ANSI_text_underline%R%ANSI_normal%efresh, %ANSI_text_underline%Q%ANSI_normal%uit: %ANSI_clear_line_right%%ANSI_clear_screen_down%"
if errorlevel 6 (
    goto :cleanup
    goto :eof
) else if errorlevel 5 (
    rem Fall through to goto :gameloop
) else if errorlevel 4 (
    call :move_right
) else if errorlevel 3 (
    call :move_down
) else if errorlevel 2 (
    call :move_left
) else if errorlevel 1 (
    call :move_up
)
goto :gameloop

:move_up
    set /a game_position_y-=1
    exit /b 0

:move_down
    set /a game_position_y+=1
    exit /b 0

:move_left
    set /a game_position_x-=1
    exit /b 0

:move_right
    set /a game_position_x+=1
    exit /b 0

:sanity_check
    if %game_position_x% lss 0 set game_position_x=0
    if %game_position_y% lss 0 set game_position_y=0
    if %game_position_x% gtr %game_board_size_x% set game_position_x=%game_board_size_x%
    if %game_position_y% gtr %game_board_size_y% set game_position_y=%game_board_size_y%
    exit /b 0

:draw_board
    for /l %%y in (0,1,%game_board_size_y%) do (
        set temp_line=
        for /l %%x in (0,1,%game_board_size_x%) do (
            if %%x==%game_position_x% (
                if %%y==%game_position_y% (
                    set temp_line=!temp_line!O
                ) else (
                    set temp_line=!temp_line!.
                )
            ) else (
                set temp_line=!temp_line!.
            )
        )
    echo x%temp_line%x%ANSI_clear_line_right%
    )
    exit /b 0

:dump_vars
    echo %ANSI_cursor_position_restore%%ANSI_header%Dumping game variables...%ANSI_normal%%ANSI_clear_line_right%
    for /f "tokens=1* delims==" %%a in ('set ^| findstr /B "game_"') do (
        echo %%a=%%b%ANSI_clear_line_right%
    )
    echo.
    exit /b 0

:cleanup
    echo %ANSI_normal%%ANSI_cursor_show%
    endlocal
    exit /b 0
