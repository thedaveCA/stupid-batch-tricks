@echo off
:: columns.cmd
:: Ever wanted to print a table in batch? Useful maybe, but who would be
:: insane enough to code it up? Oh, right, me. I'm insane.
::
:: This script will take a 2D array (yes, this is batch, yes I said array) of
:: strings and print them in dynamically sized columns.
:: 
:: - It will calculate the width of each column.
:: - It will also allow you to set the minimum width of a column manually.
:: - It will sometimes even display them correctly.
:: - There is no maximum width, try to not exceed the console width.
:: - It will not handle strings of only spaces, because batch.
::
:: Should you do this? No. But you could, and this is a proof of concept.
::
:: Please don't use this in production. Please don't use batch in production.
:: (says the guy writing batch in 2024).
::
:: Is there like a reverse-MIT license, where you're not allowed to use this
:: code for anything, and if you do you're forbidden from giving me credit?

:: TODO, stuff that is possibly broken, maybe could be improved?
:: - Column width calculation is not perfect, but it's close enough.
:: - Column width calculation does not handle strings of only spaces.
:: - Column width calculation does not consider console buffer or window size.
::
:: - Maximum width for columns could be useful. Truncating text is easy.
::   Deciding what to truncate, when, and why? Not so easy.
:: 
:: - It would be possible to wrap individual fields into variable-height rows?
::   Think about it, this is batch and we have a 2D array. There's no way to
::   manipulate arrays, so... Add a dimension just to hold wrapped text? lol.
::
::   Field-based formatting could be fun. Or column/row highlights?
::
:: - Frame drawing could be fun and useful. Actually it would be fun to draw
::   a frame around the table separate from the actual data.
::
:: - Remove references to "fun" in the comments. This is not fun. This is batch.
::
:: - Once in a while setlocal just... Fails. And all the temp variables end up
::   in the environment. I'm not sure why. Maybe add some error checking?
::

setlocal EnableDelayedExpansion

:: ############################################################################
:: ############################## CONFIGURATION ###############################
:: ############################################################################
::
:: Row and column counts and widths are treated as minimums, and are calculated
:: at runtime. Setting rowCount and columnCount will have a minor performance
:: improvement, but are not required, and longer or wider tables are allowed.
::
:: Entirely blank rows or columns will end the table, unless you set rowCount
:: and columnCount to include them.
::
:: If you set columnWidth, it will be used as a minimum width for that column.
:: Wider columns will be calculated at runtime.
::

:: Padding (Spaces) between columns
set columnPadding=2

:: (Optional) Minimum rowCount and columnCount.
set rowCount=0
set columnCount=0

:: (Optional) Set minimum column widths.
set columnWidth[0]=5
set columnWidth[1]=0
::set columnWidth[2]=
::set columnWidth[3]=
::set columnWidth[4]=

:: ############################################################################
:: ################################### DATA ###################################
:: ############################################################################
::
:: The script will parse the field array and calculate the column widths, then
:: render the columns. The field array is a 2D array of strings. Fields can be
:: blank, but an entirely blank column or an entirely blank row will end the
:: table. Fields can be omitted or left blank, "jagged" tables are allowed.
::

set field[0,0]=A
set field[0,1]=Bb
set field[0,2]=C
set field[1,0]=a
set field[1,1]=b
set field[1,2]=c
set field[1,3]=d
set field[2,0]=012345678
set field[2,1]=01234567
set field[2,2]=0123456
set "field[3,3]= x    x "
set "field[3,4]=     "
set "field[3,5]=hello there how are     you?"
set field[4,8]=X
set field[5,0]=Z

:: ############################################################################
:: ############################################################################
:: ############################################################################

:: ANSI escape codes are required. Offloading this to a helper script.
if not defined ANSI_header if not exist %~dp0..\Helpers\ANSI.cmd (
    echo ANSI.cmd not found. It is absolutely required for this script to run.
    exit /b 1
) else call %~dp0..\Helpers\ANSI.cmd

