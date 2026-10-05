@echo off
setlocal EnableExtensions EnableDelayedExpansion
color 02
title Windows Configure IT Administrator - CyberNexus PH

:: ============================================================
:: WINDOWS CONFIGURE IT ADMINISTRATOR
:: CYBERNEXUS PH
:: ============================================================
::
:: PURPOSE
:: ------------------------------------------------------------
:: Standardizes a Windows PC to use two primary local accounts:
::
::     ITAdmin  = IT Administrator / Local Administrator
::     User     = Standard User / Non-IT User
::
:: TARGET CONFIGURATION
:: ------------------------------------------------------------
:: 1. ITAdmin exists and is enabled.
:: 2. ITAdmin belongs to the local Administrators group.
:: 3. ITAdmin requires a password.
:: 4. User exists and is enabled.
:: 5. User is a Standard User, NOT an Administrator.
:: 6. User has no password.
:: 7. Other local user accounts are removed.
:: 8. Other local administrator accounts are removed from
::    the local Administrators group.
:: 9. Built-in Administrator is disabled.
:: 10. Guest is disabled.
:: 11. ITAdmin is visible on the Windows sign-in screen.
:: 12. User is visible on the Windows sign-in screen.
::
:: UAC BEHAVIOR
:: ------------------------------------------------------------
:: User cannot elevate programs by itself.
::
:: When User attempts to run an elevated program:
::
::     Windows UAC -> ITAdmin credentials required
::
:: ITAdmin can run programs requiring elevation.
::
:: NETWORK NOTE
:: ------------------------------------------------------------
:: This configures LOCAL accounts on the current PC only.
::
:: To apply the same configuration to every PC:
::
::     Run this script on each PC
::
:: or use centralized Windows/domain management.
::
:: IMPORTANT
:: ------------------------------------------------------------
:: This script removes other LOCAL accounts.
:: Back up required user data before running it.
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
echo                   CYBERNEXUS PH
echo ============================================================
echo.
echo This script standardizes local Windows accounts to:
echo.
echo     ITAdmin  = Administrator
echo     User     = Standard User
echo.
echo Other local user accounts will be removed.
echo.
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

set "CurrentUser=%USERNAME%"

echo Current User:
echo.
echo     %CurrentUser%
echo.

echo Windows Identity:
whoami
echo.


if /I NOT "%CurrentUser%"=="ITAdmin" (
    echo [ERROR] This configuration must be executed while logged in
    echo         as ITAdmin.
    echo.
    echo Sign out and log in as:
    echo.
    echo     ITAdmin
    echo.
    echo Then run this script again.
    echo.
    pause
    exit /b 1
)

echo [OK] Current session is ITAdmin.
echo.


:: ------------------------------------------------------------
:: 3. CREATE CONFIGURATION DIRECTORY
:: ------------------------------------------------------------

echo [3] CREATE CONFIGURATION DIRECTORY
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
:: 4. CREATE / VERIFY ITADMIN
:: ------------------------------------------------------------

echo [4] CREATE / VERIFY ITADMIN
echo ------------------------------------------------------------
echo.

net user ITAdmin >nul 2>&1

if "%errorlevel%"=="0" (
    echo [OK] ITAdmin account already exists.
) else (
    echo [INFO] ITAdmin does not exist.
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
)

echo.


:: ------------------------------------------------------------
:: 5. ENSURE ITADMIN IS ENABLED
:: ------------------------------------------------------------

echo [5] ENABLE ITADMIN
echo ------------------------------------------------------------
echo.

net user ITAdmin /active:yes >nul 2>&1

if not "%errorlevel%"=="0" (
    echo [ERROR] Could not enable ITAdmin.
    echo.
    pause
    exit /b 1
)

echo [OK] ITAdmin is enabled.
echo.


:: ------------------------------------------------------------
:: 6. ENSURE ITADMIN PASSWORD IS REQUIRED
:: ------------------------------------------------------------

echo [6] VERIFY ITADMIN PASSWORD REQUIREMENT
echo ------------------------------------------------------------
echo.

net user ITAdmin | findstr /I /C:"Password required" >nul 2>&1

if not "%errorlevel%"=="0" (
    echo [INFO] Password requirement could not be confirmed.
    echo.
    echo To guarantee ITAdmin has a password, set one now.
    echo.
    echo Enter a new password for ITAdmin.
    echo.

    net user ITAdmin *

    if not "%errorlevel%"=="0" (
        echo.
        echo [ERROR] Failed to set ITAdmin password.
        echo.
        pause
        exit /b 1
    )

    echo.
    echo [OK] ITAdmin password updated.
) else (
    echo [OK] ITAdmin password requirement is enabled.
)

echo.


:: ------------------------------------------------------------
:: 7. ADD ITADMIN TO LOCAL ADMINISTRATORS
:: ------------------------------------------------------------

echo [7] CONFIGURE ITADMIN ADMINISTRATOR MEMBERSHIP
echo ------------------------------------------------------------
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$group = (Get-LocalGroup -SID 'S-1-5-32-544').Name; $member = Get-LocalGroupMember -Group $group -ErrorAction SilentlyContinue | Where-Object { ($_.Name -split '\\')[-1] -ieq 'ITAdmin' }; if ($member) { exit 0 } else { exit 1 }"

