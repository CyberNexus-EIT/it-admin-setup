@echo off
setlocal EnableExtensions
color 02
title Windows Configure IT Administrator - CyberNexus PH

:: ============================================================
:: WINDOWS CONFIGURE IT ADMINISTRATOR
:: ============================================================
:: Configures the saved Daily User as a Standard User.
::
:: Platform: Microsoft Windows
::
:: This program must be run while logged in as ITAdmin.
::
:: Behavior:
::   - Verifies ITAdmin.
::   - Verifies ITAdmin is a Local Administrator.
::   - Loads the Daily User saved by Program 1.
::   - Ensures the Daily User account is enabled.
::   - Removes the Daily User from Administrators.
::   - Ensures the Daily User is not hidden by SpecialAccounts.
::   - Configures Standard User UAC credential prompting.
::   - Verifies the resulting configuration.
::   - Provides Close, Run Again, and Switch User options.
::
:: Author: Mark C. Pangilinan / CyberNexus PH
:: License: MIT
::
:: Intended for authorized Windows administration only.
:: ============================================================

:START

cls

echo ============================================================
echo       WINDOWS CONFIGURE IT ADMINISTRATOR
echo                CYBERNEXUS PH
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
:: 2. CHECK CURRENT USER
:: ------------------------------------------------------------

echo [2] CHECK CURRENT WINDOWS USER
echo ------------------------------------------------------------
echo.

echo Current Windows User:
echo.
echo     %USERNAME%
echo.

if /I not "%USERNAME%"=="ITAdmin" (
    echo [ERROR] You are not logged in as ITAdmin.
    echo.
    echo This program must be run while logged in as:
    echo.
    echo     ITAdmin
    echo.
    pause
    exit /b 1
)

echo [OK] Current user is ITAdmin.
echo.

:: ------------------------------------------------------------
:: 3. VERIFY ITADMIN ACCOUNT
:: ------------------------------------------------------------

echo [3] VERIFY IT ADMINISTRATOR
echo ------------------------------------------------------------
echo.

net user ITAdmin >nul 2>&1

if not "%errorlevel%"=="0" (
    echo [ERROR] ITAdmin account does not exist.
    echo.
    pause
    exit /b 1
)

echo [OK] ITAdmin account exists.
echo.

net user ITAdmin /active:yes >nul

echo [OK] ITAdmin account is enabled.
echo.

:: ------------------------------------------------------------
:: 4. VERIFY ITADMIN ADMINISTRATOR MEMBERSHIP
:: ------------------------------------------------------------

echo [4] VERIFY IT ADMINISTRATOR MEMBERSHIP
echo ------------------------------------------------------------
echo.

powershell -NoProfile -Command ^
 "$group = (Get-LocalGroup -SID 'S-1-5-32-544').Name; $member = Get-LocalGroupMember -Group $group -ErrorAction SilentlyContinue | Where-Object { ($_.Name -split '\\')[-1] -eq 'ITAdmin' }; if ($member) { exit 0 } else { exit 1 }"

if not "%errorlevel%"=="0" (
    echo [ERROR] ITAdmin is not a member of the local Administrators group.
    echo.
    pause
    exit /b 1
)

echo [OK] ITAdmin is a Local Administrator.
echo.

:: ------------------------------------------------------------
:: 5. LOAD DAILY USER
:: ------------------------------------------------------------

echo [5] LOAD DAILY USER CONFIGURATION
echo ------------------------------------------------------------
echo.

set "ConfigDir=%ProgramData%\CyberNexus\IT-Admin-Setup"
set "DailyUserFile=%ConfigDir%\DailyUser.txt"

if not exist "%DailyUserFile%" (
    echo [ERROR] Daily User configuration was not found.
    echo.
    echo Expected:
    echo.
    echo     %DailyUserFile%
    echo.
    echo Run Windows-Create-IT-Administrator.bat first.
    echo.
    pause
    exit /b 1
)

set "DailyUser="
set /p "DailyUser="<"%DailyUserFile%"

if not defined DailyUser (
    echo [ERROR] Daily User information is empty.
    echo.
    pause
    exit /b 1
)

echo Daily User:
echo.
echo     %DailyUser%
echo.

:: ------------------------------------------------------------
:: 6. PREVENT ITADMIN AS DAILY USER
:: ------------------------------------------------------------

if /I "%DailyUser%"=="ITAdmin" (
    echo [ERROR] ITAdmin cannot be the Daily User.
    echo.
    pause
    exit /b 1
)

:: ------------------------------------------------------------
:: 7. VERIFY DAILY USER ACCOUNT
:: ------------------------------------------------------------

echo [6] VERIFY DAILY USER ACCOUNT
echo ------------------------------------------------------------
echo.

net user "%DailyUser%" >nul 2>&1

if not "%errorlevel%"=="0" (
    echo [ERROR] The saved Daily User account does not exist.
    echo.
    echo Saved username:
    echo     %DailyUser%
    echo.
    pause
    exit /b 1
)

echo [OK] Daily User account exists.
echo.

:: ------------------------------------------------------------
:: 8. ENSURE DAILY USER IS ENABLED
:: ------------------------------------------------------------

echo [7] ENSURE DAILY USER IS ENABLED
echo ------------------------------------------------------------
echo.

net user "%DailyUser%" /active:yes >nul

if not "%errorlevel%"=="0" (
    echo [ERROR] Could not enable Daily User.
    echo.
    pause
    exit /b 1
)

echo [OK] Daily User account is enabled.
echo.

:: ------------------------------------------------------------
:: 9. ENSURE DAILY USER IS NOT HIDDEN
:: ------------------------------------------------------------

echo [8] ENSURE DAILY USER IS VISIBLE
echo ------------------------------------------------------------
echo.

reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /v "%DailyUser%" /f >nul 2>&1

echo [OK] Daily User sign-in visibility configuration checked.
echo.

:: ------------------------------------------------------------
:: 10. CHECK DAILY USER ADMINISTRATOR STATUS
:: ------------------------------------------------------------

echo [9] CHECK DAILY USER ADMINISTRATOR STATUS
echo ------------------------------------------------------------
echo.

powershell -NoProfile -Command ^
 "$group = (Get-LocalGroup -SID 'S-1-5-32-544').Name; $target = $env:DailyUser; $member = Get-LocalGroupMember -Group $group -ErrorAction SilentlyContinue | Where-Object { ($_.Name -split '\\')[-1] -eq $target }; if ($member) { exit 0 } else { exit 1 }"

if "%errorlevel%"=="0" (
    echo [INFO] Daily User is currently a member of Administrators.
    echo.
    goto REMOVE_DAILY_USER
)

echo [OK] Daily User is already not a member of Administrators.
echo [OK] Daily User is already a Standard User.
echo.
goto CONFIGURE_UAC

:: ------------------------------------------------------------
:: 11. REMOVE DAILY USER FROM ADMINISTRATORS
:: ------------------------------------------------------------

:REMOVE_DAILY_USER

echo [10] REMOVE DAILY USER FROM ADMINISTRATORS
echo ------------------------------------------------------------
echo.

echo Removing:
echo.
echo     %DailyUser%
echo.
echo from the local Administrators group.
echo.

powershell -NoProfile -Command ^
 "$group = (Get-LocalGroup -SID 'S-1-5-32-544').Name; Remove-LocalGroupMember -Group $group -Member $env:DailyUser -ErrorAction Stop"

if not "%errorlevel%"=="0" (
    echo.
    echo [ERROR] Failed to remove Daily User from Administrators.
    echo.
    goto FINAL_ERROR
)

echo.
echo [OK] Daily User removed from Administrators.
echo [OK] Daily User is now a Standard User.
echo.

:: ------------------------------------------------------------
:: 12. CONFIGURE UAC
:: ------------------------------------------------------------

:CONFIGURE_UAC

echo [11] CONFIGURE UAC
echo ------------------------------------------------------------
echo.

reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" ^
 /v ConsentPromptBehaviorUser /t REG_DWORD /d 1 /f

if not "%errorlevel%"=="0" (
    echo.
    echo [WARNING] Could not configure UAC behavior.
    echo.
) else (
    echo.
    echo [OK] Standard-user UAC credential prompting configured.
    echo.
)

:: ------------------------------------------------------------
:: 13. VERIFY DAILY USER STATUS
:: ------------------------------------------------------------

echo [12] VERIFY DAILY USER
echo ------------------------------------------------------------
echo.

echo Account information:
echo.

net user "%DailyUser%"

echo.

echo Checking Administrator membership...
echo.

powershell -NoProfile -Command ^
 "$group = (Get-LocalGroup -SID 'S-1-5-32-544').Name; $target = $env:DailyUser; $member = Get-LocalGroupMember -Group $group -ErrorAction SilentlyContinue | Where-Object { ($_.Name -split '\\')[-1] -eq $target }; if ($member) { Write-Host '[WARNING] Daily User is still an Administrator.' } else { Write-Host '[OK] Daily User is not a member of Administrators.' }"

echo.

:: ------------------------------------------------------------
:: 14. VERIFY ITADMIN
:: ------------------------------------------------------------

echo [13] VERIFY IT ADMINISTRATOR
echo ------------------------------------------------------------
echo.

powershell -NoProfile -Command ^
 "$group = (Get-LocalGroup -SID 'S-1-5-32-544').Name; $member = Get-LocalGroupMember -Group $group -ErrorAction SilentlyContinue | Where-Object { ($_.Name -split '\\')[-1] -eq 'ITAdmin' }; if ($member) { Write-Host '[OK] ITAdmin is a Local Administrator.' } else { Write-Host '[ERROR] ITAdmin is not a Local Administrator.' }"

echo.

:: ------------------------------------------------------------
:: 15. VERIFY UAC
:: ------------------------------------------------------------

echo [14] VERIFY UAC CONFIGURATION
echo ------------------------------------------------------------
echo.

reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" ^
 /v ConsentPromptBehaviorUser

echo.

:: ------------------------------------------------------------
:: 16. FINAL STATUS
:: ------------------------------------------------------------

echo ============================================================
echo              CONFIGURATION COMPLETE
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
echo     Role: Standard User
echo     Account: Enabled
echo.
echo UAC:
echo.
echo     Standard users require administrator credentials
echo     for administrator-level actions.
echo.
echo ============================================================
echo.
echo [C] Close
echo [R] Run configuration again
echo [S] Switch User
echo.

goto FINAL_MENU

:: ------------------------------------------------------------
:: FINAL ERROR
:: ------------------------------------------------------------

:FINAL_ERROR

echo ============================================================
echo              CONFIGURATION FAILED
echo ============================================================
echo.
echo The configuration did not complete successfully.
echo.
echo Review the error above.
echo.
echo [C] Close
echo [R] Run configuration again
echo [S] Switch User
echo.

:: ------------------------------------------------------------
:: FINAL MENU
:: ------------------------------------------------------------

:FINAL_MENU

choice /C CRS /N /M "Select an option [C/R/S]: "

if errorlevel 3 (
    echo.
    echo Switching User...
    echo.
    tsdiscon
    exit /b 0
)

if errorlevel 2 (
    goto START
)

if errorlevel 1 (
    echo.
    echo Closing Windows Configure IT Administrator...
    echo.
    endlocal
    exit /b 0
)

goto FINAL_MENU
