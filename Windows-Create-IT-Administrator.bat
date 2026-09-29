@echo off
setlocal EnableExtensions
color 02
title Windows Create IT Administrator - CyberNexus PH

:: ============================================================
:: WINDOWS CREATE IT ADMINISTRATOR
:: ============================================================
:: Creates a dedicated IT Administrator account.
::
:: Platform: Microsoft Windows
::
:: The current Windows user is saved as the Daily User target.
:: After successful creation, Windows automatically signs out.
::
:: Author: Mark C. Pangilinan / CyberNexus PH
:: License: MIT
::
:: Intended for authorized Windows administration only.
:: ============================================================

:: ------------------------------------------------------------
:: 1. CHECK ADMINISTRATOR PRIVILEGES
:: ------------------------------------------------------------

net session >nul 2>&1

if not "%errorlevel%"=="0" (
    cls
    echo ============================================================
    echo          WINDOWS CREATE IT ADMINISTRATOR
    echo                   CYBERNEXUS PH
    echo ============================================================
    echo.
    echo [ERROR] Administrator privileges are required.
    echo.
    echo Right-click this file and select:
    echo.
    echo     Run as administrator
    echo.
    pause
    exit /b 1
)

:: ------------------------------------------------------------
:: 2. START
:: ------------------------------------------------------------

:START

cls

echo ============================================================
echo          WINDOWS CREATE IT ADMINISTRATOR
echo                   CYBERNEXUS PH
echo ============================================================
echo.

:: ------------------------------------------------------------
:: 3. DETECT CURRENT WINDOWS USER
:: ------------------------------------------------------------

echo [1] DETECT CURRENT WINDOWS USER
echo ------------------------------------------------------------
echo.

set "DailyUser=%USERNAME%"

if not defined DailyUser (
    echo [ERROR] Could not detect the current Windows username.
    echo.
    pause
    exit /b 1
)

echo Current Windows User:
echo.
echo     %DailyUser%
echo.

echo Full Windows Identity:
whoami

echo.

:: ------------------------------------------------------------
:: 4. PREVENT ITADMIN AS CURRENT USER
:: ------------------------------------------------------------

if /I "%DailyUser%"=="ITAdmin" (
    echo [ERROR] You are already logged in as ITAdmin.
    echo.
    echo This program must be run from the existing
    echo Administrator account before ITAdmin is created.
    echo.
    pause
    exit /b 1
)

:: ------------------------------------------------------------
:: 5. CREATE CONFIGURATION DIRECTORY
:: ------------------------------------------------------------

echo [2] CREATE CONFIGURATION DIRECTORY
echo ------------------------------------------------------------
echo.

set "ConfigDir=%ProgramData%\CyberNexus\IT-Admin-Setup"

if not exist "%ConfigDir%" (
    mkdir "%ConfigDir%" >nul 2>&1
)

if not exist "%ConfigDir%" (
    echo [ERROR] Could not create configuration directory.
    echo.
    pause
    exit /b 1
)

echo [OK] Configuration directory ready.
echo.

:: ------------------------------------------------------------
:: 6. SAVE DAILY USER
:: ------------------------------------------------------------

echo [3] SAVE DAILY USER
echo ------------------------------------------------------------
echo.

> "%ConfigDir%\DailyUser.txt" echo %DailyUser%

if not exist "%ConfigDir%\DailyUser.txt" (
    echo [ERROR] Could not save Daily User information.
    echo.
    pause
    exit /b 1
)

echo [OK] Daily User saved:
echo.
echo     %DailyUser%
echo.

:: ------------------------------------------------------------
:: 7. CREATE ITADMIN ACCOUNT
:: ------------------------------------------------------------

echo [4] CREATE IT ADMINISTRATOR ACCOUNT
echo ------------------------------------------------------------
echo.

net user ITAdmin >nul 2>&1

if "%errorlevel%"=="0" (
    echo [INFO] ITAdmin already exists.
    echo.
) else (
    echo Creating ITAdmin...
    echo.
    echo Enter the password for ITAdmin.
    echo.

    net user ITAdmin * /add

    if not "%errorlevel%"=="0" (
        echo.
        echo [ERROR] Failed to create ITAdmin.
        echo.
        pause
        exit /b 1
    )

    echo.
    echo [OK] ITAdmin account created.
    echo.
)

:: ------------------------------------------------------------
:: 8. ADD ITADMIN TO ADMINISTRATORS
:: ------------------------------------------------------------

echo [5] CONFIGURE IT ADMINISTRATOR PRIVILEGES
echo ------------------------------------------------------------
echo.

net localgroup Administrators ITAdmin /add

if not "%errorlevel%"=="0" (
    echo.
    echo [ERROR] Could not add ITAdmin to Administrators.
    echo.
    pause
    exit /b 1
)

echo.
echo [OK] ITAdmin is a Local Administrator.
echo.

:: ------------------------------------------------------------
:: 9. VERIFY ITADMIN
:: ------------------------------------------------------------

echo [6] VERIFY IT ADMINISTRATOR
echo ------------------------------------------------------------
echo.

net user ITAdmin

echo.

:: ------------------------------------------------------------
:: 10. FINAL STATUS
:: ------------------------------------------------------------

echo ============================================================
echo              IT ADMIN CREATION COMPLETE
echo ============================================================
echo.
echo IT Administrator:
echo.
echo     ITAdmin
echo.
echo Role:
echo.
echo     Local Administrator
echo.
echo Daily User saved for the next setup stage:
echo.
echo     %DailyUser%
echo.
echo ============================================================
echo.
echo Windows will automatically sign out.
echo.
echo After sign-out:
echo.
echo     1. Sign in as ITAdmin.
echo     2. Run Windows-Configure-IT-Administrator.bat
echo.
echo ============================================================
echo.

timeout /t 10 /nobreak >nul

shutdown /l

endlocal
exit /b 0
