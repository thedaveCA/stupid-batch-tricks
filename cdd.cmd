:: Change Drive+Directory to the specified path, :keyword, or display current path
:: Inspired by the `cdd` command in Take Command
:: Plus support for well-known paths using syntax "cdd :keyword"
:: Some examples such as "Utils" and "Batch" are hardcoded, others pull
:: from the registry or other sources.
:: If named "~.cmd" then it changes to the %userprofile%

@echo off

setlocal EnableDelayedExpansion

if "%~1" == "--help" (
    if defined ANSI_ESC (
        :: If we are displaying help, and have ANSI, use fancy columns
        set COL1=%ANSI_ESC%[3G%ANSI_highlight%
        set COL2=%ANSI_ESC%[22G%ANSI_normal%
        set COL3=%ANSI_ESC%[55G%ANSI_emphasis%
    ) else (
        :: Otherwise, just use spaces
        set COL1= 
        set COL2=   
        set COL3=        
    )

    echo.
    echo %ANSI_header%%~nx0%ANSI_header% - Change current drive and to the specified directory or keyword.%ANSI_normal%
    echo.
    echo Usage: cdd [path^|:keyword^|--help]
    if exist "%~p0~.cmd" echo Usage: ~.cmd
    echo.
    echo Change Drive and directory to the specified path or keyword. 
    echo If no path is provided, display the current directory.
    echo.
    echo !COL1!%ANSI_emphasis%%ANSI_text_underline%Keyword!!COL2!%ANSI_normal%%ANSI_emphasis%%ANSI_text_underline%Description!COL3!%ANSI_emphasis%%ANSI_text_underline%Actual Path!%ANSI_normal%
    echo !COL1!C:\Example!!COL2!Actual path!COL3!C:\Example!%ANSI_normal%
    call :lookup_info ~&echo !COL1!!PATH_Name!!COL2!!PATH_Desc!!COL3!!PATH_To!!%ANSI_normal%
    for %%x in (
        UserProfile
        Desktop
        Documents
        Downloads
        Pictures
        AppData
        LocalAppData
        Temp
        Utils
        Batch
        OneDrive
        Dropbox
        GoogleDrive
        programfiles
        programfilesx86
    ) do (
        call :lookup_info %%x
        if defined PATH_Name (
            if defined PATH_To (
                echo !COL1!:!PATH_Name!!COL2!!PATH_Desc!!COL3!!PATH_To!!%ANSI_normal%
            ) else (
                echo !COL1!:!PATH_Name!!COL2!!PATH_Desc!!COL3!%ANSI_normal%
            )
        ) else (
                echo !COL1!%ANSI_normal%%ANSI_text_faint%:%%x!COL3!%ANSI_normal%%ANSI_text_faint%^(Not Available^)!%ANSI_normal%
        )
    )
    if "%~2" == "--shell" (
        echo.
        echo Registry keys for User Shell Folders can also be used as keywords:

        echo %ANSI_url%HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders%ANSI_normal%
        reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" | findstr /b /c:"    "
    )
    echo.
    echo :keyword can be followed by a subdirectory, e.g. cdd :temp\%RANDOM%
    echo.
    echo  Options: 
    echo  --help         - Display this help message.
    echo  --help --shell - And also display the registry keys for User Shell Folders.
) else if "%~0" == "~" (
    :: If the script is called ~.cmd, change to the user's profile directory
    cd /d "%userprofile%"
) else if "%~1" == "~" (
    :: If the user types cdd ~, change to the user's profile directory
    cd /d "%userprofile%"
) else if not "%~1"=="" (
    :: If the parameter is a :keyword, change to the corresponding directory, otherwise change to the specified path.
    for /F "tokens=1,* delims=\ " %%a in ("%~1") do (
        set keyword=%%a
        set keyword_path=%%b
    )
    :: keyword = the keyword, keyword_path = optional subdirectory under the path
    if "!keyword:~0,1!" == ":" (
        call :lookup_info !keyword:~1!
        if defined PATH_To (
            cd /d !PATH_To!\!keyword_path!
        ) else (
            echo %ANSI_highlight%!keyword!%ANSI_normal% is not a valid keyword. Type %ANSI_emphasis%cdd --help%ANSI_normal% for a list of valid keywords.
        )
    ) else (
        cd /d %*
    )
) else (
    cd
)

endlocal & cd /d %CD%
goto :eof

:: Subroutine to look up a directory based on a keyword
:lookup_info
    set PATH_To=
    set PATH_Name=
    set PATH_Desc=
    if /i "%~1" == "~" (
        set PATH_To=%userprofile%%
        set PATH_Desc=%%UserProfile%%
    ) else if /i "%~1" == "userprofile" (
        set PATH_To=%userprofile%%
        set PATH_Desc=%%UserProfile%%
    ) else if /i "%~1" == "onedrive" (
        for /F "tokens=3*" %%a in ('reg query "HKEY_CURRENT_USER\Software\Microsoft\OneDrive" /v UserFolder 2^>nul ^| find "UserFolder"') do (
            set PATH_To=%%~a
            set PATH_Desc=OneDrive root folder
        )
    ) else if /i "%~1" == "dropbox" (
        for /F "tokens=3*" %%a in ('reg query HKEY_CURRENT_USER\Software\Dropbox\client /v InstallPath 2^>nul ^| find "InstallPath" ') do (
            set PATH_To=%%~a
            set PATH_Desc=Dropbox root folder
        )
    ) else if /i "%~1" == "googledrive" (
        for /F "tokens=3*" %%a in ('reg query HKEY_CURRENT_USER\Software\Google\Drive /v DefaultLocalFolder 2^>nul ^| find "DefaultLocalFolder" ') do (
            set PATH_To=%%~a
            set PATH_Desc=Google Drive root folder
        )
    ) else if /i "%~1" == "utils" (
        set PATH_To=%UserProfile%\Utils
        set PATH_Desc=Utilities
    ) else if /i "%~1" == "batch" (
        set PATH_To=%UserProfile%\Utils\Batch
        set PATH_Desc=Batch Utilities
    ) else if /i "%~1" == "temp" (
        set PATH_To=%Temp%
        set PATH_Desc=User - Temp
    ) else if /i "%~1" == "localappdata" (
        set PATH_To=%LocalAppData%
        set PATH_Desc=User - Local AppData
    ) else if /i "%~1" == "programfiles" (
        set PATH_To=%ProgramFiles%
        set PATH_Desc=System - Program Files
    ) else if /i "%~1" == "programdata" (
        set PATH_To=%ProgramData%
        set PATH_Desc=System - "User" profile
    ) else if /i "%~1" == "programfilesx86" (
        set "PATH_To=%ProgramFiles(x86)%"
        set PATH_Desc=System - Program Files ^(x86^)
    ) else (
        if /i "%~1" == "downloads" set PATH_TARGET={374DE290-123F-4565-9164-39C4925E467B}
        if /i "%~1" == "screenshots" set PATH_TARGET={B7BEDE81-DF94-4682-A7D8-57A52620B86F}
        if /i "%~1" == "documents" set PATH_TARGET=Personal
        if /i "%~1" == "pictures" set PATH_TARGET=My Pictures
        if /i "%~1" == "startmenu" set PATH_TARGET=Start Menu
        if not defined PATH_TARGET set PATH_TARGET=%~1
        for /F "tokens=1,2,*" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" 2^>nul ^| findstr /i /b /c:"    !PATH_TARGET!    REG_"') do (
            if "%%~b" == "REG_EXPAND_SZ" (
                set PATH_To=%%~c
                set "PATH_To=!PATH_To:%%UserProfile%%=%UserProfile%!"
                set "PATH_Desc=User - %~1"
            )
        )
        if not defined PATH_To for /F "tokens=1,2,3,*" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" 2^>nul ^| findstr /i /b /c:"    !PATH_TARGET!    REG_"') do (
            if "%%~c" == "REG_EXPAND_SZ" (
                set PATH_To=%%~d
                set "PATH_To=!PATH_To:%%UserProfile%%=%UserProfile%!"
                set "PATH_Desc=User - %~1"
            )
        )
        set PATH_TARGET=
    )
    if defined PATH_To if not defined PATH_Name set PATH_Name=%~1
    exit /b 0
    :: TODO: Add more keywords here
    :: End of :lookup
