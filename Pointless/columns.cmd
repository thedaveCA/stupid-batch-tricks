@echo off

setlocal EnableDelayedExpansion

call %~dp0..\Helpers\ANSI.cmd

set column_width[0]=5
set column_width[1]=10
set column_width[2]=15
set column_width[3]=2
set column_width[4]=5

set rowCount=0
set columnCount=2

set field[0,0]=A
set field[0,1]=B
set field[0,2]=C
set field[1,0]=a
set field[1,1]=b
set field[1,2]=c
set field[1,3]=d
set field[2,0]=0123456789
set field[2,1]=0123456789
set field[2,2]=0123456789
set field[3,1]=X


echo %rowCount% rows
call :row_counter
echo %rowCount% rows
exit /b 2

call :column_calculation

set columnCount

call :render_columns


goto :eof

:: Subroutines

:: Here we count the number of rows, starting at the existing rowCount (if any)
:row_counter
    set /a rowCount+=0
    set tempvar=
    for /f "tokens=1,2 delims==" %%i in ('set field[!rowCount!^,0] 2^>nul') do set "tempvar=%%j"
    if defined tempvar (
        :: Check the next row
        set /a rowCount+=1
        goto :row_counter
    )
    exit /b 0


:column_calculation
    :: Set up variables
    if not defined columnIndex (
        set columnIndex=0
        set columnStart=0
        set columnPadding=5
        set /a columnCount+=0
    )

    :: TODO: Loop through each row and calculate the needed column widths
    ::       setting column_width[c] to the maximum width found
    ::       and columnCount to the number of columns found in each row
    ::        if !columnCount! LSS !columnIndex! set columnCount=!columnIndex!
    ::    set columnCount

    :: Loop through the column_width array, and calculate the column start position
    set tempvar=
    for /f "tokens=1,2 delims==" %%i in ('set column_width[!columnIndex!] 2^>nul') do set "tempvar=%%j"
    if defined tempvar (
        echo column: !columnIndex!, columnStart: !columnStart!, width: !tempvar!
        set column_start[!columnIndex!]=!columnStart!
        set /a columnStart+=!tempvar!+!columnPadding!
        set /a columnIndex+=1
        goto :column_calculation
    ) else (
        echo !columnIndex! - not defined
        goto :eof
    )

:render_columns
    for /L %%r in (0,1,%rowCount%) do (
        set temp_row_text=
        if not %%r == %rowCount% (
            for /L %%c in (0,1,!columnCount!) do (
                if not %%c == %columnCount% (
                    rem left-to-right
                    set "temp_row_text=!temp_row_text!%ANSI_ESC%[!column_start[%%c]!G{!field[%%r,%%c]!}"
                    rem right-to-left
                    rem set "temp_row_text=%ANSI_ESC%[!column_start[%%c]!Gcolumn %%c!temp_row_text!"
                )
            )
            echo !temp_row_text!
        )
    )
    echo.
    set column
    goto :eof


