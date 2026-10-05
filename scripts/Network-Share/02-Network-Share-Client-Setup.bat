@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Network Share - Client Setup
color 0A

rem ============================================================
rem
rem  NETWORK SHARE - CLIENT SETUP
rem
rem ============================================================
rem
rem  Purpose:
rem
rem    Prepare and diagnose a Windows client PC for:
rem
rem      - WinRM connectivity
rem      - SMB network share access
rem      - Administration PC connectivity
rem      - Network diagnostics
rem      - Basic read-only security diagnostics
rem
rem  STANDARD ADMINISTRATION SERVER:
rem
rem      IT-SERVER
rem
rem  ADMINISTRATION WORKSPACE:
rem
rem      D:\IT-Admin
rem
rem  LOCAL ADMIN CONSOLE DATA:
rem
rem      D:\AdminConsole
rem
rem  SHARED DATA:
rem
rem      D:\Share
rem
rem  NETWORK SHARE:
rem
rem      \\IT-SERVER\Share
rem
rem  NETWORK SHARE ACCOUNT:
rem
rem      ShareUser
rem
rem ============================================================
rem
rem  IMPORTANT SAFETY RULES:
rem
rem    1.  This script does NOT create D:\IT-Admin.
rem    2.  This script does NOT modify D:\IT-Admin.
rem    3.  This script does NOT delete files or folders.
rem    4.  This script does NOT delete SMB shares.
rem    5.  This script does NOT create D:\Share\Client.
rem    6.  Existing D:\Share\Client is NOT modified.
rem    7.  Existing D:\Share contents are NOT modified.
rem    8.  Existing SMB shares are NOT modified by this client.
rem    9.  Passwords are NEVER stored by this script.
rem   10.  WinRM is configured ONLY when explicitly requested.
rem   11.  WinRM service is NOT automatically started when
rem        configuration was explicitly skipped.
rem   12.  Existing configuration is preserved unless the user
rem        explicitly saves a new Administration PC.
rem   13.  Automated troubleshooting is READ-ONLY.
rem   14.  Security diagnostics are READ-ONLY.
rem   15.  No automatic firewall changes are performed.
rem   16.  No automatic SMB changes are performed.
rem   17.  No automatic account/password changes are performed.
rem   18.  This console does NOT automatically close.
rem   19.  Exit always requires explicit confirmation.
rem
rem ============================================================


rem ============================================================
rem CONFIGURATION
rem ============================================================

set "DefaultAdminPC=IT-SERVER"

set "AdminPC="
set "ShareName=Share"
set "ShareUser=ShareUser"

set "ITAdmin=D:\IT-Admin"
set "AdminConsole=D:\AdminConsole"

set "ConfigDir=%AdminConsole%\Config"
set "ConfigFile=%ConfigDir%\Client-Network.conf"

set "NetworkSharePath="


rem ============================================================
rem STATUS VARIABLES
rem ============================================================

set "AdminStatus=UNKNOWN"

set "WinRMStatus=NOT CHECKED"
set "ShareStatus=NOT CHECKED"
set "PingStatus=NOT CHECKED"
set "NameResolutionStatus=NOT CHECKED"
set "SMBPortStatus=NOT CHECKED"
set "BrowseStatus=NOT CHECKED"

set "TroubleshootStatus=NOT RUN"
set "SecurityAuditStatus=NOT RUN"

set "WinRMChangeRequested=NO"


goto START


rem ============================================================
rem START
rem ============================================================

:START

cls

echo ============================================================
echo              NETWORK SHARE - CLIENT SETUP
echo ============================================================
echo.
echo Client PC:
echo     %COMPUTERNAME%
echo.
echo User:
echo     %USERNAME%
echo.
echo Administration Server:
echo     %DefaultAdminPC%
echo.
echo Administration Workspace:
echo     %ITAdmin%
echo.
echo Local Admin Console:
echo     %AdminConsole%
echo.
echo Shared Data:
echo     D:\Share
echo.
echo Network Share:
echo     \\%DefaultAdminPC%\%ShareName%
echo.

rem ------------------------------------------------------------
rem Administrator privilege detection
rem ------------------------------------------------------------

echo ============================================================
echo                  ADMINISTRATOR STATUS
echo ============================================================
echo.

net session >nul 2>&1

if errorlevel 1 (
    set "AdminStatus=NOT ADMINISTRATOR"

    echo [WARNING] This BAT file is NOT running as Administrator.
    echo.
    echo Diagnostic functions remain available.
    echo.
    echo WinRM configuration and some security diagnostics
    echo may require Administrator privileges.
) else (
    set "AdminStatus=ADMINISTRATOR"

    echo [OK] Administrator privileges detected.
)

echo.

rem ------------------------------------------------------------
rem Load saved configuration
rem ------------------------------------------------------------

call :LOAD_CONFIG

if defined AdminPC (
    echo Saved Administration PC:
    echo     %AdminPC%
) else (
    echo Administration PC:
    echo     %DefaultAdminPC% [DEFAULT]
    set "AdminPC=%DefaultAdminPC%"
)

call :UPDATE_SHARE_PATH

echo.
echo Network Share:
echo     %NetworkSharePath%

echo.
echo ============================================================
echo.
echo Client setup console is ready.
echo.
echo No files or folders will be automatically deleted.
echo No passwords will be stored.
echo.
echo Press any key to continue to the menu.
pause >nul

goto MENU


rem ============================================================
rem MAIN MENU
rem ============================================================

:MENU

cls

call :UPDATE_SHARE_PATH

echo ============================================================
echo              NETWORK SHARE - CLIENT SETUP
echo ============================================================
echo.
echo Client PC:
echo     %COMPUTERNAME%
echo.
echo User:
echo     %USERNAME%
echo.
echo Administrator:
echo     %AdminStatus%
echo.
echo Administration PC:
if defined AdminPC (
    echo     %AdminPC%
) else (
    echo     [NOT SET]
)
echo.
echo Network Share:
if defined AdminPC (
    echo     %NetworkSharePath%
) else (
    echo     [ADMIN PC NOT SET]
)
echo.
echo Local Configuration:
echo     %ConfigFile%
echo.
echo ------------------------------------------------------------
echo STATUS
echo ------------------------------------------------------------
echo.
echo WinRM:
echo     %WinRMStatus%
echo.
echo Ping:
echo     %PingStatus%
echo.
echo Name Resolution:
echo     %NameResolutionStatus%
echo.
echo SMB Share:
echo     %ShareStatus%
echo.
echo SMB Port 445:
echo     %SMBPortStatus%
echo.
echo Network Browsing:
echo     %BrowseStatus%
echo.
echo Troubleshooting:
echo     %TroubleshootStatus%
echo.
echo Security Audit:
echo     %SecurityAuditStatus%
echo.
echo ============================================================
echo.
echo [1] Configure / Re-run Client Setup
echo [2] Enter Administration PC
echo [3] Test Ping
echo [4] Test WinRM
echo [5] Show WinRM Listener
echo [6] Test Network Share
echo [7] Test Share Credentials
echo [8] Open Network Share
echo [9] Show Network Information
echo [A] Show Client Information
echo [B] Open Windows System Folder
echo [C] Show Configuration
echo [D] Check Local Protection / Preservation
echo [E] Test Name Resolution
echo [F] Test SMB Port 445
echo [G] Automated Troubleshooting
echo [H] Local Security / WinRM Audit
echo [Q] Exit
echo.
echo ============================================================
echo.

