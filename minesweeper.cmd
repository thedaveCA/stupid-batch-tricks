:: minesweeper.cmd - Hidden Minesweeper game for Windows in Batch
@echo off

:: Has anyone ever been stupid enough to try and write this in Batch?

setlocal enabledelayedexpansion enableextensions

if exist %~dp0Helpers\ANSI.cmd (
    call %~dp0Helpers\ANSI.cmd
) else (
    echo ANSI.cmd not found. Good luck!
)
set ANSI_header=%ANSI_fg_bright_white%%ANSI_bg_magenta%%ANSI_text_underline%%ANSI_text_overline%
if exist %dp0Helpers\CleanEnvironmentVariables.cmd call %dp0Helpers\CleanEnvironmentVariables.cmd game_

echo %ANSI_cursor_move_home%%ANSI_clear_screen%%ANSI_cursor_hide%

set game_position_x=0
set game_position_y=0
set game_board_size_x=6
set game_board_size_y=3

call :generate_board

:gameloop
echo %ANSI_cursor_move_home%%ANSI_header%%~nx0%ANSI_normal% - Yup, it's Minesweeper...                     %ANSI_text_faint%%DATE% %TIME:~0,8%%ANSI_normal%
echo.
echo %ANSI_cursor_position_save%

call :sanity_check
call :dump_vars
call :draw_board
call :draw_cheater_board

echo %ANSI_clear_line%%ANSI_cursor_move_down%Move with %ANSI_text_underline%W%ANSI_text_no_underline% %ANSI_text_underline%A%ANSI_text_no_underline% %ANSI_text_underline%S%ANSI_text_no_underline% %ANSI_text_underline%D%ANSI_text_no_underline%, %ANSI_text_underline%R%ANSI_normal%efresh, %ANSI_text_underline%Q%ANSI_normal%uit%ANSI_clear_line_right%%ANSI_clear_screen_down%
choice /c wasdrq /n /t 1 /d r > nul
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
    if %game_position_x% lss 1 set game_position_x=1
    if %game_position_y% lss 1 set game_position_y=1
    if %game_position_x% gtr %game_board_size_x% set game_position_x=%game_board_size_x%
    if %game_position_y% gtr %game_board_size_y% set game_position_y=%game_board_size_y%
    exit /b 0

:: Possible mine states for each cell:
:: | 0 | No Mine
:: | 1 | Mine

:: Possible visual states for each cell:
:: | . | Hidden
:: | X | Flagged
:: | O | Revealed

:generate_board
:: Generate the game board
    for /l %%y in (1,1,!game_board_size_y!) do (
        for /l %%x in (1,1,!game_board_size_x!) do (
            set /a "game_board_mine[%%x][%%y]=!random! %% 2"
            set game_board_visual[%%x][%%y]=O
            set game_board_count[%%x][%%y]=0
        )
    )

    call :draw_cheater_board

:: Count the number of mines around each cell
    set game_count_last_x=0
    set game_count_last_y=0

    for /l %%y in (1,1,!game_board_size_y!) do (
        for /l %%x in (1,1,!game_board_size_x!) do (
            set /a game_count_last_x=%%x-1
            set /a game_count_last_y=%%y-1
            set /a game_count_next_x=%%x+1
            set /a game_count_next_y=%%y+1
            set /a game_board_count[%%x][%%y]=0
            for /l %%n in (!game_count_last_y!,1,!game_count_next_y!) do (
                for /l %%m in (!game_count_last_x!,1,!game_count_next_x!) do (
                    set temp_status=echo {x=%%x y=%%y^} [m=%%m n=%%n] [!game_board_mine[%%m][%%n]!]
                    if %%x == %%m (
                        if %%y == %%n (
                            echo !temp_status! SKIP, x=m y=n
                        ) else (
                            if defined game_board_mine[%%m][%%n] (
                                echo !temp_status! INCREMENT to {!game_board_count[%%x][%%y]!}
                                set /a game_board_count[%%x][%%y]=game_board_count[%%x][%%y]+!game_board_mine[%%m][%%n]!
                                echo !temp_status! INCREMENT to {!game_board_count[%%x][%%y]!}
                            ) else (
                                echo !temp_status! SKIP, out of bounds
                                )
                        )
                    )
                )
            )
        )
    )
    pause
    exit /b 0

:draw_board
echo %ANSI_header%Game board%ANSI_normal%
echo.
    for /l %%y in (1,1,!game_board_size_y!) do (
        set temp_line_style_clear=%ANSI_normal%%ANSI_fg_bright_yellow%%ANSI_bg_blue%
        set temp_line=%ANSI_normal%%ANSI_fg_bright_yellow%%ANSI_bg_blue%
        for /l %%x in (1,1,!game_board_size_x!) do (
            set temp_style=%temp_line_style_clear%
            if %%x==!game_position_x! if %%y==!game_position_y! set temp_style=%ANSI_text_reverse%%ANSI_text_underline%%ANSI_text_overline%
            set temp_line=!temp_line!!temp_style!!game_board_mine[%%x][%%y]!
        )
    echo !temp_line!%ANSI_normal%%ANSI_clear_line_right%
    )
    echo.
    exit /b 0

:dump_vars
    echo %ANSI_cursor_position_restore%%ANSI_header%Dumping game variables...%ANSI_normal%%ANSI_clear_line_right%
    for /f "tokens=1* delims==" %%a in ('set ^| findstr /B "game_" ^| findstr /b /v "game_board_"') do (
        echo %%a=%%b%ANSI_clear_line_right%
    )
    echo.
    exit /b 0

:draw_cheater_board
echo %ANSI_header%Cheater board%ANSI_normal%
echo.
    set temp_line_mine_clear=%ANSI_reset%%ANSI_bg_blue%
    set temp_line_visual_clear=%ANSI_reset%%ANSI_bg_green%
    set temp_line_count_clear=%ANSI_reset%%ANSI_bg_red%

    echo %temp_line_mine_clear% Mines %temp_line_visual_clear% Visual %temp_line_count_clear% Count %ANSI_normal%%ANSI_clear_line_right%

    for /l %%y in (1,1,!game_board_size_y!) do (
        set temp_line_mine=%temp_line_mine_clear%
        set temp_line_visual=%temp_line_visual_clear%
        set temp_line_count=%temp_line_count_clear%
        for /l %%x in (1,1,!game_board_size_x!) do (
            set temp_style=
            if %%x==!game_position_x! if %%y==!game_position_y! (
                set temp_style=%ANSI_text_underline%%ANSI_text_overline%%ANSI_text_bold%%ANSI_text_reverse%
            )
            set temp_line_mine=!temp_line_mine!!temp_style!!game_board_mine[%%x][%%y]!!temp_line_mine_clear!
            set temp_line_visual=!temp_line_visual!!temp_style!!game_board_visual[%%x][%%y]!!temp_line_visual_clear!
            set temp_line_count=!temp_line_count!!temp_style!!game_board_count[%%x][%%y]!!temp_line_count_clear!
        )
    echo !temp_line_mine!%ANSI_normal% !temp_line_visual!%ANSI_normal% !temp_line_count!%ANSI_normal%%ANSI_clear_line_right%
    )
    exit /b 0

:cleanup
    echo %ANSI_normal%%ANSI_cursor_show%
    endlocal
    exit /b 0
