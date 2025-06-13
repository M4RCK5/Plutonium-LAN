@echo off
>nul chcp 65001
title Plutonium LAN
call :ansi_colours

cd /d "%systemdrive%\"
taskkill /f /im "plutonium-launcher-win32.exe" 2>nul
md "Plutonium" >nul 2>&1 & cd /d "Plutonium" 2>nul

set "title_text=Plutonium LAN"
for /f "delims=" %%a in ('certutil -hashfile "%~dp0main\iw_00.iwd" MD5 ^| findstr /v :') do set md5_hash=%%a
if exist "%~dp0zone/all/base.ipak" (
	set "title_text=%red%Plutonium Black Ops 2%default%"
	set "mp_id=t6mp"
	set "coop_id=t6zm"
)
if "%md5_hash%"=="b80a50499b4498d7dc9d86e2eda12573" (
	set "title_text=%blue%Plutonium Black Ops%default%"
	set "mp_id=t5mp"
	set "coop_id=t5sp"
	call :bots t5
)
if "%md5_hash%"=="3e06c59ca86e764ba1d20bfabab54b27" (
	set "title_text=%yellow%Plutonium World at War%default%"
	set "mp_id=t4mp"
	set "coop_id=t4sp"
	call :bots t4
)
if "%md5_hash%"=="d68f0070c19aac5e20cdf5e656f2e477" (
	set "title_text=%green%Plutonium Modern Warfare 3%default%"
	set "mp_id=iw5mp"
	set "coop_id="
	call :bots iw5
)

call :title
echo Searching for updates...
ping -n 3 "cdn.plutonium.pw" >nul 2>&1
if %errorlevel% equ 0 (
	if not exist "plutonium.exe" powershell -command "$progresspreference = 'silentlycontinue'; invoke-webrequest -uri 'https://cdn.plutonium.pw/updater/plutonium.exe' -outfile 'plutonium.exe'" 2>nul
	for /f "delims=" %%a in ('powershell -command "(invoke-restmethod -Uri 'https://cdn.plutoniummod.com/updater/prod/info.json').revision" 2^>nul') do set "remote=%%a"
	if exist "info.json" for /f "delims=" %%a in ('powershell -command "(get-content -path 'info.json' -Raw | ConvertFrom-Json).revision" 2^>nul') do set "local=%%a"
	if not "%remote%"=="%local%" plutonium.exe -install-dir "." -update-only
)

:main
setlocal enabledelayedexpansion
set player_name=Plutonium
if exist "player_name.txt" set /p player_name=<player_name.txt

call :title
echo 1-Player Name    [!player_name!]
if defined mp_id echo 2-Multiplayer
if defined coop_id echo 3-Cooperative
echo.
choice /c 123 /n /m "Choose an option: "

call :title
if !errorlevel! equ 1 (
	call :input_filter player_name "[0-9 A-Z a-z _.-]" "Player Name" Plutonium
	(echo !player_name!)>player_name.txt
)
if !errorlevel! equ 2 set "app_id=!mp_id!"
if !errorlevel! equ 3 set "app_id=!coop_id!"
if !errorlevel! gtr 1 if defined app_id (
	echo Commands:
	echo	/connect IP
	echo	/fast_restart
	echo	/cg_fov
	echo	/com_maxfps
	
	timeout /t 5
	
	cls
	cd /d "%~dp0"
	start /wait "" /d "%systemdrive%\Plutonium" /b "bin\plutonium-bootstrapper-win32.exe" !app_id! "!cd!" -nocurses -lan -offline -name "!player_name!"
	exit
)
endlocal
goto :main

:bots game_id (t4 t5 iw5)
for /f "delims=" %%a in ('powershell -command "(invoke-restmethod -uri 'https://api.github.com/repos/ineedbots/%1_bot_warfare/releases/latest').assets.browser_download_url" 2^>nul') do (
	echo %%a | findstr "*bw*.zip" >nul 2>&1
	if %errorlevel% equ 0 (
		powershell -command "$progresspreference = 'silentlycontinue'; invoke-webrequest -uri '%%a' -outfile 'bot_warfare.zip'" 2>nul
		if "%1"=="t5" (
			powershell -command "$progresspreference = 'silentlycontinue'; expand-archive -path 'bot_warfare.zip' -destinationpath 'bot_warfare' -force" 2>nul
			for /d /r "bot_warfare" %%b in (*) do if "%%~nb"=="mp_bots" xcopy "%%~b" "storage\%1\mods\mp_bots\" /e /q /y >nul
			rd /s /q "bot_warfare"
		) else powershell -command "$progresspreference = 'silentlycontinue'; expand-archive -path 'bot_warfare.zip' -destinationpath 'storage\%1' -force" 2>nul
		del /f /q "bot_warfare.zip"
	)
)
goto :eof

:title
cls
echo.
echo ----%title_text%----
echo.
goto :eof

:input_filter var regex in_msg default
setlocal
for /f "delims=" %%a in ('
	powershell -noprofile -command "(read-host '%3 %2').tochararray() -match '%2' -join '' -replace '^$','%4'"
') do set "output=%%a"

endlocal & set "%1=%output%"
goto :eof

:ansi_colours
:: Enable ANSI Colours (https://ss64.com/nt/syntax-ansi.html)
for /f "tokens=2 delims=[]" %%a in ('ver') do set os_ver=%%a
for /f "tokens=2 delims= " %%a in ("%os_ver%") do set os_ver_num=%%a 
for /f "tokens=1,3 delims=." %%a in ("%os_ver_num%") do (
	if %%a geq 10 if %%b geq 16299 (
		for /f %%c in ('echo prompt $E^| cmd') do (
			:: set "ESC=%%c"
			set "default=%%c[0m"
			set "red=%%c[31;40m"
			set "green=%%c[32;40m"
			set "yellow=%%c[33;40m"
			set "blue=%%c[36;40m"
			set "pink=%%c[95m;40m"
			set "lblue=%%c[96m;40"
		)
	)
)
goto :eof