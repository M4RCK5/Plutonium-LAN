@echo off
>nul chcp 65001
title Plutonium LAN

set "workdir=%systemdrive%\Plutonium"
if exist "%~dp0plutonium_portable.txt" set "workdir=%~dp0Plutonium"
taskkill /f /im "plutonium-launcher-win32.exe" 2>nul
md "%workdir%" >nul 2>&1
cd /d "%workdir%" 2>nul

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
set "game=Plutonium LAN"
for /f "delims=" %%a in ('certutil -hashfile "%~dp0main\iw_00.iwd" MD5 ^| findstr /v :') do set md5_hash=%%a
if exist "%~dp0zone/all/base.ipak" set "game_id=t6" & set "multi_id=t6mp" & set "coop_id=t6zm" & set "game=%red%Plutonium Black Ops 2%default%"
if "%md5_hash%"=="b80a50499b4498d7dc9d86e2eda12573" set "game_id=t5" & set "multi_id=t5mp" & set "coop_id=t5sp" & set "game=%blue%Plutonium Black Ops%default%"
if "%md5_hash%"=="3e06c59ca86e764ba1d20bfabab54b27" set "game_id=t4" & set "multi_id=t4mp" & set "coop_id=t4sp" & set "game=%yellow%Plutonium World at War%default%"
if "%md5_hash%"=="d68f0070c19aac5e20cdf5e656f2e477" set "game_id=iw5" & set "multi_id=iw5mp" & set "coop_id=" & set "game=%green%Plutonium Modern Warfare 3%default%"

call :header
echo Searching for updates...
echo.

:: Update Plutonium
if not exist "plutonium.exe" powershell -noprofile -command "$progresspreference = 'silentlycontinue'; iwr 'https://cdn.plutonium.pw/updater/plutonium.exe' -outfile 'plutonium.exe'" 2>nul
ping cdn.plutonium.pw -n 1 >nul 2>&1 && if exist "plutonium.exe" start "" /min "plutonium.exe" -install-dir "."

:wait
timeout /t 1 /nobreak >nul
tasklist /fo csv /nh /fi "imagename eq plutonium.exe" | findstr "plutonium.exe" >nul && goto :wait

taskkill /im plutonium-launcher-win32.exe /f >nul 2>&1

:: Install Bot Warfare
for /f "delims=" %%a in ('powershell -command "(invoke-restmethod 'https://api.github.com/repos/ineedbots/%game_id%_bot_warfare/releases/latest').assets.browser_download_url" 2^>nul') do (
	echo %%a | findstr "*bw*.zip" >nul 2>&1
	if %errorlevel% equ 0 (
		powershell -command "$progresspreference = 'silentlycontinue'; invoke-webrequest '%%a' -outfile 'bot_warfare.zip'; expand-archive 'bot_warfare.zip' 'bot_warfare' -force" 2>nul
		if not "%game_id%"=="iw5" for /d /r "bot_warfare" %%b in (*) do if "%%~nb"=="mp_bots" xcopy "%%~b" "storage\%game_id%\mods\mp_bots\" /e /q /y >nul
		if "%game_id%"=="iw5" xcopy "bot_warfare\z_svr_bots.iwd" "storage\%game_id%\z_svr_bots.iwd*" /e /q /y >nul
		rd /s /q "bot_warfare" >nul 2>&1
		del /f /q "bot_warfare.zip" >nul 2>&1
	)
)

:main
setlocal enabledelayedexpansion
set player_name=Plutonium
if exist "player_name.txt" set /p player_name=<player_name.txt

call :header
echo 1-Player Name    [!player_name!]
if defined multi_id echo 2-Multiplayer
if defined coop_id echo 3-Cooperative
echo.
choice /c 123 /n /m "Choose an option: "

call :header
if !errorlevel! equ 1 (
	for /f "delims=" %%a in ('powershell -noprofile -command "(read-host 'Player Name').tochararray() -match '[0-9 A-Z a-z _.-]' -join '' -replace '^$','Plutonium'"') do set "player_name=%%a"
	(echo !player_name!)>player_name.txt
)
if !errorlevel! equ 2 set "launch_id=!multi_id!"
if !errorlevel! equ 3 set "launch_id=!coop_id!"
if !errorlevel! gtr 1 if defined launch_id (
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
	if exist "%workdir%\bin\plutonium-bootstrapper-win32.exe" (
		start /wait "" /d "%workdir%" /b "bin\plutonium-bootstrapper-win32.exe" !launch_id! "!cd!" -nocurses -lan -offline -name "!player_name!"
	)
	exit
)
endlocal
goto :main

:header
cls
echo.
echo ----%game%----
echo.
goto :eof