@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Network Share - Admin Setup
color 0A

rem ============================================================
rem
rem  NETWORK SHARE - ADMIN SETUP
rem
rem  File:
rem      01-Network-Share-Setup.bat
rem
rem  Purpose:
rem      Configure and validate the Administration PC for:
rem
rem        D:\IT-Admin
rem        D:\AdminConsole
rem        D:\Share
rem        ShareUser
rem        Windows SMB Share
rem        Windows WinRM
rem
rem  Standard Hostname:
rem      IT-SERVER
rem
rem ============================================================
rem
rem  SAFETY / PRESERVATION POLICY
rem
rem    1. Existing folders are NEVER deleted.
rem    2. Existing files are NEVER deleted.
rem    3. Existing D:\Share contents are NEVER moved.
rem    4. D:\Share\Client is NEVER created by this script.
rem    5. Existing SMB Share is NEVER deleted/recreated.
rem    6. Existing ShareUser password is NEVER changed.
rem    7. Existing D:\IT-Admin contents are PRESERVED.
rem    8. Existing D:\AdminConsole contents are PRESERVED.
rem    9. NTFS permissions are NOT automatically modified.
rem   10. No Administrator password is stored.
rem   11. No ShareUser password is stored.
rem   12. WinRM changes require explicit user confirmation.
rem   13. Security checks are READ-ONLY.
rem   14. Troubleshooting is READ-ONLY.
rem   15. No automatic firewall hardening is performed.
rem   16. No automatic SMB permission hardening is performed.
rem   17. No automatic hostname change is performed.
rem   18. Normal operation does NOT close the console.
rem   19. Exit requires explicit Y/N confirmation.
rem
rem ============================================================


rem ============================================================
rem PATH CONFIGURATION
rem ============================================================

set "ITAdmin=D:\IT-Admin"
set "AdminConsole=D:\AdminConsole"
set "SharePath=D:\Share"

set "Installers=%ITAdmin%\Installers"
set "Drivers=%ITAdmin%\Drivers"
set "Setup=%ITAdmin%\Setup"
set "Tools=%ITAdmin%\Tools"
set "Scripts=%ITAdmin%\Scripts"
set "NetworkShareScripts=%Scripts%\Network-Share"

set "Clients=%AdminConsole%\Clients"
set "Logs=%AdminConsole%\Logs"
set "Reports=%AdminConsole%\Reports"
set "Config=%AdminConsole%\Config"

set "ClientList=%Clients%\Clients.txt"

set "ShareName=Share"
set "ShareUser=ShareUser"

set "ExpectedHostname=IT-SERVER"


rem ============================================================
rem STATUS VARIABLES
rem ============================================================

set "SetupStatus=NOT RUN"
set "ShareStatus=NOT CHECKED"
set "ShareUserStatus=NOT CHECKED"
set "WinRMStatus=NOT CHECKED"
set "AdminStatus=NOT CHECKED"

set "ServerServiceStatus=NOT CHECKED"
set "SMBPortStatus=NOT CHECKED"
set "LocalShareTestStatus=NOT CHECKED"
set "NetworkProfileStatus=NOT CHECKED"
set "SMBv1Status=NOT CHECKED"
set "FirewallStatus=NOT CHECKED"
set "SharePermissionStatus=NOT CHECKED"

set "TroubleshootingStatus=NOT RUN"
set "SecurityStatus=NOT RUN"

set /a SetupErrors=0


goto START


rem ============================================================
rem START
rem ============================================================

:START
cls

echo ============================================================
echo              NETWORK SHARE - ADMIN SETUP
echo ============================================================
echo.
echo Computer:
echo     %COMPUTERNAME%
echo.
echo Expected Hostname:
echo     %ExpectedHostname%
echo.
echo Logged-in User:
echo     %USERNAME%
echo.
echo ============================================================
echo.

rem ------------------------------------------------------------
rem Administrator check
rem ------------------------------------------------------------

echo Checking Administrator privileges...
echo.

net session >nul 2>&1

if errorlevel 1 (

    set "AdminStatus=NOT ADMINISTRATOR"

    echo ============================================================
    echo [WARNING] Administrator privileges are not detected.
    echo ============================================================
    echo.
    echo The console will remain open.
    echo.
    echo Read-only diagnostics may still be available.
    echo.
    echo Operations requiring Administrator privileges will
    echo be refused safely.
    echo.

) else (

    set "AdminStatus=ADMINISTRATOR"

    echo [OK] Administrator privileges detected.
)

echo.

rem ------------------------------------------------------------
rem D: drive check
rem ------------------------------------------------------------

if not exist "D:\" (

    echo ============================================================
    echo [ERROR] D: drive was not found.
    echo ============================================================
    echo.
    echo This setup expects:
    echo.
    echo     %ITAdmin%
    echo     %AdminConsole%
    echo     %SharePath%
    echo.
    echo The console will remain open.
    echo.

) else (

    echo [OK] D: drive detected.
)

echo.

call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem MAIN MENU
rem ============================================================

:MENU
cls

echo ============================================================
echo              NETWORK SHARE - ADMIN SETUP
echo ============================================================
echo.
echo Administration Server:
echo     %COMPUTERNAME%
echo.
echo Standard Hostname:
echo     %ExpectedHostname%
echo.
echo IT Administration:
echo     %ITAdmin%
echo.
echo Admin Console:
echo     %AdminConsole%
echo.
echo Shared Data:
echo     %SharePath%
echo.
echo Network Share:
echo     \\%COMPUTERNAME%\%ShareName%
echo.
echo Share Account:
echo     %ShareUser%
echo.
echo Administrator:
echo     %AdminStatus%
echo.
echo Setup Status:
echo     %SetupStatus%
echo.
echo ============================================================
echo.
echo [1] Run / Re-run Setup
echo [2] Check Directories
echo [3] Check ShareUser
echo [4] Check SMB Share
echo [5] Check NTFS Permissions
echo [6] Apply ShareUser NTFS Permission
echo [7] Configure / Check WinRM
echo [8] Show Network Information
echo [9] Open D:\Share
echo [A] Open D:\IT-Admin
echo [B] Open AdminConsole
echo [C] View Setup Summary
echo [D] Safety / Preservation Status
echo [E] Automated Troubleshooting
echo [F] Security / Configuration Preflight
echo [G] Check SMB / Server Services
echo [Q] Exit
echo.
echo ============================================================
echo.

choice /C 123456789ABCDEFGQ /N /M "Select option: "

if errorlevel 17 goto EXIT
if errorlevel 16 goto SERVER_SERVICES
if errorlevel 15 goto SECURITY_PREFLIGHT
if errorlevel 14 goto TROUBLESHOOT
if errorlevel 13 goto SAFETY
if errorlevel 12 goto SUMMARY
if errorlevel 11 goto ADMINCONSOLE
if errorlevel 10 goto ITADMIN
if errorlevel 9 goto OPEN_SHARE
if errorlevel 8 goto NETWORK
if errorlevel 7 goto WINRM
if errorlevel 6 goto APPLY_NTFS
if errorlevel 5 goto SHARE_PERMISSIONS
if errorlevel 4 goto SMB_SHARE
if errorlevel 3 goto SHAREUSER
if errorlevel 2 goto DIRECTORIES
if errorlevel 1 goto RUN_SETUP