choice /C 123456789ABCDEFGHQ /N /M "Select option: "

rem
rem CHOICE positions:
rem
rem   1  = 1
rem   2  = 2
rem   3  = 3
rem   4  = 4
rem   5  = 5
rem   6  = 6
rem   7  = 7
rem   8  = 8
rem   9  = 9
rem  10  = A
rem  11  = B
rem  12  = C
rem  13  = D
rem  14  = E
rem  15  = F
rem  16  = G
rem  17  = H
rem  18  = Q
rem

if errorlevel 18 goto EXIT
if errorlevel 17 goto SECURITY_AUDIT
if errorlevel 16 goto TROUBLESHOOT
if errorlevel 15 goto TEST_SMB_PORT
if errorlevel 14 goto TEST_NAME_RESOLUTION
if errorlevel 13 goto PROTECTION_CHECK
if errorlevel 12 goto SHOW_CONFIG
if errorlevel 11 goto SYSTEM
if errorlevel 10 goto CLIENT_INFO
if errorlevel 9 goto NETWORK
if errorlevel 8 goto OPEN_SHARE
if errorlevel 7 goto TEST_CREDENTIALS
if errorlevel 6 goto TEST_SHARE
if errorlevel 5 goto WINRM_LISTENER
if errorlevel 4 goto TEST_WINRM
if errorlevel 3 goto PING_ADMIN
if errorlevel 2 goto ENTER_ADMIN
if errorlevel 1 goto RUN_SETUP

goto MENU


rem ============================================================
rem RUN CLIENT SETUP
rem ============================================================

:RUN_SETUP

cls

echo ============================================================
echo                CLIENT SETUP
echo ============================================================
echo.

if /I not "%AdminStatus%"=="ADMINISTRATOR" (

    echo [ERROR] Administrator privileges are required.
    echo.
    echo This operation may configure:
    echo.
    echo     - WinRM
    echo     - WinRM service
    echo     - Windows Remote Management firewall rules
    echo.
    echo Please restart this BAT file using:
    echo.
    echo     Right-click ^> Run as administrator
    echo.
    echo The console will NOT close automatically.
    echo.

    call :WAIT_FOR_USER
    goto MENU
)

echo Client Computer:
echo     %COMPUTERNAME%
echo.

echo Administrator:
echo     %USERNAME%
echo.

echo Administration PC:
if defined AdminPC (
    echo     %AdminPC%
) else (
    echo     [NOT SET]
)

echo.
echo ============================================================
echo SAFETY NOTICE
echo ============================================================
echo.
echo This setup will NOT:
echo.
echo     - Modify D:\IT-Admin
echo     - Modify D:\Share
echo     - Create D:\Share\Client
echo     - Delete files or folders
echo     - Delete SMB shares
echo     - Store passwords
echo.
echo WinRM configuration is the only system configuration
echo performed by this setup.
echo.

choice /C YN /N /M "Continue with client setup? [Y/N]: "

if errorlevel 2 (
    echo.
    echo [CANCELLED] Client setup was not performed.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)


rem ============================================================
rem STEP 1 - WINRM SERVICE CHECK
rem ============================================================

cls

echo ============================================================
echo              [1/5] WINRM SERVICE CHECK
echo ============================================================
echo.

sc query WinRM >nul 2>&1

if errorlevel 1 (

    echo [WARNING] WinRM service is not available.
    echo.
    echo WinRM may not be installed or available on this
    echo Windows edition.

    set "WinRMStatus=SERVICE UNAVAILABLE"

) else (

    echo [OK] WinRM service is installed.

)

echo.

call :WAIT_FOR_USER


rem ============================================================
rem STEP 2 - WINRM CONFIGURATION
rem ============================================================

cls

echo ============================================================
echo             [2/5] WINRM CONFIGURATION
echo ============================================================
echo.

echo This operation may modify:
echo.
echo     - WinRM configuration
echo     - Windows Remote Management firewall rules
echo     - WinRM service configuration
echo.
echo It does NOT modify:
echo.
echo     D:\IT-Admin
echo     D:\Share
echo.

set "WinRMChangeRequested=NO"

choice /C YN /N /M "Configure WinRM? [Y/N]: "

if errorlevel 2 (

    echo.
    echo [SKIPPED] WinRM configuration was not performed.
    echo [INFO] No WinRM service start will be forced by this step.
    echo.

) else (

    set "WinRMChangeRequested=YES"

    echo.
    echo Running Enable-PSRemoting...
    echo.

    powershell.exe -NoProfile -Command "Enable-PSRemoting -Force"

    if errorlevel 1 (
        echo.
        echo [WARNING] WinRM configuration returned an error.
        set "WinRMStatus=CONFIGURATION FAILED"
    ) else (
        echo.
        echo [OK] WinRM configuration completed.
        set "WinRMStatus=CONFIGURED"
    )

)

echo.

call :WAIT_FOR_USER


rem ============================================================
rem STEP 3 - WINRM SERVICE
rem ============================================================

cls

echo ============================================================
echo               [3/5] WINRM SERVICE
echo ============================================================
echo.

sc query WinRM

echo.

sc query WinRM >nul 2>&1

