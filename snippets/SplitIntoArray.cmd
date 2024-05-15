@echo off
setlocal enabledelayedexpansion

:: ############################################################################
:: ############ Example code to process input and generate arrays #############
:: ############################################################################

:: Process the input from the command line, or use a default value
if "%~1"=="" (
    echo %~nx0: Split input into an array of elements
    echo. 
    echo USAGE:   %~nx0 [element1] [element2] [element3] ...
    echo.
    echo TESTING: %~nx0 a b c d e f g
    call "%~nx0%" 3 a b c d e f g
    echo.&echo.
    echo TESTING: %~nx0 h i
    call "%~nx0%" 0 h i
    echo.&echo.
    echo TESTING: %~nx0 j
    call "%~nx0%" k
    exit /b 0
)

call :split_into_array %*

:: Show the array and queue directly from the environment
set "arraycount=%arrayindex%"
set "arrayindex="
set "queueindex="
echo -------------------
set array
echo -------------------

:: Loop through the array and queue to show the values (last will be empty)
for /L %%i in (0,1,%arraycount%) do (
    echo array[%%i]: !array[%%i]!
)
goto :eof

:: ############################################################################
:: ################ Function to split the input into an array #################
:: ############################################################################
:: "While" loop to process the elements
:split_into_array
    if not defined arrayindex set arrayindex=0
    if "%~1"=="" exit /b 0
    call :split_into_array_process_element %%~1
    shift
    goto :split_into_array
:split_into_array_process_element
    set "array[!arrayindex!]=%1"
    set /a arrayindex+=1
    exit /b 0