goto MENU


rem ============================================================
rem RUN SETUP
rem ============================================================

:RUN_SETUP

call :REQUIRE_ADMIN

if errorlevel 1 (
    call :WAIT_FOR_USER
    goto MENU
)

cls

echo ============================================================
echo                   RUN / RE-RUN SETUP
echo ============================================================
echo.
echo This setup is designed to be safely re-runnable.
echo.
echo Existing folders:
echo     KEEP
echo.
echo Existing files:
echo     KEEP
echo.
echo Existing D:\Share contents:
echo     KEEP
echo.
echo Existing D:\IT-Admin contents:
echo     KEEP
echo.
echo Existing D:\AdminConsole contents:
echo     KEEP
echo.
echo Existing SMB Share:
echo     KEEP
echo.
echo Existing ShareUser:
echo     KEEP
echo.
echo Existing ShareUser password:
echo     KEEP
echo.
echo NTFS permissions:
echo     NOT AUTOMATICALLY MODIFIED
echo.
echo Firewall/security settings:
echo     NOT AUTOMATICALLY HARDENED
echo.
echo No destructive cleanup will be performed.
echo.

choice /C YN /N /M "Continue with setup? [Y/N]: "

if errorlevel 2 goto MENU

set /a SetupErrors=0


rem ============================================================
rem STEP 1 - DIRECTORY STRUCTURE
rem ============================================================

cls

echo ============================================================
echo              [1/6] DIRECTORY STRUCTURE
echo ============================================================
echo.

call :ENSURE_DIR "%ITAdmin%"
call :ENSURE_DIR "%Installers%"
call :ENSURE_DIR "%Drivers%"
call :ENSURE_DIR "%Setup%"
call :ENSURE_DIR "%Tools%"
call :ENSURE_DIR "%Scripts%"
call :ENSURE_DIR "%NetworkShareScripts%"

call :ENSURE_DIR "%AdminConsole%"
call :ENSURE_DIR "%Clients%"
call :ENSURE_DIR "%Logs%"
call :ENSURE_DIR "%Reports%"
call :ENSURE_DIR "%Config%"

call :ENSURE_DIR "%SharePath%"

echo.
echo Directory step completed.
echo.

call :WAIT_FOR_USER


rem ============================================================
rem STEP 2 - CLIENT LIST
rem ============================================================

cls

echo ============================================================
echo                 [2/6] CLIENT LIST
echo ============================================================
echo.

if exist "%ClientList%" (

    echo [KEEP] Existing client list:
    echo.
    echo        %ClientList%

) else (

    >"%ClientList%" echo # Registered client PCs
    >>"%ClientList%" echo # One computer name or IP address per line
    >>"%ClientList%" echo # Lines beginning with # are ignored

    if exist "%ClientList%" (

        echo [CREATE] %ClientList%

    ) else (

        echo [ERROR] Could not create client list.
        set /a SetupErrors+=1
    )
)

echo.
echo Client list step completed.
echo.

call :WAIT_FOR_USER


rem ============================================================
rem STEP 3 - SHAREUSER
rem ============================================================

cls

echo ============================================================
echo                   [3/6] SHAREUSER
echo ============================================================
echo.

net user "%ShareUser%" >nul 2>&1

if errorlevel 1 (

    echo [INFO] %ShareUser% does not exist.
    echo.
    echo Windows will now prompt for the password.
    echo.
    echo IMPORTANT:
    echo The password will NOT be stored by this script.
    echo.

    net user "%ShareUser%" * /add

    if errorlevel 1 (

        echo.
        echo [ERROR] Could not create %ShareUser%.
        set /a SetupErrors+=1
        set "ShareUserStatus=FAILED"

    ) else (

        echo.
        echo [OK] %ShareUser% created.
        set "ShareUserStatus=CREATED"
    )

) else (

    echo [KEEP] %ShareUser% already exists.
    echo [INFO] Existing password was NOT changed.
    set "ShareUserStatus=EXISTS"
)

echo.

rem ------------------------------------------------------------
rem Ensure account is active
rem ------------------------------------------------------------

net user "%ShareUser%" /active:yes >nul 2>&1

if errorlevel 1 (

    echo [WARNING] Could not activate %ShareUser%.

) else (

    echo [OK] %ShareUser% is active.
)

echo.
echo ShareUser step completed.
echo.

call :WAIT_FOR_USER


rem ============================================================
rem STEP 4 - SMB SHARE
rem ============================================================

cls

echo ============================================================
echo                   [4/6] SMB SHARE
echo ============================================================
echo.

rem ------------------------------------------------------------
rem Do not create an SMB share if ShareUser failed.
rem ------------------------------------------------------------

net user "%ShareUser%" >nul 2>&1

if errorlevel 1 (

    echo [ERROR] %ShareUser% is not available.
    echo [INFO] SMB Share creation was skipped.
    echo.
    set "ShareStatus=FAILED - SHAREUSER UNAVAILABLE"
    set /a SetupErrors+=1

) else (

    call :CHECK_SHARE
)

echo.
echo SMB Share step completed.
echo.

call :WAIT_FOR_USER


rem ============================================================
rem STEP 5 - WINRM
rem ============================================================

cls

echo ============================================================
echo                    [5/6] WINRM
echo ============================================================
echo.

echo IMPORTANT:
echo WinRM configuration changes Windows remote-management
echo settings on this computer.
echo.
echo No password is stored by this script.
echo.
echo WinRM will ONLY be configured when you explicitly select Y.
echo.

choice /C YN /N /M "Configure WinRM now? [Y/N]: "

if errorlevel 2 (

    echo.
    echo [SKIPPED] WinRM configuration was not performed.
    set "WinRMStatus=SKIPPED"

) else (

    echo.
    echo [ACTION] Configuring WinRM...
    echo.

    powershell.exe -NoProfile -Command "Enable-PSRemoting -Force"

    if errorlevel 1 (

        echo.
        echo [WARNING] WinRM configuration returned an error.
        set "WinRMStatus=FAILED"

    ) else (

        echo.
        echo [OK] WinRM configuration completed.
        set "WinRMStatus=CONFIGURED"
    )

    echo.
    echo Testing localhost...
    echo.

    powershell.exe -NoProfile -Command ^
        "Test-WSMan -ComputerName localhost -ErrorAction Stop" >nul 2>&1

    if errorlevel 1 (

        echo [WARNING] Local WinRM test failed.
        set "WinRMStatus=FAILED"

    ) else (

        echo [OK] Local WinRM is reachable.
        set "WinRMStatus=READY"
    )
)

echo.
echo WinRM step completed.
echo.

call :WAIT_FOR_USER


rem ============================================================
rem STEP 6 - FINAL VERIFICATION
rem ============================================================

cls

echo ============================================================
echo                 [6/6] FINAL VERIFICATION
echo ============================================================
echo.

call :VERIFY_DIRECTORIES
call :VERIFY_SHAREUSER
call :VERIFY_SHARE
call :VERIFY_WINRM

echo.
echo ============================================================
echo                       SETUP RESULT
echo ============================================================
echo.

if "%SetupErrors%"=="0" (

    set "SetupStatus=COMPLETED"

    echo [OK] Setup completed without creation errors.

) else (

    set "SetupStatus=COMPLETED WITH ERRORS"

    echo [WARNING] Setup completed with %SetupErrors% error(s).
)