if errorlevel 1 (

    echo [ERROR] WinRM service is unavailable.
    set "WinRMStatus=SERVICE UNAVAILABLE"

) else (

    sc query WinRM | find /I "RUNNING" >nul

    if errorlevel 1 (

        echo [INFO] WinRM service is not running.
        echo.

        if /I "%WinRMChangeRequested%"=="YES" (

            echo WinRM configuration was explicitly requested.
            echo Attempting to start WinRM...
            echo.

            net start WinRM

            if errorlevel 1 (
                echo.
                echo [WARNING] WinRM service could not be started.
                set "WinRMStatus=SERVICE START FAILED"
            ) else (
                echo.
                echo [OK] WinRM service started.
                set "WinRMStatus=SERVICE RUNNING"
            )

        ) else (

            echo [INFO] WinRM configuration was skipped.
            echo [INFO] WinRM service was NOT started.
            set "WinRMStatus=SERVICE NOT RUNNING - NOT CHANGED"

        )

    ) else (

        echo [OK] WinRM service is already running.

        if /I "%WinRMChangeRequested%"=="YES" (
            set "WinRMStatus=SERVICE RUNNING"
        )

    )
)

echo.

call :WAIT_FOR_USER


rem ============================================================
rem STEP 4 - LOCAL WINRM TEST
rem ============================================================

cls

echo ============================================================
echo              [4/5] LOCAL WINRM TEST
echo ============================================================
echo.

powershell.exe -NoProfile -Command ^
    "Test-WSMan -ComputerName localhost -ErrorAction Stop"

if errorlevel 1 (

    echo.
    echo [WARNING] Local WinRM test failed.

    if /I "%WinRMChangeRequested%"=="NO" (
        set "WinRMStatus=LOCAL TEST FAILED - NOT CHANGED"
    ) else (
        set "WinRMStatus=LOCAL TEST FAILED"
    )

) else (

    echo.
    echo [OK] Local WinRM test passed.
    set "WinRMStatus=READY"

)

echo.

call :WAIT_FOR_USER


rem ============================================================
rem STEP 5 - CLIENT CONFIGURATION
rem ============================================================

cls

echo ============================================================
echo             [5/5] CLIENT CONFIGURATION
echo ============================================================
echo.

if not exist "%ConfigDir%\" (

    echo Creating:
    echo     %ConfigDir%
    echo.

    mkdir "%ConfigDir%" >nul 2>&1

    if errorlevel 1 (
        echo [WARNING] Could not create configuration directory.
    ) else (
        echo [OK] Configuration directory created.
    )

) else (

    echo [KEEP] Configuration directory already exists.

)

echo.

if defined AdminPC (

    call :SAVE_CONFIG

    if errorlevel 1 (
        echo [WARNING] Configuration could not be saved.
    ) else (
        echo [OK] Administration PC configuration saved.
    )

) else (

    echo [INFO] Administration PC is not configured.

)

echo.

echo ============================================================
echo                    SETUP RESULTS
echo ============================================================
echo.

echo Client:
echo     %COMPUTERNAME%
echo.

echo Administration PC:
if defined AdminPC (
    echo     %AdminPC%
) else (
    echo     [NOT SET]
)

echo.

echo Network Share:
if defined AdminPC (
    echo     %NetworkSharePath%
) else (
    echo     [NOT SET]
)

echo.

echo WinRM:
echo     %WinRMStatus%
echo.

echo Local Configuration:
echo     %ConfigFile%
echo.

echo ============================================================
echo                  PRESERVATION STATUS
echo ============================================================
echo.

echo D:\IT-Admin:
echo     NOT CREATED / NOT MODIFIED
echo.

echo D:\Share:
echo     NOT MODIFIED
echo.

echo D:\Share\Client:
echo     NOT CREATED
echo.

echo Existing D:\Share\Client:
echo     NOT MODIFIED
echo.

echo SMB Shares:
echo     NOT CREATED / NOT DELETED BY THIS SCRIPT
echo.

echo Passwords:
echo     NOT STORED
echo.

echo Deleted files:
echo     NONE
echo.

echo Deleted folders:
echo     NONE
echo.

call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem ENTER ADMINISTRATION PC
rem ============================================================

:ENTER_ADMIN

cls

echo ============================================================
echo                ADMINISTRATION PC
echo ============================================================
echo.

echo Current Administration PC:
if defined AdminPC (
    echo     %AdminPC%
) else (
    echo     [NOT SET]
)

echo.

echo Recommended Administration PC:
echo     %DefaultAdminPC%
echo.

echo Enter the computer name or IP address of the
echo Administration PC.
echo.
echo Examples:
echo     IT-SERVER
echo     192.168.1.10
echo.

set "NewAdminPC="

set /p "NewAdminPC=Administration PC: "

if not defined NewAdminPC (

    echo.
    echo [WARNING] No Administration PC was entered.
    echo.

    call :WAIT_FOR_USER
    goto MENU
)

rem ------------------------------------------------------------
rem Normalize spaces.
rem Windows computer names and IPv4 addresses do not contain
rem spaces, so only the first whitespace-delimited token is used.
rem ------------------------------------------------------------

for /f "tokens=1" %%A in ("%NewAdminPC%") do set "NewAdminPC=%%A"

if not defined NewAdminPC (

    echo.
    echo [WARNING] Invalid Administration PC value.
    echo.

    call :WAIT_FOR_USER
    goto MENU
)

set "AdminPC=%NewAdminPC%"

call :UPDATE_SHARE_PATH

echo.
echo New Administration PC:
echo     %AdminPC%
echo.

echo Network Share:
echo     %NetworkSharePath%
echo.

choice /C YN /N /M "Save this configuration? [Y/N]: "

if errorlevel 2 (

    echo.
    echo [INFO] Configuration was not saved.
    echo.

    call :WAIT_FOR_USER
    goto MENU
)

call :SAVE_CONFIG

if errorlevel 1 (
    echo.
    echo [ERROR] Configuration could not be saved.
) else (
    echo.
    echo [OK] Configuration saved.
)

echo.

call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem PING ADMINISTRATION PC
rem ============================================================

:PING_ADMIN

cls

echo ============================================================
echo                    TEST PING
echo ============================================================
echo.

if not defined AdminPC (

    echo [ERROR] Administration PC has not been configured.
    echo.
    echo Use menu option [2] first.
    echo.

    call :WAIT_FOR_USER
    goto MENU
)

set "TARGET_PC=%AdminPC%"

echo Target:
echo     %TARGET_PC%
echo.

echo Sending 4 ICMP requests...
echo.

ping "%TARGET_PC%" -n 4

set "PingResult=%errorlevel%"

echo.
echo ------------------------------------------------------------
echo.

if "%PingResult%"=="0" (

    set "PingStatus=READY"

    echo [OK] Ping test completed successfully.

) else (

    set "PingStatus=FAILED"

    echo [WARNING] Ping test failed.
    echo.
    echo Possible causes:
    echo.
    echo     - PC is offline
    echo     - Incorrect computer name or IP address
    echo     - Network connectivity problem
    echo     - ICMP is blocked by firewall
)

