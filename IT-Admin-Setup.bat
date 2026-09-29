@echo off
setlocal EnableExtensions
color 02
title IT Admin Setup - CyberNexus PH

:: ============================================================
:: IT ADMIN SETUP
:: ============================================================
:: Creates a dedicated IT administrator account and configures
:: the currently logged-in Windows account as a Standard User.
::
:: IT Administrator Account:
::     ITAdmin
::
:: Daily-use Account:
::     Automatically detected using %USERNAME%.
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
    echo                    IT ADMIN SETUP
    echo                     CYBERNEXUS PH
    echo ============================================================
    echo.
    echo [ERROR] Administrator privileges are required.
    echo.
    echo Right-click this file and select:
    echo.
    echo     Run as administrator
    echo.
    echo The window will remain open.
    echo.
    pause
    exit /b 1
)


:: ============================================================
:: START SETUP
:: ============================================================

:START_SETUP

cls

echo ============================================================
echo                    IT ADMIN SETUP
echo                     CYBERNEXUS PH
echo ============================================================
echo.


:: ------------------------------------------------------------
:: 2. COMPUTER INFORMATION
:: ------------------------------------------------------------

echo [1] COMPUTER INFORMATION
echo ------------------------------------------------------------
echo.

echo Computer Name:
hostname

echo.
echo Current Windows Account:
echo     %USERNAME%

echo.
echo Full Windows Identity:
whoami

echo.
echo IPv4 Address:
ipconfig | findstr /i "IPv4"

echo.


:: ------------------------------------------------------------
:: 3. AUTOMATICALLY DETECT CURRENT DAILY-USE ACCOUNT
:: ------------------------------------------------------------

echo [2] DETECT DAILY-USE WINDOWS ACCOUNT
echo ------------------------------------------------------------
echo.

set "DailyUser=%USERNAME%"

if not defined DailyUser (
    echo [ERROR] Could not detect the current Windows username.
    echo.
    echo The setup cannot continue.
    echo.
    goto FINAL_ERROR
)

echo Current Windows user detected:
echo.
echo     %DailyUser%
echo.


:: ------------------------------------------------------------
:: 4. CREATE IT ADMINISTRATOR ACCOUNT
:: ------------------------------------------------------------

echo [3] IT ADMINISTRATOR ACCOUNT
echo ------------------------------------------------------------
echo.

echo Dedicated IT administrator account:
echo.
echo     ITAdmin
echo.
echo The password will be entered interactively.
echo The password is NOT stored in this script.
echo.

net user ITAdmin >nul 2>&1

if "%errorlevel%"=="0" (
    echo [INFO] ITAdmin already exists.
) else (
    echo Creating ITAdmin...
    echo.

    net user ITAdmin * /add

    if not "%errorlevel%"=="0" (
        echo.
        echo [ERROR] Failed to create ITAdmin.
        echo.
        goto FINAL_ERROR
    )

    echo.
    echo [OK] ITAdmin account created.
)

echo.


:: ------------------------------------------------------------
:: 5. ADD ITADMIN TO LOCAL ADMINISTRATORS
:: ------------------------------------------------------------

echo [4] IT ADMINISTRATOR PRIVILEGES
echo ------------------------------------------------------------
echo.

net localgroup Administrators ITAdmin >nul 2>&1

if "%errorlevel%"=="0" (
    echo [OK] ITAdmin is a member of Administrators.
) else (
    echo [WARNING] Could not add ITAdmin to Administrators.
)

echo.


:: ------------------------------------------------------------
:: 6. PREVENT ACCIDENTAL DEMOTION OF ITADMIN
:: ------------------------------------------------------------

if /I "%DailyUser%"=="ITAdmin" (
    echo ============================================================
    echo [ERROR]
    echo ============================================================
    echo.
    echo The currently logged-in account is ITAdmin.
    echo.
    echo ITAdmin must remain a Local Administrator.
    echo The account will NOT be changed to Standard User.
    echo.
    goto FINAL_ERROR
)


:: ------------------------------------------------------------
:: 7. VERIFY CURRENT DAILY-USE ACCOUNT
:: ------------------------------------------------------------

echo [5] VERIFY DAILY-USE ACCOUNT
echo ------------------------------------------------------------
echo.

echo Account automatically selected as Standard User:
echo.
echo     %DailyUser%
echo.

net user "%DailyUser%" >nul 2>&1

if not "%errorlevel%"=="0" (
    echo [ERROR] The detected account does not exist.
    echo.
    goto FINAL_ERROR
)

net user "%DailyUser%"

echo.


:: ------------------------------------------------------------
:: 8. CONFIRM ACCOUNT CHANGE
:: ------------------------------------------------------------

echo ============================================================
echo WARNING
echo ============================================================
echo.
echo The currently logged-in account:
echo.
echo     %DailyUser%
echo.
echo will be removed from the local Administrators group.
echo.
echo After the change:
echo.
echo     ITAdmin     = Local Administrator
echo     %DailyUser% = Standard User
echo.
echo Administrator-level programs will require
echo IT administrator credentials through UAC.
echo.

choice /C YN /N /M "Continue? [Y/N]: "

if errorlevel 2 (
    echo.
    echo [CANCELLED] No account changes were made.
    echo.
    goto FINAL_MENU
)

echo.


