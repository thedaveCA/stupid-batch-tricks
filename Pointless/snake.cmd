::::::::::::::::::::::::::::::::::
:: Windows 10 Console ANSI Demo ::
::  Robert F Van Etta III 2018  ::
::::::::::::::::::::::::::::::::::

:initialization

	::Don't show commands, don't retain variables, enable delayed expansion, clear the screen
	@echo off & setlocal & setlocal enabledelayedexpansion & cls

	::Initialize Row and Column history arrays
	for /l %%a in (1,1,16) do (set RowArr=  0!RowArr!) & set ColArr=!RowArr!

	::Define Default Screen Dimensions and set starting position/direction
	set /a MaxRow=40, MaxCol=120, CurRow=1, CurCol=1, CurRowD=1, CurColD=1
	
	::Update the Window title to help users terminate the script...
	title Press Control+C (Twice sometimes) to Stop

	::Use forfiles to capture non-typable ASCII characters
	for /f "tokens=* delims=" %%a in ('forfiles /p %~dps0 /m %~nxs0 /c "cmd /c echo.0x200xB00xB10xB20xDB0x1B"') do @set arrChar=%%a
	set Esc=!arrChar:~5,1!
	
	::16 sets of 4 bytes that represent a gray-scale fade from white to black
	set FadeArray=7140713771277117704701170127001701370140013000370120701001100040
	
	::Use results of "mode con" to determine console buffer dimensions
	for /f "tokens=1,2" %%a in ('mode con') do (
		if "%%a"=="Lines:" set MaxRow=%%b
		if "%%a"=="Columns:" set MaxCol=%%b
		)

	::Limit console row buffer/window size to 40 rows
	if %MaxRow% GTR 40 set MaxRow=40

	::Lockdown the window dimensions
	mode con cols=%MaxCol% lines=%MaxRow%

:Loop
	::If at top or left then "bounce"
	if %CurRow% equ 1 set CurRowD=1
	if %CurCol% equ 1 set CurColD=1

	::If at bottom or right "bounce"
	if %CurCol% equ %MaxCol% set CurColD=-1
	if %CurRow% equ %MaxRow% set CurRowD=-1

	::Calculate new location and format it with fixed size for array
	set /a CurCol=CurCol+CurColD, CurRow=CurRow+CurRowD
	set CurCol=  %CurCol%& set CurRow=  %CurRow%
    
	::Push current positions to front and remove last value
    set ColArr=!CurCol:~-3!!ColArr:~,45!& set RowArr=!CurRow:~-3!!RowArr:~,45!

	::Draw from new position, fading out to black in 16 steps (0-15)
	for /l %%a in (0,1,15) do (
	
		::Each PacChar item is 4 bytes. Each value of RowArr/ColArr is 3 bytes. 
		set /a ia=%%a*4, ib=%%a*3
		
		::Use For loops to assist in extracting values from the arrays (strings)
		for %%b in (!ib!) do set /a row=!RowArr:~%%b,3!, col=!ColArr:~%%b,3!
		for %%b in (!ia!) do set PacChar=!FadeArray:~%%b,4!
		
		::PacChar consist of 4 bytes: FGColor, Intensity, intChar, BGColor
		set fg=!PacChar:~0,1!&set intChar=!PacChar:~2,1!& set bg=!PacChar:~3,1!
		set /a i=!PacChar:~1,1!, bg=bg+40, fg=fg+30
		
		::Char references the ASCII characters stored in arrChar on line 21
		for %%b in (!intChar!) do set Char=!arrChar:~%%b,1!
		
		::Change: row, col, intensity, fgcolor, bgcolor/Display char/Reset colors/Move to 0,0
	    echo %Esc%[!row!;!col!H%Esc%[!i!;!fg!m%Esc%[!bg!m!Char!%Esc%[0m%Esc%[0;0H
	)
goto :Loop





