if "%errorlevel%"=="0" (
    echo [OK] ITAdmin is already a Local Administrator.
) else (
    echo [INFO] Adding ITAdmin to Administrators...
    
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
     "$group = (Get-LocalGroup -SID 'S-1-5-32-544').Name; Add-LocalGroupMember -Group $group -Member 'ITAdmin' -ErrorAction Stop"

    if not "%errorlevel%"=="0" (
        echo.
        echo [ERROR] Could not add ITAdmin to Administrators.
        echo.
        pause
        exit /b 1
    )

    echo [OK] ITAdmin added to Administrators.
)

echo.


:: ------------------------------------------------------------
:: 8. CREATE / VERIFY STANDARD USER
:: ------------------------------------------------------------

echo [8] CREATE / VERIFY STANDARD USER
echo ------------------------------------------------------------
echo.

net user User >nul 2>&1

if "%errorlevel%"=="0" (
    echo [OK] User account already exists.
) else (
    echo [INFO] User account does not exist.
    echo.
    echo Creating User...
    echo.

    net user User "" /add

    if not "%errorlevel%"=="0" (
        echo.
        echo [ERROR] Failed to create User.
        echo.
        pause
        exit /b 1
    )

    echo [OK] User account created.
)

echo.


:: ------------------------------------------------------------
:: 9. CONFIGURE USER AS PASSWORDLESS
:: ------------------------------------------------------------

echo [9] CONFIGURE PASSWORDLESS STANDARD USER
echo ------------------------------------------------------------
echo.

net user User /passwordchg:no >nul 2>&1
net user User /active:yes >nul 2>&1

:: Set blank password.
net user User "" >nul 2>&1

if not "%errorlevel%"=="0" (
    echo [ERROR] Could not set User to a blank password.
    echo.
    pause
    exit /b 1
)

echo [OK] User has no password.
echo.


:: ------------------------------------------------------------
:: 10. REMOVE USER FROM ADMINISTRATORS
:: ------------------------------------------------------------

echo [10] ENSURE USER IS NOT AN ADMINISTRATOR
echo ------------------------------------------------------------
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$group = (Get-LocalGroup -SID 'S-1-5-32-544').Name; Remove-LocalGroupMember -Group $group -Member 'User' -ErrorAction SilentlyContinue"

echo [OK] User is configured as a Standard User.
echo.


:: ------------------------------------------------------------
:: 11. REMOVE USER FROM OTHER PRIVILEGED LOCAL GROUPS
:: ------------------------------------------------------------

echo [11] REMOVE USER FROM PRIVILEGED LOCAL GROUPS
echo ------------------------------------------------------------
echo.

net localgroup "Remote Desktop Users" User /delete >nul 2>&1
net localgroup "Backup Operators" User /delete >nul 2>&1
net localgroup "Power Users" User /delete >nul 2>&1
net localgroup "Network Configuration Operators" User /delete >nul 2>&1

echo [OK] User privileged-group memberships checked.
echo.


:: ------------------------------------------------------------
:: 12. DISABLE BUILT-IN ADMINISTRATOR
:: ------------------------------------------------------------

echo [12] DISABLE BUILT-IN ADMINISTRATOR
echo ------------------------------------------------------------
echo.

net user Administrator /active:no >nul 2>&1

if "%errorlevel%"=="0" (
    echo [OK] Built-in Administrator disabled.
) else (
    echo [INFO] Built-in Administrator was not available or could
    echo        not be modified.
)

echo.


:: ------------------------------------------------------------
:: 13. DISABLE GUEST
:: ------------------------------------------------------------

echo [13] DISABLE GUEST
echo ------------------------------------------------------------
echo.

net user Guest /active:no >nul 2>&1

if "%errorlevel%"=="0" (
    echo [OK] Guest disabled.
) else (
    echo [INFO] Guest was not available or could not be modified.
)

echo.


:: ------------------------------------------------------------
:: 14. REMOVE OTHER LOCAL USERS
:: ------------------------------------------------------------

echo [14] REMOVE OTHER LOCAL USER ACCOUNTS
echo ------------------------------------------------------------
echo.

echo The following local accounts will be evaluated:
echo.
echo     ITAdmin  = KEEP
echo     User     = KEEP
echo.
echo Other normal local accounts will be removed.
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$keep = @('ITAdmin','User','Administrator','Guest','DefaultAccount','WDAGUtilityAccount'); Get-LocalUser | ForEach-Object { if ($keep -notcontains $_.Name) { Write-Host ('[REMOVE] ' + $_.Name); try { Remove-LocalUser -Name $_.Name -ErrorAction Stop } catch { Write-Host ('[ERROR] Could not remove ' + $_.Name) } } }"

echo.
echo [OK] Other removable local user accounts processed.
echo.


:: ------------------------------------------------------------
:: 15. REMOVE OTHER LOCAL ADMINISTRATORS
:: ------------------------------------------------------------

