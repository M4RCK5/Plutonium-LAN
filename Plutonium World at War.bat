@echo off
>nul chcp 65001
cd /d "%~dp0"
title Plutonium World at War
color 08

taskkill /f /im "plutonium-launcher-win32.exe" 2>nul

call :title
echo Checking for updates...
echo.

ping -n 5 "plutonium-archive.getserve.rs" >nul 2>&1
if %errorlevel% equ 1 echo Connection Failed.
if %errorlevel% equ 0 (
	for /f "delims=" %%a in ('powershell -command "(invoke-restmethod -uri 'https://api.github.com/repos/ineedbots/t4_bot_warfare/releases/latest').assets.browser_download_url"') do (
		echo %%a | findstr "*bw*.zip" >nul 2>&1
		if %errorlevel% equ 0 (
			powershell -command "$progresspreference = 'silentlycontinue'; invoke-webrequest -uri '%%a' -outfile 'bot_warfare.zip'"
			powershell -noprofile -command "expand-archive -path 'bot_warfare.zip' -destinationpath 'Plutonium World at War\storage\t4\mods' -force"
			del /f /q "bot_warfare.zip"
		)
	)
	
	if not exist "plutonium-updater.exe" (
		powershell -command "$progresspreference = 'silentlycontinue'; invoke-webrequest -uri 'https://github.com/mxve/plutonium-updater.rs/releases/latest/download/plutonium-updater-x86_64-pc-windows-msvc.zip' -outfile 'plutonium-updater.zip'"
		powershell -noprofile -command "$progresspreference = 'silentlycontinue'; expand-archive -path 'plutonium-updater.zip' -destinationpath '.'"
		del /f /q "plutonium-updater.zip"
	)
	
	if exist "plutonium-updater.exe" (
		plutonium-updater --no-color -qfd "Plutonium World at War" -e bin/plutonium-launcher-win32.exe -e bin/steam_api64.dll -e bin/VibeCheck.exe -e games/t5sp.exe -e games/t5mp.exe -e storage/t5 -e games/t6zm.exe -e games/t6mp.exe -e storage/t6 -e games/iw5sp.exe -e games/iw5mp.exe -e storage/iw5
		color 08
	)
)
timeout /t 5

:start
set player_name=Plutonium
set /p player_name=<player_name.txt

call :title
echo Player: %player_name%
echo.
echo 1-Player Name
echo 2-World at War Multiplayer
echo 3-World at War Cooperative
echo.
choice /c 123 /n /m "Choose an option: "

call :title
if %errorlevel% equ 1 for /f "delims=" %%i in ('
		powershell -NoProfile -Command "$input = Read-Host 'Player Name [a-zA-Z0-9 -_.]'; $filtered = ($input.ToCharArray() | Where-Object { $_ -match '[a-zA-Z0-9 -_.]' }) -join ''; if ($filtered) { $filtered } else { 'Plutonium' }"
') do set "player_name=%%i" && (echo %%i)>player_name.txt & goto :start
if %errorlevel% equ 2 (
	set app_id=t4mp
	if exist "Plutonium World at War\storage\t4\mods\mp_bots" set extra=+set fs_localAppData "%~dp0Plutonium World at War\storage\t4" +set fs_game "mods\mp_bots"
	echo Start a private match and join using "/connect IP".
)
if %errorlevel% equ 3 (
	set app_id=t4sp
	echo 1-Start a SOLO match and wait for other players.
	echo 2-Join using "/connect IP".
	echo 3-Restart using "/fast_restart".
)
timeout /t 5

start /wait "" /d "Plutonium World at War" /b "bin\plutonium-bootstrapper-win32.exe" %app_id% "%cd%" -nocurses -lan -offline -name "%player_name%" %extra%
exit

:title
cls
echo.
echo ----Plutonium LAN----
echo.
goto :eof
