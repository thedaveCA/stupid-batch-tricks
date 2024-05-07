:: fileorfolder.cmd - Is this a file, a folder, or not?
:: https://stackoverflow.com/a/60421827

@echo off
:is_directory
    :: file_attribute can start with "d" or "-", otherwise something went wrong
    set file_attribute=%~a1
    if "%file_attribute:~0,1%"=="d" (
        exit /b 0
    ) else if "%file_attribute:~0,1%"=="-" (
        exit /b 1
    ) else (
        exit /b 2
    )
    goto :eof
    :: End of :is_directory