echo.

call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem TEST WINRM
rem ============================================================

:TEST_WINRM

cls

echo ============================================================
echo                    TEST WINRM
echo ============================================================
echo.

if not defined AdminPC (

    echo [ERROR] Administration PC has not been configured.
    echo.
    echo Use menu option [2] first.
    echo.

    call :WAIT_FOR_USER
    goto MENU
)

set "TARGET_PC=%AdminPC%"

echo Target:
echo     %TARGET_PC%
echo.

echo Testing WinRM connectivity...
echo.

powershell.exe -NoProfile -Command ^
    "$t=$env:TARGET_PC; Test-WSMan -ComputerName $t -ErrorAction Stop"

if errorlevel 1 (

    set "WinRMStatus=FAILED"

    echo.
    echo [ERROR] WinRM is NOT reachable.
    echo.
    echo Check:
    echo.
    echo     1. Administration PC is online.
    echo     2. WinRM service is running.
    echo     3. Windows Firewall permits WinRM.
    echo     4. Computer name or IP is correct.
    echo     5. Network profile is appropriate.
    echo     6. WinRM is configured on the Administration PC.

) else (

    set "WinRMStatus=READY"

    echo.
    echo [OK] WinRM is reachable.

)

echo.

call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem SHOW WINRM LISTENER
rem ============================================================

:WINRM_LISTENER

cls

echo ============================================================
echo                  WINRM LISTENER
echo ============================================================
echo.

echo Computer:
echo     %COMPUTERNAME%
echo.

echo WinRM Listener Configuration:
echo ------------------------------------------------------------
echo.

winrm enumerate winrm/config/listener

if errorlevel 1 (
    echo.
    echo [WARNING] Unable to enumerate the WinRM listener.
) else (
    echo.
    echo [OK] WinRM listener information displayed.
)

echo.

call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem TEST NETWORK SHARE
rem ============================================================

:TEST_SHARE

cls

echo ============================================================
echo                  TEST NETWORK SHARE
echo ============================================================
echo.

if not defined AdminPC (

    echo [ERROR] Administration PC has not been configured.
    echo.
    echo Use menu option [2] first.
    echo.

    call :WAIT_FOR_USER
    goto MENU
)

call :UPDATE_SHARE_PATH

echo Network Share:
echo     %NetworkSharePath%
echo.

echo Testing direct SMB share access...
echo.

dir "%NetworkSharePath%" >nul 2>&1

if errorlevel 1 (

    set "ShareStatus=FAILED"

    echo [ERROR] Network Share could not be accessed.
    echo.
    echo Possible causes:
    echo.
    echo     1. Administration PC is offline.
    echo     2. SMB Share is not available.
    echo     3. ShareUser credentials are not authenticated.
    echo     4. Windows Firewall is blocking SMB.
    echo     5. Share permissions deny access.
    echo     6. NTFS permissions deny access.
    echo     7. Network connectivity failed.
    echo     8. Name resolution failed.
    echo.
    echo NOTE:
    echo Direct \\Server\Share access is more useful than
    echo network browsing for determining whether SMB itself
    echo is available.

) else (

    set "ShareStatus=READY"

    echo [OK] Network Share is accessible.
    echo.
    echo Share contents:
    echo ------------------------------------------------------------
    dir "%NetworkSharePath%"
)

echo.

call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem TEST SHARE CREDENTIALS
rem ============================================================

:TEST_CREDENTIALS

cls

echo ============================================================
echo               TEST SHARE CREDENTIALS
echo ============================================================
echo.

if not defined AdminPC (

    echo [ERROR] Administration PC has not been configured.
    echo.
    echo Use menu option [2] first.
    echo.

    call :WAIT_FOR_USER
    goto MENU
)

call :UPDATE_SHARE_PATH

echo Administration PC:
echo     %AdminPC%
echo.

echo Share:
echo     %NetworkSharePath%
echo.

echo Expected network account:
echo     %AdminPC%\%ShareUser%
echo.

echo ============================================================
echo IMPORTANT
echo ============================================================
echo.
echo This script does NOT store passwords.
echo.
echo Existing SMB connections:
echo ------------------------------------------------------------
echo.

net use

echo.
echo ------------------------------------------------------------
echo.
echo To authenticate manually, Windows can request:
echo.
echo     Username:
echo         %AdminPC%\%ShareUser%
echo.
echo     Password:
echo         [ENTER MANUALLY]
echo.
echo The password is not written to this BAT file.
echo.

call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem OPEN NETWORK SHARE
rem ============================================================

:OPEN_SHARE

cls

echo ============================================================
echo                  OPEN NETWORK SHARE
echo ============================================================
echo.

if not defined AdminPC (

    echo [ERROR] Administration PC has not been configured.
    echo.
    echo Use menu option [2] first.
    echo.

    call :WAIT_FOR_USER
    goto MENU
)

call :UPDATE_SHARE_PATH

echo Network Share:
echo     %NetworkSharePath%
echo.

echo Opening Windows Explorer...
echo.

explorer.exe "%NetworkSharePath%"

echo.
echo [OK] Explorer request sent.
echo.
echo If Windows requests credentials, enter them manually.
echo No password is stored by this script.
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

echo User:
echo     %USERNAME%
echo.

echo Administrator Status:
echo     %AdminStatus%
echo.

echo ------------------------------------------------------------
echo COMPUTER / DOMAIN INFORMATION
echo ------------------------------------------------------------
echo.

powershell.exe -NoProfile -Command ^
    "Get-CimInstance Win32_ComputerSystem | Select-Object Name,Domain,PartOfDomain | Format-List"

echo.
echo ------------------------------------------------------------
echo IP CONFIGURATION
echo ------------------------------------------------------------
echo.

ipconfig

echo.
echo ------------------------------------------------------------
echo NETWORK ADAPTERS
echo ------------------------------------------------------------
echo.

powershell.exe -NoProfile -Command ^
    "Get-NetAdapter | Select-Object Name,Status,LinkSpeed,MacAddress | Format-Table -AutoSize"

echo.
echo ------------------------------------------------------------
echo ADMINISTRATION SERVER
echo ------------------------------------------------------------
echo.

if defined AdminPC (

    echo Administration PC:
    echo     %AdminPC%
    echo.

    echo Network Share:
    echo     %NetworkSharePath%

) else (

    echo Administration PC:
    echo     [NOT SET]

)

echo.

call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem CLIENT INFORMATION
rem ============================================================