echo.
echo Existing D:\Share contents:
echo     PRESERVED
echo.
echo Existing D:\IT-Admin contents:
echo     PRESERVED
echo.
echo Existing D:\AdminConsole contents:
echo     PRESERVED
echo.
echo D:\Share\Client:
echo     NOT CREATED
echo.
echo Existing SMB Share:
echo     NOT DELETED / NOT RECREATED
echo.
echo Existing ShareUser password:
echo     NOT CHANGED
echo.
echo Automatic recursive NTFS modification:
echo     DISABLED
echo.
echo Automatic firewall/security modification:
echo     DISABLED
echo.
echo ============================================================
echo.

call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem REQUIRE ADMINISTRATOR
rem ============================================================

:REQUIRE_ADMIN

net session >nul 2>&1

if errorlevel 1 (

    echo ============================================================
    echo [ERROR] Administrator privileges are required.
    echo ============================================================
    echo.
    echo Please restart this BAT file using:
    echo.
    echo     Right-click ^> Run as administrator
    echo.

    set "AdminStatus=NOT ADMINISTRATOR"

    exit /b 1
)

set "AdminStatus=ADMINISTRATOR"

exit /b 0


rem ============================================================
rem ENSURE DIRECTORY
rem ============================================================

:ENSURE_DIR

if exist "%~1\" (

    echo [KEEP]   %~1

    exit /b 0
)

echo [CREATE] %~1

mkdir "%~1" >nul 2>&1

if exist "%~1\" (

    echo [OK]     Created successfully.

) else (

    echo [ERROR]  Could not create:
    echo          %~1

    set /a SetupErrors+=1
)

exit /b 0


rem ============================================================
rem CHECK SMB SHARE
rem ============================================================

:CHECK_SHARE

net share "%ShareName%" >nul 2>&1

if errorlevel 1 (

    echo [INFO] SMB Share does not exist.
    echo.
    echo Requested share:
    echo     \\%COMPUTERNAME%\%ShareName%
    echo.
    echo Target:
    echo     %SharePath%
    echo.

    echo Verifying target directory...

    if not exist "%SharePath%\" (

        echo [ERROR] Share target directory does not exist.
        echo [INFO] SMB Share was NOT created.

        set "ShareStatus=FAILED - TARGET MISSING"
        set /a SetupErrors+=1

        exit /b 0
    )

    echo [OK] Share target exists.
    echo.

    echo Creating SMB Share...
    echo.

    net share "%ShareName%"="%SharePath%" ^
        /GRANT:"%ShareUser%",CHANGE ^
        /REMARK:"Administration Shared Data"

    if errorlevel 1 (

        echo.
        echo [ERROR] Could not create SMB Share.

        set "ShareStatus=FAILED"
        set /a SetupErrors+=1

    ) else (

        echo.
        echo [OK] SMB Share created.

        set "ShareStatus=CREATED"
    )

    exit /b 0
)

echo [KEEP] SMB Share already exists.
echo.
echo Existing SMB Share was NOT deleted or recreated.
echo.

call :VERIFY_SHARE_PATH

exit /b 0


rem ============================================================
rem VERIFY SHARE PATH
rem ============================================================

:VERIFY_SHARE_PATH

set "SHARECHECK_NAME=%ShareName%"
set "SHARECHECK_PATH=%SharePath%"

powershell.exe -NoProfile -Command ^
    "$name=$env:SHARECHECK_NAME; $expected=$env:SHARECHECK_PATH; $s=Get-SmbShare -Name $name -ErrorAction SilentlyContinue; if($s){Write-Host ('Share Path: ' + $s.Path); if($s.Path -ieq $expected){exit 0}else{exit 2}}else{exit 1}"

if errorlevel 2 goto SHARE_PATH_WRONG
if errorlevel 1 goto SHARE_PATH_FALLBACK

echo.
echo [OK] Existing Share points to:
echo      %SharePath%

set "ShareStatus=EXISTS - VERIFIED"

exit /b 0


:SHARE_PATH_WRONG

echo.
echo [WARNING] Existing Share does not point to:
echo           %SharePath%
echo.
echo The existing Share was NOT changed.

set "ShareStatus=EXISTS - WRONG PATH"

exit /b 0


:SHARE_PATH_FALLBACK

echo.
echo [WARNING] Get-SmbShare could not verify the Share path.
echo.
echo Attempting CIM fallback...
echo.

set "SHARECHECK_NAME=%ShareName%"
set "SHARECHECK_PATH=%SharePath%"

powershell.exe -NoProfile -Command ^
    "$name=$env:SHARECHECK_NAME; $expected=$env:SHARECHECK_PATH; $s=Get-CimInstance -ClassName Win32_Share -Filter ('Name=''' + $name + '''') -ErrorAction SilentlyContinue; if($s){Write-Host ('Share Path: ' + $s.Path); if($s.Path -ieq $expected){exit 0}else{exit 2}}else{exit 1}"

if errorlevel 2 (

    echo.
    echo [WARNING] Existing Share has a different path.
    echo [INFO] Existing Share was NOT changed.

    set "ShareStatus=EXISTS - WRONG PATH"

) else if errorlevel 1 (

    echo.
    echo [WARNING] Existing Share path could not be verified.
    echo [INFO] Existing Share was NOT changed.

    set "ShareStatus=EXISTS - UNVERIFIED"

) else (

    echo.
    echo [OK] Existing Share points to:
    echo      %SharePath%

    set "ShareStatus=EXISTS - VERIFIED"
)

exit /b 0


rem ============================================================
rem VERIFY DIRECTORIES
rem ============================================================

:VERIFY_DIRECTORIES

echo --- Directory Verification ---
echo.

for %%D in (
    "%ITAdmin%"
    "%Installers%"
    "%Drivers%"
    "%Setup%"
    "%Tools%"
    "%Scripts%"
    "%NetworkShareScripts%"
    "%AdminConsole%"
    "%Clients%"
    "%Logs%"
    "%Reports%"
    "%Config%"
    "%SharePath%"
) do (

    if exist "%%~D\" (

        echo [OK] %%~D

    ) else (

        echo [ERROR] Missing %%~D
        set /a SetupErrors+=1
    )
)

echo.

exit /b 0


rem ============================================================
rem VERIFY SHAREUSER
rem ============================================================

:VERIFY_SHAREUSER

echo --- ShareUser Verification ---
echo.

net user "%ShareUser%" >nul 2>&1

if errorlevel 1 (

    echo [ERROR] %ShareUser% does not exist.
    set "ShareUserStatus=NOT FOUND"

) else (

    echo [OK] %ShareUser% exists.
    set "ShareUserStatus=EXISTS"
)

echo.

exit /b 0


rem ============================================================
rem VERIFY SMB SHARE
rem ============================================================

:VERIFY_SHARE

echo --- SMB Share Verification ---
echo.

net share "%ShareName%" >nul 2>&1

if errorlevel 1 (

    echo [ERROR] SMB Share is not available.
    set "ShareStatus=NOT FOUND"

    echo.

    exit /b 0
)

echo [OK] SMB Share exists.
echo.

call :VERIFY_SHARE_PATH

echo.

