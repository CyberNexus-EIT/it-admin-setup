@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Network Share - Admin Setup
color 0A

REM ============================================================================
REM 01-Network-Share-Setup.bat
REM
REM SERVER BASELINE
REM ----------------------------------------------------------------------------
REM Hostname       : IT-SERVER
REM IPv4           : 192.168.1.100
REM Share Name     : Share
REM Share Path     : D:\Share
REM Share User     : ShareUser
REM
REM PURPOSE
REM ----------------------------------------------------------------------------
REM Network Share setup, verification, troubleshooting and security hardening.
REM
REM IMPORTANT SECURITY MODEL
REM ----------------------------------------------------------------------------
REM - Normal setup does NOT automatically harden security.
REM - Security hardening is explicitly launched from menu option J.
REM - Security hardening requires Administrator privileges.
REM - Security hardening requires explicit Y/N confirmation.
REM - Existing files are preserved.
REM - Existing folders are preserved.
REM - Existing SMB shares are never deleted/recreated.
REM - Existing ShareUser passwords are never changed.
REM - D:\Share\Client is never created or modified.
REM - Passwords are never stored in this BAT file.
REM
REM SECURITY HARDENING AVAILABLE
REM ----------------------------------------------------------------------------
REM 1. Require SMB server signing.
REM 2. Require SMB client signing.
REM 3. Disable insecure SMB guest logons.
REM 4. Remove Everyone FULL share access.
REM 5. Ensure ShareUser has Modify NTFS access.
REM 6. Remove Public profile from inbound SMB firewall rules.
REM 7. Remove Public profile from inbound WinRM firewall rules.
REM 8. Optionally enable SMB encryption on the Share share.
REM
REM SAFETY
REM ----------------------------------------------------------------------------
REM Security hardening is NOT part of normal option [1] setup.
REM Option [I] performs READ-ONLY full security audit.
REM Option [J] performs explicit security hardening.
REM
REM The program does NOT automatically close.
REM Only Q -> Y intentionally closes the CMD process.
REM ============================================================================


REM ============================================================================
REM CONFIGURATION
REM ============================================================================

set "ExpectedHostname=IT-SERVER"
set "ServerIP=192.168.1.100"

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


REM ============================================================================
REM MAIN MENU
REM ============================================================================

:MENU

cls

echo.
echo ===============================================================================
echo                    NETWORK SHARE - ADMIN SETUP
echo ===============================================================================
echo.
echo Server       : %ExpectedHostname%
echo Server IP   : %ServerIP%
echo Share       : \\%ExpectedHostname%\%ShareName%
echo Share Path  : %SharePath%
echo Share User  : %ShareUser%
echo.
echo ===============================================================================
echo SETUP AND VERIFICATION
echo ===============================================================================
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
echo.
echo ===============================================================================
echo DIAGNOSTICS
echo ===============================================================================
echo.
echo [E] Automated Troubleshooting
echo [F] Security / Configuration Preflight
echo [G] Check SMB / Server Services
echo [H] Check SMB Share Permissions
echo [I] Full Security Audit
echo [J] Apply Security Hardening
echo.
echo [Q] Exit
echo.
echo ===============================================================================

choice /C 123456789ABCDEFGHIJQ /N /M "Select an option: "

REM Q = 20
if errorlevel 20 goto EXIT_PROGRAM

REM J = 19
if errorlevel 19 goto APPLY_SECURITY_HARDENING

REM I = 18
if errorlevel 18 goto FULL_SECURITY_AUDIT

REM H = 17
if errorlevel 17 goto CHECK_SHARE_PERMISSIONS

REM G = 16
if errorlevel 16 goto SERVER_SERVICES

REM F = 15
if errorlevel 15 goto SECURITY_PREFLIGHT

REM E = 14
if errorlevel 14 goto AUTOMATED_TROUBLESHOOTING

REM D = 13
if errorlevel 13 goto SAFETY_STATUS

REM C = 12
if errorlevel 12 goto SETUP_SUMMARY

REM B = 11
if errorlevel 11 goto OPEN_ADMINCONSOLE

REM A = 10
if errorlevel 10 goto OPEN_ITADMIN

REM 9
if errorlevel 9 goto OPEN_SHARE

REM 8
if errorlevel 8 goto NETWORK_INFORMATION

REM 7
if errorlevel 7 goto CONFIGURE_WINRM

REM 6
if errorlevel 6 goto APPLY_NTFS

REM 5
if errorlevel 5 goto CHECK_NTFS

REM 4
if errorlevel 4 goto CHECK_SHARE

REM 3
if errorlevel 3 goto CHECK_SHAREUSER

REM 2
if errorlevel 2 goto CHECK_DIRECTORIES_MENU

REM 1
if errorlevel 1 goto RUN_SETUP

goto MENU


REM ============================================================================
REM 1 - RUN / RE-RUN SETUP
REM ============================================================================

:RUN_SETUP

cls

set "SetupErrors=0"
set "SetupWarnings=0"
set "WinRMRequested=NO"

echo.
echo ===============================================================================
echo                         RUN / RE-RUN SETUP
echo ===============================================================================
echo.
echo Setup will run continuously from beginning to end.
echo.
echo IMPORTANT:
echo   No pause will occur between setup steps.
echo   Every step will display its result.
echo   WinRM will ask for confirmation because it can change system configuration.
echo   Security hardening is NOT automatically performed by this setup.
echo   Use option J from the main menu for explicit security hardening.
echo.
echo Existing files and folders will be preserved.
echo Existing SMB shares will not be deleted or recreated.
echo.


REM ============================================================================
REM ADMINISTRATOR CHECK
REM ============================================================================

call :REQUIRE_ADMIN

if errorlevel 1 (
    echo.
    echo [FAILED] Administrator privileges are required.
    echo.
    echo Setup was not performed.
    echo.
    call :FINAL_PAUSE
    goto MENU
)


REM ============================================================================
REM STEP 1 OF 6 - DIRECTORY STRUCTURE
REM ============================================================================

echo.
echo ===============================================================================
echo [1/6] DIRECTORY STRUCTURE
echo ===============================================================================
echo.

if not exist "D:\" (
    echo [FAILED] D: drive is not available.
    set /a SetupErrors+=1
) else (
    echo [OK] D: drive is available.
)

call :ENSURE_DIR "%ITAdmin%" "IT-Admin"
call :ENSURE_DIR "%Installers%" "Installers"
call :ENSURE_DIR "%Drivers%" "Drivers"
call :ENSURE_DIR "%Setup%" "Setup"
call :ENSURE_DIR "%Tools%" "Tools"
call :ENSURE_DIR "%Scripts%" "Scripts"
call :ENSURE_DIR "%NetworkShareScripts%" "Network-Share"

call :ENSURE_DIR "%AdminConsole%" "AdminConsole"
call :ENSURE_DIR "%Clients%" "Clients"
call :ENSURE_DIR "%Logs%" "Logs"
call :ENSURE_DIR "%Reports%" "Reports"
call :ENSURE_DIR "%Config%" "Config"

call :ENSURE_DIR "%SharePath%" "Share"

echo.
echo [STEP 1 RESULT] Directory processing completed.
echo [CONTINUE] Proceeding immediately to Step 2.
echo.


REM ============================================================================
REM STEP 2 OF 6 - CLIENT LIST
REM ============================================================================

echo.
echo ===============================================================================
echo [2/6] CLIENT LIST
echo ===============================================================================
echo.

if exist "%ClientList%" (
    echo [KEEP] Existing client list found.
    echo       %ClientList%
) else (
    echo [CREATE] Creating client list.
    echo         %ClientList%

    type nul > "%ClientList%" 2>&1

    if exist "%ClientList%" (
        echo [OK] Client list created successfully.
    ) else (
        echo [FAILED] Unable to create client list.
        set /a SetupErrors+=1
    )
)

echo.
echo [STEP 2 RESULT] Client list processing completed.
echo [CONTINUE] Proceeding immediately to Step 3.
echo.


REM ============================================================================
REM STEP 3 OF 6 - SHAREUSER
REM ============================================================================

echo.
echo ===============================================================================
echo [3/6] SHAREUSER ACCOUNT
echo ===============================================================================
echo.

call :ENSURE_SHAREUSER

echo.
echo [STEP 3 RESULT] ShareUser processing completed.
echo [CONTINUE] Proceeding immediately to Step 4.
echo.


REM ============================================================================
REM STEP 4 OF 6 - SMB SHARE
REM ============================================================================

echo.
echo ===============================================================================
echo [4/6] SMB SHARE
echo ===============================================================================
echo.

call :ENSURE_SMB_SHARE

echo.
echo [STEP 4 RESULT] SMB share processing completed.
echo [CONTINUE] Proceeding immediately to Step 5.
echo.


REM ============================================================================
REM STEP 5 OF 6 - WINRM
REM ============================================================================

echo.
echo ===============================================================================
echo [5/6] WINRM
echo ===============================================================================
echo.

echo Checking current WinRM configuration...
echo.

call :SHOW_WINRM_STATUS

echo.
echo -------------------------------------------------------------------------------
echo WinRM configuration requires explicit confirmation.
echo -------------------------------------------------------------------------------
echo.

choice /C YN /N /M "Configure WinRM now? [Y/N]: "

