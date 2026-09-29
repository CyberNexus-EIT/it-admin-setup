@echo off
setlocal EnableExtensions
title IT Admin Setup
color 02

echo.
echo ========================================================
echo                    IT ADMIN SETUP
echo ========================================================
echo.

net session >nul 2>&1

if not "%errorlevel%"=="0" (
    echo [ERROR] Administrator privileges are required.
    echo.
    echo Right-click this file and select:
    echo     Run as administrator
    echo.
    pause
    exit /b 1
)

echo [OK] Administrator privileges confirmed.
echo.

echo ========================================================
echo COMPUTER INFORMATION
echo ========================================================
echo.

echo Computer Name:
hostname

echo.
echo IPv4 Address:
ipconfig | findstr /R /C:"IPv4 Address"

echo.

echo ========================================================
echo IT ADMINISTRATOR ACCOUNT
echo ========================================================
echo.

net user ITAdmin >nul 2>&1

if "%errorlevel%"=="0" (
    echo [OK] ITAdmin account already exists.
) else (
    echo Creating ITAdmin account...
    echo.
    net user ITAdmin * /add

    if not "%errorlevel%"=="0" (
        echo.
        echo [ERROR] Failed to create ITAdmin.
        pause
        exit /b 1
    )

    echo.
    echo [OK] ITAdmin account created.
)

echo.

echo Adding ITAdmin to local Administrators group...

net localgroup Administrators ITAdmin /add >nul 2>&1

if "%errorlevel%"=="0" (
    echo [OK] ITAdmin is an Administrator.
) else (
    echo [INFO] ITAdmin may already be an Administrator.
)

echo.

echo ========================================================
echo REMOTE ADMINISTRATION
echo ========================================================
echo.

echo Enabling PowerShell Remoting...

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Enable-PSRemoting -Force"

if not "%errorlevel%"=="0" (
    echo.
    echo [WARNING] PowerShell Remoting configuration returned an error.
) else (
    echo.
    echo [OK] PowerShell Remoting enabled.
)

echo.

echo Configuring Windows Firewall...

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Enable-NetFirewallRule -DisplayGroup 'Windows Remote Management'"

if not "%errorlevel%"=="0" (
    echo [WARNING] Could not enable all WinRM firewall rules.
) else (
    echo [OK] WinRM firewall rules enabled.
)

echo.

echo ========================================================
echo VERIFYING ADMINISTRATOR ACCOUNT
echo ========================================================
echo.

net user ITAdmin

echo.

echo ========================================================
echo VERIFYING WINDOWS REMOTE MANAGEMENT
echo ========================================================
echo.

sc query WinRM

echo.

echo ========================================================
echo SETUP COMPLETED
echo ========================================================
echo.

echo Computer:
hostname

echo.
echo IT Administrator:
echo ITAdmin

echo.
echo IPv4 Address:
ipconfig | findstr /R /C:"IPv4 Address"

echo.
echo IMPORTANT:
echo - Keep the ITAdmin password secure.
echo - Do not store the password inside this BAT file.
echo - Use this only on computers you are authorized to manage.
echo.

pause
endlocal