exit /b 0


rem ============================================================
rem VERIFY WINRM
rem ============================================================

:VERIFY_WINRM

echo --- WinRM Verification ---
echo.

powershell.exe -NoProfile -Command ^
    "Test-WSMan -ComputerName localhost -ErrorAction Stop" >nul 2>&1

if errorlevel 1 (

    echo [WARNING] Local WinRM test failed.
    set "WinRMStatus=FAILED"

) else (

    echo [OK] Local WinRM is reachable.
    set "WinRMStatus=READY"
)

echo.

exit /b 0


rem ============================================================
rem DIRECTORY CHECK
rem ============================================================

:DIRECTORIES

cls

echo ============================================================
echo                    DIRECTORY CHECK
echo ============================================================
echo.

call :VERIFY_DIRECTORIES

echo ============================================================
echo.
echo This check does not delete or modify directories.
echo.

call :WAIT_FOR_USER

goto MENU


rem ============================================================
rem SHAREUSER CHECK
rem ============================================================

:SHAREUSER

cls

echo ============================================================
echo                     SHAREUSER CHECK
echo ============================================================
echo.

net user "%ShareUser%"

if errorlevel 1 (

    echo.
    echo [ERROR] %ShareUser% was not found.
    set "ShareUserStatus=NOT FOUND"

) else (

    echo.
    echo [OK] %ShareUser% exists.
    echo [INFO] Password was not changed.
    set "ShareUserStatus=EXISTS"
)

echo.

call :WAIT_FOR_USER

goto MENU


rem ============================================================
rem SMB SHARE CHECK
rem ============================================================

:SMB_SHARE

cls

echo ============================================================
echo                     SMB SHARE CHECK
echo ============================================================
echo.

call :VERIFY_SHARE

echo.
echo Network path:
echo     \\%COMPUTERNAME%\%ShareName%
echo.

call :WAIT_FOR_USER

goto MENU


rem ============================================================
rem NTFS PERMISSION CHECK
rem ============================================================

:SHARE_PERMISSIONS

cls

echo ============================================================
echo                 NTFS PERMISSION CHECK
echo ============================================================
echo.

echo Share root:
echo     %SharePath%
echo.

if not exist "%SharePath%\" (

    echo [ERROR] %SharePath% does not exist.
    echo.

    call :WAIT_FOR_USER
    goto MENU
)

echo Current NTFS permissions:
echo.
echo ------------------------------------------------------------

icacls "%SharePath%"

echo ------------------------------------------------------------
echo.

echo IMPORTANT:
echo This option only READS permissions.
echo It does NOT modify anything.
echo.

call :WAIT_FOR_USER

goto MENU


rem ============================================================
rem APPLY SHAREUSER NTFS PERMISSION
rem ============================================================

:APPLY_NTFS

call :REQUIRE_ADMIN

if errorlevel 1 (
    call :WAIT_FOR_USER
    goto MENU
)

cls

echo ============================================================
echo             APPLY SHAREUSER NTFS PERMISSION
echo ============================================================
echo.

echo This operation will add:
echo.
echo     %COMPUTERNAME%\%ShareUser%
echo.
echo with Modify permission to:
echo.
echo     %SharePath%
echo.
echo The permission will inherit to child objects.
echo.
echo ============================================================
echo WARNING
echo ============================================================
echo.
echo This changes NTFS permissions on the Share tree.
echo.
echo It is NOT performed automatically during normal setup.
echo.

if not exist "%SharePath%\" (

    echo [ERROR] %SharePath% does not exist.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

net user "%ShareUser%" >nul 2>&1

if errorlevel 1 (

    echo [ERROR] %ShareUser% does not exist.
    echo [INFO] Permission change was cancelled.
    echo.

    call :WAIT_FOR_USER
    goto MENU
)

choice /C YN /N /M "Apply this permission? [Y/N]: "

if errorlevel 2 (

    echo.
    echo [CANCELLED] No NTFS permission changes were made.
    echo.

    call :WAIT_FOR_USER
    goto MENU
)

echo.
echo Applying permission...
echo.

icacls "%SharePath%" /grant "%COMPUTERNAME%\%ShareUser%:(OI)(CI)M"

if errorlevel 1 (

    echo.
    echo [ERROR] Failed to apply NTFS permission.

) else (

    echo.
    echo [OK] ShareUser NTFS permission applied.
)

echo.

call :WAIT_FOR_USER

goto MENU


rem ============================================================
rem WINRM
rem ============================================================

:WINRM

call :REQUIRE_ADMIN

if errorlevel 1 (
    call :WAIT_FOR_USER
    goto MENU
)

cls

echo ============================================================
echo                    WINRM CONFIGURATION
echo ============================================================
echo.

echo IMPORTANT:
echo This changes Windows remote-management configuration.
echo.
echo Configuration requires explicit confirmation.
echo.

choice /C YN /N /M "Configure WinRM now? [Y/N]: "

if errorlevel 2 (

    echo.
    echo [CANCELLED] WinRM configuration was not changed.
    set "WinRMStatus=SKIPPED"

    echo.

    call :WAIT_FOR_USER

    goto MENU
)

echo.
echo Configuring WinRM...
echo.

powershell.exe -NoProfile -Command "Enable-PSRemoting -Force"

if errorlevel 1 (

    echo.
    echo [WARNING] WinRM configuration returned an error.
    set "WinRMStatus=FAILED"

) else (

    echo.
    echo [OK] WinRM configuration completed.
    set "WinRMStatus=CONFIGURED"
)

echo.
echo Testing localhost...
echo.

powershell.exe -NoProfile -Command ^
    "Test-WSMan -ComputerName localhost -ErrorAction Stop"

if errorlevel 1 (

    echo.
    echo [WARNING] Local WinRM test failed.
    set "WinRMStatus=FAILED"

) else (

    echo.
    echo [OK] Local WinRM is reachable.
    set "WinRMStatus=READY"
)

echo.

call :WAIT_FOR_USER

goto MENU


rem ============================================================
rem NETWORK INFORMATION
rem ============================================================

:NETWORK

cls

echo ============================================================
echo                  NETWORK INFORMATION
echo ============================================================
echo.

echo Computer Name:
echo     %COMPUTERNAME%
echo.

echo Expected Hostname:
echo     %ExpectedHostname%
echo.

if /I "%COMPUTERNAME%"=="%ExpectedHostname%" (

    echo Hostname Status:
    echo     [OK] Standard hostname is in use.

) else (

    echo Hostname Status:
    echo     [WARNING] Current hostname differs from standard.
    echo     [INFO] Hostname was NOT changed.
)

echo.

echo User:
echo     %USERNAME%
echo.

echo IP Configuration:
echo ------------------------------------------------------------
echo.

ipconfig

echo.
echo ------------------------------------------------------------
echo.

echo Network Share:
echo     \\%COMPUTERNAME%\%ShareName%
echo.

call :WAIT_FOR_USER

goto MENU


rem ============================================================
rem OPEN SHARE
rem ============================================================

:OPEN_SHARE

cls

echo ============================================================
echo                    OPEN SHARED DATA
echo ============================================================
echo.

if not exist "%SharePath%\" (

    echo [ERROR] %SharePath% does not exist.
    echo.

    call :WAIT_FOR_USER
    goto MENU
)