if errorlevel 2 (
    echo.
    echo [SKIPPED] WinRM configuration was not requested.
    echo [CONTINUE] Proceeding immediately to final verification.
    echo.
    goto WINRM_STEP_COMPLETE
)

set "WinRMRequested=YES"

echo.
echo [ACTION] Running Enable-PSRemoting -Force...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "Enable-PSRemoting -Force"

if errorlevel 1 (
    echo.
    echo [FAILED] WinRM configuration reported an error.
    set /a SetupErrors+=1
) else (
    echo.
    echo [OK] WinRM configuration completed.
)

echo.
echo [VERIFY] Testing WinRM after configuration...
echo.

call :VERIFY_WINRM

if errorlevel 1 (
    set /a SetupErrors+=1
)

:WINRM_STEP_COMPLETE

echo.
echo [STEP 5 RESULT] WinRM processing completed.
echo [CONTINUE] No pause. Proceeding immediately to Step 6.
echo.


REM ============================================================================
REM STEP 6 OF 6 - FINAL VERIFICATION
REM ============================================================================

echo.
echo ===============================================================================
echo [6/6] FINAL VERIFICATION
echo ===============================================================================
echo.

echo [CHECK 1] Required directories
echo -------------------------------------------------------------------------------
call :VERIFY_DIRECTORIES

if errorlevel 1 (
    set /a SetupErrors+=1
)

echo.
echo [CHECK 2] ShareUser
echo -------------------------------------------------------------------------------
call :VERIFY_SHAREUSER

if errorlevel 1 (
    set /a SetupErrors+=1
)

echo.
echo [CHECK 3] SMB share
echo -------------------------------------------------------------------------------
call :VERIFY_SMB_SHARE

if errorlevel 1 (
    set /a SetupErrors+=1
)

echo.
echo [CHECK 4] WinRM
echo -------------------------------------------------------------------------------
call :VERIFY_WINRM

if errorlevel 1 (
    set /a SetupWarnings+=1
)

echo.
echo [CHECK 5] Existing D:\Share\Client
echo -------------------------------------------------------------------------------

if exist "%SharePath%\Client" (
    echo [PRESERVED] Existing D:\Share\Client detected.
    echo            It was not modified.
) else (
    echo [OK] D:\Share\Client does not exist.
    echo     This script did not create it.
)

echo.
echo [STEP 6 RESULT] Final verification completed.
echo.


REM ============================================================================
REM FINAL SETUP SUMMARY
REM ============================================================================

echo.
echo ===============================================================================
echo                              FINAL SUMMARY
echo ===============================================================================
echo.

echo SERVER
echo -------------------------------------------------------------------------------
echo Expected Hostname : %ExpectedHostname%
echo Current Hostname  : %COMPUTERNAME%
echo Server IP         : %ServerIP%
echo.

if /I not "%COMPUTERNAME%"=="%ExpectedHostname%" (
    echo [WARNING] Current hostname does not match expected hostname.
    set /a SetupWarnings+=1
)

echo SMB
echo -------------------------------------------------------------------------------
echo Share Name        : %ShareName%
echo Share Path        : %SharePath%
echo Share User        : %ShareUser%
echo UNC Path          : \\%ExpectedHostname%\%ShareName%
echo.

echo ADMINISTRATION
echo -------------------------------------------------------------------------------
echo IT-Admin          : %ITAdmin%
echo AdminConsole      : %AdminConsole%
echo Scripts           : %NetworkShareScripts%
echo Client List       : %ClientList%
echo.

echo WINRM
echo -------------------------------------------------------------------------------
if /I "%WinRMRequested%"=="YES" (
    echo Configuration    : REQUESTED
) else (
    echo Configuration    : NOT REQUESTED
)
echo.

echo SETUP RESULT
echo -------------------------------------------------------------------------------
echo Errors            : %SetupErrors%
echo Warnings          : %SetupWarnings%
echo.

echo PRESERVATION
echo -------------------------------------------------------------------------------
echo Existing files    : PRESERVED
echo Existing folders  : PRESERVED
echo Existing SMB      : NOT DELETED / RECREATED
echo ShareUser password: NOT RESET
echo D:\Share\Client   : NOT CREATED / MODIFIED
echo.

echo SECURITY
echo -------------------------------------------------------------------------------
echo Security audit    : READ-ONLY
echo Security hardening: NOT AUTOMATICALLY PERFORMED
echo Firewall changes  : NOT AUTOMATICALLY PERFORMED
echo SMB changes       : NOT AUTOMATICALLY PERFORMED
echo NTFS changes      : NOT AUTOMATICALLY PERFORMED
echo.

if "%SetupErrors%"=="0" (
    echo [OVERALL RESULT] SETUP COMPLETED WITHOUT REPORTED ERRORS.
) else (
    echo [OVERALL RESULT] SETUP COMPLETED WITH %SetupErrors% ERROR^(S^).
)

echo.
echo ===============================================================================
echo                           SETUP COMPLETELY FINISHED
echo ===============================================================================
echo.
echo All setup steps are complete.
echo.
echo This is the ONLY pause in the complete setup workflow.
echo After pressing a key, the script will return to the main menu.
echo The program will NOT automatically close.
echo.

call :FINAL_PAUSE
goto MENU


REM ============================================================================
REM DIRECTORY CREATION
REM ============================================================================

:ENSURE_DIR

if exist "%~1\" (
    echo [KEEP] %~2
    echo       %~1
    goto :eof
)

echo [CREATE] %~2
echo         %~1

mkdir "%~1" >nul 2>&1

if exist "%~1\" (
    echo [OK] Directory created.
) else (
    echo [FAILED] Unable to create directory.
    set /a SetupErrors+=1
)

goto :eof


REM ============================================================================
REM SHAREUSER CREATION / VERIFICATION
REM ============================================================================

:ENSURE_SHAREUSER

net user "%ShareUser%" >nul 2>&1

if not errorlevel 1 (
    echo [KEEP] ShareUser already exists.
    echo.

    net user "%ShareUser%"

    echo.
    echo [SECURITY] Existing ShareUser password was not changed.
    goto :eof
)

echo [CREATE] ShareUser does not exist.
echo.
echo A secure password will be requested interactively.
echo The password will NOT be stored in this script.
echo.

net user "%ShareUser%" * /add

if errorlevel 1 (
    echo.
    echo [FAILED] Unable to create ShareUser.
    set /a SetupErrors+=1
    goto :eof
)

net user "%ShareUser%" /active:yes >nul 2>&1

echo.
echo [OK] ShareUser account created.
echo [OK] ShareUser account activated.
echo [SECURITY] Password was supplied interactively.
echo [SECURITY] Password was not stored.

goto :eof


REM ============================================================================
REM SMB SHARE CREATION / VERIFICATION
REM ============================================================================

:ENSURE_SMB_SHARE

set "SHARECHECK_NAME=%ShareName%"
set "SHARECHECK_PATH=%SharePath%"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$s=Get-SmbShare -Name $env:SHARECHECK_NAME -ErrorAction SilentlyContinue; if($null -eq $s){exit 1}; Write-Host ('Existing share : ' + $s.Name); Write-Host ('Existing path  : ' + $s.Path); if($s.Path -ieq $env:SHARECHECK_PATH){exit 0}else{exit 2}"

if not errorlevel 1 (
    echo [KEEP] Existing SMB share points to the expected path.
    goto :eof
)

if errorlevel 2 (
    echo.
    echo [WARNING] Existing SMB share points to another path.
    echo [WARNING] No automatic changes were made.
    set /a SetupWarnings+=1
    goto :eof
)

echo.
echo [CREATE] SMB share does not exist.
echo         Name : %ShareName%
echo         Path : %SharePath%
echo.

net share "%ShareName%"="%SharePath%" /GRANT:"%ShareUser%",CHANGE /REMARK:"Administration Shared Data"

if errorlevel 1 (
    echo [FAILED] Unable to create SMB share.
    set /a SetupErrors+=1
    goto :eof
)

echo [OK] SMB share created successfully.

goto :eof


REM ============================================================================
REM CHECK DIRECTORIES
REM ============================================================================

:CHECK_DIRECTORIES_MENU

cls

echo.
echo ===============================================================================
echo                            CHECK DIRECTORIES
echo ===============================================================================
echo.

call :VERIFY_DIRECTORIES

echo.
echo [RESULT] Directory check completed.
echo.

call :FINAL_PAUSE
goto MENU


:VERIFY_DIRECTORIES

set "DirectoryFailures=0"

call :VERIFY_ONE_DIR "%ITAdmin%" "IT-Admin"
call :VERIFY_ONE_DIR "%Installers%" "Installers"
call :VERIFY_ONE_DIR "%Drivers%" "Drivers"
call :VERIFY_ONE_DIR "%Setup%" "Setup"
call :VERIFY_ONE_DIR "%Tools%" "Tools"
call :VERIFY_ONE_DIR "%Scripts%" "Scripts"
call :VERIFY_ONE_DIR "%NetworkShareScripts%" "Network-Share"

call :VERIFY_ONE_DIR "%AdminConsole%" "AdminConsole"
call :VERIFY_ONE_DIR "%Clients%" "Clients"
call :VERIFY_ONE_DIR "%Logs%" "Logs"
call :VERIFY_ONE_DIR "%Reports%" "Reports"
call :VERIFY_ONE_DIR "%Config%" "Config"

call :VERIFY_ONE_DIR "%SharePath%" "Share"

