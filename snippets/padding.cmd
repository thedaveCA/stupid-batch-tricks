:: padding.cmd -- returns a string of spaces of the specified length
:: String width is hardcoded and must be changed in the script, cannot be
:: passed as a parameter in a sensible way.

@echo off

:: enabledelayedexpansion is required for string manipulation
setlocal enabledelayedexpansion

echo %ANSI_header%^|0123456789^| Pad to 10 characters%ANSI_normal%
call :PadStringLeft "Hello"
echo ^|%string%^|
call :PadStringRight Hello
echo ^|%string%^|
call :PadNumber 123
echo ^|%string%^|
echo.
echo %ANSI_header%^|012345678901234^| Exceeds 10 characters already, do not pad or truncate%ANSI_normal%
call :PadStringLeft "HelloHelloHello"
echo ^|%string%^|
call :PadStringRight HelloHelloHello
echo ^|%string%^|
call :PadNumber 012345678901234
echo ^|%string%^|

echo.
echo %ANSI_header%^|0123456789^| Truncate to 10 characters%ANSI_normal%
call :TrunStringLeft HelloThereHowAreYou
echo ^|%string%^|
call :TrunStringRight HelloThereHowAreYou
echo ^|%string%^|


goto :eof

:: Pad a string with spaces to the left to make it at least 10 characters long
:: Note: Strings longer than 10 characters will be returned as is (longer than 10 characters)
:PadStringLeft
    set string=%~1
    if %string:~0,10% == %~1 (
        set string=          %~1
        set string=!string:~-10!
    )   else (
    set string=%~1
    )
    GOTO :EOF

:: Pad a string with spaces to the right to make it at least 10 characters long
:: Note: Strings longer than 10 characters will be returned as is (longer than 10 characters)
:PadStringRight
    set string=%~1
    if %string:~0,10% == %~1 (
        set string=%~1              
        set string=!string:~0,10!
    ) else (
        set string=%~1
    )
    GOTO :EOF

:: Pad a string with zeros to the left to make it at least 10 characters long
:: Note: This will not work for negative numbers
:: Note: Numbers longer than 10 characters will be returned as is (longer than 10 characters)
:PadNumber
    set string=%~1
    if %string:~0,10% == %~1 (
        set string=0000000000%~1
        set string=!string:~-10!
    )   else (
    set string=%~1
    )
    GOTO :EOF

:: Truncate a string to 10 characters from the left
:TrunStringLeft
    set string=%~1
    set string=!string:~0,10!
    GOTO :EOF

:: Truncate a string to 10 characters from the right
:TrunStringRight
    set string=%~1
    set string=!string:~-10!
    GOTO :EOF