echo Opening:
echo     %SharePath%
echo.

explorer.exe "%SharePath%"

echo.
echo [OK] Explorer was opened.
echo.

call :WAIT_FOR_USER

goto MENU


rem ============================================================
rem OPEN IT-ADMIN
rem ============================================================

:ITADMIN

cls

echo ============================================================
echo                    OPEN IT-ADMIN
echo ============================================================
echo.

if not exist "%ITAdmin%\" (

    echo [ERROR] %ITAdmin% does not exist.
    echo.

    call :WAIT_FOR_USER
    goto MENU
)

echo Opening:
echo     %ITAdmin%
echo.

explorer.exe "%ITAdmin%"

echo.
echo [OK] Explorer was opened.
echo.

call :WAIT_FOR_USER

goto MENU


rem ============================================================
rem OPEN ADMINCONSOLE
rem ============================================================

:ADMINCONSOLE

cls

echo ============================================================
echo                    OPEN ADMINCONSOLE
echo ============================================================
echo.

if not exist "%AdminConsole%\" (

    echo [ERROR] %AdminConsole% does not exist.
    echo.

    call :WAIT_FOR_USER
    goto MENU
)

echo Opening:
echo     %AdminConsole%
echo.

explorer.exe "%AdminConsole%"

echo.
echo [OK] Explorer was opened.
echo.

call :WAIT_FOR_USER

goto MENU


rem ============================================================
rem SETUP SUMMARY
rem ============================================================

:SUMMARY

cls

echo ============================================================
echo                    SETUP SUMMARY
echo ============================================================
echo.

echo Computer:
echo     %COMPUTERNAME%
echo.

echo Expected Hostname:
echo     %ExpectedHostname%
echo.

echo Administrator:
echo     %USERNAME%
echo.

echo Administrator Status:
echo     %AdminStatus%
echo.

echo IT Administration:
echo     %ITAdmin%
echo.

echo Network Share Scripts:
echo     %NetworkShareScripts%
echo.

echo Admin Console:
echo     %AdminConsole%
echo.

echo Shared Data:
echo     %SharePath%
echo.

echo SMB Share:
echo     \\%COMPUTERNAME%\%ShareName%
echo.

echo Share Account:
echo     %ShareUser%
echo.

echo Client List:
echo     %ClientList%
echo.

echo ------------------------------------------------------------
echo SETUP STATUS
echo ------------------------------------------------------------
echo.

echo Setup:
echo     %SetupStatus%
echo.

echo ShareUser:
echo     %ShareUserStatus%
echo.

echo SMB Share:
echo     %ShareStatus%
echo.

echo WinRM:
echo     %WinRMStatus%
echo.

echo ------------------------------------------------------------
echo DIAGNOSTIC STATUS
echo ------------------------------------------------------------
echo.

echo Server Service:
echo     %ServerServiceStatus%
echo.

echo TCP 445:
echo     %SMBPortStatus%
echo.

echo Local SMB Share Test:
echo     %LocalShareTestStatus%
echo.

echo Network Profile:
echo     %NetworkProfileStatus%
echo.

echo SMBv1:
echo     %SMBv1Status%
echo.

echo Firewall:
echo     %FirewallStatus%
echo.

echo Share Permission Audit:
echo     %SharePermissionStatus%
echo.

echo Troubleshooting:
echo     %TroubleshootingStatus%
echo.

echo Security Preflight:
echo     %SecurityStatus%
echo.

echo ------------------------------------------------------------
echo PRESERVATION RULES
echo ------------------------------------------------------------
echo.

echo Existing D:\IT-Admin files:
echo     PRESERVED
echo.

echo Existing D:\IT-Admin folders:
echo     PRESERVED
echo.

echo Existing D:\AdminConsole contents:
echo     PRESERVED
echo.

echo Existing D:\Share files:
echo     PRESERVED
echo.

echo Existing D:\Share folders:
echo     PRESERVED
echo.

echo D:\Share\Client:
echo     NOT CREATED
echo.

echo Existing SMB Share:
echo     NOT DELETED / NOT RECREATED
echo.

echo Existing ShareUser password:
echo     NOT CHANGED
echo.

echo Automatic recursive NTFS modification:
echo     DISABLED
echo.

echo Automatic firewall modification:
echo     DISABLED
echo.

echo Automatic security hardening:
echo     DISABLED
echo.

echo ============================================================
echo.

call :WAIT_FOR_USER

goto MENU


rem ============================================================
rem SAFETY / PRESERVATION STATUS
rem ============================================================

:SAFETY

cls

echo ============================================================
echo               SAFETY / PRESERVATION STATUS
echo ============================================================
echo.

echo This console follows a non-destructive setup policy.
echo.

echo ------------------------------------------------------------
echo FILE AND FOLDER PROTECTION
echo ------------------------------------------------------------
echo.

echo Existing folders:
echo     PRESERVED
echo.

echo Existing files:
echo     PRESERVED
echo.

echo Existing D:\IT-Admin contents:
echo     PRESERVED
echo.

echo Existing D:\AdminConsole contents:
echo     PRESERVED
echo.

echo Existing D:\Share contents:
echo     PRESERVED
echo.

echo D:\Share\Client:
echo     NOT CREATED
echo.

echo ------------------------------------------------------------
echo SMB PROTECTION
echo ------------------------------------------------------------
echo.

echo Existing SMB Share:
echo     NOT DELETED
echo     NOT RECREATED
echo.

echo If an existing Share points to another path:
echo     WARNING ONLY
echo     NO AUTOMATIC CHANGE
echo.

echo ------------------------------------------------------------
echo ACCOUNT PROTECTION
echo ------------------------------------------------------------
echo.

echo ShareUser:
echo     Created only if missing
echo.

echo Existing ShareUser password:
echo     NOT CHANGED
echo.

echo Password storage:
echo     NONE
echo.

echo ------------------------------------------------------------
echo NTFS PROTECTION
echo ------------------------------------------------------------
echo.

echo Automatic recursive NTFS changes:
echo     DISABLED
echo.

echo NTFS changes:
echo     EXPLICIT USER ACTION REQUIRED
echo.

echo ------------------------------------------------------------
echo SYSTEM CONFIGURATION
echo ------------------------------------------------------------
echo.

echo WinRM:
echo     Explicit configuration required
echo.

echo Hostname:
echo     NOT changed by this BAT
echo.

echo Firewall:
echo     NOT automatically modified
echo.

echo SMB configuration:
echo     NOT automatically hardened
echo.

echo ------------------------------------------------------------
echo TROUBLESHOOTING
echo ------------------------------------------------------------
echo.

echo Automated troubleshooting:
echo     READ-ONLY
echo.

echo Firewall repair:
echo     NOT automatic
echo.

echo WinRM repair:
echo     NOT automatic
echo.

echo SMB repair:
echo     NOT automatic
echo.

echo ------------------------------------------------------------
echo DESTRUCTIVE COMMANDS
echo ------------------------------------------------------------
echo.

echo Automatic rmdir / del / format:
echo     NONE
echo.

echo Automatic SMB share deletion:
echo     NONE
echo.

echo ============================================================
echo.

call :WAIT_FOR_USER

goto MENU


rem ============================================================
rem AUTOMATED TROUBLESHOOTING
rem ============================================================

