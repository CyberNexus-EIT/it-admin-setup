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
::   - Saves the current Windows user as the Daily User.
::   - Creates ITAdmin if the account does not exist.
::   - If ITAdmin already exists and is already an Administrator,
::     no duplicate creation or group modification is performed.
::   - If ITAdmin exists but is not an Administrator, it is added
::     to the local Administrators group.
::   - Signs out automatically after successful completion.
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

:: ------------------------------------------------------------
:: 2. DETECT CURRENT WINDOWS USER
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
:: 3. PREVENT ITADMIN AS CURRENT USER
:: ------------------------------------------------------------

if /I "%DailyUser%"=="ITAdmin" (
    echo [ERROR] You are already logged in as ITAdmin.
    echo.
    echo Run this program from the existing Administrator account.
    echo.
    pause
    exit /b 1
)

:: ------------------------------------------------------------
:: 4. CREATE CONFIGURATION DIRECTORY
:: ------------------------------------------------------------

echo [2] CREATE CONFIGURATION DIRECTORY
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
:: 5. SAVE DAILY USER
:: ------------------------------------------------------------

echo [3] SAVE DAILY USER
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
:: 6. CHECK ITADMIN ACCOUNT
:: ------------------------------------------------------------

echo [4] CHECK IT ADMINISTRATOR ACCOUNT
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
:: 7. CHECK ITADMIN ADMINISTRATOR STATUS
:: ------------------------------------------------------------

:CHECK_ITADMIN_ADMIN

echo [5] CHECK IT ADMINISTRATOR PRIVILEGES
echo ------------------------------------------------------------
echo.

powershell -NoProfile -Command ^
 "$group = (Get-LocalGroup -SID 'S-1-5-32-544').Name; $member = Get-LocalGroupMember -Group $group -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '\\ITAdmin$' }; if ($member) { exit 0 } else { exit 1 }"

if "%errorlevel%"=="0" (
    echo [OK] ITAdmin is already a Local Administrator.
    echo.
    goto VERIFY_ITADMIN
)

echo [INFO] ITAdmin exists but is not a Local Administrator.
echo.
echo Adding ITAdmin to the local Administrators group...
echo.

powershell -NoProfile -Command ^
 "$group = (Get-LocalGroup -SID 'S-1-5-32-544').Name; Add-LocalGroupMember -Group $group -Member 'ITAdmin' -ErrorAction Stop"

if not "%errorlevel%"=="0" (
    echo.
    echo [ERROR] Could not add ITAdmin to the local Administrators group.
    echo.
    pause
    exit /b 1
)

echo.
echo [OK] ITAdmin is now a Local Administrator.
echo.

:: ------------------------------------------------------------
:: 8. VERIFY ITADMIN
:: ------------------------------------------------------------

:VERIFY_ITADMIN

echo [6] VERIFY IT ADMINISTRATOR
echo ------------------------------------------------------------
echo.

echo Local Administrators membership:
echo.

powershell -NoProfile -Command ^
 "$group = (Get-LocalGroup -SID 'S-1-5-32-544').Name; Get-LocalGroupMember -Group $group | Where-Object { $_.Name -match '\\ITAdmin$' }"

echo.

echo ITAdmin account information:
echo.

net user ITAdmin

echo.

:: ------------------------------------------------------------
:: 9. FINAL STATUS
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
echo Daily User saved:
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