echo.

if "%DirectoryFailures%"=="0" (
    echo [SUMMARY] All required directories are present.
    exit /b 0
)

echo [SUMMARY] %DirectoryFailures% required directory/directories are missing.
exit /b 1


:VERIFY_ONE_DIR

if exist "%~1\" (
    echo [OK]      %~2
    echo           %~1
) else (
    echo [MISSING] %~2
    echo           %~1
    set /a DirectoryFailures+=1
)

goto :eof


REM ============================================================================
REM CHECK SHAREUSER
REM ============================================================================

:CHECK_SHAREUSER

cls

echo.
echo ===============================================================================
echo                              CHECK SHAREUSER
echo ===============================================================================
echo.

call :VERIFY_SHAREUSER

echo.
echo [RESULT] ShareUser check completed.
echo.

call :FINAL_PAUSE
goto MENU


:VERIFY_SHAREUSER

net user "%ShareUser%" >nul 2>&1

if errorlevel 1 (
    echo [FAILED] ShareUser account does not exist.
    exit /b 1
)

echo [OK] ShareUser account exists.
echo.

net user "%ShareUser%"

echo.
echo [SECURITY] Password is never displayed.
echo [SECURITY] Password is never stored.
echo [SECURITY] Password is never changed by this check.

exit /b 0


REM ============================================================================
REM CHECK SMB SHARE
REM ============================================================================

:CHECK_SHARE

cls

echo.
echo ===============================================================================
echo                               CHECK SMB SHARE
echo ===============================================================================
echo.

call :VERIFY_SMB_SHARE

echo.
echo [SHARE ACCESS PERMISSIONS]
echo -------------------------------------------------------------------------------

set "SHARECHECK_NAME=%ShareName%"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$a=Get-SmbShareAccess -Name $env:SHARECHECK_NAME -ErrorAction SilentlyContinue; if($null -eq $a){Write-Host '[FAILED] Unable to read share permissions.'}else{$a | Format-Table -AutoSize}"

echo.
echo [RESULT] SMB share check completed.
echo.

call :FINAL_PAUSE
goto MENU


:VERIFY_SMB_SHARE

set "SHARECHECK_NAME=%ShareName%"
set "SHARECHECK_PATH=%SharePath%"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$s=Get-SmbShare -Name $env:SHARECHECK_NAME -ErrorAction SilentlyContinue; if($null -eq $s){exit 1}; Write-Host ('Name : ' + $s.Name); Write-Host ('Path : ' + $s.Path); if($s.Path -ieq $env:SHARECHECK_PATH){exit 0}else{exit 2}"

if not errorlevel 1 (
    echo [OK] SMB share exists and points to:
    echo     %SharePath%
    exit /b 0
)

if errorlevel 2 (
    echo [WARNING] SMB share exists but points to another path.
    echo [WARNING] No changes were made.
    exit /b 2
)

echo [FAILED] SMB share %ShareName% was not found.
exit /b 1


REM ============================================================================
REM CHECK NTFS
REM ============================================================================

:CHECK_NTFS

cls

echo.
echo ===============================================================================
echo                           CHECK NTFS PERMISSIONS
echo ===============================================================================
echo.

if not exist "%SharePath%\" (
    echo [FAILED] Share path does not exist:
    echo          %SharePath%
    call :FINAL_PAUSE
    goto MENU
)

echo [READ-ONLY] Current NTFS permissions:
echo.
echo -------------------------------------------------------------------------------

icacls "%SharePath%"

echo -------------------------------------------------------------------------------
echo.
echo [INFO] No NTFS permissions were modified.
echo.

call :FINAL_PAUSE
goto MENU


REM ============================================================================
REM APPLY NTFS PERMISSION
REM ============================================================================

:APPLY_NTFS

cls

echo.
echo ===============================================================================
echo                      APPLY SHAREUSER NTFS PERMISSION
echo ===============================================================================
echo.

call :REQUIRE_ADMIN

if errorlevel 1 (
    call :FINAL_PAUSE
    goto MENU
)

echo This action changes NTFS permissions.
echo.
echo Permission:
echo   %COMPUTERNAME%\%ShareUser% = Modify
echo.
echo Existing permissions will NOT be removed.
echo.

choice /C YN /N /M "Apply this NTFS permission? [Y/N]: "

if errorlevel 2 (
    echo.
    echo [CANCELLED] No changes were made.
    call :FINAL_PAUSE
    goto MENU
)

echo.
echo [ACTION] Applying NTFS permission...

icacls "%SharePath%" /grant "%COMPUTERNAME%\%ShareUser%:(OI)(CI)M"

if errorlevel 1 (
    echo [FAILED] NTFS permission command reported an error.
) else (
    echo [OK] NTFS permission applied.
)

echo.
echo [VERIFY]
icacls "%SharePath%"

echo.
echo [RESULT] NTFS operation completed.

call :FINAL_PAUSE
goto MENU


REM ============================================================================
REM WINRM MENU
REM ============================================================================

:CONFIGURE_WINRM

cls

echo.
echo ===============================================================================
echo                         CONFIGURE / CHECK WINRM
echo ===============================================================================
echo.

call :REQUIRE_ADMIN

if errorlevel 1 (
    call :FINAL_PAUSE
    goto MENU
)

echo [CURRENT STATUS]
call :SHOW_WINRM_STATUS

echo.
echo -------------------------------------------------------------------------------
echo WinRM configuration can change system/network behavior.
echo -------------------------------------------------------------------------------
echo.

choice /C YN /N /M "Configure WinRM now? [Y/N]: "

if errorlevel 2 (
    echo.
    echo [SKIPPED] No WinRM changes were made.
    echo.
    echo [FINAL RESULT] Current WinRM status was displayed above.
    call :FINAL_PAUSE
    goto MENU
)

echo.
echo [ACTION] Running Enable-PSRemoting -Force...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "Enable-PSRemoting -Force"

if errorlevel 1 (
    echo.
    echo [FAILED] WinRM configuration reported an error.
) else (
    echo.
    echo [OK] WinRM configuration completed.
)

echo.
echo [VERIFY] Testing WinRM after configuration...
call :VERIFY_WINRM

echo.
echo [RESULT] WinRM operation completed.

call :FINAL_PAUSE
goto MENU


:SHOW_WINRM_STATUS

echo.
echo [SERVICE]
sc query WinRM

echo.
echo [STARTUP CONFIGURATION]
sc qc WinRM

echo.
echo [LISTENER]
winrm enumerate winrm/config/listener

echo.
echo [LOCAL TEST]

powershell -NoProfile -ExecutionPolicy Bypass -Command "try{Test-WSMan -ComputerName localhost -ErrorAction Stop | Out-Null; exit 0}catch{exit 1}"

if errorlevel 1 (
    echo [WARNING] Local WinRM test failed.
) else (
    echo [OK] Local WinRM test succeeded.
)

goto :eof


:VERIFY_WINRM

powershell -NoProfile -ExecutionPolicy Bypass -Command "try{Test-WSMan -ComputerName localhost -ErrorAction Stop | Out-Null; exit 0}catch{exit 1}"

if errorlevel 1 (
    echo [WARNING] WinRM verification failed.
    exit /b 1
)

echo [OK] WinRM is responding locally.
exit /b 0


REM ============================================================================
REM NETWORK INFORMATION
REM ============================================================================

:NETWORK_INFORMATION

cls

echo.
echo ===============================================================================
echo                           NETWORK INFORMATION
echo ===============================================================================
echo.

echo [HOSTNAME]
hostname

echo.
echo [IP CONFIGURATION]
ipconfig /all

echo.
echo [NETWORK PROFILE]

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "Get-NetConnectionProfile | Select-Object Name,InterfaceAlias,NetworkCategory,IPv4Connectivity,IPv6Connectivity | Format-Table -AutoSize"

echo.
echo [TCP 445]

netstat -ano | findstr ":445"

echo.
echo [SERVER TCP 445 TEST]

set "TEST_SERVER=%ServerIP%"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "Test-NetConnection -ComputerName $env:TEST_SERVER -Port 445"

echo.
echo [RESULT] Network information check completed.

call :FINAL_PAUSE
goto MENU


REM ============================================================================
REM OPEN SHARE
REM ============================================================================

:OPEN_SHARE

cls

echo.
echo ===============================================================================
echo                             OPEN D:\SHARE
echo ===============================================================================
echo.

if not exist "%SharePath%\" (
    echo [FAILED] Folder does not exist:
    echo          %SharePath%
    call :FINAL_PAUSE
    goto MENU
)

echo [OPEN] %SharePath%

start "" explorer.exe "%SharePath%"

echo.
echo [OK] Explorer launch requested.

call :FINAL_PAUSE
goto MENU


REM ============================================================================
REM OPEN IT-ADMIN
REM ============================================================================

:OPEN_ITADMIN

cls

echo.
echo ===============================================================================
echo                            OPEN D:\IT-ADMIN
echo ===============================================================================
echo.

if not exist "%ITAdmin%\" (
    echo [FAILED] Folder does not exist:
    echo          %ITAdmin%
    call :FINAL_PAUSE
    goto MENU
)

echo [OPEN] %ITAdmin%

start "" explorer.exe "%ITAdmin%"

echo.
echo [OK] Explorer launch requested.

call :FINAL_PAUSE
goto MENU


