@echo off
:: jump.cmd - A batch solution for the "Jumping Game" problem
:: Inspired by https://www.youtube.com/watch?v=EIKGHSxALdk&t=726s
:: https://leetcode.com/problems/jump-game/?envType=study-plan-v2&envId=top-interview-150
:: https://builtin.com/software-engineering-perspectives/jump-game-leetcode
::
:: Why in batch? Because I can. Because nobody was here to stop me.
:: Your Scientists Were So Preoccupied With Whether Or Not They Could, They
:: Didn’t Stop To Think If They Should
::

setlocal enabledelayedexpansion enableextensions

if "%~1" == "--help" GOTO HELP
if "%~1" == "--test" GOTO TEST
if "%~1" == "" GOTO HELP

:: If the parameter is a file, read the file and call the script again with the contents
if exist "%~1" (
    for /F "usebackq delims=" %%a in ("%~1") do (
        call %0 %%a
    )
    goto :eof
)
 
:: Otherwise we assume the parameter is a list of integers
set LIST_INPUT=%*
set LIST=%*

:: Remove any brackets from the list
set LIST=%LIST:[=%
set LIST=%LIST:]=%

:: Initialize the number of steps allowed
set STEPS_ALLOWED=0

:: Step through the list until we run out of steps and then see if we consumed
:: all the digits or not
:ContinueLoop
if defined LIST (
    call :TakeStep
    if !STEPS_ALLOWED! EQU -1 (
        exit /b 2
    )
    if not defined LIST (
        echo true    %LIST_INPUT%
        exit /b 0
    )
    if !STEPS_ALLOWED! EQU 0 (
        echo false   %LIST_INPUT% ^(Can't get to !LIST!^)
        exit /b 1
    )
    goto ContinueLoop
)

:: If we reach this point, something went wrong.
echo ERROR: Something went wrong. It's batch, good luck troubleshooting.
exit /b 2

:: Subroutines

:: This subroutine takes a single step into the list.
:TakeStep
    for /F "tokens=1,* delims=,[] " %%a in ("%LIST%") do (
        set /a LAST_DIGIT=%%a
        if not !LAST_DIGIT! == %%a (
            echo ERROR   %LIST_INPUT% ^(Only digits are allowed, can't parse %%a^)
            set STEPS_ALLOWED=-1
            exit /b 1
        )
        if !LAST_DIGIT! LSS 0 (
            echo ERROR   %LIST_INPUT% ^(Only positive integers are allowed, can't parse %%a^)
            set STEPS_ALLOWED=-1
            exit /b 1
        )
        set /a STEPS_ALLOWED-=1
        if %%a GTR !STEPS_ALLOWED! set STEPS_ALLOWED=%%a
        set LIST=%%b
    )
    exit /b 0
    :: End of TakeStep

:: Test Suite
:Test
echo Testing %~nx0: Should return TRUE: 
    for %%z in (
        "1,2,3,4,5,6,7,8,9,10"
        "[2,3,1,1,4]"
        "1 2 3 4 0 0 0"
        "5"
        "0"
    ) do (
        call %0 %%~z
        if not !ERRORLEVEL! EQU 0 (
            echo ...TESTFAIL: Expected TRUE, got !ERRORLEVEL! for %%z
        )
    )
echo.&echo Testing %~nx0: Should return FALSE: 
    for %%z in (
        "0,1,2,3,4"
        "[3,2,1,0,4]"
    ) do (
        call %0 %%~z
        if not !ERRORLEVEL! EQU 1 (
            echo ...TESTFAIL: Expected FALSE, got !ERRORLEVEL! for %%z
        )
    )
echo.&echo Testing %~nx0: Should return ERROR ^(with explanation^):
    for %%z in (
        "1,2,-3,4,-5"
        "-5"
        "1,2,3,a,5"
        "z0"
        "z"
        "0z"
    ) do (
        call %0 %%~z
        if not !ERRORLEVEL! EQU 2 (
            echo ...TESTFAIL: Expected ERROR, got !ERRORLEVEL! for %%z
        )
    )
    exit /b 0
:: End of Test

:HELP
    echo Usage: %~nx0 [list of integers] -or- [file with list of integers] -or- [--option]
    echo.
    echo This script will determine if it is possible to reach the end of the list
    echo by starting at the first element and jumping forward up to the number of 
    echo steps equal to the value of the current element. 
    echo.
    echo Options:
    echo   --help  Display this help message
    echo   --test  Run the test suite
    echo.
    echo Returns codes: 
    echo   0 - TRUE: The end of the list was reached
    echo   1 - FALSE: The end of the list was not reached
    echo   2 - An error occurred
    echo.
    exit /b 2