:: ------------------------------------------------------------
:: 9. REMOVE DAILY USER FROM ADMINISTRATORS
:: ------------------------------------------------------------

echo [6] CONFIGURE STANDARD USER
echo ------------------------------------------------------------
echo.

net localgroup Administrators "%DailyUser%" /delete

if not "%errorlevel%"=="0" (
    echo.
    echo [WARNING] Could not remove "%DailyUser%" from
    echo Administrators.
    echo.
) else (
    echo [OK] "%DailyUser%" is now a Standard User.
)

echo.


:: ------------------------------------------------------------
:: 10. CONFIGURE UAC
:: ------------------------------------------------------------

echo [7] CONFIGURE UAC
echo ------------------------------------------------------------
echo.

echo Configuring UAC to request administrator credentials
echo for Standard Users...

reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" ^
 /v ConsentPromptBehaviorUser /t REG_DWORD /d 1 /f >nul

if "%errorlevel%"=="0" (
    echo [OK] Standard-user UAC credential prompt configured.
) else (
    echo [WARNING] Could not configure UAC behavior.
)

echo.


:: ------------------------------------------------------------
:: 11. ENABLE POWERSHELL REMOTING
:: ------------------------------------------------------------

echo [8] ENABLE POWERSHELL REMOTING
echo ------------------------------------------------------------
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "Enable-PSRemoting -Force"

if "%errorlevel%"=="0" (
    echo [OK] PowerShell Remoting configured.
) else (
    echo [WARNING] PowerShell Remoting returned an error.
)

echo.


:: ------------------------------------------------------------
:: 12. CONFIGURE WINRM FIREWALL
:: ------------------------------------------------------------

echo [9] CONFIGURE WINRM FIREWALL
echo ------------------------------------------------------------
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "Enable-NetFirewallRule -DisplayGroup 'Windows Remote Management'"

if "%errorlevel%"=="0" (
    echo [OK] Windows Remote Management firewall rules enabled.
) else (
    echo [WARNING] Could not enable WinRM firewall rules.
)

echo.


:: ------------------------------------------------------------
:: 13. VERIFY ITADMIN ACCOUNT
:: ------------------------------------------------------------

echo [10] VERIFY IT ADMIN
echo ------------------------------------------------------------
echo.

net user ITAdmin

echo.


:: ------------------------------------------------------------
:: 14. VERIFY DAILY USER
:: ------------------------------------------------------------

echo [11] VERIFY DAILY USER
echo ------------------------------------------------------------
echo.

net user "%DailyUser%"

echo.


:: ------------------------------------------------------------
:: 15. VERIFY ADMINISTRATORS GROUP
:: ------------------------------------------------------------

echo [12] VERIFY ADMINISTRATORS GROUP
echo ------------------------------------------------------------
echo.

net localgroup Administrators

echo.


:: ------------------------------------------------------------
:: 16. VERIFY UAC CONFIGURATION
:: ------------------------------------------------------------

echo [13] VERIFY UAC CONFIGURATION
echo ------------------------------------------------------------
echo.

reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" ^
 /v ConsentPromptBehaviorUser

echo.


:: ------------------------------------------------------------
:: 17. VERIFY WINRM
:: ------------------------------------------------------------

echo [14] VERIFY WINRM
echo ------------------------------------------------------------
echo.

winrm get winrm/config

echo.


:: ------------------------------------------------------------
:: 18. FINAL STATUS
:: ------------------------------------------------------------

echo ============================================================
echo                    SETUP COMPLETE
echo ============================================================
echo.

echo IT Administrator:
echo.
echo     ITAdmin
echo     Role: Local Administrator
echo.

echo Daily-use Account:
echo.
echo     %DailyUser%
echo     Role: Standard User
echo.

echo Account Structure:
echo.
echo     ITAdmin
echo       ^|-- Local Administrator
echo       ^|-- IT maintenance
echo       ^|-- System administration
echo       ^|-- UAC elevation
echo.
echo     %DailyUser%
echo       ^|-- Standard User
echo       ^|-- Normal daily computer use
echo.

echo UAC:
echo.
echo     Administrator credentials are required for
echo     administrator-level actions by Standard Users.
echo.

echo Remote Administration:
echo.
echo     PowerShell Remoting / WinRM
echo.

echo ============================================================
echo.
echo The setup has finished.
echo.
echo This window will remain open until you choose an option.
echo.
echo [C] Close
echo [R] Run setup again
echo.

goto FINAL_MENU


:: ============================================================
:: FINAL ERROR
:: ============================================================

:FINAL_ERROR

echo ============================================================
echo                    SETUP STOPPED
echo ============================================================
echo.
echo The setup could not complete successfully.
echo.
echo Review the message above for the reason.
echo.
echo The window will remain open.
echo.
echo [C] Close
echo [R] Run setup again
echo.

goto FINAL_MENU


:: ============================================================
:: FINAL MENU
:: ============================================================

:FINAL_MENU

choice /C CR /N /M "Select an option [C/R]: "

if errorlevel 2 (
    echo.
    echo ============================================================
    echo                    RUNNING AGAIN
    echo ============================================================
    echo.
    goto START_SETUP
)

if errorlevel 1 (
    echo.
    echo Closing IT Admin Setup...
    echo.
    endlocal
    exit /b 0
)

goto FINAL_MENU