REM ============================================================================
REM OPEN ADMINCONSOLE
REM ============================================================================

:OPEN_ADMINCONSOLE

cls

echo.
echo ===============================================================================
echo                           OPEN ADMINCONSOLE
echo ===============================================================================
echo.

if not exist "%AdminConsole%\" (
    echo [FAILED] Folder does not exist:
    echo          %AdminConsole%
    call :FINAL_PAUSE
    goto MENU
)

echo [OPEN] %AdminConsole%

start "" explorer.exe "%AdminConsole%"

echo.
echo [OK] Explorer launch requested.

call :FINAL_PAUSE
goto MENU


REM ============================================================================
REM SETUP SUMMARY MENU
REM ============================================================================

:SETUP_SUMMARY

cls

echo.
echo ===============================================================================
echo                             SETUP SUMMARY
echo ===============================================================================
echo.

echo [SERVER]
echo Expected Hostname : %ExpectedHostname%
echo Current Hostname  : %COMPUTERNAME%
echo Server IP         : %ServerIP%
echo.

echo [SMB]
echo Share Name        : %ShareName%
echo Share Path        : %SharePath%
echo Share User        : %ShareUser%
echo UNC Path          : \\%ExpectedHostname%\%ShareName%
echo.

echo [ADMINISTRATION]
echo IT-Admin          : %ITAdmin%
echo AdminConsole      : %AdminConsole%
echo Scripts           : %NetworkShareScripts%
echo Client List       : %ClientList%
echo.

echo [PRESERVATION]
echo Existing files    : PRESERVED
echo Existing folders  : PRESERVED
echo Existing SMB      : NOT DELETED / RECREATED
echo ShareUser password: NOT RESET
echo D:\Share\Client   : NOT CREATED / MODIFIED
echo.

echo [SECURITY]
echo Security Audit    : READ-ONLY
echo Security Harden   : MANUAL / EXPLICIT
echo Firewall          : NOT AUTOMATICALLY MODIFIED
echo SMB hardening     : NOT AUTOMATICALLY MODIFIED
echo NTFS              : NOT AUTOMATICALLY MODIFIED
echo WinRM             : CONFIRMATION REQUIRED
echo.

echo [SECURITY MENU]
echo [I] Full Security Audit
echo [J] Apply Security Hardening

call :FINAL_PAUSE
goto MENU


REM ============================================================================
REM SAFETY STATUS
REM ============================================================================

:SAFETY_STATUS

cls

echo.
echo ===============================================================================
echo                       SAFETY / PRESERVATION STATUS
echo ===============================================================================
echo.

echo [OK] Existing D:\Share files are preserved.
echo [OK] Existing D:\Share folders are preserved.
echo [OK] Existing SMB shares are not deleted/recreated.
echo [OK] Existing ShareUser passwords are not changed.
echo [OK] D:\Share\Client is not created automatically.
echo [OK] D:\Share\Client is not modified automatically.
echo [OK] NTFS permissions are not automatically changed by normal setup.
echo [OK] Firewall rules are not automatically changed by normal setup.
echo [OK] SMB security is not automatically hardened by normal setup.
echo [OK] WinRM changes require explicit confirmation.
echo.
echo [OK] Security hardening is separated from normal setup.
echo [OK] Security hardening requires Administrator privileges.
echo [OK] Security hardening requires explicit confirmation.
echo [OK] Full Security Audit is READ-ONLY.
echo.
echo [OK] Setup steps do not pause individually.
echo [OK] Setup results are displayed continuously.
echo [OK] Final summary appears after all setup steps.
echo [OK] One final pause occurs after the summary.
echo [OK] Main menu is displayed after the pause.
echo [OK] Program does not automatically close.
echo.
echo [INFO] Only Q -> Y exits the program.

call :FINAL_PAUSE
goto MENU


REM ============================================================================
REM AUTOMATED TROUBLESHOOTING
REM ============================================================================

:AUTOMATED_TROUBLESHOOTING

cls

set "TroublePass=0"
set "TroubleWarn=0"
set "TroubleFail=0"

echo.
echo ===============================================================================
echo                         AUTOMATED TROUBLESHOOTING
echo ===============================================================================
echo.
echo Target Host : %ExpectedHostname%
echo Target IP   : %ServerIP%
echo Share       : \\%ExpectedHostname%\%ShareName%
echo.
echo All tests are READ-ONLY.
echo No configuration will be changed.
echo.


REM ----------------------------------------------------------------------------
REM 1 - TARGET CONFIGURATION
REM ----------------------------------------------------------------------------

echo ===============================================================================
echo [1/8] TARGET CONFIGURATION
echo ===============================================================================

echo [PASS] Hostname : %ExpectedHostname%
echo [PASS] IP       : %ServerIP%
echo [PASS] Share    : \\%ExpectedHostname%\%ShareName%

set /a TroublePass+=1


REM ----------------------------------------------------------------------------
REM 2 - PING
REM ----------------------------------------------------------------------------

echo.
echo ===============================================================================
echo [2/8] PING
echo ===============================================================================

ping -n 2 -w 1000 "%ServerIP%"

if errorlevel 1 (
    echo [FAIL] Ping failed.
    set /a TroubleFail+=1
) else (
    echo [PASS] Ping succeeded.
    set /a TroublePass+=1
)


REM ----------------------------------------------------------------------------
REM 3 - NAME RESOLUTION
REM ----------------------------------------------------------------------------

echo.
echo ===============================================================================
echo [3/8] NAME RESOLUTION
echo ===============================================================================

set "TARGET_PC=%ExpectedHostname%"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$t=$env:TARGET_PC; try{$r=Resolve-DnsName $t -ErrorAction Stop; $r | Select-Object Name,Type,IPAddress | Format-Table -AutoSize; Write-Host '[PASS] DNS name resolution succeeded.'; exit 0}catch{Write-Host '[WARN] DNS resolution unavailable. SMB may still work through NetBIOS/LLMNR.'; exit 2}"

if errorlevel 2 (
    set /a TroubleWarn+=1
) else if errorlevel 1 (
    set /a TroubleFail+=1
) else (
    set /a TroublePass+=1
)


REM ----------------------------------------------------------------------------
REM 4 - TCP 445
REM ----------------------------------------------------------------------------

echo.
echo ===============================================================================
echo [4/8] TCP PORT 445
echo ===============================================================================

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$r=Test-NetConnection -ComputerName $env:TARGET_PC -Port 445 -WarningAction SilentlyContinue; if($r.TcpTestSucceeded){Write-Host '[PASS] TCP 445 is reachable.'; exit 0}else{Write-Host '[FAIL] TCP 445 is not reachable.'; exit 1}"

if errorlevel 1 (
    set /a TroubleFail+=1
) else (
    set /a TroublePass+=1
)


REM ----------------------------------------------------------------------------
REM 5 - DIRECT SMB SHARE
REM ----------------------------------------------------------------------------

echo.
echo ===============================================================================
echo [5/8] DIRECT SMB SHARE
echo ===============================================================================

set "SHARE_TARGET=\\%ExpectedHostname%\%ShareName%"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "try{Get-ChildItem -LiteralPath $env:SHARE_TARGET -ErrorAction Stop | Select-Object -First 5 Name,Length,LastWriteTime | Format-Table -AutoSize; Write-Host ('[PASS] Share accessible: ' + $env:SHARE_TARGET); exit 0}catch{Write-Host ('[FAIL] Share access failed: ' + $_.Exception.Message); exit 1}"

if errorlevel 1 (
    set /a TroubleFail+=1
) else (
    set /a TroublePass+=1
)


REM ----------------------------------------------------------------------------
REM 6 - WINRM
REM ----------------------------------------------------------------------------

echo.
echo ===============================================================================
echo [6/8] WINRM
echo ===============================================================================

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "try{Test-WSMan -ComputerName $env:TARGET_PC -ErrorAction Stop | Out-Null; Write-Host '[PASS] WinRM responded.'; exit 0}catch{Write-Host '[WARN] WinRM did not respond.'; exit 1}"

if errorlevel 1 (
    set /a TroubleWarn+=1
) else (
    set /a TroublePass+=1
)


REM ----------------------------------------------------------------------------
REM 7 - EXISTING SMB CONNECTIONS
REM ----------------------------------------------------------------------------

echo.
echo ===============================================================================
echo [7/8] EXISTING SMB CONNECTIONS
echo ===============================================================================

net use

echo.
echo [INFO] Existing SMB connection information displayed.

set /a TroublePass+=1


REM ----------------------------------------------------------------------------
REM 8 - NETWORK VIEW
REM ----------------------------------------------------------------------------

echo.
echo ===============================================================================
echo [8/8] NETWORK VIEW
echo ===============================================================================

echo [INFO] Network browsing is informational only.
echo.

net view "\\%ExpectedHostname%" 2>&1

if errorlevel 1 (
    echo [WARN] Network view could not enumerate the server.
    set /a TroubleWarn+=1
) else (
    echo [PASS] Network view completed.
    set /a TroublePass+=1
)


REM ----------------------------------------------------------------------------
REM TROUBLESHOOTING SUMMARY
REM ----------------------------------------------------------------------------

echo.
echo ===============================================================================
echo                       TROUBLESHOOTING SUMMARY
echo ===============================================================================
echo.

