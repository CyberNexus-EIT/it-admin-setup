@echo off
setlocal EnableExtensions
color 02
title Windows Create IT Administrator - CyberNexus PH

:: ============================================================
:: WINDOWS CREATE IT ADMINISTRATOR
:: ============================================================
:: Creates or verifies the dedicated IT Administrator account.
::
:: Platform: Microsoft Windows
::
:: Behavior:
::   - Detects the currently logged-in user as the Daily User.
::   - Saves the Daily User locally.
::   - Creates ITAdmin if it does not exist.
::   - If ITAdmin already exists, it is not recreated.
::   - Ensures ITAdmin is a Local Administrator.
::   - Ensures ITAdmin is visible on the Windows sign-in screen.
::   - Automatically signs out after completion.
::
:: Author: Mark C. Pangilinan / CyberNexus PH
:: License: MIT
::
:: Intended for authorized Windows administration only.
:: ============================================================

:START

cls

echo ============================================================
echo          WINDOWS CREATE IT ADMINISTRATOR
echo                   CYBERNEXUS PH
echo ============================================================
echo.

:: ------------------------------------------------------------
:: 1. CHECK ADMINISTRATOR PRIVILEGES
:: ------------------------------------------------------------

echo [1] CHECK ADMINISTRATOR PRIVILEGES
echo ------------------------------------------------------------
echo.

net session >nul 2>&1

if not "%errorlevel%"=="0" (
    echo [ERROR] Administrator privileges are required.
    echo.
    echo Right-click this file and select:
    echo.
    echo     Run as administrator
    echo.
    pause
    exit /b 1
)

echo [OK] Administrator privileges confirmed.
echo.

:: ------------------------------------------------------------
:: 2. DETECT CURRENT USER
:: ------------------------------------------------------------

echo [2] DETECT CURRENT WINDOWS USER
echo ------------------------------------------------------------
echo.

set "DailyUser=%USERNAME%"

if not defined DailyUser (
    echo [ERROR] Could not detect the current Windows username.
    echo.
    pause
    exit /b 1
)

if /I "%DailyUser%"=="ITAdmin" (
    echo [ERROR] You are already logged in as ITAdmin.
    echo.
    echo Run this program from the existing Daily User /
    echo existing Administrator account.
    echo.
    pause
    exit /b 1
)

echo Daily User:
echo.
echo     %DailyUser%
echo.

echo Full Windows Identity:
whoami
echo.

:: ------------------------------------------------------------
:: 3. CREATE CONFIGURATION DIRECTORY
:: ------------------------------------------------------------

echo [3] CREATE CONFIGURATION DIRECTORY
echo ------------------------------------------------------------
echo.

set "ConfigDir=%ProgramData%\CyberNexus\IT-Admin-Setup"
set "DailyUserFile=%ConfigDir%\DailyUser.txt"

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
:: 4. SAVE DAILY USER
:: ------------------------------------------------------------

echo [4] SAVE DAILY USER
echo ------------------------------------------------------------
echo.

> "%DailyUserFile%" echo %DailyUser%

if not exist "%DailyUserFile%" (
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
:: 5. CHECK ITADMIN ACCOUNT
:: ------------------------------------------------------------

echo [5] CHECK IT ADMINISTRATOR ACCOUNT
echo ------------------------------------------------------------
echo.

net user ITAdmin >nul 2>&1

if "%errorlevel%"=="0" (
    echo [OK] ITAdmin account already exists.
    echo.
    goto CHECK_ITADMIN_ADMIN
)

echo [INFO] ITAdmin account does not exist.
echo.
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

:: ------------------------------------------------------------
:: 6. CHECK ITADMIN ADMINISTRATOR MEMBERSHIP
:: ------------------------------------------------------------

:CHECK_ITADMIN_ADMIN

echo [6] CHECK IT ADMINISTRATOR MEMBERSHIP
echo ------------------------------------------------------------
echo.

powershell -NoProfile -Command ^
 "$group = (Get-LocalGroup -SID 'S-1-5-32-544').Name; $member = Get-LocalGroupMember -Group $group -ErrorAction SilentlyContinue | Where-Object { $_.Name -split '\\' | Select-Object -Last 1 -eq 'ITAdmin' }; if ($member) { exit 0 } else { exit 1 }"

if "%errorlevel%"=="0" (
    echo [OK] ITAdmin is already a Local Administrator.
    echo.
    goto ENABLE_ITADMIN
)

echo [INFO] ITAdmin is not a Local Administrator.
echo.
echo Adding ITAdmin to the local Administrators group...
echo.

powershell -NoProfile -Command ^
 "$group = (Get-LocalGroup -SID 'S-1-5-32-544').Name; Add-LocalGroupMember -Group $group -Member 'ITAdmin' -ErrorAction Stop"

if not "%errorlevel%"=="0" (
    echo.
    echo [ERROR] Could not add ITAdmin to Administrators.
    echo.
    pause
    exit /b 1
)

echo.
echo [OK] ITAdmin added to Administrators.
echo.

:: ------------------------------------------------------------
:: 7. ENSURE ITADMIN IS ENABLED
:: ------------------------------------------------------------

:ENABLE_ITADMIN

echo [7] ENSURE IT ADMINISTRATOR IS ENABLED
echo ------------------------------------------------------------
echo.

net user ITAdmin /active:yes >nul

if not "%errorlevel%"=="0" (
    echo [ERROR] Could not enable ITAdmin.
    echo.
    pause
    exit /b 1
)

echo [OK] ITAdmin account is enabled.
echo.

:: ------------------------------------------------------------
:: 8. ENSURE ITADMIN IS NOT HIDDEN
:: ------------------------------------------------------------

echo [8] ENSURE IT ADMINISTRATOR IS VISIBLE
echo ------------------------------------------------------------
echo.

reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /v ITAdmin /f >nul 2>&1

echo [OK] ITAdmin sign-in visibility configuration checked.
echo.

:: ------------------------------------------------------------
:: 9. VERIFY ITADMIN
:: ------------------------------------------------------------

echo [9] VERIFY IT ADMINISTRATOR
echo ------------------------------------------------------------
echo.

echo ITAdmin account:
echo.

net user ITAdmin

echo.

echo ITAdmin Administrators membership:
echo.

powershell -NoProfile -Command ^
 "$group = (Get-LocalGroup -SID 'S-1-5-32-544').Name; Get-LocalGroupMember -Group $group | Where-Object { $_.Name -split '\\' | Select-Object -Last 1 -eq 'ITAdmin' }"

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
echo     Role: Local Administrator
echo.
echo Daily User:
echo.
echo     %DailyUser%
echo.
echo Configuration file:
echo.
echo     %DailyUserFile%
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
