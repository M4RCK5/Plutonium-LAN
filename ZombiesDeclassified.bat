@echo off
title ZombiesDeclassified

net session >nul 2>&1 || powershell -command "start-process '%~f0' -verb runas -argumentList ' %*'" && exit

set "workdir=%systemdrive%\Plutonium"
echo %~n0 | findstr /i "portable" >nul 2>&1 && set "workdir=%~dp0Plutonium"
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

call :header
if not exist "%~dp0zone/all/base.ipak" (echo Place this script inside %red%Black Ops 2 folder%default%.) & goto :exit

echo Downloading ZombiesDeclassified Updater...
if not exist "DLC5.exe" call :dl "https://github.com/Logo-2K/zombies-declassified/releases/latest/download/ZombiesDeclassified-Updater.exe" "DLC5.exe"

call :header
echo 1-Install
echo 2-Update
echo 3-Verify
echo 4-Uninstall
echo.
choice /c 1234 /n /m "Choose an option: "
if %errorlevel% equ 1 set "choice=install"
if %errorlevel% equ 2 set "choice=update"
if %errorlevel% equ 3 set "choice=verify"
if %errorlevel% equ 4 set "choice=uninstall"

call :header

set "BO2_PATH=%~dp0"
set "BO2_PATH=%BO2_PATH:~0,-1%"
DLC5.exe %choice% --bo2-path "%BO2_PATH%" --pluto-path "%workdir%\storage\t6" --force

:exit
echo.
pause
exit

:dl url output
md "%~dp2" >nul 2>&1
powershell -noprofile -command "$progresspreference = 'silentlycontinue'; iwr '%~1' -outfile '%~2'" >nul 2>&1
goto :eof

:header
cls
echo.
echo ----%red%ZombiesDeclassified%default%----
echo.
goto :eof
