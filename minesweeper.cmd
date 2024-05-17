:: minesweeper.cmd - Hidden Minesweeper game for Windows in Batch
@echo off

:: Has anyone ever been stupid enough to try and write this in Batch?

setlocal enabledelayedexpansion enableextensions

if exist %~dp0Helpers\ANSI.cmd (
    call %~dp0Helpers\ANSI.cmd
) else (
    echo ANSI.cmd not found. Good luck!
)
set ANSI_header=%ANSI_fg_bright_yellow%%ANSI_bg_blue%%ANSI_text_underline%%ANSI_text_overline%

if exist %dp0Helpers\CleanEnvironmentVariables.cmd call %dp0Helpers\CleanEnvironmentVariables.cmd game_

:: Possible mine states for each cell:
:: | 0 | No Mine
:: | 1 | Mine

:: Emojis are used for visual representation of the game board. 
:: Too janky to use for the moment.
:: TODO: Fix the emojis, or rip them out entirely.
:: TODO: Implement box drawing, or rip it out entirely.
:: TODO: Heck, if I can figure out the screen buffer, I could dynamically place stuff.
if 1 == 1 (
    set "ascii_vertical_bar=^|"
    set ascii_horizontal_bar=-
    set ascii_cross=+
    set ascii_top_left=/
    set ascii_top_right=\
    set ascii_bottom_left=\
    set ascii_bottom_right=/
) else (
    chcp 65001 
    set "ascii_vertical_bar=│"
    set ascii_horizontal_bar=─
    set ascii_cross=┼
    set ascii_top_left=┌
    set ascii_top_right=┐
    set ascii_bottom_left=└
    set ascii_bottom_right=┘
    set game_visual_hidden=😁
    set game_visual_flag=🚩
)

:: Possible visual states for each cell
set game_visual_hidden=.
set game_visual_flag=X

:: Set game board size. Don't be stupid.
set game_board_size_x=7
set game_board_size_y=7

:: Set mine density. 1 in X chance of a mine.
set game_board_mine_density=5
call :generate_board

:gameloop
call :draw_header
call :sanity_check
call :draw_board
call :draw_cheater_board
call :draw_menu
echo %ANSI_clear_screen_down%
call :dump_vars