:: Subroutines
call %~dp0..\Helpers\ANSI.cmd

:: Main
call :rowCounter
call :columnCounter
call :columnCalculation
call :renderTableData

goto :eof

:: Subroutines

:: Here we count the number of rows, starting at the existing rowCount (if any)
:: Counting stops when we hit a blank row.
:rowCounter
    set /a rowCount+=0
    set | findstr /b /c:"field[!rowCount!," > nul
    if !errorlevel! equ 0 (
        set /a rowCount+=1
        goto :rowCounter
    )
    exit /b 0

:: Here we count the number of columns, starting at the existing columnCount (if any)
:: Counting stops when we hit a blank column.
:columnCounter
    set /a columnCount+=0
    for /l %%r in (0,1,%rowCount%) do (
        for /f "tokens=1,2 delims=,]" %%i in ('set field[%%r^, 2^>nul') do (
            if !columnCount! LSS %%j set columnCount=%%j
        )
    )
    :: We're finding the highest column number, the count is +1
    set /a columnCount+=1
    exit /b 0

:: Here we calculate the start point and width of each column. We assume that
:: the columnPadding has been set. We also assume that the rowCount and
:: columnCount have been set.
:columnCalculation
    set tempColumnNextStart=0

    for /l %%c in (0,1,%columnCount%) do (
        set columnStart[%%c]=!tempColumnNextStart!
        set /a columnWidth[%%c]+=0
        for /l %%r in (0,1,%rowCount%) do (
            if defined field[%%r,%%c] (
                call :charCounter !field[%%r,%%c]!
                if !charCount! GTR !columnWidth[%%c]! set columnWidth[%%c]=!charCount!
            )
            set /a tempColumnNextStart+=!columnWidth[%%c]!+!columnPadding!
        )
    )
    exit /b 0

:: Here we count the number of characters in a string. This is not perfect.
:charCounter
    set "charCounterString=.%*."
    set charCount=0
    :charCounterLoop
    if defined charCounterString (
        set "charCounterString=!charCounterString:~1!"
        set /a charCount+=1
        if defined charCounterString goto charCounterLoop
    )
    exit /b 0

:: Here we render the table to the screen. This is the easy part. We assume
:: that the column widths and starting positions have been calculated.
:: Text can be written left-to-right or right-to-left. This is not about
:: character direction, just the order that the columns are printed in, which
:: can be useful for debugging.
:renderTableData
    for /L %%r in (0,1,%rowCount%) do (
        set tempRowText=
        if not %%r == %rowCount% (
            for /L %%c in (0,1,!columnCount!) do (
                if not %%c == %columnCount% (
                    rem left-to-right
                    rem set "tempRowText=!tempRowText!%ANSI_ESC%[!columnStart[%%c]!G{!field[%%r,%%c]!}"
                    rem right-to-left
                    set "tempRowText=%ANSI_ESC%[!columnStart[%%c]!G{!field[%%r,%%c]!}!tempRowText!"
                )
            )
            echo !tempRowText!
        )
    )
    goto :eof

:: Here we draw a frame around the table. Dunno if this is useful. 
:: We assume that appropriate padding will exist between the frame and the
:: table, these can possibly be written separately, or maybe the frame can be
:: integrated into the table rendering.
:: TODO: Write this code, I guess?
:renderTableFrame
    set "tableFrameCharLeft=["
    set "tableFrameCharRight=]"
    set "tableFrameCharTop=-"
    set "tableFrameCharBottom=-"
    set "tableFrameCharSplit=\"
    set table

    exit /b 1
    for /L %%r in (0,1,%rowCount%) do (
        set tempRowText=
        if not %%r == %rowCount% (
            for /L %%c in (0,1,!columnCount!) do (
                if not %%c == %columnCount% (
                    ::set "tempRowText=%ANSI_ESC%[!columnStart[%%c]!G{!field[%%r,%%c]!}!tempRowText!"
                )
            )
            echo !tempRowText!
        )
    )
    goto :eof
