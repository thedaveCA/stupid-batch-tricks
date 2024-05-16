@echo off
:: columns.cmd
:: Ever wanted to print a table in batch? Useful maybe, but who would be
:: insane enough to code it up? Oh, right, me. I'm insane.
::
:: This script will take a 2D array (yes, this is batch, yes I said array) of
:: strings and print them in columns.
:: 
:: - It will calculate the width of each column.
:: - It will also allow you to set the minimum width of a column manually.
:: - It will sometimes even display them correctly.
:: - Right now there is no maximum width for a column.
:: - If you exceed the console width, well, you get what is coming to you.
:: - It will not handle strings of only spaces, because batch.
::
:: Should you do this? No. But you could, and this is a proof of concept.
::
:: Please don't use this in production. Please don't use batch in production.
:: (says the guy writing batch in 2024).
::
:: Jeebus, even ChatGPT is telling me to stop using batch. People say AI
:: halucinates, and maybe it does, but when it's right, it's right.

:: Is there like a reverse-MIT license, where you're not allowed to use this
:: code for anything, and if you do you're forbidden from giving me credit?
:: I should look into that.

:: TODO, stuff that is possibly broken, maybe could be improved?
:: - Column width calculation is not perfect, but it's close enough.
:: - Column width calculation does not handle strings of only spaces, ANSI
::   codes, unicode, double-width characters, combining characters, zero-width
::   characters, control characters, emoji, RTL text, CJK text, tabs, line
::   breaks, custom wrapping, etc.
:: - Column width calculation does not handle console buffer or window size.
::
:: - Maximum width for columns could be useful. Truncating text is easy.
::   Deciding what to truncate, when, and why? Not so easy.
::
:: - If we had that, maybe we could check the console width and if we're
::   generating a table that is too wide... ??? I dunno. Who cares.
:: 
:: - It would be possible to wrap individual fields, but that would be a lot
::   of work for something that is already a lot of work. And it would be
::   ugly. Ugly code, ugly to use. Ugly all around. Like really, really ugly.
::   Think about it, this is batch and we have a 2D array. There's no way to
::   manipulate arrays, so... Add a dimension just to hold wrapped text? lol.
::   I'm not doing that. I'm not. I'm not. I'm not. I'm not. I'm not. I'm not.
::   And if I do, I'm not. I'm not. I'm not. I'm not. I'm not. I'm not. I'm not.
::   You know how LLMs sometimes repeat themselves? I get it now. I really do.
::   I'm not. I'm not. I'm not. I'm really not. I'm not. I'm not. I'm not.
::   Except I might, because it would actually be a lot easier than it sounds.
::
:: - ANSI escape codes are not handled in the column width calculation
::   or the rendering. This is a big deal if you're using them. I guess I
::   could add field-based formatting. But I'm not writing a damn ANSI parser.
::   But if I added style support then I could add a bug that causes stuff to
::   blink instead of the defined style. Everybody loves blinking text.
::
:: - Right now I just wrap the text in braces because it was helpful to 
::   visualize during development. I'd like to add some kind of formatting
::   Maybe a table-left-character, field separator, table-right-character?
::
:: - Oh and you need ANSI, like for real. If you want a version that uses
::   spaces instead of ANSI, go do it. I won't stop you. If there was a god,
::   they would stop you. But this abomination exists, which I think is pretty
::   good evidence that there is no god. Or that god is a sadist.
::

setlocal EnableDelayedExpansion

call %~dp0..\Helpers\ANSI.cmd

::set column_width[0]=3
:: set column_width[1]=10
set column_width[2]=15
:: set column_width[3]=2
:: set column_width[4]=5

set rowCount=0
set columnCount=0

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
:: Omit field [3,
set "field[3,3]= x    x "
set "field[3,4]=     "
set "field[3,5]=hello there how are     you?"
set field[4,8]=X
set field[5,0]=Z


call :row_counter
call :column_counter
call :column_calculation
call :render_columns

goto :eof

:: Subroutines

:: Here we count the number of rows, starting at the existing rowCount (if any)
:: We assume that if we encounter a blank row, we have reached the end of the data
:row_counter
    set /a rowCount+=0
    set | findstr /b /c:"field[!rowCount!," > nul
    if !errorlevel! equ 0 (
        set /a rowCount+=1
        goto :row_counter
    )
    exit /b 0

:: Here we count the number of columns, starting at the existing columnCount (if any)
:: Empty columns are ignored, subsequent columns are handled properly.
:: As noted above, a completely empty row ends processing.
:column_counter
    set /a columnCount+=0
    for /l %%r in (0,1,%rowCount%) do (
        for /f "tokens=1,2 delims=,]" %%i in ('set field[%%r^, 2^>nul') do (
            if !columnCount! LSS %%j set columnCount=%%j
        )
    )
    :: We're finding the highest column number, the count is +1
    set /a columnCount+=1
    exit /b 0

:: Here we calculate the column widths and starting positions for each column
:: We will only increase the width of a column, never decrease it, honouring 
:: any values set externally, where applicable.
:column_calculation
    set column_next_start=0
    set columnPadding=2

    for /l %%c in (0,1,%columnCount%) do (
        set column_start[%%c]=!column_next_start!
        set /a column_width[%%c]+=0
        for /l %%r in (0,1,%rowCount%) do (
            if defined field[%%r,%%c] (
                call :char_counter !field[%%r,%%c]!
                if !charCount! GTR !column_width[%%c]! set column_width[%%c]=!charCount!
            )
            set /a column_next_start+=!column_width[%%c]!+!columnPadding!
        )
    )
    exit /b 0

:: Here we count the number of characters in a string
:: We use this to determine the width of a column. Because batch is batchy, 
:: strings entirely of spaces will not be counted correctly. Best of luck.
:char_counter
    set "char_counter_string=.%*."
    set charCount=0
    :char_counter_loop
    if defined char_counter_string (
        set "char_counter_string=!char_counter_string:~1!"
        set /a charCount+=1
        if defined char_counter_string goto char_counter_loop
    )
    exit /b 0

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
    goto :eof