choice /c wasdqzx0123rc9 /n /t 5 /d 9 > nul
if errorlevel 14 (
    rem Timeout, do nothing
) else if errorlevel 13 (
    call :clear_board_state
) else if errorlevel 12 (
    cls
) else if errorlevel 11 (
    set game_board_mine_density=10
    call :generate_board
) else if errorlevel 10 (
    set game_board_mine_density=2
    call :generate_board
) else if errorlevel 9 (
    set game_board_mine_density=1
    call :generate_board
) else if errorlevel 8 (
    set game_board_mine_density=0
    call :generate_board
) else if errorlevel 7 (
    call :toggle_flag
) else if errorlevel 6 (
    call :toggle_visible
) else if errorlevel 5 (
    goto :cleanup
    goto :eof
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

:toggle_visible
    if "!game_board_state[%game_position_x%][%game_position_y%]!" == "%game_visual_flag%" (
        set game_error=Cannot reveal a flagged cell
    ) else if "!game_board_state[%game_position_x%][%game_position_y%]!" == "%game_visual_hidden%" (
        set game_board_state[%game_position_x%][%game_position_y%]=!game_board_count[%game_position_x%][%game_position_y%]!
    ) else (
        set game_error=Cannot unreveal a visible cell, that's just silly... Oh well okay, this one time.
        set game_board_state[%game_position_x%][%game_position_y%]=%game_visual_hidden%
    )
    exit /b 0

:toggle_flag
    if "!game_board_state[%game_position_x%][%game_position_y%]!" == "%game_visual_hidden%" (
        set game_board_state[%game_position_x%][%game_position_y%]=%game_visual_flag%
    ) else if "!game_board_state[%game_position_x%][%game_position_y%]!" == "%game_visual_flag%" (
        set game_board_state[%game_position_x%][%game_position_y%]=%game_visual_hidden%
    ) else (
        set game_error=Cannot flag a visible cell
    )
    exit /b 0

:sanity_check
    if %game_position_x% lss 1 set game_position_x=1
    if %game_position_y% lss 1 set game_position_y=1
    if %game_position_x% gtr %game_board_size_x% set game_position_x=%game_board_size_x%
    if %game_position_y% gtr %game_board_size_y% set game_position_y=%game_board_size_y%
    exit /b 0

:clear_board_state
    set game_error=Board state cleared / reset from scratch
    for /l %%y in (1,1,%game_board_size_y%) do (
        for /l %%x in (1,1,%game_board_size_x%) do (
            set game_board_state[%%x][%%y]=%game_visual_hidden%
        )
    )
    exit /b 0

:generate_board
    :: Set starting position. Must be integers, doesn't need to be within the board.
    set game_position_x=0
    set game_position_y=0
    set "game_error=Board Generated... Ready to play"

    :: Generate the game board
        for /l %%y in (1,1,!game_board_size_y!) do (
            for /l %%x in (1,1,!game_board_size_x!) do (
                if %game_board_mine_density% EQU 0 (
                    set game_error=I heard you're scared of mines. Don't worry, there are none here.
                    set game_board_mine[%%x][%%y]=0
                ) else if %game_board_mine_density% EQU 1 (
                    set game_error=I heard you like mines. Here, have some mines.
                    set game_board_mine[%%x][%%y]=1
                ) else (
                    set /a game_count+=1
                    set /a "game_board_mine[%%x][%%y]=^(!random! %% %game_board_mine_density%^) / ^(%game_board_mine_density%-1^)"
                )
                set game_board_state[%%x][%%y]=%game_visual_hidden%
                set game_board_count[%%x][%%y]=0
            )
        )

    :: Count the number of mines around each cell
    for /l %%y in (1,1,%game_board_size_y%) do (
        for /l %%x in (1,1,%game_board_size_x%) do (
            set /a game_board_count[%%x][%%y]=0
            set /a game_count_last_x=%%x-1
            set /a game_count_last_y=%%y-1
            set /a game_count_next_x=%%x+1
            set /a game_count_next_y=%%y+1
            for /l %%n in (!game_count_last_y!,1,!game_count_next_y!) do (
                for /l %%m in (!game_count_last_x!,1,!game_count_next_x!) do (
                    if %%m geq 1 if %%m leq %game_board_size_x% if %%n geq 1 if %%n leq %game_board_size_y% (
                        set same_cell=
                        if %%x EQU %%m if %%y EQU %%n set same_cell=1
                        if not defined same_cell (
                            set /a game_board_count[%%x][%%y]+=!game_board_mine[%%m][%%n]!
                        )
                    )
                )
            )
        )
    )
    exit /b 0

:draw_header
    :: TODO: Move the clock to the right side of the screen
    echo %ANSI_cursor_hide%%ANSI_cursor_move_home%%ANSI_header%Yup, it's Minesweeper-ish%ANSI_normal%                                         %ANSI_text_faint%%DATE% %TIME:~0,8%%ANSI_normal%%ANSI_clear_line_right%
    echo %ANSI_clear_line%
    echo %ANSI_header_note%%game_error%%ANSI_normal%%ANSI_clear_line_right%
    echo %ANSI_clear_line%
    set game_error=
    exit /b 0

:draw_menu
    echo %ANSI_header%Instructions%ANSI_normal%%ANSI_clear_line_right%
    echo %ANSI_clear_line%%ANSI_cursor_next_line%Game play:%ANSI_clear_line_right%
    echo    %ANSI_text_underline%W%ANSI_text_no_underline% %ANSI_text_underline%A%ANSI_text_no_underline% %ANSI_text_underline%S%ANSI_text_no_underline% %ANSI_text_underline%D%ANSI_text_no_underline% Move around the board.%ANSI_clear_line_right%
    echo    %ANSI_text_underline%X%ANSI_text_no_underline% Flag as mine.     %ANSI_text_underline%Z%ANSI_text_no_underline% Mark as safe.%ANSI_clear_line_right%
    echo %ANSI_clear_line%%ANSI_cursor_next_line%Start a new game with: %ANSI_clear_line_right%
    echo    %ANSI_text_underline%0%ANSI_text_no_underline% No mines.         %ANSI_text_underline%1%ANSI_text_no_underline% ALL THE MINES%ANSI_clear_line_right%
    echo    %ANSI_text_underline%2%ANSI_text_no_underline% A lot of mines.   %ANSI_text_underline%3%ANSI_text_no_underline% A few mines.%ANSI_clear_line_right%
    echo    %ANSI_text_underline%c%ANSI_text_no_underline% Clear the board.  %ANSI_text_underline%R%ANSI_text_no_underline% Refresh the screen.   %ANSI_text_underline%Q%ANSI_text_no_underline%uit%ANSI_clear_line_right%
    echo %ANSI_clear_line%
    exit /b 0

:draw_board
    echo %ANSI_header%Game board%ANSI_normal%%ANSI_clear_line_right%
    echo %ANSI_clear_line%
    ::echo %ascii_top_left% %ascii_horizontal_bar%%ascii_horizontal_bar%%ascii_horizontal_bar% %ascii_top_right%%ANSI_clear_line_right%
    for /l %%y in (1,1,!game_board_size_y!) do (
        set temp_line=
        for /l %%x in (1,1,!game_board_size_x!) do (
            rem if %%x==!game_position_x! if %%y==!game_position_y! set temp_style=%ANSI_text_reverse%%ANSI_text_underline%%ANSI_text_overline%
            if "!game_board_state[%%x][%%y]!" == "%game_visual_hidden%" (
                set temp_line=!temp_line!%game_visual_hidden%
            ) else if "!game_board_state[%%x][%%y]!" == "%game_visual_flag%" (
                set temp_line=!temp_line!%game_visual_flag%
            ) else (
                set temp_line=!temp_line!!game_board_count[%%x][%%y]!
            )
        )
    echo %ascii_vertical_bar% !temp_line!%ANSI_normal%%ANSI_clear_line_right% %ascii_vertical_bar%
    )
    :: echo %ascii_bottom_left% %ascii_horizontal_bar%%ascii_horizontal_bar%%ascii_horizontal_bar% %ascii_bottom_right%%ANSI_clear_line_right%
    echo %ANSI_clear_line%
    exit /b 0

:dump_vars
    echo %ANSI_header%Dumping game variables...%ANSI_normal%%ANSI_clear_line_right%
    for /f "tokens=1* delims==" %%a in ('set ^| findstr /B "game_" ^| findstr /b /v "game_board_"') do (
        echo %%a=%%b%ANSI_clear_line_right%
    )
    exit /b 0

:draw_cheater_board
:: This is a cheater board. It shows the mines and count of mines around each cell.
:: It's not part of the game, but it's useful for debugging. It's also reasonably
:: expensive to draw, so it will slow down the game.
echo %ANSI_header%Cheater board%ANSI_normal%%ANSI_clear_line_right%
echo %ANSI_clear_line%
    set temp_line_mine_clear=%ANSI_reset%%ANSI_bg_blue%
    set temp_line_visible_clear=%ANSI_reset%%ANSI_bg_green%
    set temp_line_count_clear=%ANSI_reset%%ANSI_bg_red%

    echo %temp_line_mine_clear% Mines %temp_line_visible_clear% State %temp_line_count_clear% Count %ANSI_normal%%ANSI_clear_line_right%

    for /l %%y in (1,1,!game_board_size_y!) do (
        set temp_line_mine=%temp_line_mine_clear%
        set temp_line_visible=%temp_line_visible_clear%
        set temp_line_count=%temp_line_count_clear%
        for /l %%x in (1,1,!game_board_size_x!) do (
            set temp_style=
            if %%x==!game_position_x! if %%y==!game_position_y! (
                set temp_style=%ANSI_text_underline%%ANSI_text_overline%%ANSI_text_bold%%ANSI_text_reverse%
            )
            set temp_line_mine=!temp_line_mine!!temp_style!!game_board_mine[%%x][%%y]!!temp_line_mine_clear!
            set temp_line_visible=!temp_line_visible!!temp_style!!game_board_state[%%x][%%y]!!temp_line_visible_clear!
            set temp_line_count=!temp_line_count!!temp_style!!game_board_count[%%x][%%y]!!temp_line_count_clear!
        )
    echo  !temp_line_mine!%ANSI_normal%  !temp_line_visible!%ANSI_normal%  !temp_line_count!%ANSI_normal%%ANSI_clear_line_right%
    )
    echo %ANSI_clear_line%
    exit /b 0

:cleanup
    echo %ANSI_normal%%ANSI_cursor_show%
    endlocal
    exit /b 0