:CLIENT_INFO

cls

echo ============================================================
echo                   CLIENT INFORMATION
echo ============================================================
echo.

echo Computer Name:
echo     %COMPUTERNAME%
echo.

echo User:
echo     %USERNAME%
echo.

echo Administrator:
echo     %AdminStatus%
echo.

echo Operating System:
echo ------------------------------------------------------------
echo.

ver

echo.

powershell.exe -NoProfile -Command ^
    "Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version,BuildNumber,OSArchitecture,LastBootUpTime | Format-List"

echo.
echo ------------------------------------------------------------
echo WINRM SERVICE
echo ------------------------------------------------------------
echo.

sc query WinRM

echo.
echo ------------------------------------------------------------
echo ADMINISTRATION PC
echo ------------------------------------------------------------
echo.

if defined AdminPC (
    echo     %AdminPC%
) else (
    echo     [NOT SET]
)

echo.
echo ------------------------------------------------------------
echo NETWORK SHARE
echo ------------------------------------------------------------
echo.

if defined AdminPC (
    echo     %NetworkSharePath%
) else (
    echo     [ADMIN PC NOT SET]
)

echo.
echo ------------------------------------------------------------
echo STORAGE POLICY
echo ------------------------------------------------------------
echo.

echo D:\IT-Admin:
echo     NOT MODIFIED BY THIS SCRIPT
echo.

echo D:\Share:
echo     NOT MODIFIED BY THIS SCRIPT
echo.

echo D:\Share\Client:
echo     NOT CREATED BY THIS SCRIPT
echo.

echo Existing D:\Share\Client:
echo     NOT MODIFIED BY THIS SCRIPT
echo.

echo Passwords:
echo     NOT STORED
echo.

call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem OPEN WINDOWS SYSTEM FOLDER
rem ============================================================

:SYSTEM

cls

echo ============================================================
echo                WINDOWS SYSTEM FOLDER
echo ============================================================
echo.

echo Windows System Folder:
echo     %SystemRoot%
echo.

if not exist "%SystemRoot%\" (

    echo [ERROR] Windows System Folder was not found.
    echo.

    call :WAIT_FOR_USER
    goto MENU
)

echo Opening Windows Explorer...
echo.

explorer.exe "%SystemRoot%"

echo.
echo [OK] Explorer request sent.
echo.

call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem SHOW CONFIGURATION
rem ============================================================

:SHOW_CONFIG

cls

echo ============================================================
echo                  CLIENT CONFIGURATION
echo ============================================================
echo.

echo Client PC:
echo     %COMPUTERNAME%
echo.

echo Administrator:
echo     %AdminStatus%
echo.

echo Administration PC:
if defined AdminPC (
    echo     %AdminPC%
) else (
    echo     [NOT SET]
)

echo.
echo Share Name:
echo     %ShareName%
echo.

echo Share User:
echo     %ShareUser%
echo.

if defined AdminPC (
    echo Network Share:
    echo     %NetworkSharePath%
) else (
    echo Network Share:
    echo     [ADMIN PC NOT SET]
)

echo.
echo Local Configuration:
echo     %ConfigFile%
echo.

echo ============================================================
echo              LOCAL CONFIGURATION FILE
echo ============================================================
echo.

if exist "%ConfigFile%" (
    type "%ConfigFile%"
) else (
    echo [INFO] Configuration file does not exist yet.
)

echo.
echo ============================================================
echo SAFETY
echo ============================================================
echo.

echo Password stored:
echo     NO
echo.

echo D:\IT-Admin modified:
echo     NO
echo.

echo D:\Share modified:
echo     NO
echo.

echo D:\Share\Client modified:
echo     NO
echo.

call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem PROTECTION / PRESERVATION CHECK
rem ============================================================

:PROTECTION_CHECK

cls

echo ============================================================
echo             LOCAL PROTECTION / PRESERVATION
echo ============================================================
echo.

echo This client setup follows these rules:
echo.

echo [1] D:\IT-Admin
echo.
echo     NOT CREATED
echo     NOT MODIFIED
echo     NOT DELETED
echo.

echo [2] D:\Share
echo.
echo     NOT CREATED
echo     NOT MODIFIED
echo     NOT DELETED
echo.

echo [3] D:\Share\Client
echo.
echo     NOT CREATED
echo     NOT MODIFIED
echo.

echo [4] SMB Shares
echo.
echo     NOT CREATED
echo     NOT DELETED
echo     NOT MODIFIED
echo.

echo [5] Passwords
echo.
echo     NOT STORED
echo.

echo [6] Local Configuration
echo.
echo     Script-owned configuration:
echo.
echo     %ConfigFile%
echo.

echo [7] WinRM
echo.
echo     Modified ONLY through:
echo.
echo     Menu [1]
echo.

echo [8] Automated Troubleshooting
echo.
echo     READ-ONLY
echo     No configuration changes
echo.

echo [9] Security Audit
echo.
echo     READ-ONLY
echo     No firewall changes
echo     No WinRM changes
echo     No SMB changes
echo.

echo ============================================================
echo.
echo [OK] Preservation policy is active.
echo.

call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem TEST NAME RESOLUTION
rem ============================================================

:TEST_NAME_RESOLUTION

cls

echo ============================================================
echo                TEST NAME RESOLUTION
echo ============================================================
echo.

if not defined AdminPC (

    echo [ERROR] Administration PC has not been configured.
    echo.
    echo Use menu option [2] first.
    echo.

    call :WAIT_FOR_USER
    goto MENU
)

set "TARGET_PC=%AdminPC%"

echo Target:
echo     %TARGET_PC%
echo.

echo Resolving Administration PC name...
echo.

powershell.exe -NoProfile -Command ^
    "$t=$env:TARGET_PC; if($t -match '^\d{1,3}(\.\d{1,3}){3}$'){Write-Host 'Target is an IPv4 address. DNS lookup is not required.'; exit 0}; $r=Resolve-DnsName -Name $t -ErrorAction SilentlyContinue; if($r){$r | Select-Object Name,Type,IPAddress | Format-Table -AutoSize; exit 0}else{exit 1}"

if errorlevel 1 (

    set "NameResolutionStatus=FAILED"

    echo.
    echo [WARNING] DNS/name resolution failed.
    echo.
    echo If this is a local LAN computer, also check:
    echo.
    echo     ping %AdminPC%
    echo     nbtstat -a %AdminPC%
    echo.
    echo An IP address can be used to bypass hostname
    echo resolution problems.

) else (

    set "NameResolutionStatus=READY"

    echo.
    echo [OK] Name resolution test completed.

)