:TROUBLESHOOT

cls

echo ============================================================
echo                AUTOMATED TROUBLESHOOTING
echo ============================================================
echo.

echo This diagnostic is READ-ONLY.
echo.
echo It will NOT:
echo.
echo     - delete files
echo     - delete folders
echo     - delete SMB shares
echo     - modify NTFS permissions
echo     - change passwords
echo     - change firewall rules
echo     - configure WinRM
echo     - change the hostname
echo.
echo ============================================================
echo.

call :WAIT_FOR_USER

cls

echo ============================================================
echo                AUTOMATED TROUBLESHOOTING
echo ============================================================
echo.

set "TroubleshootingStatus=RUNNING"

rem ------------------------------------------------------------
rem TEST 1 - HOSTNAME
rem ------------------------------------------------------------

echo [1/8] Hostname
echo ------------------------------------------------------------

if /I "%COMPUTERNAME%"=="%ExpectedHostname%" (

    echo [PASS] Computer name matches %ExpectedHostname%.

) else (

    echo [WARN] Current computer name is:
    echo        %COMPUTERNAME%
    echo.
    echo        Expected:
    echo        %ExpectedHostname%
)

echo.


rem ------------------------------------------------------------
rem TEST 2 - LANMANSERVER
rem ------------------------------------------------------------

echo [2/8] SMB Server Service
echo ------------------------------------------------------------

sc query LanmanServer | find /I "RUNNING" >nul 2>&1

if errorlevel 1 (

    echo [FAIL] LanmanServer is not reported as RUNNING.
    set "ServerServiceStatus=FAILED"

) else (

    echo [PASS] LanmanServer is RUNNING.
    set "ServerServiceStatus=RUNNING"
)

echo.


rem ------------------------------------------------------------
rem TEST 3 - TCP 445
rem ------------------------------------------------------------

echo [3/8] TCP 445
echo ------------------------------------------------------------

set "TARGET_PC=%COMPUTERNAME%"

powershell.exe -NoProfile -Command ^
    "$t=$env:TARGET_PC; $r=Test-NetConnection -ComputerName $t -Port 445 -WarningAction SilentlyContinue; if($r.TcpTestSucceeded){exit 0}else{exit 1}"

if errorlevel 1 (

    echo [FAIL] TCP port 445 is not reachable locally.
    set "SMBPortStatus=FAILED"

) else (

    echo [PASS] TCP port 445 is reachable locally.
    set "SMBPortStatus=OPEN"
)

echo.


rem ------------------------------------------------------------
rem TEST 4 - LOCAL SMB SHARE
rem ------------------------------------------------------------

echo [4/8] Local SMB Share Access
echo ------------------------------------------------------------

if not exist "%SharePath%\" (

    echo [FAIL] Local share target does not exist.
    set "LocalShareTestStatus=FAILED"

) else (

    dir "\\localhost\%ShareName%\" >nul 2>&1

    if errorlevel 1 (

        echo [FAIL] Could not access:
        echo        \\localhost\%ShareName%
        set "LocalShareTestStatus=FAILED"

    ) else (

        echo [PASS] Local SMB share is accessible:
        echo        \\localhost\%ShareName%
        set "LocalShareTestStatus=PASS"
    )
)

echo.


rem ------------------------------------------------------------
rem TEST 5 - WINRM
rem ------------------------------------------------------------

echo [5/8] WinRM
echo ------------------------------------------------------------

powershell.exe -NoProfile -Command ^
    "Test-WSMan -ComputerName localhost -ErrorAction Stop" >nul 2>&1

if errorlevel 1 (

    echo [WARN] Local WinRM is not reachable.
    echo [INFO] This does not necessarily affect SMB.
    set "WinRMStatus=FAILED"

) else (

    echo [PASS] Local WinRM is reachable.
    set "WinRMStatus=READY"
)

echo.


rem ------------------------------------------------------------
rem TEST 6 - NETWORK PROFILE
rem ------------------------------------------------------------

echo [6/8] Network Profile
echo ------------------------------------------------------------

powershell.exe -NoProfile -Command ^
    "$p=Get-NetConnectionProfile -ErrorAction SilentlyContinue; if($p){$p | Select-Object Name,InterfaceAlias,NetworkCategory | Format-Table -AutoSize}else{exit 1}"

if errorlevel 1 (

    echo [WARN] Could not read Network Connection Profile.
    set "NetworkProfileStatus=UNAVAILABLE"

) else (

    echo [INFO] Network profile information displayed above.
    set "NetworkProfileStatus=CHECKED"
)

echo.


rem ------------------------------------------------------------
rem TEST 7 - SMBv1
rem ------------------------------------------------------------

echo [7/8] SMBv1
echo ------------------------------------------------------------

powershell.exe -NoProfile -Command ^
    "$f=Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -ErrorAction SilentlyContinue; if($f){Write-Host ('SMB1Protocol state: ' + $f.State); if($f.State -eq 'Enabled'){exit 2}else{exit 0}}else{Write-Host 'SMB1Protocol feature information unavailable.'; exit 1}"

if errorlevel 2 (

    echo [WARN] SMBv1 appears to be ENABLED.
    set "SMBv1Status=ENABLED - REVIEW"

) else if errorlevel 1 (

    echo [INFO] SMBv1 state could not be verified.
    set "SMBv1Status=UNVERIFIED"

) else (

    echo [PASS] SMBv1 does not appear to be enabled.
    set "SMBv1Status=DISABLED"
)

echo.


rem ------------------------------------------------------------
rem TEST 8 - FIREWALL / FILE SHARING
rem ------------------------------------------------------------

echo [8/8] File and Printer Sharing Firewall Rules
echo ------------------------------------------------------------

powershell.exe -NoProfile -Command ^
    "$r=Get-NetFirewallRule -DisplayGroup 'File and Printer Sharing' -ErrorAction SilentlyContinue | Where-Object {$_.Enabled -eq 'True'}; if($r){Write-Host ('Enabled File and Printer Sharing rules: ' + @($r).Count); exit 0}else{exit 1}"

if errorlevel 1 (

    echo [WARN] No enabled File and Printer Sharing firewall rules were found.
    set "FirewallStatus=REVIEW"

) else (

    echo [INFO] Enabled File and Printer Sharing firewall rules were found.
    set "FirewallStatus=RULES ENABLED"
)

echo.


rem ------------------------------------------------------------
rem TROUBLESHOOTING CLASSIFICATION
rem ------------------------------------------------------------

echo ============================================================
echo                    DIAGNOSTIC SUMMARY
echo ============================================================
echo.

echo Server Service:
echo     %ServerServiceStatus%
echo.

echo TCP 445:
echo     %SMBPortStatus%
echo.

echo Local SMB Share:
echo     %LocalShareTestStatus%
echo.

echo WinRM:
echo     %WinRMStatus%
echo.

echo Network Profile:
echo     %NetworkProfileStatus%
echo.

echo SMBv1:
echo     %SMBv1Status%
echo.

echo Firewall:
echo     %FirewallStatus%
echo.

echo ------------------------------------------------------------
echo LIKELY DIAGNOSIS
echo ------------------------------------------------------------
echo.