echo PASS      : %TroublePass%
echo WARNINGS  : %TroubleWarn%
echo FAILURES  : %TroubleFail%
echo.

if "%TroubleFail%"=="0" if "%TroubleWarn%"=="0" (
    echo [OVERALL RESULT] ALL TESTS PASSED.
) else if "%TroubleFail%"=="0" (
    echo [OVERALL RESULT] CONNECTIVITY PASSED WITH WARNINGS.
) else (
    echo [OVERALL RESULT] ONE OR MORE TESTS FAILED.
)

echo.
echo No configuration changes were made.

call :FINAL_PAUSE
goto MENU


REM ============================================================================
REM SECURITY / CONFIGURATION PREFLIGHT
REM ============================================================================

:SECURITY_PREFLIGHT

cls

set "PreflightPass=0"
set "PreflightWarn=0"
set "PreflightFail=0"

echo.
echo ===============================================================================
echo                      SECURITY / CONFIGURATION PREFLIGHT
echo ===============================================================================
echo.
echo READ-ONLY SECURITY REVIEW.
echo No security configuration will be modified.
echo.


REM ----------------------------------------------------------------------------
REM 1 - NETWORK PROFILE
REM ----------------------------------------------------------------------------

echo ===============================================================================
echo [1/9] NETWORK PROFILE
echo ===============================================================================

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$p=Get-NetConnectionProfile; $p | Select-Object Name,InterfaceAlias,NetworkCategory,IPv4Connectivity,IPv6Connectivity | Format-Table -AutoSize; if($p.NetworkCategory -contains 'Public'){Write-Host '[WARNING] Public network detected.'; exit 1}else{Write-Host '[PASS] No Public network detected.'; exit 0}"

if errorlevel 1 (
    set /a PreflightWarn+=1
) else (
    set /a PreflightPass+=1
)


REM ----------------------------------------------------------------------------
REM 2 - WINDOWS FIREWALL
REM ----------------------------------------------------------------------------

echo.
echo ===============================================================================
echo [2/9] WINDOWS FIREWALL
echo ===============================================================================

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$p=Get-NetFirewallProfile; $p | Select-Object Name,Enabled,DefaultInboundAction,DefaultOutboundAction | Format-Table -AutoSize; if(($p | Where-Object {$_.Enabled -eq $false}).Count -gt 0){Write-Host '[WARNING] Firewall profile disabled.'; exit 1}else{Write-Host '[PASS] Firewall profiles enabled.'; exit 0}"

if errorlevel 1 (
    set /a PreflightWarn+=1
) else (
    set /a PreflightPass+=1
)


REM ----------------------------------------------------------------------------
REM 3 - SMB SERVER CONFIGURATION
REM ----------------------------------------------------------------------------

echo.
echo ===============================================================================
echo [3/9] SMB SERVER CONFIGURATION
echo ===============================================================================

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "Get-SmbServerConfiguration | Select-Object EnableSMB1Protocol,EnableSMB2Protocol,EnableSecuritySignature,RequireSecuritySignature,EncryptData,RejectUnencryptedAccess,EnableStrictNameChecking | Format-List"

echo.
echo [REVIEW] SMB1 should remain disabled.
echo [REVIEW] SMB2/3 should remain enabled.
echo [REVIEW] SMB signing should be required.
echo [REVIEW] SMB encryption may be enabled after compatibility review.

set /a PreflightPass+=1


REM ----------------------------------------------------------------------------
REM 4 - SMB1 STATUS
REM ----------------------------------------------------------------------------

echo.
echo ===============================================================================
echo [4/9] SMB1 STATUS
echo ===============================================================================

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$s=Get-SmbServerConfiguration; if($s.EnableSMB1Protocol){Write-Host '[HIGH] SMB1 is enabled.'; exit 1}else{Write-Host '[PASS] SMB1 is disabled.'; exit 0}"

if errorlevel 1 (
    set /a PreflightFail+=1
) else (
    set /a PreflightPass+=1
)


REM ----------------------------------------------------------------------------
REM 5 - GUEST / SIGNING
REM ----------------------------------------------------------------------------

echo.
echo ===============================================================================
echo [5/9] GUEST / SIGNING
echo ===============================================================================

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$s=Get-SmbClientConfiguration; $s | Select-Object EnableInsecureGuestLogons,RequireSecuritySignature | Format-List; $x=0; if($s.EnableInsecureGuestLogons){Write-Host '[HIGH] Insecure guest logons enabled.'; $x=1}else{Write-Host '[PASS] Insecure guest logons disabled.'}; if(-not $s.RequireSecuritySignature){Write-Host '[WARNING] SMB client signing is not required.'; $x=1}else{Write-Host '[PASS] SMB client signing is required.'}; exit $x"

if errorlevel 1 (
    set /a PreflightWarn+=1
) else (
    set /a PreflightPass+=1
)


REM ----------------------------------------------------------------------------
REM 6 - SMB SHARE PERMISSIONS
REM ----------------------------------------------------------------------------

echo.
echo ===============================================================================
echo [6/9] SMB SHARE PERMISSIONS
echo ===============================================================================

set "SHARECHECK_NAME=%ShareName%"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$a=Get-SmbShareAccess -Name $env:SHARECHECK_NAME -ErrorAction SilentlyContinue; if($null -eq $a){Write-Host '[FAIL] Unable to read share permissions.'; exit 2}; $a | Format-Table -AutoSize; $e=$a | Where-Object {$_.AccountName -eq 'Everyone' -and $_.AccessRight -eq 'Full'}; if($e){Write-Host '[HIGH] Everyone has FULL share access.'; exit 1}else{Write-Host '[PASS] Everyone FULL access not detected.'; exit 0}"

if errorlevel 2 (
    set /a PreflightFail+=1
) else if errorlevel 1 (
    set /a PreflightWarn+=1
) else (
    set /a PreflightPass+=1
)


REM ----------------------------------------------------------------------------
REM 7 - NTFS PERMISSIONS
REM ----------------------------------------------------------------------------

echo.
echo ===============================================================================
echo [7/9] NTFS PERMISSIONS
echo ===============================================================================

if exist "%SharePath%\" (
    icacls "%SharePath%"
    echo.
    echo [REVIEW] Confirm ShareUser has required Modify access.
    echo [REVIEW] Confirm SYSTEM and Administrators retain Full Control.
    set /a PreflightPass+=1
) else (
    echo [FAIL] Share path does not exist.
    set /a PreflightFail+=1
)


REM ----------------------------------------------------------------------------
REM 8 - FIREWALL SMB / WINRM
REM ----------------------------------------------------------------------------

echo.
echo ===============================================================================
echo [8/9] FIREWALL SMB / WINRM
echo ===============================================================================

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$groups=@('File and Printer Sharing','Windows Management Instrumentation (WMI)','Windows Firewall Remote Management','Windows Remote Management'); $found=$false; foreach($g in $groups){$r=Get-NetFirewallRule -DisplayGroup $g -ErrorAction SilentlyContinue | Where-Object {$_.Enabled -eq 'True' -and $_.Direction -eq 'Inbound' -and $_.Action -eq 'Allow' -and ($_.Profile -band 4)}; if($r){$found=$true; Write-Host ('['+$g+'] Public-profile inbound rules detected:'); $r | Select-Object DisplayName,Profile,Direction,Action | Format-Table -AutoSize}}; if($found){Write-Host '[WARNING] Public-profile SMB/remote-management exposure detected.'; exit 1}else{Write-Host '[PASS] No matching Public-profile inbound exposure detected.'; exit 0}"

if errorlevel 1 (
    set /a PreflightWarn+=1
) else (
    set /a PreflightPass+=1
)


REM ----------------------------------------------------------------------------
REM 9 - WINRM
REM ----------------------------------------------------------------------------

echo.
echo ===============================================================================
echo [9/9] WINRM
echo ===============================================================================

echo [SERVICE]
sc query WinRM

echo.
echo [LISTENER]
winrm enumerate winrm/config/listener

echo.
echo [LOCAL TEST]

call :VERIFY_WINRM

if errorlevel 1 (
    echo [WARNING] WinRM local test failed.
    set /a PreflightWarn+=1
) else (
    echo [PASS] WinRM local test succeeded.
    set /a PreflightPass+=1
)


REM ----------------------------------------------------------------------------
REM PREFLIGHT SUMMARY
REM ----------------------------------------------------------------------------

echo.
echo ===============================================================================
echo                           PREFLIGHT SUMMARY
echo ===============================================================================
echo.

echo PASS      : %PreflightPass%
echo WARNINGS  : %PreflightWarn%
echo FAILURES  : %PreflightFail%
echo.

if "%PreflightFail%"=="0" if "%PreflightWarn%"=="0" (
    echo [OVERALL RESULT] NO IMMEDIATE PREFLIGHT ISSUES DETECTED.
) else if "%PreflightFail%"=="0" (
    echo [OVERALL RESULT] REVIEW RECOMMENDED.
) else (
    echo [OVERALL RESULT] HIGH PRIORITY REVIEW REQUIRED.
)

echo.
echo [INFO] No configuration changes were made.

call :FINAL_PAUSE
goto MENU


REM ============================================================================
REM SMB / SERVER SERVICES
REM ============================================================================

:SERVER_SERVICES

cls

echo.
echo ===============================================================================
echo                         SMB / SERVER SERVICES
echo ===============================================================================
echo.

