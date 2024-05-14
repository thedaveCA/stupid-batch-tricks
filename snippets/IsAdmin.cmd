:: fileorfolder.cmd - Are we an administrator?


@echo off
:CheckIsAdmin
    net session >nul 2>&1
    if !errorlevel! == 0 (
        exit /b 0
    ) else (
        exit /b 1
    )
    exit /b 2
