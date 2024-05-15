@echo off

setlocal EnableDelayedExpansion

call %~dp0..\Helpers\ANSI.cmd

set column_width[0]=5
set column_width[1]=10
set column_width[2]=15
set column_width[3]=2
set column_width[4]=5

set rowCount=0
set columnCount=0

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
:: Omit field [3,
set field[4,8]=X
::set field[5,0]=Z


call :row_counter
call :column_counter
call :column_calculation

set columnCount

call :render_columns


goto :eof

:: Subroutines

:: Here we count the number of rows, starting at the existing rowCount (if any)
:: We assume that the first column is always defined, because *shrug*
:: TODO: Refactor a bit, could we "set[!rowCount!, " to get a true/false for 
::       any columns in a given row? Or do we care? The user can pass rowCount too.
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

:: Here we count the number of columns, starting at the existing columnCount (if any)
:column_counter
    set /a columnCount+=0
    set tempvar=
    for /l %%r in (0,1,%rowCount%) do (
        echo -- checking row %%r of %rowCount%
        set field[%%r,
        for /f "tokens=1,2 delims=,]" %%i in ('set field[%%r^, 2^>nul') do (
            echo i=%%i, j=%%j
            if !columnCount! LSS %%j set columnCount=%%j
            set columnCount
        )
    )
    exit /b 0

:: Here we calculate the column widths and starting positions
:: TODO: We should know how many columns, so we can use columnCount instead of 
::       iterating through the array. We should also know the column padding.
:column_calculation
    set /a columnCount+=0

    :: Set up variables
    if not defined columnIndex (
        set columnIndex=0
        set columnStart=0
        set columnPadding=2
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


