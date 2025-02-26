@echo off
>nul chcp 65001
cd /d "%~dp0"
title Plutonium Modern Warfare 3
color 0A

taskkill /f /im "plutonium-launcher-win32.exe" 2>nul

call :title
echo Checking for updates...
echo.

ping -n 5 "plutonium-archive.getserve.rs" >nul 2>&1
if %errorlevel% equ 1 echo Connection Failed.
if %errorlevel% equ 0 (
	for /f "delims=" %%a in ('powershell -command "(invoke-restmethod -uri 'https://api.github.com/repos/ineedbots/iw5_bot_warfare/releases/latest').assets.browser_download_url"') do (
		echo %%a | findstr "*bw*.zip" >nul 2>&1
		if %errorlevel% equ 0 (
			powershell -command "$progresspreference = 'silentlycontinue'; invoke-webrequest -uri '%%a' -outfile 'bot_warfare.zip'"
			powershell -noprofile -command "$progresspreference = 'silentlycontinue'; expand-archive -path 'bot_warfare.zip' -destinationpath 'Plutonium Modern Warfare 3\storage\iw5' -force"
			del /f /q "bot_warfare.zip"
		)
	)
	
	if not exist "plutonium-updater.exe" (
		powershell -command "$progresspreference = 'silentlycontinue'; invoke-webrequest -uri 'https://github.com/mxve/plutonium-updater.rs/releases/latest/download/plutonium-updater-x86_64-pc-windows-msvc.zip' -outfile 'plutonium-updater.zip'"
		powershell -noprofile -command "$progresspreference = 'silentlycontinue'; expand-archive -path 'plutonium-updater.zip' -destinationpath '.'"
		del /f /q "plutonium-updater.zip"
	)
	
	if exist "plutonium-updater.exe" (
		plutonium-updater --no-color -qfd "Plutonium Modern Warfare 3" -e bin/plutonium-launcher-win32.exe -e bin/steam_api64.dll -e bin/VibeCheck.exe -e games/t4sp.exe -e games/t4mp.exe -e storage/t4 -e games/t5sp.exe -e games/t5mp.exe -e storage/t5 -e games/t6zm.exe -e games/t6mp.exe -e storage/t6
		color 0A
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
echo 2-Modern Warfare 3 Multiplayer
echo.
choice /c 12 /n /m "Choose an option: "

call :title
if %errorlevel% equ 1 for /f "delims=" %%i in ('
		powershell -NoProfile -Command "$input = Read-Host 'Player Name [a-zA-Z0-9 -_.]'; $filtered = ($input.ToCharArray() | Where-Object { $_ -match '[a-zA-Z0-9 -_.]' }) -join ''; if ($filtered) { $filtered } else { 'Plutonium' }"
') do set "player_name=%%i" && (echo %%i)>player_name.txt & goto :start

echo Start a private match and join using "/connect IP".
timeout /t 5

start /wait "" /d "Plutonium Modern Warfare 3" /b "bin\plutonium-bootstrapper-win32.exe" iw5mp "%cd%" -nocurses -lan -offline -name "%player_name%"
exit

:title
cls
echo.
echo ----Plutonium LAN----
echo.
goto :eof