echo.

call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem TEST SMB PORT 445
rem ============================================================

:TEST_SMB_PORT

cls

echo ============================================================
echo                  TEST SMB PORT 445
echo ============================================================
echo.

if not defined AdminPC (

    echo [ERROR] Administration PC has not been configured.
    echo.
    echo Use menu option [2] first.
    echo.

    call :WAIT_FOR_USER
    goto MENU
)

set "TARGET_PC=%AdminPC%"

echo Target:
echo     %TARGET_PC%
echo.

echo Testing TCP port 445...
echo.

powershell.exe -NoProfile -Command ^
    "$t=$env:TARGET_PC; $r=Test-NetConnection -ComputerName $t -Port 445 -WarningAction SilentlyContinue; Write-Host ('ComputerName      : ' + $r.ComputerName); Write-Host ('RemoteAddress     : ' + $r.RemoteAddress); Write-Host ('RemotePort        : ' + $r.RemotePort); Write-Host ('TcpTestSucceeded  : ' + $r.TcpTestSucceeded); if($r.TcpTestSucceeded){exit 0}else{exit 1}"

if errorlevel 1 (

    set "SMBPortStatus=FAILED"

    echo.
    echo [WARNING] TCP port 445 is not reachable.
    echo.
    echo Possible causes:
    echo.
    echo     - SMB service unavailable
    echo     - Windows Firewall
    echo     - Server offline
    echo     - Wrong computer name or IP
    echo     - Network connectivity problem

) else (

    set "SMBPortStatus=READY"

    echo.
    echo [OK] TCP port 445 is reachable.

)

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

echo This diagnostic performs READ-ONLY tests.
echo.
echo It does NOT:
echo.
echo     - change WinRM
echo     - start or stop services
echo     - change firewall rules
echo     - change SMB shares
echo     - change NTFS permissions
echo     - change accounts
echo     - store passwords
echo     - delete files
echo.
echo Tests:
echo.
echo     [1] Target configuration
echo     [2] Ping
echo     [3] Name resolution
echo     [4] TCP port 445
echo     [5] Direct SMB Share
echo     [6] Network browsing
echo     [7] WinRM
echo     [8] Diagnostic conclusion
echo.

if not defined AdminPC (

    echo [ERROR] Administration PC has not been configured.
    echo.
    echo Use menu option [2] first.
    echo.

    set "TroubleshootStatus=NOT RUN - NO TARGET"

    call :WAIT_FOR_USER
    goto MENU
)

set "TARGET_PC=%AdminPC%"
call :UPDATE_SHARE_PATH

echo ============================================================
echo TARGET
echo ============================================================
echo.
echo Administration PC:
echo     %TARGET_PC%
echo.
echo Network Share:
echo     %NetworkSharePath%
echo.

call :WAIT_FOR_USER


rem ------------------------------------------------------------
rem TEST 1 - TARGET
rem ------------------------------------------------------------

cls

echo ============================================================
echo                  [1/8] TARGET CHECK
echo ============================================================
echo.

if defined TARGET_PC (
    echo [OK] Target is configured:
    echo.
    echo     %TARGET_PC%
) else (
    echo [FAIL] Target is not configured.
    set "TroubleshootStatus=FAILED"
    call :WAIT_FOR_USER
    goto MENU
)

echo.

call :WAIT_FOR_USER


rem ------------------------------------------------------------
rem TEST 2 - PING
rem ------------------------------------------------------------

cls

echo ============================================================
echo                    [2/8] PING
echo ============================================================
echo.

echo Target:
echo     %TARGET_PC%
echo.

ping "%TARGET_PC%" -n 4

if errorlevel 1 (
    set "PingStatus=FAILED"
    echo.
    echo [FAIL] Ping did not succeed.
) else (
    set "PingStatus=READY"
    echo.
    echo [PASS] Ping succeeded.
)

echo.

call :WAIT_FOR_USER


rem ------------------------------------------------------------
rem TEST 3 - NAME RESOLUTION
rem ------------------------------------------------------------

cls

echo ============================================================
echo              [3/8] NAME RESOLUTION
echo ============================================================
echo.

powershell.exe -NoProfile -Command ^
    "$t=$env:TARGET_PC; if($t -match '^\d{1,3}(\.\d{1,3}){3}$'){Write-Host '[INFO] Target is an IP address; DNS lookup is bypassed.'; exit 0}; $r=Resolve-DnsName -Name $t -ErrorAction SilentlyContinue; if($r){$r | Select-Object Name,Type,IPAddress | Format-Table -AutoSize; exit 0}else{exit 1}"

if errorlevel 1 (
    set "NameResolutionStatus=FAILED"
    echo.
    echo [FAIL] Name resolution failed.
) else (
    set "NameResolutionStatus=READY"
    echo.
    echo [PASS] Name resolution is acceptable for this target.
)

echo.

call :WAIT_FOR_USER


rem ------------------------------------------------------------
rem TEST 4 - SMB PORT
rem ------------------------------------------------------------

cls

echo ============================================================
echo                 [4/8] TCP PORT 445
echo ============================================================
echo.

powershell.exe -NoProfile -Command ^
    "$t=$env:TARGET_PC; $r=Test-NetConnection -ComputerName $t -Port 445 -WarningAction SilentlyContinue; Write-Host ('RemoteAddress    : ' + $r.RemoteAddress); Write-Host ('RemotePort       : ' + $r.RemotePort); Write-Host ('TcpTestSucceeded : ' + $r.TcpTestSucceeded); if($r.TcpTestSucceeded){exit 0}else{exit 1}"

if errorlevel 1 (
    set "SMBPortStatus=FAILED"
    echo.
    echo [FAIL] TCP port 445 is NOT reachable.
) else (
    set "SMBPortStatus=READY"
    echo.
    echo [PASS] TCP port 445 is reachable.
)

echo.

call :WAIT_FOR_USER


rem ------------------------------------------------------------
rem TEST 5 - DIRECT SMB SHARE
rem ------------------------------------------------------------

cls

echo ============================================================
echo                 [5/8] DIRECT SMB SHARE
echo ============================================================
echo.

echo Testing:
echo     %NetworkSharePath%
echo.

dir "%NetworkSharePath%" >nul 2>&1

if errorlevel 1 (

    set "ShareStatus=FAILED"

    echo [FAIL] Direct SMB Share access failed.
    echo.
    echo This can indicate:
    echo.
    echo     - Authentication problem
    echo     - Share permission problem
    echo     - NTFS permission problem
    echo     - SMB server/share problem
    echo     - Firewall problem
    echo     - Network problem

) else (

    set "ShareStatus=READY"

    echo [PASS] Direct SMB Share access succeeded.

)