echo ===============================================================================
echo [1/5] SERVER SERVICE
echo ===============================================================================

sc query LanmanServer

echo.
echo ===============================================================================
echo [2/5] SMB SERVER CONFIGURATION
echo ===============================================================================

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "Get-SmbServerConfiguration | Select-Object EnableSMB1Protocol,EnableSMB2Protocol,EnableSecuritySignature,RequireSecuritySignature,EncryptData,RejectUnencryptedAccess,EnableStrictNameChecking,EnableLeasing,EnableMultiChannel | Format-List"

echo.
echo ===============================================================================
echo [3/5] SMB SHARES
echo ===============================================================================

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "Get-SmbShare | Select-Object Name,Path,Description,FolderEnumerationMode,EncryptData | Format-Table -AutoSize"

echo.
echo ===============================================================================
echo [4/5] SMB SESSIONS
echo ===============================================================================

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "Get-SmbSession | Select-Object ClientComputerName,ClientUserName,Dialect,NumOpens,SecondsIdle | Format-Table -AutoSize"

echo.
echo ===============================================================================
echo [5/5] TCP 445
echo ===============================================================================

netstat -ano | findstr ":445"

echo.
echo ===============================================================================
echo                           SERVICE SUMMARY
echo ===============================================================================
echo.

echo [INFO] SMB/server information displayed.
echo [INFO] No configuration was changed.

call :FINAL_PAUSE
goto MENU


REM ============================================================================
REM SMB SHARE PERMISSIONS
REM ============================================================================

:CHECK_SHARE_PERMISSIONS

cls

echo.
echo ===============================================================================
echo                         SMB SHARE PERMISSIONS
echo ===============================================================================
echo.

set "SHARECHECK_NAME=%ShareName%"

echo Share Name : %ShareName%
echo Share Path : %SharePath%
echo.

echo -------------------------------------------------------------------------------
echo CURRENT SHARE PERMISSIONS
echo -------------------------------------------------------------------------------

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$a=Get-SmbShareAccess -Name $env:SHARECHECK_NAME -ErrorAction SilentlyContinue; if($null -eq $a){Write-Host '[FAILED] Unable to read share permissions.'; exit 2}; $a | Format-Table -AutoSize; $f=$a | Where-Object {$_.AccountName -eq 'Everyone' -and $_.AccessRight -eq 'Full'}; if($f){Write-Host '[HIGH] Everyone currently has FULL share access.'}; $e=$a | Where-Object {$_.AccountName -eq 'Everyone'}; if($e -and -not $f){Write-Host '[WARNING] Everyone has share access.'}; if(-not $e){Write-Host '[GOOD] Everyone share access not detected.'}"

echo.
echo [INFO] This operation is READ-ONLY.
echo [INFO] No share permissions were modified.

call :FINAL_PAUSE
goto MENU


REM ============================================================================
REM FULL SECURITY AUDIT
REM ============================================================================

:FULL_SECURITY_AUDIT

cls

echo.
echo ===============================================================================
echo                         FULL SECURITY AUDIT
echo ===============================================================================
echo.
echo This audit is READ-ONLY.
echo No configuration will be changed.
echo.

REM ----------------------------------------------------------------------------
REM NETWORK PROFILE
REM ----------------------------------------------------------------------------

echo.
echo ===============================================================================
echo NETWORK PROFILE
echo ===============================================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "Get-NetConnectionProfile | Select-Object Name,InterfaceAlias,InterfaceIndex,NetworkCategory,IPv4Connectivity,IPv6Connectivity | Format-List"

echo.
echo Interpretation:
echo Private network  = normally appropriate for trusted LAN.
echo Public network   = WARNING for a server providing SMB services.


REM ----------------------------------------------------------------------------
REM FIREWALL
REM ----------------------------------------------------------------------------

echo.
echo ===============================================================================
echo WINDOWS FIREWALL PROFILES
echo ===============================================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "Get-NetFirewallProfile | Select-Object Name,Enabled,DefaultInboundAction,DefaultOutboundAction,AllowInboundRules,AllowLocalFirewallRules,AllowLocalIPsecRules | Format-Table -AutoSize"

echo.
echo Checking common SMB and WinRM firewall rules...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$groups=@('File and Printer Sharing','Windows Management Instrumentation (WMI)','Windows Firewall Remote Management','Windows Remote Management'); foreach($g in $groups){Write-Host ('--- ' + $g + ' ---'); Get-NetFirewallRule -DisplayGroup $g -ErrorAction SilentlyContinue | Where-Object {$_.Enabled -eq 'True' -and $_.Direction -eq 'Inbound'} | Select-Object DisplayName,Enabled,Profile,Direction,Action | Format-Table -AutoSize}"

echo.
echo NOTE:
echo This audit does not enable, disable, create, or remove firewall rules.


REM ----------------------------------------------------------------------------
REM SMB SERVER SECURITY
REM ----------------------------------------------------------------------------

echo.
echo ===============================================================================
echo SMB SERVER SECURITY
echo ===============================================================================
echo.

echo --- SMB Server Configuration ---
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "Get-SmbServerConfiguration | Select-Object EnableSMB1Protocol,EnableSMB2Protocol,EnableSecuritySignature,RequireSecuritySignature,EncryptData,RejectUnencryptedAccess,EnableAuthenticateUserSharing,EnableStrictNameChecking,EnableLeasing,EnableMultiChannel | Format-List"

echo.
echo --- SMB Server Shares ---
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "Get-SmbShare | Select-Object Name,Path,Description,EncryptData,FolderEnumerationMode,ConcurrentUserLimit | Format-Table -AutoSize"

echo.
echo --- SMB Server Sessions ---
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "Get-SmbSession | Select-Object ClientComputerName,ClientUserName,NumOpens,Dialect,SecondsIdle,SecondsExists | Format-Table -AutoSize"

echo.
echo Security notes:
echo RequireSecuritySignature = True is preferred where compatible.
echo EnableSMB1Protocol = False is preferred.
echo EncryptData = True provides stronger protection but requires compatibility review.


REM ----------------------------------------------------------------------------
REM SMB1
REM ----------------------------------------------------------------------------

echo.
echo ===============================================================================
echo SMB1 STATUS
echo ===============================================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "Get-SmbServerConfiguration | Select-Object EnableSMB1Protocol | Format-List"

echo.
echo --- Windows Optional Feature ---
echo.

dism /online /Get-FeatureInfo /FeatureName:SMB1Protocol

echo.
echo SMB1 is obsolete and should normally remain disabled.
echo This audit does NOT disable SMB1.


REM ----------------------------------------------------------------------------
REM GUEST / SIGNING
REM ----------------------------------------------------------------------------

echo.
echo ===============================================================================
echo GUEST / SMB SIGNING
echo ===============================================================================
echo.

echo --- SMB Client Configuration ---
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$s=Get-SmbClientConfiguration; $s | Select-Object EnableInsecureGuestLogons,RequireSecuritySignature | Format-List"

echo.
echo --- SMB Server Signing ---
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$s=Get-SmbServerConfiguration; $s | Select-Object EnableSecuritySignature,RequireSecuritySignature | Format-List"

echo.
echo --- Local Guest Account ---
echo.

net user Guest

echo.
echo --- LSA Anonymous / Guest Related Values ---
echo.

reg query "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RestrictAnonymous
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RestrictAnonymousSAM
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v EveryoneIncludesAnonymous

echo.
echo Security notes:
echo Insecure guest SMB access should normally remain disabled.
echo SMB signing should be required where compatibility permits.
echo This audit does NOT modify guest or signing configuration.


REM ----------------------------------------------------------------------------
REM WINRM
REM ----------------------------------------------------------------------------

echo.
echo ===============================================================================
echo WINRM SECURITY
echo ===============================================================================
echo.

echo --- WinRM Service ---
echo.

sc query WinRM

echo.
echo --- WinRM Startup Configuration ---
echo.

sc qc WinRM

echo.
echo --- WinRM Listeners ---
echo.

winrm enumerate winrm/config/listener

echo.
echo --- Local WinRM Test ---
echo.

call :VERIFY_WINRM

if errorlevel 1 (
    echo [WARNING] WinRM local verification failed.
) else (
    echo [OK] WinRM local verification succeeded.
)


REM ----------------------------------------------------------------------------
REM SHARE PERMISSIONS
REM ----------------------------------------------------------------------------

echo.
echo ===============================================================================
echo SMB SHARE PERMISSIONS
echo ===============================================================================
echo.

echo --- net share ---
echo.

net share "%ShareName%"

echo.
echo --- SMB Share Access Rules ---
echo.

set "SHARECHECK_NAME=%ShareName%"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$a=Get-SmbShareAccess -Name $env:SHARECHECK_NAME -ErrorAction SilentlyContinue; if($null -eq $a){Write-Host '[FAILED] Unable to read share permissions.'}else{$a | Format-Table -AutoSize}"

echo.
echo --- SMB Share Details ---
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$s=Get-SmbShare -Name $env:SHARECHECK_NAME -ErrorAction SilentlyContinue; if($s){$s | Select-Object Name,Path,Description,EncryptData,FolderEnumerationMode | Format-List}else{Write-Host '[FAILED] Share not found.'}"

echo.
echo IMPORTANT:
echo Share permissions and NTFS permissions work together.
echo The most restrictive effective permission applies.
echo.