if /I "%ServerServiceStatus%"=="FAILED" (

    echo [FAIL]
    echo LanmanServer is not running.
    echo SMB services should be investigated first.
    set "TroubleshootingStatus=FAIL - SMB SERVICE"

) else if /I "%SMBPortStatus%"=="FAILED" (

    echo [FAIL]
    echo TCP 445 is not reachable.
    echo.
    echo Likely causes include:
    echo     - Windows Firewall
    echo     - Network isolation
    echo     - SMB service issue
    echo     - Network configuration
    set "TroubleshootingStatus=FAIL - TCP 445"

) else if /I "%LocalShareTestStatus%"=="FAILED" (

    echo [FAIL]
    echo TCP 445 is available but the SMB share could not
    echo be accessed locally.
    echo.
    echo Check:
    echo     - Share existence
    echo     - Share path
    echo     - Share permissions
    echo     - NTFS permissions
    set "TroubleshootingStatus=FAIL - SMB SHARE ACCESS"

) else if /I "%WinRMStatus%"=="FAILED" (

    echo [WARN]
    echo SMB appears operational, but WinRM is not reachable.
    echo.
    echo This is a WinRM-specific issue and does not necessarily
    echo indicate an SMB problem.
    set "TroubleshootingStatus=WARN - WINRM"

) else (

    echo [PASS]
    echo Core local SMB checks are operational.
    echo.
    echo Continue with the client-side troubleshooting script
    echo when diagnosing another computer.
    set "TroubleshootingStatus=PASS - CORE SERVICES"
)

echo.
echo ============================================================
echo No configuration was changed by this diagnostic.
echo ============================================================
echo.

call :WAIT_FOR_USER

goto MENU


rem ============================================================
rem SECURITY / CONFIGURATION PREFLIGHT
rem ============================================================

:SECURITY_PREFLIGHT

cls

echo ============================================================
echo              SECURITY / CONFIGURATION PREFLIGHT
echo ============================================================
echo.

echo This is a READ-ONLY security review.
echo.
echo It does NOT automatically harden or change the system.
echo.
echo ============================================================
echo.

set "SecurityStatus=RUNNING"


rem ------------------------------------------------------------
rem 1 - NETWORK PROFILE
rem ------------------------------------------------------------

echo [1] Network Profile
echo ------------------------------------------------------------

powershell.exe -NoProfile -Command ^
    "$p=Get-NetConnectionProfile -ErrorAction SilentlyContinue; if($p){$p | Select-Object Name,InterfaceAlias,NetworkCategory | Format-Table -AutoSize}else{exit 1}"

if errorlevel 1 (

    echo [WARN] Network profile could not be read.
    set "NetworkProfileStatus=UNVERIFIED"

) else (

    echo [INFO] Review the NetworkCategory shown above.
    echo [INFO] An unexpected Public/Private/Domain profile can
    echo [INFO] affect firewall behavior.
    set "NetworkProfileStatus=CHECKED"
)

echo.


rem ------------------------------------------------------------
rem 2 - SMBv1
rem ------------------------------------------------------------

echo [2] SMBv1
echo ------------------------------------------------------------

powershell.exe -NoProfile -Command ^
    "$f=Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -ErrorAction SilentlyContinue; if($f){Write-Host ('SMB1Protocol: ' + $f.State); if($f.State -eq 'Enabled'){exit 2}else{exit 0}}else{exit 1}"

if errorlevel 2 (

    echo [HIGH] SMBv1 appears to be enabled.
    echo [INFO] SMBv1 should normally be disabled unless a
    echo [INFO] specific legacy requirement exists.
    set "SMBv1Status=ENABLED - HIGH"

) else if errorlevel 1 (

    echo [WARN] SMBv1 state could not be verified.
    set "SMBv1Status=UNVERIFIED"

) else (

    echo [PASS] SMBv1 appears disabled.
    set "SMBv1Status=DISABLED"
)

echo.


rem ------------------------------------------------------------
rem 3 - SMB SIGNING
rem ------------------------------------------------------------

echo [3] SMB Signing Configuration
echo ------------------------------------------------------------

powershell.exe -NoProfile -Command ^
    "$c=Get-SmbServerConfiguration -ErrorAction SilentlyContinue; if($c){Write-Host ('EnableSecuritySignature: ' + $c.EnableSecuritySignature); Write-Host ('RequireSecuritySignature: ' + $c.RequireSecuritySignature); if($c.RequireSecuritySignature){exit 0}else{exit 2}}else{exit 1}"

if errorlevel 2 (

    echo [WARN] SMB signing is not required by the server configuration.
    echo [INFO] This is a security-hardening consideration.
    set "SecurityStatus=REVIEW REQUIRED"

) else if errorlevel 1 (

    echo [WARN] SMB server configuration could not be read.
    set "SecurityStatus=REVIEW REQUIRED"

) else (

    echo [PASS] SMB server requires signing.
)

echo.


rem ------------------------------------------------------------
rem 4 - SMB SHARE
rem ------------------------------------------------------------

echo [4] SMB Share
echo ------------------------------------------------------------

net share "%ShareName%" >nul 2>&1

if errorlevel 1 (

    echo [FAIL] Share "%ShareName%" does not exist.
    set "ShareStatus=NOT FOUND"
    set "SecurityStatus=REVIEW REQUIRED"

) else (

    echo [PASS] Share "%ShareName%" exists.
    call :VERIFY_SHARE_PATH
)

echo.


rem ------------------------------------------------------------
rem 5 - SHARE PERMISSIONS
rem ------------------------------------------------------------

echo [5] SMB Share Permissions
echo ------------------------------------------------------------

powershell.exe -NoProfile -Command ^
    "$name=$env:SHARECHECK_NAME; $s=Get-SmbShareAccess -Name $name -ErrorAction SilentlyContinue; if($s){$s | Format-Table AccountName,AccessControlType,AccessRight -AutoSize; if($s | Where-Object {$_.AccountName -eq 'Everyone' -and $_.AccessRight -match 'Full'}){exit 2}else{exit 0}}else{exit 1}"

if errorlevel 2 (

    echo [HIGH] Everyone has FULL share access.
    echo [INFO] Review and restrict the share permissions.
    echo [INFO] No automatic change was made.
    set "SharePermissionStatus=HIGH - EVERYONE FULL"
    set "SecurityStatus=HIGH - REVIEW REQUIRED"

) else if errorlevel 1 (

    echo [WARN] SMB share permissions could not be read.
    set "SharePermissionStatus=UNVERIFIED"

) else (

    echo [PASS] No Everyone/FULL share permission was detected.
    set "SharePermissionStatus=REVIEWED"
)

echo.


rem ------------------------------------------------------------
rem 6 - NTFS
rem ------------------------------------------------------------

echo [6] NTFS Permissions
echo ------------------------------------------------------------

if exist "%SharePath%\" (

    icacls "%SharePath%"

    echo.
    echo [INFO] Review the NTFS ACL above.
    echo [INFO] No NTFS permission changes were made.

) else (

    echo [FAIL] Share path does not exist.
)

echo.


rem ------------------------------------------------------------
rem 7 - FIREWALL
rem ------------------------------------------------------------

echo [7] File and Printer Sharing Firewall
echo ------------------------------------------------------------