echo.

call :WAIT_FOR_USER


rem ------------------------------------------------------------
rem TEST 6 - NETWORK BROWSING
rem ------------------------------------------------------------

cls

echo ============================================================
echo              [6/8] NETWORK BROWSING
echo ============================================================
echo.

echo Testing:
echo     net view \\%TARGET_PC%
echo.

net view "\\%TARGET_PC%"

if errorlevel 1 (

    set "BrowseStatus=FAILED / INFORMATIONAL"

    echo.
    echo [WARNING] Network browsing test failed.
    echo.
    echo IMPORTANT:
    echo A net view failure does NOT automatically mean SMB
    echo is unavailable.
    echo.
    echo If TCP 445 and direct \\Server\Share access succeed,
    echo the problem may be network discovery/browsing only.

) else (

    set "BrowseStatus=READY"

    echo.
    echo [PASS] Network browsing returned successfully.

)

echo.

call :WAIT_FOR_USER


rem ------------------------------------------------------------
rem TEST 7 - WINRM
rem ------------------------------------------------------------

cls

echo ============================================================
echo                    [7/8] WINRM
echo ============================================================
echo.

echo Testing:
echo     Test-WSMan %TARGET_PC%
echo.

powershell.exe -NoProfile -Command ^
    "$t=$env:TARGET_PC; Test-WSMan -ComputerName $t -ErrorAction Stop"

if errorlevel 1 (

    set "WinRMStatus=FAILED"

    echo.
    echo [FAIL] WinRM is NOT reachable.
    echo.
    echo Possible causes:
    echo.
    echo     - WinRM service is stopped
    echo     - WinRM is not configured
    echo     - Firewall is blocking WinRM
    echo     - Network profile/security policy
    echo     - TrustedHosts/authentication configuration
    echo     - Incorrect target

) else (

    set "WinRMStatus=READY"

    echo.
    echo [PASS] WinRM is reachable.

)

echo.

call :WAIT_FOR_USER


rem ------------------------------------------------------------
rem TEST 8 - CONCLUSION
rem ------------------------------------------------------------

cls

echo ============================================================
echo               [8/8] DIAGNOSTIC CONCLUSION
echo ============================================================
echo.

echo Target:
echo     %TARGET_PC%
echo.

echo ------------------------------------------------------------
echo RESULTS
echo ------------------------------------------------------------
echo.

echo Ping:
echo     %PingStatus%
echo.

echo Name Resolution:
echo     %NameResolutionStatus%
echo.

echo TCP Port 445:
echo     %SMBPortStatus%
echo.

echo Direct SMB Share:
echo     %ShareStatus%
echo.

echo Network Browsing:
echo     %BrowseStatus%
echo.

echo WinRM:
echo     %WinRMStatus%
echo.

echo ------------------------------------------------------------
echo INTERPRETATION
echo ------------------------------------------------------------
echo.

if /I "%PingStatus%"=="FAILED" (

    echo [PRIMARY] Basic network reachability failed.
    echo.
    echo Investigate:
    echo     - Target address
    echo     - Wi-Fi/LAN connectivity
    echo     - Target PC power state
    echo     - ICMP firewall policy
    echo.

) else if /I "%SMBPortStatus%"=="FAILED" (

    echo [PRIMARY] Ping works but TCP 445 failed.
    echo.
    echo This strongly points toward an SMB/firewall/service
    echo problem rather than basic IP connectivity.
    echo.

) else if /I "%ShareStatus%"=="FAILED" (

    echo [PRIMARY] TCP 445 is reachable but the Share failed.
    echo.
    echo Investigate:
    echo     - ShareUser authentication
    echo     - SMB share permissions
    echo     - NTFS permissions
    echo     - Share path
    echo.

) else if /I "%WinRMStatus%"=="FAILED" (

    echo [PRIMARY] SMB works but WinRM failed.
    echo.
    echo This indicates a WinRM-specific problem.
    echo.
    echo Investigate:
    echo     - WinRM service
    echo     - WinRM listener
    echo     - Firewall
    echo     - Authentication/trust configuration
    echo.

) else if /I "%BrowseStatus%"=="FAILED / INFORMATIONAL" (

    echo [PRIMARY] Direct SMB access works but network browsing
    echo failed.
    echo.
    echo This is likely a discovery/browsing issue rather than
    echo an SMB share availability problem.
    echo.

) else (

    echo [OK] No major connectivity failure was detected.
    echo.
    echo SMB and WinRM appear reachable from this client.
)

echo.
echo ============================================================
echo TROUBLESHOOTING SAFETY
echo ============================================================
echo.
echo No configuration changes were performed.
echo No services were started or stopped.
echo No firewall rules were changed.
echo No shares were changed.
echo No passwords were stored.
echo.

set "TroubleshootStatus=COMPLETED"

call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem LOCAL SECURITY / WINRM AUDIT
rem ============================================================

:SECURITY_AUDIT

cls

echo ============================================================
echo             LOCAL SECURITY / WINRM AUDIT
echo ============================================================
echo.

echo This is a READ-ONLY audit.
echo.
echo It does NOT:
echo.
echo     - modify firewall rules
echo     - modify WinRM
echo     - modify SMB
echo     - modify NTFS permissions
echo     - change accounts
echo     - change passwords
echo     - delete files
echo.
echo ============================================================
echo.

set "SecurityAuditStatus=RUNNING"

call :REQUIRE_ADMIN_READONLY

echo ------------------------------------------------------------
echo [1] NETWORK PROFILE
echo ------------------------------------------------------------
echo.

powershell.exe -NoProfile -Command ^
    "Get-NetConnectionProfile | Select-Object Name,InterfaceAlias,NetworkCategory,IPv4Connectivity,IPv6Connectivity | Format-Table -AutoSize"

if errorlevel 1 (
    echo [WARNING] Network profile information unavailable.
)

echo.
echo ------------------------------------------------------------
echo [2] WINDOWS FIREWALL PROFILES
echo ------------------------------------------------------------
echo.

powershell.exe -NoProfile -Command ^
    "Get-NetFirewallProfile | Select-Object Name,Enabled,DefaultInboundAction,DefaultOutboundAction | Format-Table -AutoSize"

if errorlevel 1 (
    echo [WARNING] Firewall profile information unavailable.
)