REM ----------------------------------------------------------------------------
REM NTFS
REM ----------------------------------------------------------------------------

echo.
echo ===============================================================================
echo NTFS PERMISSIONS
echo ===============================================================================
echo.

if exist "%SharePath%\" (
    echo --- Root NTFS ACL ---
    echo.
    icacls "%SharePath%"
    echo.
    echo --- NTFS ACL Summary ---
    echo.

    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
     "$p='%SharePath%'; (Get-Acl $p) | Format-List Owner,Access"

    echo.
    echo --- ShareUser NTFS Entries ---
    echo.

    icacls "%SharePath%" | findstr /I "%ShareUser%"

    echo.
    echo NOTE:
    echo This audit does not modify D:\Share permissions.
    echo Existing files and folders are preserved.
) else (
    echo [FAIL] %SharePath% does not exist.
)


REM ----------------------------------------------------------------------------
REM SHAREUSER
REM ----------------------------------------------------------------------------

echo.
echo ===============================================================================
echo SHAREUSER ACCOUNT AUDIT
echo ===============================================================================
echo.

echo --- Account Information ---
echo.

net user "%ShareUser%"

echo.
echo --- Local Group Membership ---
echo.

net user "%ShareUser%" | findstr /I "Local Group Memberships Global Group memberships"

echo.
echo --- Administrators Group ---
echo.

net localgroup Administrators

echo.
echo --- Users Group ---
echo.

net localgroup Users

echo.
echo Security notes:
echo ShareUser should normally remain a standard account.
echo Password should not be stored in BAT files.
echo Password should not be embedded in configuration files.


REM ----------------------------------------------------------------------------
REM TCP 445
REM ----------------------------------------------------------------------------

echo.
echo ===============================================================================
echo TCP 445 SMB CONNECTIVITY
echo ===============================================================================
echo.

echo Testing local SMB listener...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "Test-NetConnection -ComputerName '%ServerIP%' -Port 445 | Select-Object ComputerName,RemotePort,TcpTestSucceeded | Format-Table -AutoSize"

echo.
echo Testing server hostname...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "Test-NetConnection -ComputerName '%ExpectedHostname%' -Port 445 | Select-Object ComputerName,RemotePort,TcpTestSucceeded | Format-Table -AutoSize"

echo.
echo --- Local Listening Port ---
echo.

netstat -ano | findstr ":445"

echo.
echo NOTE:
echo TCP 445 should be reachable only from networks that require SMB.
echo This audit does not change firewall rules.


REM ----------------------------------------------------------------------------
REM AUDIT SUMMARY
REM ----------------------------------------------------------------------------

echo.
echo ===============================================================================
echo                         SECURITY AUDIT SUMMARY
echo ===============================================================================
echo.

echo [IMPORTANT FINDINGS TO REVIEW]
echo.
echo 1. SMB server RequireSecuritySignature
echo 2. SMB client RequireSecuritySignature
echo 3. Insecure SMB guest logons
echo 4. Everyone FULL share access
echo 5. Public-profile SMB firewall exposure
echo 6. Public-profile WinRM firewall exposure
echo 7. SMB share encryption
echo 8. ShareUser NTFS Modify access
echo.
echo Use menu option [J] to apply the supported hardening actions.
echo.
echo This audit made NO configuration changes.

call :FINAL_PAUSE
goto MENU


REM ============================================================================
REM APPLY SECURITY HARDENING
REM ============================================================================

:APPLY_SECURITY_HARDENING

cls

echo.
echo ===============================================================================
echo                         APPLY SECURITY HARDENING
echo ===============================================================================
echo.
echo WARNING:
echo This operation WILL change Windows security/network configuration.
echo.
echo The following security changes are available:
echo.
echo [1] Require SMB server signing
echo [2] Require SMB client signing
echo [3] Disable insecure SMB guest logons
echo [4] Remove Everyone FULL share access
echo [5] Ensure ShareUser has Modify NTFS access
echo [6] Remove Public profile from inbound SMB firewall rules
echo [7] Remove Public profile from inbound WinRM firewall rules
echo [8] Optionally enable SMB encryption on the Share share
echo.
echo SAFETY:
echo Existing files are NOT deleted.
echo Existing folders are NOT deleted.
echo D:\Share\Client is NOT created or modified.
echo ShareUser password is NOT changed.
echo Existing SMB share is NOT deleted/recreated.
echo.
echo Some security changes can affect compatibility with older clients.
echo.

call :REQUIRE_ADMIN

if errorlevel 1 (
    echo.
    echo [FAILED] Administrator privileges are required.
    call :FINAL_PAUSE
    goto MENU
)

echo.
echo ===============================================================================
echo CURRENT SECURITY BASELINE
echo ===============================================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$s=Get-SmbServerConfiguration; Write-Host 'SMB Server Signing Required :' $s.RequireSecuritySignature; Write-Host 'SMB Server Encryption        :' $s.EncryptData; $c=Get-SmbClientConfiguration; Write-Host 'SMB Client Signing Required :' $c.RequireSecuritySignature; Write-Host 'Insecure Guest Logons        :' $c.EnableInsecureGuestLogons"

echo.
echo ===============================================================================
echo SECURITY CHANGE CONFIRMATION
echo ===============================================================================
echo.
echo These changes are intended for the trusted LAN server configuration.
echo.
echo Do NOT continue if legacy SMB clients, old NAS devices, or applications
echo require unsigned SMB or guest authentication.
echo.

choice /C YN /N /M "Apply security hardening now? [Y/N]: "

if errorlevel 2 (
    echo.
    echo [CANCELLED] No security changes were made.
    call :FINAL_PAUSE
    goto MENU
)

echo.
echo ===============================================================================
echo SECURITY HARDENING IN PROGRESS
echo ===============================================================================
echo.


REM ----------------------------------------------------------------------------
REM 1 - SERVER SMB SIGNING
REM ----------------------------------------------------------------------------

echo [1/8] SMB SERVER SIGNING
echo -------------------------------------------------------------------------------

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "try{Set-SmbServerConfiguration -EnableSecuritySignature $true -RequireSecuritySignature $true -Force -Confirm:$false; Write-Host '[OK] SMB server signing is required.'; exit 0}catch{Write-Host ('[FAILED] ' + $_.Exception.Message); exit 1}"

if errorlevel 1 (
    echo [FAILED] SMB server signing change failed.
) else (
    echo [OK] SMB server signing hardening completed.
)


REM ----------------------------------------------------------------------------
REM 2 - CLIENT SMB SIGNING
REM ----------------------------------------------------------------------------

echo.
echo [2/8] SMB CLIENT SIGNING
echo -------------------------------------------------------------------------------

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "try{Set-SmbClientConfiguration -RequireSecuritySignature $true -Force; Write-Host '[OK] SMB client signing is required.'; exit 0}catch{Write-Host ('[FAILED] ' + $_.Exception.Message); exit 1}"

if errorlevel 1 (
    echo [FAILED] SMB client signing change failed.
) else (
    echo [OK] SMB client signing hardening completed.
)


REM ----------------------------------------------------------------------------
REM 3 - INSECURE GUEST
REM ----------------------------------------------------------------------------

echo.
echo [3/8] INSECURE SMB GUEST LOGONS
echo -------------------------------------------------------------------------------

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "try{Set-SmbClientConfiguration -EnableInsecureGuestLogons $false -Force; Write-Host '[OK] Insecure SMB guest logons disabled.'; exit 0}catch{Write-Host ('[FAILED] ' + $_.Exception.Message); exit 1}"

if errorlevel 1 (
    echo [FAILED] Guest-logon hardening failed.
) else (
    echo [OK] Insecure SMB guest logons disabled.
)


REM ----------------------------------------------------------------------------
REM 4 - SHARE EVERYONE
REM ----------------------------------------------------------------------------

echo.
echo [4/8] SMB SHARE PERMISSIONS
echo -------------------------------------------------------------------------------

set "SHARECHECK_NAME=%ShareName%"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$a=Get-SmbShareAccess -Name $env:SHARECHECK_NAME -ErrorAction SilentlyContinue; if($null -eq $a){Write-Host '[FAILED] Share not found.'; exit 1}; $e=$a | Where-Object {$_.AccountName -eq 'Everyone'}; if($e){Revoke-SmbShareAccess -Name $env:SHARECHECK_NAME -AccountName 'Everyone' -Force -Confirm:$false; Write-Host '[OK] Everyone share access removed.'}else{Write-Host '[KEEP] Everyone share access was not present.'}; $u=$a | Where-Object {$_.AccountName -match 'ShareUser$'}; if(-not $u){Grant-SmbShareAccess -Name $env:SHARECHECK_NAME -AccountName $env:ShareUser -AccessRight Change -Force -Confirm:$false; Write-Host '[OK] ShareUser Change access granted.'}else{Write-Host '[KEEP] ShareUser share access already exists.'}; exit 0"

if errorlevel 1 (
    echo [FAILED] SMB share permission hardening failed.
) else (
    echo [OK] SMB share permission hardening completed.
)

echo.
echo [VERIFY] Current share access:
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$a=Get-SmbShareAccess -Name $env:SHARECHECK_NAME -ErrorAction SilentlyContinue; $a | Format-Table -AutoSize"


REM ----------------------------------------------------------------------------
REM 5 - NTFS
REM ----------------------------------------------------------------------------

