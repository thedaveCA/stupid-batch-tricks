@echo off
setlocal enabledelayedexpansion

:: ############################################################################
:: ############ Example code to process input and generate queues #############
:: ############################################################################

:: Process the input from the command line, or use a default value
if "%~1"=="" (
    echo %~nx0: Split input into a number of queues
    echo. 
    echo USAGE:   %~nx0 [queuecount] [element1] [element2] [element3] ...
    echo.
    echo TESTING: %~nx0 3 a b c d e f g h i j k l m n o p q r s t u v w x y z
    call "%~nx0%" 3 a b c d e f g h i j k l m n o p q r s t u v w x y z
    echo.&echo.
    echo TESTING: %~nx0 1 a b c d e f g h i j k l m n o p q r s t u v w x y z
    call "%~nx0%" 1 a b c d e f g h i j k l m n o p q r s t u v w x y z
    echo.&echo.
    echo TESTING: %~nx0 0 aa bb
    call "%~nx0%" 0 aa bb
    exit /b 0    
)

call :split_into_queues %*

:: Show the array and queue directly from the environment
echo -------------------
set queue
echo -------------------

for /L %%i in (0,1,%queuecount%) do (
    echo queue[%%i]: !queue[%%i]!
)
goto :eof

:: ############################################################################
:: ################# Function to split the input into queues ##################
:: ############################################################################
:: The queue is a circular buffer, so the last element will be empty
:split_into_queues
    :: On the first pass, set up the queue count
    if not defined queuecount (
        set "queuecount=%~1"&set /a queuecount+=0&shift
        set "queuenextindex=0"
        if !queuecount! lss 1 (
            echo WARNING: Queue count must be a positive integer, but was "%~1" ^(!queuecount!^).
            exit /b 1
        ) else if !queuecount! equ 1 (
            echo WARNING: The queue count is 1, so the queue will be the same as the input.
            echo          but with extra time wasted on generating the queue.
        )
    )
    if "%~1"=="" exit /b 0
    call :process_queue_process_element %%~1
    shift
    goto :split_into_queues
:process_queue_process_element
    for /f "tokens=1,2 delims==" %%i in ('set queue[!queuenextindex!] 2^>nul') do set "tempvar=%%j"
    if "!tempvar!"=="" (set "tempvar=") else (set "tempvar=!tempvar! ")
    set "queue[!queuenextindex!]=!tempvar!%1"
    set /a "queuenextindex=(!queuenextindex!+1) %% !queuecount!"
    exit /b