powershell.exe -NoProfile -Command ^
    "$r=Get-NetFirewallRule -DisplayGroup 'File and Printer Sharing' -ErrorAction SilentlyContinue | Where-Object {$_.Enabled -eq 'True'}; if($r){$r | Select-Object DisplayName,Profile,Direction,Action,Enabled | Format-Table -AutoSize; exit 0}else{exit 1}"

if errorlevel 1 (

    echo [WARN] No enabled File and Printer Sharing rules found.
    set "FirewallStatus=REVIEW"

) else (

    echo [INFO] Enabled File and Printer Sharing rules are shown above.
    echo [INFO] Rule scope should be reviewed for the intended LAN.
    set "FirewallStatus=CHECKED"
)

echo.


rem ------------------------------------------------------------
rem 8 - WINRM
rem ------------------------------------------------------------

echo [8] WinRM
echo ------------------------------------------------------------

sc query WinRM | find /I "RUNNING" >nul 2>&1

if errorlevel 1 (

    echo [INFO] WinRM service is not currently RUNNING.

) else (

    echo [INFO] WinRM service is RUNNING.
)

echo.
echo WinRM listeners:
echo ------------------------------------------------------------

winrm enumerate winrm/config/listener

echo ------------------------------------------------------------
echo.

echo [INFO] WinRM exposure should be restricted to trusted
echo        administration networks.
echo [INFO] No WinRM firewall or listener changes were made.
echo.


rem ------------------------------------------------------------
rem 9 - ADMINISTRATOR ACCOUNTS
rem ------------------------------------------------------------

echo [9] Local Administrator Group
echo ------------------------------------------------------------

net localgroup Administrators

echo.
echo [INFO] Review unexpected administrator accounts.
echo.


rem ------------------------------------------------------------
rem 10 - GUEST
rem ------------------------------------------------------------

echo [10] Guest Account
echo ------------------------------------------------------------

net user Guest

echo.
echo [INFO] Review Guest account state.
echo.


rem ------------------------------------------------------------
rem SECURITY SUMMARY
rem ------------------------------------------------------------

echo ============================================================
echo                  SECURITY PREFLIGHT SUMMARY
echo ============================================================
echo.

echo SMBv1:
echo     %SMBv1Status%
echo.

echo Share:
echo     %ShareStatus%
echo.

echo Share Permissions:
echo     %SharePermissionStatus%
echo.

echo Firewall:
echo     %FirewallStatus%
echo.

echo Network Profile:
echo     %NetworkProfileStatus%
echo.

echo Security Status:
echo     %SecurityStatus%
echo.

echo ------------------------------------------------------------
echo SECURITY POLICY
echo ------------------------------------------------------------
echo.

echo This preflight does NOT automatically:
echo.
echo     - disable SMBv1
echo     - change SMB signing
echo     - change share permissions
echo     - change NTFS permissions
echo     - modify firewall rules
echo     - modify WinRM listeners
echo     - disable accounts
echo     - remove administrators
echo.
echo Those changes belong in a separate explicit hardening
echo workflow and require confirmation.
echo.
echo ============================================================
echo.

if /I "%SecurityStatus%"=="RUNNING" (
    set "SecurityStatus=COMPLETED - REVIEW RESULTS"
)

call :WAIT_FOR_USER

goto MENU


rem ============================================================
rem SERVER / SMB SERVICES
rem ============================================================

:SERVER_SERVICES

cls

echo ============================================================
echo               SMB / SERVER SERVICE CHECK
echo ============================================================
echo.

echo [1] LanmanServer
echo ------------------------------------------------------------

sc query LanmanServer

echo.

echo [2] TCP Port 445
echo ------------------------------------------------------------

set "TARGET_PC=%COMPUTERNAME%"

powershell.exe -NoProfile -Command ^
    "$t=$env:TARGET_PC; $r=Test-NetConnection -ComputerName $t -Port 445 -WarningAction SilentlyContinue; $r | Select-Object ComputerName,RemotePort,TcpTestSucceeded | Format-Table -AutoSize; if($r.TcpTestSucceeded){exit 0}else{exit 1}"

if errorlevel 1 (
    echo [FAIL] TCP 445 test failed.
    set "SMBPortStatus=FAILED"
) else (
    echo [PASS] TCP 445 test succeeded.
    set "SMBPortStatus=OPEN"
)

echo.

echo [3] SMB Server Configuration
echo ------------------------------------------------------------

powershell.exe -NoProfile -Command ^
    "Get-SmbServerConfiguration -ErrorAction SilentlyContinue | Select-Object EnableSMB1Protocol,EnableSMB2Protocol,EnableSecuritySignature,RequireSecuritySignature | Format-List"

echo.

echo [4] Current Shares
echo ------------------------------------------------------------

net share

echo.

echo [5] Share Details
echo ------------------------------------------------------------

net share "%ShareName%"

echo.

echo [6] Current SMB Sessions
echo ------------------------------------------------------------

powershell.exe -NoProfile -Command ^
    "Get-SmbSession -ErrorAction SilentlyContinue | Select-Object ClientComputerName,ClientUserName,NumOpens,Dialect | Format-Table -AutoSize"

echo.

call :WAIT_FOR_USER

goto MENU


rem ============================================================
rem WAIT FOR USER
rem ============================================================

:WAIT_FOR_USER

echo.
echo ============================================================
echo Press any key to continue...
echo ============================================================

pause >nul

exit /b 0


rem ============================================================
rem EXIT CONFIRMATION
rem ============================================================

:EXIT

cls

echo ============================================================
echo                  EXIT ADMIN SETUP
echo ============================================================
echo.

echo Are you sure you want to exit?
echo.

echo Current Setup Status:
echo     %SetupStatus%
echo.

echo Security Status:
echo     %SecurityStatus%
echo.

echo Troubleshooting Status:
echo     %TroubleshootingStatus%
echo.

echo Administration Server:
echo     %COMPUTERNAME%
echo.

echo Network Share:
echo     \\%COMPUTERNAME%\%ShareName%
echo.

echo ============================================================
echo.
echo [Y] Yes - Exit
echo [N] No  - Return to Main Menu
echo.
echo ============================================================
echo.

choice /C YN /N /M "Exit? [Y/N]: "

if errorlevel 2 goto MENU
if errorlevel 1 goto EXIT_CONFIRMED

goto MENU


rem ============================================================
rem CONFIRMED EXIT
rem ============================================================

:EXIT_CONFIRMED

cls

echo ============================================================
echo              NETWORK SHARE SETUP CLOSED
echo ============================================================
echo.

echo Computer:
echo     %COMPUTERNAME%
echo.

echo User:
echo     %USERNAME%
echo.

echo IT Administration:
echo     %ITAdmin%
echo.

echo Admin Console:
echo     %AdminConsole%
echo.

echo Shared Data:
echo     %SharePath%
echo.

echo Network Share:
echo     \\%COMPUTERNAME%\%ShareName%
echo.

echo Setup Status:
echo     %SetupStatus%
echo.

echo Security Status:
echo     %SecurityStatus%
echo.

echo Troubleshooting Status:
echo     %TroubleshootingStatus%
echo.

echo ============================================================
echo.
echo No files or folders were deleted by exiting this console.
echo.
echo Closing this Command Prompt...
echo ============================================================
echo.

timeout /t 2 /nobreak >nul

endlocal
exit