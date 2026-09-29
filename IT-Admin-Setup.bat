@echo off
setlocal EnableExtensions
color 02
title IT Admin Setup - CyberNexus PH

:: ============================================================
:: IT Admin Setup
:: Creates a dedicated IT administrator account and configures
:: the selected daily-use account as a Standard User.
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
echo Computer Name:
hostname
echo.
echo Current Account:
whoami
echo.
echo IPv4 Address:
ipconfig | findstr /i "IPv4"
echo.

:: ------------------------------------------------------------
:: 3. CREATE IT ADMIN ACCOUNT
:: ------------------------------------------------------------

echo [2] IT ADMINISTRATOR ACCOUNT
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

:: ------------------------------------------------------------
:: 4. ADD ITADMIN TO LOCAL ADMINISTRATORS
:: ------------------------------------------------------------

echo [3] IT ADMINISTRATOR PRIVILEGES
echo ------------------------------------------------------------

net localgroup Administrators ITAdmin >nul 2>&1

if "%errorlevel%"=="0" (
    echo [OK] ITAdmin is a member of Administrators.
) else (
    echo [WARNING] Could not add ITAdmin to Administrators.
)

echo.

:: ------------------------------------------------------------
:: 5. ASK FOR DAILY-USE ACCOUNT
:: ------------------------------------------------------------

echo [4] DAILY-USE WINDOWS ACCOUNT
echo ------------------------------------------------------------
echo.
echo Enter the Windows username that should be used for
echo normal daily work.
echo.
echo This account will be changed to a Standard User.
echo.
set /p "DailyUser=Daily-use username: "

if not defined DailyUser (
    echo.
    echo [ERROR] No username entered.
    pause
    exit /b 1
)

echo.

:: ------------------------------------------------------------
:: 6. VERIFY DAILY USER EXISTS
:: ------------------------------------------------------------

net user "%DailyUser%" >nul 2>&1

if not "%errorlevel%"=="0" (
    echo [ERROR] The account "%DailyUser%" does not exist.
    echo.
    pause
    exit /b 1
)

:: Prevent accidentally demoting ITAdmin
if /I "%DailyUser%"=="ITAdmin" (
    echo [ERROR] ITAdmin cannot be configured as the Standard User.
    echo.
    pause
    exit /b 1
)

:: ------------------------------------------------------------
:: 7. SHOW ACCOUNT BEFORE CHANGING IT
:: ------------------------------------------------------------

echo [5] VERIFY DAILY-USE ACCOUNT
echo ------------------------------------------------------------
echo.
net user "%DailyUser%"
echo.

echo ============================================================
echo WARNING
echo ============================================================
echo.
echo The account "%DailyUser%" will be removed from the
echo local Administrators group.
echo.
echo After this change:
echo.
echo   %DailyUser% = Standard User
echo   ITAdmin     = Local Administrator
echo.
echo Programs requiring administrator privileges will use
echo Windows UAC and require administrator credentials.
echo.
choice /C YN /N /M "Continue? [Y/N]: "

if errorlevel 2 (
    echo.
    echo [CANCELLED] No account changes were made.
    pause
    exit /b 0
)

echo.

:: ------------------------------------------------------------
:: 8. REMOVE DAILY USER FROM ADMINISTRATORS
:: ------------------------------------------------------------

echo [6] CONFIGURE STANDARD USER
echo ------------------------------------------------------------

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
:: 9. CONFIGURE UAC FOR STANDARD USERS
:: ------------------------------------------------------------

echo [7] CONFIGURE UAC
echo ------------------------------------------------------------

echo.
echo Configuring UAC to request administrator credentials
echo for standard users...

reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" ^
 /v ConsentPromptBehaviorUser /t REG_DWORD /d 1 /f >nul

if "%errorlevel%"=="0" (
    echo [OK] Standard-user UAC credential prompt configured.
) else (
    echo [WARNING] Could not configure UAC behavior.
)

echo.

:: ------------------------------------------------------------
:: 10. ENABLE POWERSHELL REMOTING
:: ------------------------------------------------------------

echo [8] ENABLE POWERSHELL REMOTING
echo ------------------------------------------------------------

powershell -NoProfile -ExecutionPolicy Bypass -Command "Enable-PSRemoting -Force"

if "%errorlevel%"=="0" (
    echo [OK] PowerShell Remoting configured.
) else (
    echo [WARNING] PowerShell Remoting returned an error.
)

echo.

:: ------------------------------------------------------------
:: 11. ENABLE WINRM FIREWALL RULES
:: ------------------------------------------------------------

echo [9] CONFIGURE WINRM FIREWALL
echo ------------------------------------------------------------

powershell -NoProfile -ExecutionPolicy Bypass -Command "Enable-NetFirewallRule -DisplayGroup 'Windows Remote Management'"

if "%errorlevel%"=="0" (
    echo [OK] Windows Remote Management firewall rules enabled.
) else (
    echo [WARNING] Could not enable WinRM firewall rules.
)

echo.

:: ------------------------------------------------------------
:: 12. VERIFY ITADMIN
:: ------------------------------------------------------------

echo [10] VERIFY IT ADMIN
echo ------------------------------------------------------------

net user ITAdmin

echo.

:: ------------------------------------------------------------
:: 13. VERIFY DAILY USER
:: ------------------------------------------------------------

echo [11] VERIFY DAILY USER
echo ------------------------------------------------------------

net user "%DailyUser%"

echo.

:: ------------------------------------------------------------
:: 14. VERIFY ADMINISTRATORS GROUP
:: ------------------------------------------------------------

echo [12] VERIFY ADMINISTRATORS GROUP
echo ------------------------------------------------------------

net localgroup Administrators

echo.

:: ------------------------------------------------------------
:: 15. VERIFY WINRM
:: ------------------------------------------------------------

echo [13] VERIFY WINRM
echo ------------------------------------------------------------

winrm get winrm/config

echo.

:: ------------------------------------------------------------
:: 16. FINAL STATUS
:: ------------------------------------------------------------

echo ============================================================
echo                    SETUP COMPLETE
echo ============================================================
echo.
echo IT Administrator:
echo     ITAdmin
echo.
echo Daily-use account:
echo     %DailyUser%
echo.
echo Account structure:
echo.
echo     ITAdmin
echo       ^|-- Local Administrator
echo       ^|-- IT maintenance / administration
echo.
echo     %DailyUser%
echo       ^|-- Standard User
echo       ^|-- Normal daily computer use
echo.
echo UAC:
echo     Administrator credentials required for
echo     administrator-level actions.
echo.
echo Remote Administration:
echo     PowerShell Remoting / WinRM
echo.
echo IMPORTANT:
echo This utility must only be used on computers that you
echo own or are explicitly authorized to administer.
echo.
echo A restart or sign-out may be required before all
echo account and UAC changes are fully reflected.
echo.
pause

endlocal
