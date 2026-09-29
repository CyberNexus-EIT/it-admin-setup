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
::   - Verifies ITAdmin exists.
::   - Verifies ITAdmin is a Local Administrator.
::   - Loads the Daily User saved by the first program.
::   - Removes the Daily User from the local Administrators group.
::   - Configures UAC for Standard Users.
::   - Verifies the resulting configuration.
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
:: 2. CHECK CURRENT WINDOWS USER
:: ------------------------------------------------------------

echo [1] CHECK CURRENT WINDOWS USER
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

echo [2] VERIFY IT ADMINISTRATOR
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

:: ------------------------------------------------------------
:: 4. VERIFY ITADMIN ADMINISTRATOR MEMBERSHIP
:: ------------------------------------------------------------

echo Checking local Administrators group...
echo.

powershell -NoProfile -Command ^
 "$group = (Get-LocalGroup -SID 'S-1-5-32-544').Name; $member = Get-LocalGroupMember -Group $group -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '\\ITAdmin$' }; if ($member) { exit 0 } else { exit 1 }"

if not "%errorlevel%"=="0" (
    echo [ERROR] ITAdmin is not a member of the local Administrators group.
    echo.
    pause
    exit /b 1
)

echo [OK] ITAdmin is a Local Administrator.
echo.

:: ------------------------------------------------------------
:: 5. LOAD DAILY USER CONFIGURATION
:: ------------------------------------------------------------

echo [3] LOAD DAILY USER CONFIGURATION
echo ------------------------------------------------------------
echo.

set "ConfigDir=%ProgramData%\CyberNexus\IT-Admin-Setup"
set "DailyUserFile=%ConfigDir%\DailyUser.txt"

if not exist "%DailyUserFile%" (
    echo [ERROR] Daily User configuration was not found.
    echo.
    echo Expected file:
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

echo Daily User detected:
echo.
echo     %DailyUser%
echo.

:: ------------------------------------------------------------
:: 6. PREVENT ITADMIN FROM BEING DEMOTED
:: ------------------------------------------------------------

if /I "%DailyUser%"=="ITAdmin" (
    echo [ERROR] ITAdmin cannot be configured as the Daily User.
    echo.
    pause
    exit /b 1
)

:: ------------------------------------------------------------
:: 7. VERIFY DAILY USER
:: ------------------------------------------------------------

echo [4] VERIFY DAILY USER
echo ------------------------------------------------------------
echo.

net user "%DailyUser%" >nul 2>&1

if not "%errorlevel%"=="0" (
    echo [ERROR] The saved Daily User does not exist.
    echo.
    pause
    exit /b 1
)

echo [OK] Daily User account exists.
echo.

:: ------------------------------------------------------------
:: 8. DISPLAY DAILY USER
:: ------------------------------------------------------------

echo [5] DAILY USER ACCOUNT
echo ------------------------------------------------------------
echo.

net user "%DailyUser%"

echo.

:: ------------------------------------------------------------
:: 9. CHECK WHETHER DAILY USER IS ALREADY STANDARD
:: ------------------------------------------------------------

echo [6] CHECK DAILY USER ADMINISTRATOR STATUS
echo ------------------------------------------------------------
echo.

powershell -NoProfile -Command ^
 "$group = (Get-LocalGroup -SID 'S-1-5-32-544').Name; $member = Get-LocalGroupMember -Group $group -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '\\%DailyUser%$' }; if ($member) { exit 0 } else { exit 1 }"

if "%errorlevel%"=="0" (
    echo [INFO] %DailyUser% is currently a member of Administrators.
    echo.
    goto REMOVE_DAILY_USER_ADMIN
)

echo [OK] %DailyUser% is already not a member of Administrators.
echo [OK] %DailyUser% is configured as a Standard User.
echo.
goto CONFIGURE_UAC

:: ------------------------------------------------------------
:: 10. REMOVE DAILY USER FROM ADMINISTRATORS
:: ------------------------------------------------------------

:REMOVE_DAILY_USER_ADMIN

echo [7] CONFIGURE DAILY USER AS STANDARD USER
echo ------------------------------------------------------------
echo.

echo Removing:
echo.
echo     %DailyUser%
echo.
echo from the local Administrators group.
echo.

powershell -NoProfile -Command ^
 "$group = (Get-LocalGroup -SID 'S-1-5-32-544').Name; Remove-LocalGroupMember -Group $group -Member '%DailyUser%' -ErrorAction Stop"

if not "%errorlevel%"=="0" (
    echo.
    echo [ERROR] Failed to remove %DailyUser% from Administrators.
    echo.
    echo The configuration was not completed.
    echo.
    goto FINAL_ERROR
)

echo.
echo [OK] %DailyUser% removed from Administrators.
echo.
echo [OK] %DailyUser% is now a Standard User.
echo.

:: ------------------------------------------------------------
:: 11. CONFIGURE UAC
:: ------------------------------------------------------------

:CONFIGURE_UAC

echo [8] CONFIGURE UAC
echo ------------------------------------------------------------
echo.

echo Configuring UAC for Standard Users...
echo.

reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" ^
 /v ConsentPromptBehaviorUser /t REG_DWORD /d 1 /f

if not "%errorlevel%"=="0" (
    echo.
    echo [WARNING] Could not configure UAC behavior.
    echo.
) else (
    echo.
    echo [OK] Standard-user UAC credential prompt configured.
    echo.
)

:: ------------------------------------------------------------
:: 12. VERIFY ITADMIN
:: ------------------------------------------------------------

echo [9] VERIFY IT ADMINISTRATOR
echo ------------------------------------------------------------
echo.

echo ITAdmin membership:
echo.

powershell -NoProfile -Command ^
 "$group = (Get-LocalGroup -SID 'S-1-5-32-544').Name; Get-LocalGroupMember -Group $group | Where-Object { $_.Name -match '\\ITAdmin$' }"

echo.

:: ------------------------------------------------------------
:: 13. VERIFY DAILY USER
:: ------------------------------------------------------------

echo [10] VERIFY DAILY USER
echo ------------------------------------------------------------
echo.

net user "%DailyUser%"

echo.

:: ------------------------------------------------------------
:: 14. VERIFY ADMINISTRATORS GROUP
:: ------------------------------------------------------------

echo [11] VERIFY ADMINISTRATORS GROUP
echo ------------------------------------------------------------
echo.

powershell -NoProfile -Command ^
 "$group = (Get-LocalGroup -SID 'S-1-5-32-544').Name; Get-LocalGroupMember -Group $group"

echo.

:: ------------------------------------------------------------
:: 15. VERIFY UAC
:: ------------------------------------------------------------

echo [12] VERIFY UAC CONFIGURATION
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
echo.
echo UAC:
echo.
echo     Standard users require administrator credentials
echo     for administrator-level actions.
echo.
echo ============================================================
echo.
echo Setup has finished.
echo.
echo [C] Close
echo [R] Run configuration again
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
echo.

:: ------------------------------------------------------------
:: FINAL MENU
:: ------------------------------------------------------------

:FINAL_MENU

choice /C CR /N /M "Select an option [C/R]: "

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
