@echo off
>nul chcp 65001
title Plutonium LAN

set "workdir=%systemdrive%\"
if exist "%~dp0plutonium_portable.txt" set "workdir=%~dp0"
taskkill /f /im "plutonium-launcher-win32.exe" 2>nul
cd /d "%workdir%" & md "Plutonium" >nul 2>&1 & cd /d "Plutonium" 2>nul

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
			set "pink=%%c[95;40m"
			set "lblue=%%c[96;40m"
		)
	)
)

:: Identify Game
set "title=Plutonium LAN"
for /f "delims=" %%a in ('certutil -hashfile "%~dp0main\iw_00.iwd" MD5 ^| findstr /v :') do set md5_hash=%%a
if exist "%~dp0zone/all/base.ipak" set "app_id=t6" & set "mp_id=t6mp" & set "cp_id=t6zm" & set "title=%red%Plutonium Black Ops 2%default%"
if "%md5_hash%"=="b80a50499b4498d7dc9d86e2eda12573" set "app_id=t5" & set "mp_id=t5mp" & set "cp_id=t5sp" & set "title=%blue%Plutonium Black Ops%default%"
if "%md5_hash%"=="3e06c59ca86e764ba1d20bfabab54b27" set "app_id=t4" & set "mp_id=t4mp" & set "cp_id=t4sp" & set "title=%yellow%Plutonium World at War%default%"
if "%md5_hash%"=="d68f0070c19aac5e20cdf5e656f2e477" set "app_id=iw5" & set "mp_id=iw5mp" & set "cp_id=" & set "title=%green%Plutonium Modern Warfare 3%default%"

call :title
echo Searching for updates...
echo.

:: Update Plutonium
set "updater_url=https://github.com/mxve/plutonium-updater.rs/releases/latest/download/plutonium-updater-x86_64-pc-windows-msvc.zip"
if not exist "plutonium-updater.exe" (
	powershell -noprofile -command "$progresspreference = 'silentlycontinue'; invoke-webrequest -uri '%updater_url%' -outfile 'plutonium_updater.zip'" >nul 2>&1
	powershell -noprofile -command "$progresspreference = 'silentlycontinue'; expand-archive -path 'plutonium_updater.zip' -destinationpath '.' -force" >nul 2>&1
	del /f /q "plutonium_updater.zip" >nul 2>&1
)
plutonium-updater --no-color -d "." -c -q || plutonium-updater --no-color -d "." -q

:: Install Bot Warfare
for /f "delims=" %%a in ('powershell -command "(invoke-restmethod 'https://api.github.com/repos/ineedbots/%app_id%_bot_warfare/releases/latest').assets.browser_download_url" 2^>nul') do (
	echo %%a | findstr "*bw*.zip" >nul 2>&1
	if %errorlevel% equ 0 (
		powershell -command "$progresspreference = 'silentlycontinue'; invoke-webrequest '%%a' -outfile 'bot_warfare.zip'; expand-archive 'bot_warfare.zip' 'bot_warfare' -force" 2>nul
		if not "%app_id%"=="iw5" for /d /r "bot_warfare" %%b in (*) do if "%%~nb"=="mp_bots" xcopy "%%~b" "storage\%app_id%\mods\mp_bots\" /e /q /y >nul
		if "%app_id%"=="iw5" xcopy "bot_warfare\z_svr_bots.iwd" "storage\%app_id%\z_svr_bots.iwd*" /e /q /y >nul
		rd /s /q "bot_warfare" >nul 2>&1
		del /f /q "bot_warfare.zip" >nul 2>&1
	)
)

:main
setlocal enabledelayedexpansion
set player_name=Plutonium
if exist "player_name.txt" set /p player_name=<player_name.txt

call :title
echo 1-Player Name    [!player_name!]
if defined mp_id echo 2-Multiplayer
if defined cp_id echo 3-Cooperative
echo.
choice /c 123 /n /m "Choose an option: "

call :title
if !errorlevel! equ 1 (
	for /f "delims=" %%a in ('powershell -noprofile -command "(read-host 'Player Name').tochararray() -match '[0-9 A-Z a-z _.-]' -join '' -replace '^$','Plutonium'"') do set "player_name=%%a"
	(echo !player_name!)>player_name.txt
)
if !errorlevel! equ 2 set "run_id=!mp_id!"
if !errorlevel! equ 3 set "run_id=!cp_id!"
if !errorlevel! gtr 1 if defined run_id (
	echo Commands:
	echo     /connect IP
	echo     /fast_restart
	echo     /xpartygo
	echo     /com_maxfps
	echo     /r_dof_enable
	echo     /cg_drawfps
	echo     /cg_fov
	timeout /t 5
	echo.
	
	cd /d "%~dp0"
	start /wait "" /d "%workdir%Plutonium" /b "bin\plutonium-bootstrapper-win32.exe" !run_id! "!cd!" -nocurses -lan -offline -name "!player_name!"
	exit
)
endlocal
goto :main

:title
cls
echo.
echo ----%title%----
echo.

goto :eof



