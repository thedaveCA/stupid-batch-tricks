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

echo %ANSI_esc%[?1049h
echo %ANSI_esc%[10;10r

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

set game_debug=1
set game_debug_cheaterboard=%game_debug%
set game_debug_dumpvars=%game_debug%

:gameloop
call :draw_header
call :sanity_check
call :draw_board
if defined game_debug_cheaterboard call :draw_cheater_board
call :draw_menu
echo %ANSI_clear_screen_down%
if defined game_debug_dumpvars call :dump_vars

:: Get and handle user input
choice /c wasdqzx0123RcCDr /cs /n /t 5 /d r > nul

if %errorlevel% geq 16 rem Timeout, do nothing
if %errorlevel% equ 15 call :toggle_dump_vars
if %errorlevel% equ 14 call :toggle_cheater_board
if %errorlevel% equ 13 call :clear_board_state
if %errorlevel% equ 12 set "game_console_dimensions="
if %errorlevel% equ 11 (
    set "game_board_mine_density=10"
    call :generate_board
)
if %errorlevel% equ 10 (
    set "game_board_mine_density=2"
    call :generate_board
)
if %errorlevel% equ 9 (
    set "game_board_mine_density=1"
    call :generate_board
)
if %errorlevel% equ 8 (
    set "game_board_mine_density=0"
    call :generate_board
)
if %errorlevel% equ 7 call :toggle_flag
if %errorlevel% equ 6 call :toggle_visible
if %errorlevel% equ 5 (
    goto :cleanup
    goto :eof
)
if %errorlevel% equ 4 call :move_right
if %errorlevel% equ 3 call :move_down
if %errorlevel% equ 2 call :move_left
if %errorlevel% equ 1 call :move_up

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
        set game_message_type=ERROR
        set game_message_text=Cannot reveal a flagged cell
    ) else if "!game_board_state[%game_position_x%][%game_position_y%]!" == "%game_visual_hidden%" (
        set game_board_state[%game_position_x%][%game_position_y%]=!game_board_count[%game_position_x%][%game_position_y%]!
    ) else (
        set game_message_type=ERROR
        set game_message_text=Cannot unreveal a visible cell, that's just silly... Oh well okay, this one time.
        set game_board_state[%game_position_x%][%game_position_y%]=%game_visual_hidden%
    )
    exit /b 0

:toggle_flag
    if "!game_board_state[%game_position_x%][%game_position_y%]!" == "%game_visual_hidden%" (
        set game_board_state[%game_position_x%][%game_position_y%]=%game_visual_flag%
    ) else if "!game_board_state[%game_position_x%][%game_position_y%]!" == "%game_visual_flag%" (
        set game_board_state[%game_position_x%][%game_position_y%]=%game_visual_hidden%
    ) else (
        set game_message_type=ERROR
        set game_message_text=Cannot flag a visible cell
    )
    exit /b 0

:sanity_check
    if %game_position_x% lss 1 set game_position_x=1
    if %game_position_y% lss 1 set game_position_y=1
    if %game_position_x% gtr %game_board_size_x% set game_position_x=%game_board_size_x%
    if %game_position_y% gtr %game_board_size_y% set game_position_y=%game_board_size_y%
    exit /b 0

:clear_board_state
    set game_message_text=Board play state cleared
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
    set "game_message_text=Board Generated... Ready to play"

    :: Generate the game board
        for /l %%y in (1,1,!game_board_size_y!) do (
            for /l %%x in (1,1,!game_board_size_x!) do (
                if %game_board_mine_density% EQU 0 (
                    set game_message_text=I heard you're scared of mines. Don't worry, there are none here.
                    set game_board_mine[%%x][%%y]=0
                ) else if %game_board_mine_density% EQU 1 (
                    set game_message_text=I heard you like mines. Here, have some mines.
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
    :: Get the dimensions of the console
    for /f "tokens=1,2 delims=: " %%a in ('mode con^|findstr /C:"Columns" /C:"Lines"') do (
        if "%%~a" == "Columns" (
            set game_console_width=%%b
            set /a game_console_width_center=!game_console_width!/2
            set /a game_console_position_clock=!game_console_width!-19
            set /a game_console_position_debug_cheater=!game_console_position_clock!-12
            set /a game_console_position_debug_dumpvars=!game_console_position_debug_cheater!-11
            set /a game_console_position_debug=!game_console_position_debug_dumpvars!-8
        )
        if "%%~a" == "Lines" (
            set game_console_height=%%b
            set /a game_console_height_center=!game_console_height!/2
        )
    )

    :: If the console dimensions have changed, redraw the screen.
    if not "%game_console_dimensions%" == "!game_console_width!x!game_console_height!" (
        set game_console_dimensions=!game_console_width!x!game_console_height!
        set game_message_type=DEBUG
        set game_message_text=Console dimensions changed. Redrawing...
        echo %ANSI_cursor_hide%%ANSI_normal%
        cls
    )

    :: Draw the header and clock.
    set "game_header=%ANSI_cursor_move_home%%ANSI_clear_line%%ANSI_header%Yup, it's Minesweeper-ish%ANSI_normal%"
    set "game_header=%game_header%%ANSI_ESC%[0;%game_console_position_clock%H%ANSI_text_faint%%DATE% %TIME:~0,8%%ANSI_normal%"

    if defined game_debug set "game_header=%game_header%%ANSI_ESC%[0;%game_console_position_debug%H%ANSI_text_faint%%ANSI_bg_red%[debug]%ANSI_normal%"
    if defined game_debug_cheaterboard set "game_header=%game_header%%ANSI_ESC%[0;%game_console_position_debug_cheater%H%ANSI_text_faint%%ANSI_bg_red%[cheater]%ANSI_normal%"
    if defined game_debug_dumpvars set "game_header=%game_header%%ANSI_ESC%[0;%game_console_position_debug_dumpvars%H%ANSI_text_faint%%ANSI_bg_red%[dumpvars]%ANSI_normal%"

    echo %game_header%%ANSI_cursor_next_line%%ANSI_clear_line%
    set game_header=
    
    call :draw_message_box
    exit /b 0

:: TODO: Implement a message box that can be called from anywhere.
:: TODO: Handle debug crap more gracefully.
:draw_message_box
    if defined game_message_type if not defined game_debug_enabled if game_message_type == "DEBUG" set game_message_text=
    if defined game_message_text (
        if "!game_message_type!" == "DEBUG" (
            echo %ANSI_header_important%!game_message_text!%ANSI_normal%%ANSI_clear_line_right%
        ) else if "%game_message_type%" == "ERROR" (
            echo %ANSI_header_important%!game_message_text!%ANSI_normal%%ANSI_clear_line_right%
        ) else (
            echo %ANSI_header_note%!game_message_text!%ANSI_normal%%ANSI_clear_line_right%
        )
    ) else (
        echo %ANSI_clear_line%
    )
    echo %ANSI_clear_line%
    set game_message_type=
    set game_message_text=
    exit /b 0

:draw_menu
    echo %ANSI_header%Instructions%ANSI_normal%%ANSI_clear_line_right%
    echo %ANSI_clear_line%%ANSI_cursor_next_line%Game play:%ANSI_clear_line_right%
    echo    %ANSI_text_underline%w%ANSI_text_no_underline% %ANSI_text_underline%a%ANSI_text_no_underline% %ANSI_text_underline%s%ANSI_text_no_underline% %ANSI_text_underline%d%ANSI_text_no_underline% Move around the board.%ANSI_clear_line_right%
    echo    %ANSI_text_underline%x%ANSI_text_no_underline% Flag as mine.     %ANSI_text_underline%z%ANSI_text_no_underline% Mark as safe.%ANSI_clear_line_right%
    echo    %ANSI_text_underline%r%ANSI_text_no_underline% Draw the screen.  %ANSI_text_underline%R%ANSI_text_no_underline% Refresh the screen.%ANSI_clear_line_right%
    echo %ANSI_clear_line%%ANSI_cursor_next_line%Start, restart or end game: %ANSI_clear_line_right%
    echo    %ANSI_text_underline%0%ANSI_text_no_underline% No mines.         %ANSI_text_underline%1%ANSI_text_no_underline% ALL THE MINES%ANSI_clear_line_right%
    echo    %ANSI_text_underline%2%ANSI_text_no_underline% A lot of mines.   %ANSI_text_underline%3%ANSI_text_no_underline% A few mines.%ANSI_clear_line_right%
    echo    %ANSI_text_underline%c%ANSI_text_no_underline% Clear the board.  %ANSI_text_underline%q%ANSI_text_no_underline% Quit...%ANSI_clear_line_right%
    if defined game_debug (
        echo %ANSI_clear_line%%ANSI_cursor_next_line%Debugging stuff: %ANSI_clear_line_right%
        echo    %ANSI_text_underline%C%ANSI_text_no_underline% Toggle Cheaterd.  %ANSI_text_underline%D%ANSI_text_no_underline% Toggle variable dump%ANSI_clear_line_right%
    )
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

:toggle_cheater_board
    if defined game_debug_cheaterboard (
        set game_debug_cheaterboard=
    ) else (
        set game_debug_cheaterboard=1
    )
    exit /b 0

:toggle_dump_vars
    if defined game_debug_dumpvars (
        set game_debug_dumpvars=
    ) else (
        set game_debug_dumpvars=1
    )
    exit /b 0

:draw_cheater_board
:: This is a cheater board. It shows the mines and count of mines around each cell.
:: It's not part of the game, but it's useful for debugging. It's also reasonably
:: unoptimized and expensive to draw, so it will slow down the game.
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
    echo %ANSI_esc%[?1049l
    endlocal
    exit /b 0