echo.
echo [5/8] NTFS SHAREUSER ACCESS
echo -------------------------------------------------------------------------------

if not exist "%SharePath%\" (
    echo [FAILED] Share path does not exist.
) else (
    echo Checking ShareUser NTFS permission...

    icacls "%SharePath%" | findstr /I "%ShareUser%" >nul 2>&1

    if not errorlevel 1 (
        echo [KEEP] ShareUser NTFS entry already exists.
        icacls "%SharePath%" | findstr /I "%ShareUser%"
    ) else (
        echo [ACTION] ShareUser NTFS Modify permission is missing.
        echo [ACTION] Adding Modify permission.

        icacls "%SharePath%" /grant "%COMPUTERNAME%\%ShareUser%:(OI)(CI)M"

        if errorlevel 1 (
            echo [FAILED] Unable to add ShareUser NTFS Modify permission.
        ) else (
            echo [OK] ShareUser NTFS Modify permission added.
        )
    )
)


REM ----------------------------------------------------------------------------
REM 6 - PUBLIC SMB FIREWALL
REM ----------------------------------------------------------------------------

echo.
echo [6/8] PUBLIC SMB FIREWALL EXPOSURE
echo -------------------------------------------------------------------------------

echo The hardening action will remove Public profile applicability from
echo enabled inbound "File and Printer Sharing" rules.
echo Domain/Private applicability will be retained where supported.
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$r=Get-NetFirewallRule -DisplayGroup 'File and Printer Sharing' -ErrorAction SilentlyContinue | Where-Object {$_.Enabled -eq 'True' -and $_.Direction -eq 'Inbound' -and $_.Action -eq 'Allow'}; if($null -eq $r){Write-Host '[OK] No enabled inbound File and Printer Sharing rules found.'; exit 0}; try{$r | Set-NetFirewallRule -Profile Domain,Private; Write-Host '[OK] Public profile removed from inbound File and Printer Sharing rules.'; exit 0}catch{Write-Host ('[FAILED] ' + $_.Exception.Message); exit 1}"

if errorlevel 1 (
    echo [FAILED] SMB firewall hardening reported an error.
) else (
    echo [OK] SMB firewall hardening completed.
)


REM ----------------------------------------------------------------------------
REM 7 - PUBLIC WINRM FIREWALL
REM ----------------------------------------------------------------------------

echo.
echo [7/8] PUBLIC WINRM FIREWALL EXPOSURE
echo -------------------------------------------------------------------------------

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$groups=@('Windows Firewall Remote Management','Windows Remote Management'); $all=@(); foreach($g in $groups){$r=Get-NetFirewallRule -DisplayGroup $g -ErrorAction SilentlyContinue | Where-Object {$_.Enabled -eq 'True' -and $_.Direction -eq 'Inbound' -and $_.Action -eq 'Allow'}; if($r){$all += $r}}; if($all.Count -eq 0){Write-Host '[OK] No enabled inbound WinRM firewall rules found.'; exit 0}; try{$all | Set-NetFirewallRule -Profile Domain,Private; Write-Host '[OK] Public profile removed from inbound WinRM rules.'; exit 0}catch{Write-Host ('[FAILED] ' + $_.Exception.Message); exit 1}"

if errorlevel 1 (
    echo [FAILED] WinRM firewall hardening reported an error.
) else (
    echo [OK] WinRM firewall hardening completed.
)


REM ----------------------------------------------------------------------------
REM 8 - SMB ENCRYPTION
REM ----------------------------------------------------------------------------

echo.
echo [8/8] SMB SHARE ENCRYPTION
echo -------------------------------------------------------------------------------
echo.
echo SMB encryption provides additional protection for data in transit.
echo It can affect compatibility with older SMB clients.
echo.
echo Current Share encryption state:

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$s=Get-SmbShare -Name $env:SHARECHECK_NAME -ErrorAction SilentlyContinue; if($s){Write-Host ('EncryptData : ' + $s.EncryptData)}else{Write-Host '[FAILED] Share not found. '}"

echo.

choice /C YN /N /M "Enable SMB encryption on Share? [Y/N]: "

if errorlevel 2 (
    echo.
    echo [SKIPPED] SMB share encryption was not enabled.
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
     "try{Set-SmbShare -Name $env:SHARECHECK_NAME -EncryptData $true -Force; Write-Host '[OK] SMB encryption enabled on Share.'; exit 0}catch{Write-Host ('[FAILED] ' + $_.Exception.Message); exit 1}"

    if errorlevel 1 (
        echo [FAILED] SMB encryption could not be enabled.
    ) else (
        echo [OK] SMB share encryption enabled.
    )
)


REM ============================================================================
REM SECURITY HARDENING VERIFICATION
REM ============================================================================

echo.
echo ===============================================================================
echo                       SECURITY HARDENING VERIFICATION
echo ===============================================================================
echo.

echo [SMB SERVER]
echo -------------------------------------------------------------------------------

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$s=Get-SmbServerConfiguration; $s | Select-Object EnableSMB1Protocol,EnableSMB2Protocol,EnableSecuritySignature,RequireSecuritySignature,EncryptData,RejectUnencryptedAccess | Format-List"

echo.
echo [SMB CLIENT]
echo -------------------------------------------------------------------------------

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$s=Get-SmbClientConfiguration; $s | Select-Object EnableInsecureGuestLogons,EnableSecuritySignature,RequireSecuritySignature | Format-List"

echo.
echo [SHARE PERMISSIONS]
echo -------------------------------------------------------------------------------

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$a=Get-SmbShareAccess -Name $env:SHARECHECK_NAME -ErrorAction SilentlyContinue; $a | Format-Table -AutoSize"

echo.
echo [NTFS]
echo -------------------------------------------------------------------------------

icacls "%SharePath%" | findstr /I "%ShareUser% BUILTIN\Administrators NT AUTHORITY\SYSTEM"

echo.
echo [FIREWALL - PUBLIC SMB]
echo -------------------------------------------------------------------------------

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$r=Get-NetFirewallRule -DisplayGroup 'File and Printer Sharing' -ErrorAction SilentlyContinue | Where-Object {$_.Enabled -eq 'True' -and $_.Direction -eq 'Inbound' -and $_.Action -eq 'Allow'}; $x=$r | Where-Object {($_.Profile -band 4) -ne 0}; if($x){Write-Host '[WARNING] Public SMB inbound rules still detected.'; $x | Select-Object DisplayName,Profile,Action | Format-Table -AutoSize}else{Write-Host '[OK] No enabled Public-profile SMB inbound rules detected.'}"

echo.
echo [FIREWALL - PUBLIC WINRM]
echo -------------------------------------------------------------------------------

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$all=@(); foreach($g in @('Windows Firewall Remote Management','Windows Remote Management')){$r=Get-NetFirewallRule -DisplayGroup $g -ErrorAction SilentlyContinue | Where-Object {$_.Enabled -eq 'True' -and $_.Direction -eq 'Inbound' -and $_.Action -eq 'Allow'}; if($r){$all += $r}}; $x=$all | Where-Object {($_.Profile -band 4) -ne 0}; if($x){Write-Host '[WARNING] Public WinRM inbound rules still detected.'; $x | Select-Object DisplayName,Profile,Action | Format-Table -AutoSize}else{Write-Host '[OK] No enabled Public-profile WinRM inbound rules detected.'}"

echo.
echo ===============================================================================
echo                       SECURITY HARDENING COMPLETE
echo ===============================================================================
echo.
echo Security configuration changes were explicitly requested.
echo.
echo IMPORTANT:
echo Existing files were preserved.
echo Existing folders were preserved.
echo D:\Share\Client was not created or modified.
echo ShareUser password was not changed.
echo Existing SMB share was not deleted/recreated.
echo.
echo Review the verification results above.
echo Run option [I] Full Security Audit again for a complete read-only review.
echo.

call :FINAL_PAUSE
goto MENU


REM ============================================================================
REM ADMIN PRIVILEGE CHECK
REM ============================================================================

:REQUIRE_ADMIN

net session >nul 2>&1

if errorlevel 1 (
    echo [ERROR] Administrator privileges are required.
    exit /b 1
)

exit /b 0


REM ============================================================================
REM FINAL PAUSE
REM ============================================================================

:FINAL_PAUSE

echo.
echo ===============================================================================
echo Operation complete.
echo ===============================================================================
echo.
echo Press any key to return to the main menu...
pause >nul

goto :eof


REM ============================================================================
REM EXIT PROGRAM
REM
REM This is the ONLY location that intentionally closes the batch program.
REM ============================================================================

:EXIT_PROGRAM

cls

echo.
echo ===============================================================================
echo                              EXIT PROGRAM
echo ===============================================================================
echo.
echo The Network Share Admin Setup tool is ready to exit.
echo.
echo The program will NOT close unless you confirm.
echo.

choice /C YN /N /M "Exit the program? [Y/N]: "

if errorlevel 2 (
    echo.
    echo [CANCELLED] Exit cancelled.
    echo Returning to the main menu...
    timeout /t 2 /nobreak >nul
    goto MENU
)

cls

echo.
echo ===============================================================================
echo                         PROGRAM EXIT CONFIRMED
echo ===============================================================================
echo.
echo Program exited by user.
echo.
echo No automatic exit occurred.
echo The exit was explicitly confirmed.
echo.
echo ===============================================================================

endlocal
exit