echo.
echo ------------------------------------------------------------
echo [3] WINRM SERVICE
echo ------------------------------------------------------------
echo.

sc query WinRM

echo.
echo ------------------------------------------------------------
echo [4] WINRM LISTENER
echo ------------------------------------------------------------
echo.

winrm enumerate winrm/config/listener

if errorlevel 1 (
    echo [WARNING] WinRM listener information unavailable.
)

echo.
echo ------------------------------------------------------------
echo [5] WINRM CONFIGURATION
echo ------------------------------------------------------------
echo.

winrm get winrm/config

if errorlevel 1 (
    echo [WARNING] WinRM configuration could not be displayed.
)

echo.
echo ------------------------------------------------------------
echo [6] WINRM FIREWALL RULES
echo ------------------------------------------------------------
echo.

powershell.exe -NoProfile -Command ^
    "Get-NetFirewallRule -DisplayGroup 'Windows Remote Management' -ErrorAction SilentlyContinue | Select-Object DisplayName,Enabled,Profile,Direction,Action | Format-Table -AutoSize"

if errorlevel 1 (
    echo [WARNING] WinRM firewall rules could not be queried.
)

echo.
echo ------------------------------------------------------------
echo [7] SMB CLIENT CONFIGURATION
echo ------------------------------------------------------------
echo.

powershell.exe -NoProfile -Command ^
    "Get-SmbClientConfiguration | Select-Object EnableSecuritySignature,RequireSecuritySignature,EnableInsecureGuestLogons | Format-List"

if errorlevel 1 (
    echo [WARNING] SMB client configuration unavailable.
)

echo.
echo ------------------------------------------------------------
echo [8] SMB CONNECTIONS
echo ------------------------------------------------------------
echo.

net use

echo.
echo ------------------------------------------------------------
echo [9] LOCAL ADMINISTRATORS
echo ------------------------------------------------------------
echo.

net localgroup Administrators

if errorlevel 1 (
    echo [WARNING] Local Administrators group could not be queried.
)

echo.
echo ------------------------------------------------------------
echo [10] GUEST ACCOUNT
echo ------------------------------------------------------------
echo.

net user Guest

if errorlevel 1 (
    echo [WARNING] Guest account information unavailable.
)

echo.
echo ============================================================
echo SECURITY AUDIT NOTES
echo ============================================================
echo.
echo [INFO] This audit does not automatically harden the client.
echo.
echo Any security changes must be reviewed and explicitly
echo performed by an administrator.
echo.
echo In particular, do NOT automatically:
echo.
echo     - enable broad firewall rules
echo     - enable insecure guest SMB access
echo     - disable SMB signing
echo     - weaken WinRM authentication
echo     - store passwords in scripts
echo.
echo ============================================================

set "SecurityAuditStatus=COMPLETED"

call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem REQUIRE ADMINISTRATOR FOR READ-ONLY SECURITY AUDIT
rem ============================================================

:REQUIRE_ADMIN_READONLY

if /I "%AdminStatus%"=="ADMINISTRATOR" (
    exit /b 0
)

echo [WARNING] This session is not elevated.
echo.
echo The security audit will continue where Windows permits
echo read-only information.
echo.
exit /b 0


rem ============================================================
rem UPDATE NETWORK SHARE PATH
rem ============================================================

:UPDATE_SHARE_PATH

set "NetworkSharePath="

if defined AdminPC (
    set "NetworkSharePath=\\%AdminPC%\%ShareName%"
)

exit /b 0


rem ============================================================
rem LOAD CONFIGURATION
rem ============================================================

:LOAD_CONFIG

if not exist "%ConfigFile%" (
    exit /b 0
)

rem ------------------------------------------------------------
rem IMPORTANT:
rem
rem Do NOT use:
rem
rem     if defined %%B
rem
rem because that tests whether an environment variable named
rem after the value exists.
rem
rem We only need to verify that the value is not empty.
rem ------------------------------------------------------------

for /f "usebackq tokens=1,* delims==" %%A in ("%ConfigFile%") do (

    if /I "%%A"=="AdminPC" (

        if not "%%B"=="" (
            set "AdminPC=%%B"
        )

    )

)

exit /b 0


rem ============================================================
rem SAVE CONFIGURATION
rem ============================================================

:SAVE_CONFIG

if not defined AdminPC (
    exit /b 1
)

if not exist "%ConfigDir%\" (

    mkdir "%ConfigDir%" >nul 2>&1

    if errorlevel 1 (
        exit /b 1
    )
)

if not exist "%ConfigDir%\" (
    exit /b 1
)

rem ------------------------------------------------------------
rem This is script-owned configuration.
rem No password is written.
rem ------------------------------------------------------------

> "%ConfigFile%" echo # Network Share Client Configuration
>>"%ConfigFile%" echo # Configuration only - no passwords are stored.
>>"%ConfigFile%" echo.
>>"%ConfigFile%" echo AdminPC=%AdminPC%

if errorlevel 1 (
    exit /b 1
)

if not exist "%ConfigFile%" (
    exit /b 1
)

exit /b 0


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
rem EXIT
rem ============================================================

:EXIT

cls

echo ============================================================
echo                 EXIT CLIENT SETUP
echo ============================================================
echo.

echo Client Computer:
echo     %COMPUTERNAME%
echo.

if defined AdminPC (
    echo Administration PC:
    echo     %AdminPC%
) else (
    echo Administration PC:
    echo     [NOT SET]
)

echo.

echo Current session will be closed only if you confirm.
echo.

echo ============================================================
echo.

choice /C YN /N /M "Exit Client Setup? [Y/N]: "

if errorlevel 2 (

    echo.
    echo [INFO] Exit cancelled.
    echo.

    call :WAIT_FOR_USER
    goto MENU
)

cls

echo ============================================================
echo              CLIENT SETUP SESSION CLOSED
echo ============================================================
echo.

echo Client:
echo     %COMPUTERNAME%
echo.

if defined AdminPC (
    echo Administration PC:
    echo     %AdminPC%
) else (
    echo Administration PC:
    echo     [NOT SET]
)

echo.

echo Preservation:
echo     D:\IT-Admin     - NOT MODIFIED
echo     D:\Share        - NOT MODIFIED
echo     D:\Share\Client - NOT MODIFIED
echo.

echo Passwords:
echo     NOT STORED
echo.

echo Deleted files:
echo     NONE
echo.

echo Deleted folders:
echo     NONE
echo.

echo ============================================================
echo.
echo Closing this Command Prompt...
echo ============================================================
echo.

timeout /t 2 /nobreak >nul

endlocal
exit