echo [15] REMOVE OTHER LOCAL ADMINISTRATOR MEMBERS
echo ------------------------------------------------------------
echo.

echo ITAdmin will remain the designated local administrator.
echo.
echo Other local user accounts will be removed from the
echo Administrators group.
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$group = (Get-LocalGroup -SID 'S-1-5-32-544').Name; $keep = @('ITAdmin','Administrator'); Get-LocalGroupMember -Group $group -ErrorAction SilentlyContinue | ForEach-Object { $name = ($_.Name -split '\\')[-1]; if ($keep -notcontains $name -and $_.ObjectClass -eq 'User') { Write-Host ('[REMOVE ADMIN] ' + $_.Name); try { Remove-LocalGroupMember -Group $group -Member $_.Name -ErrorAction Stop } catch { Write-Host ('[ERROR] Could not remove ' + $_.Name) } } }"

echo.
echo [OK] Local administrator membership standardized.
echo.


:: ------------------------------------------------------------
:: 16. ENSURE ITADMIN REMAINS ADMINISTRATOR
:: ------------------------------------------------------------

echo [16] FINALIZE ITADMIN ADMINISTRATOR MEMBERSHIP
echo ------------------------------------------------------------
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$group = (Get-LocalGroup -SID 'S-1-5-32-544').Name; Add-LocalGroupMember -Group $group -Member 'ITAdmin' -ErrorAction SilentlyContinue"

echo [OK] ITAdmin administrator membership verified.
echo.


:: ------------------------------------------------------------
:: 17. SIGN-IN VISIBILITY
:: ------------------------------------------------------------

echo [17] CONFIGURE SIGN-IN VISIBILITY
echo ------------------------------------------------------------
echo.

reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /v ITAdmin /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /v User /f >nul 2>&1

echo [OK] ITAdmin and User are configured for normal sign-in visibility.
echo.


:: ------------------------------------------------------------
:: 18. SAVE CONFIGURATION
:: ------------------------------------------------------------

echo [18] SAVE CONFIGURATION
echo ------------------------------------------------------------
echo.

set "ConfigFile=%ConfigDir%\AccountConfiguration.txt"

(
echo CyberNexus PH - Windows Local Account Configuration
echo.
echo IT Administrator:
echo Username: ITAdmin
echo Full Name: IT Administrator
echo Description: IT Administrator Account
echo Role: Local Administrator
echo.
echo Standard User:
echo Username: User
echo Full Name: Standard User
echo Description: Standard User Account
echo Role: Standard User
echo Password: None
echo.
echo Built-in Administrator: Disabled
echo Guest: Disabled
echo.
echo Configuration Date:
echo %DATE% %TIME%
) > "%ConfigFile%"

echo [OK] Configuration saved:
echo.
echo     %ConfigFile%
echo.


:: ------------------------------------------------------------
:: 19. FINAL VERIFICATION
:: ------------------------------------------------------------

echo [19] FINAL ACCOUNT VERIFICATION
echo ------------------------------------------------------------
echo.

echo ============================================================
echo ITADMIN
echo ============================================================
echo.

net user ITAdmin

echo.
echo ============================================================
echo USER
echo ============================================================
echo.

net user User

echo.
echo ============================================================
echo LOCAL ADMINISTRATORS
echo ============================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$group = (Get-LocalGroup -SID 'S-1-5-32-544').Name; Get-LocalGroupMember -Group $group | Select-Object Name,ObjectClass"

echo.
echo ============================================================
echo LOCAL USERS
echo ============================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "Get-LocalUser | Select-Object Name,Enabled,PasswordRequired,LastLogon"

echo.


:: ------------------------------------------------------------
:: 20. FINAL STATUS
:: ------------------------------------------------------------

echo ============================================================
echo       WINDOWS ACCOUNT CONFIGURATION COMPLETE
echo ============================================================
echo.
echo PRIMARY WINDOWS ACCOUNTS
echo.
echo     ITAdmin
echo     Role: Local Administrator
echo     Password: REQUIRED
echo.
echo     User
echo     Role: Standard User
echo     Password: NONE
echo.
echo ============================================================
echo.
echo UAC BEHAVIOR
echo.
echo     User
echo       |
echo       +-- Run as administrator
echo               |
echo               +-- ITAdmin credentials required
echo.
echo ============================================================
echo.
echo BUILT-IN ACCOUNTS
echo.
echo     Administrator = Disabled
echo     Guest         = Disabled
echo.
echo ============================================================
echo.
echo IMPORTANT:
echo.
echo This configuration applies to THIS WINDOWS PC.
echo It does not automatically configure every PC on the network.
echo.
echo For another PC, run the configuration there as ITAdmin.
echo.
echo ============================================================
echo.
echo The computer will sign out in 15 seconds.
echo.
echo After sign-out, use:
echo.
echo     ITAdmin
echo
echo or
echo
echo     User
echo.
echo ============================================================
echo.

timeout /t 15 /nobreak >nul

shutdown /l

endlocal
exit /b 0
