@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Network Share - Administration Console
color 0A

rem ============================================================
rem
rem  NETWORK SHARE - ADMINISTRATION CONSOLE
rem
rem ============================================================
rem
rem  Purpose:
rem
rem    Central administration console for registered Windows PCs.
rem
rem  SERVER / ADMINISTRATION PC:
rem
rem    IT-SERVER
rem
rem  LOCAL ADMINISTRATION DATA:
rem
rem    D:\AdminConsole
rem
rem  SHARED DATA:
rem
rem    D:\Share
rem
rem  NETWORK SHARE:
rem
rem    \\IT-SERVER\Share
rem
rem  CLIENT REGISTRY:
rem
rem    D:\AdminConsole\Clients\Clients.txt
rem
rem  ADMINISTRATION WORKSPACE:
rem
rem    D:\IT-Admin
rem
rem
rem  IMPORTANT SAFETY RULES:
rem
rem    1. Existing files are preserved.
rem    2. Existing folders are preserved.
rem    3. Existing client entries are preserved.
rem    4. Duplicate client entries are not added.
rem    5. D:\IT-Admin is NOT modified by this console.
rem    6. D:\Share is NOT modified by this console.
rem    7. D:\Share\Client is NOT created or used.
rem    8. Existing D:\Share\Client is NOT modified.
rem    9. Passwords are NEVER stored by this script.
rem   10. Remote PCs are modified ONLY by explicit actions.
rem   11. Remote commands require confirmation.
rem   12. Restart requires confirmation.
rem   13. Shutdown requires confirmation.
rem   14. LAN discovery only adds devices after confirmation.
rem   15. Existing client entries are never automatically removed.
rem   16. Removing a client removes ONLY its local registry entry.
rem   17. LAN discovery does not modify remote computers.
rem   18. SMB share data is never modified by this console.
rem   19. Security diagnostics are READ-ONLY.
rem   20. This console does NOT automatically close.
rem   21. Only Q -> Y may close the console.
rem
rem ============================================================


rem ============================================================
rem CONFIGURATION
rem ============================================================

set "ServerName=IT-SERVER"

set "AdminConsole=D:\AdminConsole"
set "Clients=%AdminConsole%\Clients"
set "Logs=%AdminConsole%\Logs"
set "Reports=%AdminConsole%\Reports"
set "Config=%AdminConsole%\Config"

set "ClientList=%Clients%\Clients.txt"
set "AdminLog=%Logs%\AdminConsole.log"

set "SharePath=D:\Share"
set "ShareName=Share"
set "ShareUser=ShareUser"

rem ------------------------------------------------------------
rem LAN SCAN CONFIGURATION
rem ------------------------------------------------------------

set "ScanSubnet=192.168.1."
set "ScanStart=1"
set "ScanEnd=254"
set "PingTimeout=100"


rem ============================================================
rem SESSION STATUS
rem ============================================================

set "AdminStatus=UNKNOWN"
set "ShareStatus=NOT CHECKED"
set "LastAction=NONE"

set "TARGET_PC="
set "REMOTE_COMMAND="
set "TempClientList="


goto START


rem ============================================================
rem START
rem ============================================================

:START
cls

echo ============================================================
echo              NETWORK ADMINISTRATION CONSOLE
echo ============================================================
echo.
echo Administration Server:
echo     %ServerName%
echo.
echo Current Computer:
echo     %COMPUTERNAME%
echo.
echo User:
echo     %USERNAME%
echo.
echo Admin Console:
echo     %AdminConsole%
echo.
echo Shared Data:
echo     %SharePath%
echo.
echo Network Share:
echo     \\%ServerName%\%ShareName%
echo.
echo ============================================================
echo.


rem ------------------------------------------------------------
rem Administrator privilege check
rem ------------------------------------------------------------

echo Checking Administrator privileges...
echo.

net session >nul 2>&1

if errorlevel 1 (
    set "AdminStatus=NOT ADMINISTRATOR"

    echo ============================================================
    echo [WARNING] Administrator privileges were not detected.
    echo ============================================================
    echo.
    echo Information and diagnostic functions may still work.
    echo.
    echo Remote administration functions may require an
    echo elevated console.
    echo.
    echo Recommended:
    echo.
    echo     Right-click this BAT file
    echo     Run as administrator
    echo.
) else (
    set "AdminStatus=ADMINISTRATOR"

    echo [OK] Administrator privileges detected.
    echo.
)


rem ------------------------------------------------------------
rem D: drive check
rem ------------------------------------------------------------

if not exist "D:\" (
    echo ============================================================
    echo [ERROR] D: drive was not found.
    echo ============================================================
    echo.
    echo Expected:
    echo.
    echo     %AdminConsole%
    echo     %SharePath%
    echo.
    echo No files or folders were deleted.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

echo [OK] D: drive detected.
echo.


rem ------------------------------------------------------------
rem Ensure local AdminConsole directories
rem ------------------------------------------------------------

call :ENSURE_DIR "%AdminConsole%"
call :ENSURE_DIR "%Clients%"
call :ENSURE_DIR "%Logs%"
call :ENSURE_DIR "%Reports%"
call :ENSURE_DIR "%Config%"


rem ------------------------------------------------------------
rem Create client registry only if missing
rem ------------------------------------------------------------

if not exist "%ClientList%" (

    >"%ClientList%" echo # Registered client PCs
    >>"%ClientList%" echo # One computer name or IP address per line
    >>"%ClientList%" echo # Lines beginning with # are ignored

    if exist "%ClientList%" (
        echo [CREATE] %ClientList%
    ) else (
        echo [WARNING] Could not create:
        echo           %ClientList%
    )

) else (

    echo [KEEP] Client registry:
    echo       %ClientList%
)


rem ------------------------------------------------------------
rem Create administration log only if missing
rem ------------------------------------------------------------

if not exist "%AdminLog%" (

    >"%AdminLog%" echo ============================================================
    >>"%AdminLog%" echo Network Administration Console Log
    >>"%AdminLog%" echo Administration Server: %ServerName%
    >>"%AdminLog%" echo Computer: %COMPUTERNAME%
    >>"%AdminLog%" echo ============================================================

)


call :LOG "Administration Console started."

echo.
echo ============================================================
echo                    CONSOLE READY
echo ============================================================
echo.
echo Administrator Status:
echo     %AdminStatus%
echo.
echo Administration Server:
echo     %ServerName%
echo.
echo Network Share:
echo     \\%ServerName%\%ShareName%
echo.
echo Client Registry:
echo     %ClientList%
echo.
echo ============================================================
echo.

call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem MAIN MENU
rem ============================================================

:MENU
cls

echo ============================================================
echo              NETWORK ADMINISTRATION CONSOLE
echo ============================================================
echo.
echo Administration Server:
echo     %ServerName%
echo.
echo Current Computer:
echo     %COMPUTERNAME%
echo.
echo User:
echo     %USERNAME%
echo.
echo Administrator:
echo     %AdminStatus%
echo.
echo Admin Console:
echo     %AdminConsole%
echo.
echo Client List:
echo     %ClientList%
echo.
echo Shared Data:
echo     %SharePath%
echo.
echo Network Share:
echo     \\%ServerName%\%ShareName%
echo.
echo LAN Scan:
echo     %ScanSubnet%%ScanStart% - %ScanSubnet%%ScanEnd%
echo.
echo Last Action:
echo     %LastAction%
echo.
echo ============================================================
echo.
echo [1] Show Registered PCs
echo [2] Test All PCs
echo [3] Test One PC
echo [4] Remote PC Information
echo [5] Run Remote PowerShell Command
echo [6] Open Remote PowerShell Session
echo [7] Restart Remote PC
echo [8] Shutdown Remote PC
echo [9] Open Network Share
echo [A] Add PC
echo [B] Remove PC
echo [C] Reload Client List
echo [D] Open AdminConsole
echo [E] Network Information
echo [F] Check SMB Share
echo [G] View Administration Log
echo [H] Scan LAN and Add Devices
echo [Q] Exit
echo.
echo ============================================================
echo.

choice /C 123456789ABCDEFGHQ /N /M "Select option: "

set "MenuChoice=%errorlevel%"


rem ------------------------------------------------------------
rem MENU ROUTING
rem ------------------------------------------------------------

if "%MenuChoice%"=="18" goto EXIT_CONFIRMATION
if "%MenuChoice%"=="17" goto SCAN_LAN
if "%MenuChoice%"=="16" goto VIEW_LOG
if "%MenuChoice%"=="15" goto CHECK_SHARE
if "%MenuChoice%"=="14" goto NETWORK
if "%MenuChoice%"=="13" goto ADMIN_FOLDER
if "%MenuChoice%"=="12" goto RELOAD
if "%MenuChoice%"=="11" goto REMOVE_PC
if "%MenuChoice%"=="10" goto ADD_PC
if "%MenuChoice%"=="9" goto OPEN_SHARE
if "%MenuChoice%"=="8" goto SHUTDOWN_PC
if "%MenuChoice%"=="7" goto RESTART_PC
if "%MenuChoice%"=="6" goto REMOTE_SHELL
if "%MenuChoice%"=="5" goto REMOTE_COMMAND
if "%MenuChoice%"=="4" goto REMOTE_INFO
if "%MenuChoice%"=="3" goto TEST_ONE
if "%MenuChoice%"=="2" goto TEST_ALL
if "%MenuChoice%"=="1" goto SHOW_CLIENTS

rem ------------------------------------------------------------
rem SAFETY GUARD
rem ------------------------------------------------------------
rem
rem If CHOICE ever returns an unexpected value, DO NOT allow
rem the script to fall through into another label.
rem
goto MENU


rem ============================================================
rem SHOW REGISTERED PCs
rem ============================================================

:SHOW_CLIENTS
cls

echo ============================================================
echo                    REGISTERED PCs
echo ============================================================
echo.

if not exist "%ClientList%" (
    echo [ERROR] Client registry does not exist.
    echo.
    echo     %ClientList%
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

set /a Count=0

for /f "usebackq eol=# tokens=* delims=" %%A in ("%ClientList%") do (

    set "PC=%%A"

    if defined PC (

        call :NORMALIZE_TARGET PC

        if defined PC (
            set /a Count+=1
            echo [!Count!] !PC!
        )
    )
)

if !Count! EQU 0 (
    echo [INFO] No PCs are currently registered.
)

echo.
echo ------------------------------------------------------------
echo Total Registered PCs:
echo     !Count!
echo.
echo Client Registry:
echo     %ClientList%
echo ------------------------------------------------------------
echo.

set "LastAction=Displayed registered PCs."

call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem TEST ALL PCs
rem ============================================================

:TEST_ALL
cls

echo ============================================================
echo                    TEST ALL PCs
echo ============================================================
echo.
echo This test is diagnostic only.
echo.
echo It does NOT:
echo.
echo     - Change remote configuration
echo     - Start WinRM
echo     - Restart computers
echo     - Modify SMB shares
echo     - Store passwords
echo.
echo ============================================================
echo.

if not exist "%ClientList%" (
    echo [ERROR] Client registry does not exist.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

set /a Total=0
set /a PingReachable=0
set /a PingFailed=0
set /a WinRMReachable=0
set /a WinRMFailed=0

for /f "usebackq eol=# tokens=* delims=" %%A in ("%ClientList%") do (

    set "PC=%%A"

    if defined PC (

        call :NORMALIZE_TARGET PC

        if defined PC (

            set /a Total+=1

            echo ------------------------------------------------------------
            echo Testing:
            echo     !PC!
            echo ------------------------------------------------------------
            echo.

            ping "!PC!" -n 1 -w %PingTimeout% >nul 2>&1

            if errorlevel 1 (
                echo [PING]   FAILED / NO ICMP RESPONSE
                set /a PingFailed+=1
            ) else (
                echo [PING]   REACHABLE
                set /a PingReachable+=1
            )

            set "TARGET_PC=!PC!"

            powershell.exe -NoProfile -Command ^
                "$t=$env:TARGET_PC; Test-WSMan -ComputerName $t -ErrorAction Stop" ^
                >nul 2>&1

            if errorlevel 1 (
                echo [WINRM]  NOT REACHABLE
                set /a WinRMFailed+=1
            ) else (
                echo [WINRM]  REACHABLE
                set /a WinRMReachable+=1
            )

            set "TARGET_PC="

            echo.
        )
    )
)


echo ============================================================
echo                         SUMMARY
echo ============================================================
echo.
echo Total Registered:
echo     %Total%
echo.
echo Ping Reachable:
echo     %PingReachable%
echo.
echo Ping Failed:
echo     %PingFailed%
echo.
echo WinRM Reachable:
echo     %WinRMReachable%
echo.
echo WinRM Not Reachable:
echo     %WinRMFailed%
echo.
echo ============================================================
echo.
echo NOTE:
echo.
echo A failed Ping test does not prove that a PC is offline.
echo Firewalls may block ICMP.
echo.
echo A failed WinRM test does not prove SMB is unavailable.
echo ============================================================
echo.

call :LOG "Tested all registered PCs. Total=%Total%, PingOK=%PingReachable%, PingFailed=%PingFailed%, WinRM_OK=%WinRMReachable%, WinRM_Failed=%WinRMFailed%."

set "LastAction=Tested all registered PCs."

call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem TEST ONE PC
rem ============================================================

:TEST_ONE
cls

echo ============================================================
echo                     TEST ONE PC
echo ============================================================
echo.

set "TargetPC="

set /p "TargetPC=Computer name or IP address: "

if not defined TargetPC (
    echo.
    echo [INFO] No target entered.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

call :NORMALIZE_TARGET TargetPC

if not defined TargetPC (
    echo.
    echo [ERROR] Invalid target.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

set "TARGET_PC=%TargetPC%"

echo.
echo Target:
echo     %TargetPC%
echo.

echo ------------------------------------------------------------
echo PING TEST
echo ------------------------------------------------------------
echo.

ping "%TargetPC%" -n 2 -w %PingTimeout%

set "PingResult=%errorlevel%"

echo.
echo ------------------------------------------------------------
echo TCP 445 TEST
echo ------------------------------------------------------------
echo.

powershell.exe -NoProfile -Command ^
"$t=$env:TARGET_PC; ^
$r=Test-NetConnection -ComputerName $t -Port 445 -WarningAction SilentlyContinue; ^
if ($r.TcpTestSucceeded) { Write-Host '[OK] TCP 445 is reachable.' } else { Write-Host '[WARNING] TCP 445 is NOT reachable.'; exit 1 }"

set "SMBResult=%errorlevel%"

echo.
echo ------------------------------------------------------------
echo WINRM TEST
echo ------------------------------------------------------------
echo.

powershell.exe -NoProfile -Command ^
"$t=$env:TARGET_PC; Test-WSMan -ComputerName $t -ErrorAction Stop"

if errorlevel 1 (
    echo.
    echo [WARNING] WinRM is NOT reachable.
    call :LOG "WinRM test failed for %TargetPC%."
) else (
    echo.
    echo [OK] WinRM is reachable.
    call :LOG "WinRM test passed for %TargetPC%."
)

echo.
echo ------------------------------------------------------------
echo PING RESULT
echo ------------------------------------------------------------

if "%PingResult%"=="0" (
    echo [OK] Ping successful.
) else (
    echo [WARNING] Ping failed.
    echo [INFO] ICMP may be blocked by a firewall.
)

echo.
echo ------------------------------------------------------------
echo SMB RESULT
echo ------------------------------------------------------------

if "%SMBResult%"=="0" (
    echo [OK] TCP port 445 is reachable.
) else (
    echo [WARNING] TCP port 445 is NOT reachable.
)

set "TARGET_PC="

set "LastAction=Tested %TargetPC%."

call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem REMOTE PC INFORMATION
rem ============================================================

:REMOTE_INFO
cls

echo ============================================================
echo                REMOTE PC INFORMATION
echo ============================================================
echo.

set "TargetPC="

set /p "TargetPC=Computer name or IP address: "

if not defined TargetPC (
    echo.
    echo [INFO] No target entered.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

call :NORMALIZE_TARGET TargetPC

if not defined TargetPC (
    echo.
    echo [ERROR] Invalid target.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

set "TARGET_PC=%TargetPC%"

echo.
echo Connecting to:
echo     %TargetPC%
echo.
echo Retrieving read-only information...
echo.

powershell.exe -NoProfile -Command ^
"$Target=$env:TARGET_PC; ^
Invoke-Command -ComputerName $Target -ScriptBlock { ^
Write-Host '============================================================'; ^
Write-Host 'REMOTE COMPUTER'; ^
Write-Host '============================================================'; ^
Get-CimInstance Win32_ComputerSystem | Select-Object Name,Manufacturer,Model,UserName | Format-List; ^
Write-Host ''; ^
Write-Host 'OPERATING SYSTEM'; ^
Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version,BuildNumber,OSArchitecture,LastBootUpTime | Format-List; ^
Write-Host ''; ^
Write-Host 'WINRM SERVICE'; ^
Get-Service WinRM | Select-Object Name,Status,StartType | Format-List; ^
Write-Host ''; ^
Write-Host 'NETWORK'; ^
Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*'} | Select-Object InterfaceAlias,IPAddress,PrefixLength | Format-Table -AutoSize; ^
Write-Host ''; ^
Write-Host 'DISKS'; ^
Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | Select-Object DeviceID,@{N='SizeGB';E={[math]::Round($_.Size/1GB,2)}},@{N='FreeGB';E={[math]::Round($_.FreeSpace/1GB,2)}} | Format-Table -AutoSize ^
}"

if errorlevel 1 (
    echo.
    echo [ERROR] Unable to retrieve remote information.
    call :LOG "Remote information failed for %TargetPC%."
) else (
    echo.
    echo [OK] Remote information retrieved.
    call :LOG "Remote information retrieved from %TargetPC%."
)

set "TARGET_PC="

set "LastAction=Retrieved information from %TargetPC%."

echo.
call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem REMOTE POWERSHELL COMMAND
rem ============================================================

:REMOTE_COMMAND
cls

echo ============================================================
echo              REMOTE POWERSHELL COMMAND
echo ============================================================
echo.

set "TargetPC="
set "RemoteCommand="

set /p "TargetPC=Computer name or IP address: "

if not defined TargetPC (
    echo.
    echo [INFO] No target entered.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

call :NORMALIZE_TARGET TargetPC

if not defined TargetPC (
    echo.
    echo [ERROR] Invalid target.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

set /p "RemoteCommand=PowerShell command: "

if not defined RemoteCommand (
    echo.
    echo [INFO] No PowerShell command entered.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

echo.
echo ============================================================
echo Target:
echo     %TargetPC%
echo.
echo Command:
echo     %RemoteCommand%
echo ============================================================
echo.

echo WARNING:
echo.
echo This command will execute on the remote computer using
echo the current administrative credentials.
echo.
echo The command may modify the remote computer.
echo.
echo Only execute commands that you understand.
echo.

choice /C YN /N /M "Execute command? [Y/N]: "

if errorlevel 2 (
    echo.
    echo [CANCELLED] Remote command was not executed.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

set "TARGET_PC=%TargetPC%"
set "REMOTE_COMMAND=%RemoteCommand%"

echo.
echo Executing remote command...
echo.

powershell.exe -NoProfile -Command ^
"$Target=$env:TARGET_PC; ^
$Command=$env:REMOTE_COMMAND; ^
Invoke-Command -ComputerName $Target -ScriptBlock { ^
param($Command); ^
& ([scriptblock]::Create($Command)) ^
} -ArgumentList $Command"

if errorlevel 1 (
    echo.
    echo [ERROR] Remote command failed.
    call :LOG "Remote command failed on %TargetPC%."
) else (
    echo.
    echo [OK] Remote command completed.
    call :LOG "Remote command executed on %TargetPC%."
)

set "TARGET_PC="
set "REMOTE_COMMAND="

set "LastAction=Executed remote command on %TargetPC%."

echo.
call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem OPEN REMOTE POWERSHELL SESSION
rem ============================================================

:REMOTE_SHELL
cls

echo ============================================================
echo                REMOTE POWERSHELL SESSION
echo ============================================================
echo.

set "TargetPC="

set /p "TargetPC=Computer name or IP address: "

if not defined TargetPC (
    echo.
    echo [INFO] No target entered.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

call :NORMALIZE_TARGET TargetPC

if not defined TargetPC (
    echo.
    echo [ERROR] Invalid target.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

set "TARGET_PC=%TargetPC%"

echo.
echo Target:
echo     %TargetPC%
echo.
echo A remote PowerShell session will open.
echo.
echo Type:
echo     exit
echo.
echo to return to this console.
echo.

choice /C YN /N /M "Open remote PowerShell session? [Y/N]: "

if errorlevel 2 (
    echo.
    echo [CANCELLED] Remote PowerShell session was not opened.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

echo.
echo Opening remote PowerShell session...
echo.

powershell.exe -NoProfile -Command ^
"$Target=$env:TARGET_PC; Enter-PSSession -ComputerName $Target"

call :LOG "Opened remote PowerShell session for %TargetPC%."

set "TARGET_PC="

set "LastAction=Opened remote PowerShell session for %TargetPC%."

echo.
echo Remote PowerShell session closed.
echo.

call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem RESTART REMOTE PC
rem ============================================================

:RESTART_PC
cls

echo ============================================================
echo                    RESTART REMOTE PC
echo ============================================================
echo.

set "TargetPC="

set /p "TargetPC=Computer name or IP address: "

if not defined TargetPC (
    echo.
    echo [INFO] No target entered.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

call :NORMALIZE_TARGET TargetPC

if not defined TargetPC (
    echo.
    echo [ERROR] Invalid target.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

echo.
echo ============================================================
echo WARNING
echo ============================================================
echo.
echo The following computer will be restarted:
echo.
echo     %TargetPC%
echo.
echo Any unsaved work may be lost.
echo.
echo This is a REMOTE CHANGE.
echo.
echo ============================================================
echo.

choice /C YN /N /M "Restart this PC? [Y/N]: "

if errorlevel 2 (
    echo.
    echo [CANCELLED] Restart was not sent.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

set "TARGET_PC=%TargetPC%"

echo.
echo Sending restart command...
echo.

powershell.exe -NoProfile -Command ^
"$Target=$env:TARGET_PC; ^
Invoke-Command -ComputerName $Target -ScriptBlock { Restart-Computer -Force }"

if errorlevel 1 (
    echo.
    echo [WARNING] Restart request returned a non-zero result.
    echo [INFO] The computer may already have begun restarting.
    call :LOG "Remote restart request returned non-zero for %TargetPC%."
) else (
    echo.
    echo [OK] Restart request sent to %TargetPC%.
    call :LOG "Remote restart request sent to %TargetPC%."
)

echo.
echo [INFO] Remote connectivity may now be unavailable.
echo.

set "TARGET_PC="

set "LastAction=Restart request sent to %TargetPC%."

call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem SHUTDOWN REMOTE PC
rem ============================================================

:SHUTDOWN_PC
cls

echo ============================================================
echo                    SHUTDOWN REMOTE PC
echo ============================================================
echo.

set "TargetPC="

set /p "TargetPC=Computer name or IP address: "

if not defined TargetPC (
    echo.
    echo [INFO] No target entered.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

call :NORMALIZE_TARGET TargetPC

if not defined TargetPC (
    echo.
    echo [ERROR] Invalid target.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

echo.
echo ============================================================
echo WARNING
echo ============================================================
echo.
echo The following computer will be shut down:
echo.
echo     %TargetPC%
echo.
echo Any unsaved work may be lost.
echo.
echo This is a REMOTE CHANGE.
echo.
echo ============================================================
echo.

choice /C YN /N /M "Shutdown this PC? [Y/N]: "

if errorlevel 2 (
    echo.
    echo [CANCELLED] Shutdown was not sent.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

set "TARGET_PC=%TargetPC%"

echo.
echo Sending shutdown command...
echo.

powershell.exe -NoProfile -Command ^
"$Target=$env:TARGET_PC; ^
Invoke-Command -ComputerName $Target -ScriptBlock { Stop-Computer -Force }"

if errorlevel 1 (
    echo.
    echo [WARNING] Shutdown request returned a non-zero result.
    echo [INFO] The computer may already have begun shutting down.
    call :LOG "Remote shutdown request returned non-zero for %TargetPC%."
) else (
    echo.
    echo [OK] Shutdown request sent to %TargetPC%.
    call :LOG "Remote shutdown request sent to %TargetPC%."
)

echo.
echo [INFO] Remote connectivity may now be unavailable.
echo.

set "TARGET_PC="

set "LastAction=Shutdown request sent to %TargetPC%."

call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem OPEN NETWORK SHARE
rem ============================================================

:OPEN_SHARE
cls

echo ============================================================
echo                    NETWORK SHARE
echo ============================================================
echo.

echo Administration Server:
echo     %ServerName%
echo.

echo SMB Share:
echo     \\%ServerName%\%ShareName%
echo.

echo Local Shared Data:
echo     %SharePath%
echo.

echo Opening Windows Explorer...
echo.

explorer.exe "\\%ServerName%\%ShareName%"

call :LOG "Opened network share \\%ServerName%\%ShareName%."

set "LastAction=Opened \\%ServerName%\%ShareName%."

echo.
echo [OK] Explorer request sent.
echo.

call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem ADD PC
rem ============================================================

:ADD_PC
cls

echo ============================================================
echo                       ADD PC
echo ============================================================
echo.

set "NewPC="

set /p "NewPC=Computer name or IP address: "

if not defined NewPC (
    echo.
    echo [INFO] No PC entered.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

call :NORMALIZE_TARGET NewPC

if not defined NewPC (
    echo.
    echo [ERROR] Invalid target.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

echo.
echo PC to register:
echo     %NewPC%
echo.

findstr /I /X /C:"%NewPC%" "%ClientList%" >nul 2>&1

if not errorlevel 1 (
    echo [INFO] PC is already registered.
    echo.
    set "LastAction=Checked existing PC %NewPC%."
    call :WAIT_FOR_USER
    goto MENU
)

echo This action adds one line to:
echo.
echo     %ClientList%
echo.
echo No remote computer will be modified.
echo.

choice /C YN /N /M "Add this PC? [Y/N]: "

if errorlevel 2 (
    echo.
    echo [CANCELLED] PC was not added.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

>>"%ClientList%" echo %NewPC%

if errorlevel 1 (
    echo.
    echo [ERROR] Could not update the client registry.
    call :LOG "Failed to add PC: %NewPC%."
) else (
    echo.
    echo [OK] %NewPC% added to the client registry.
    call :LOG "Added PC to registry: %NewPC%."
)

echo.
echo Testing WinRM...
echo.

set "TARGET_PC=%NewPC%"

powershell.exe -NoProfile -Command ^
"$t=$env:TARGET_PC; Test-WSMan -ComputerName $t -ErrorAction Stop" ^
>nul 2>&1

if errorlevel 1 (
    echo.
    echo [WARNING] PC was added, but WinRM is not reachable.
) else (
    echo.
    echo [OK] WinRM is reachable.
)

set "TARGET_PC="

set "LastAction=Added %NewPC% to client registry."

echo.
call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem REMOVE PC
rem ============================================================

:REMOVE_PC
cls

echo ============================================================
echo                      REMOVE PC
echo ============================================================
echo.

set "RemovePC="

set /p "RemovePC=Computer name or IP address to remove: "

if not defined RemovePC (
    echo.
    echo [INFO] No PC entered.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

call :NORMALIZE_TARGET RemovePC

if not defined RemovePC (
    echo.
    echo [ERROR] Invalid target.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

echo.
echo Searching:
echo     %RemovePC%
echo.

findstr /I /X /C:"%RemovePC%" "%ClientList%" >nul 2>&1

if errorlevel 1 (
    echo [INFO] PC is not registered.
    echo.
    set "LastAction=Checked unregistered PC %RemovePC%."
    call :WAIT_FOR_USER
    goto MENU
)

echo ============================================================
echo IMPORTANT
echo ============================================================
echo.
echo This removes ONLY the local registry entry:
echo.
echo     %ClientList%
echo.
echo It does NOT:
echo.
echo     - Delete the remote computer
echo     - Delete remote files
echo     - Uninstall software
echo     - Disable WinRM
echo     - Remove SMB shares
echo     - Change remote settings
echo.

choice /C YN /N /M "Remove registry entry? [Y/N]: "

if errorlevel 2 (
    echo.
    echo [CANCELLED] Registry entry was not removed.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

set "TempClientList=%ClientList%.tmp"

rem ------------------------------------------------------------
rem SAFETY:
rem NEVER delete an unrelated pre-existing temp file.
rem ------------------------------------------------------------

if exist "%TempClientList%" (
    echo.
    echo [ERROR] Temporary file already exists:
    echo     %TempClientList%
    echo.
    echo Operation cancelled to preserve the existing file.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

findstr /I /V /X /C:"%RemovePC%" "%ClientList%" >"%TempClientList%"

if errorlevel 1 (
    echo.
    echo [ERROR] Could not create temporary client registry.
    echo.
    echo Original client registry was preserved.
    echo.

    if exist "%TempClientList%" (
        del /q "%TempClientList%" >nul 2>&1
    )

    call :WAIT_FOR_USER
    goto MENU
)

if not exist "%TempClientList%" (
    echo.
    echo [ERROR] Temporary client registry was not created.
    echo.
    echo Original client registry was preserved.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

move /Y "%TempClientList%" "%ClientList%" >nul 2>&1

if errorlevel 1 (
    echo.
    echo [ERROR] Could not replace the client registry.
    echo.
    echo The original registry was preserved if replacement failed.
    echo.

    if exist "%TempClientList%" (
        echo Temporary file retained:
        echo     %TempClientList%
    )

    call :WAIT_FOR_USER
    goto MENU
)

echo.
echo [OK] PC removed from local registry list.
echo.

call :LOG "Removed PC from registry: %RemovePC%."

set "LastAction=Removed %RemovePC% from client registry."

call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem RELOAD CLIENT LIST
rem ============================================================

:RELOAD
cls

echo ============================================================
echo                 RELOAD CLIENT LIST
echo ============================================================
echo.

if not exist "%ClientList%" (

    >"%ClientList%" echo # Registered client PCs
    >>"%ClientList%" echo # One computer name or IP address per line
    >>"%ClientList%" echo # Lines beginning with # are ignored

    if exist "%ClientList%" (
        echo [CREATE] Client registry created.
    ) else (
        echo [ERROR] Client registry could not be created.
    )

) else (

    echo [OK] Client registry exists.
)

echo.
echo Client List:
echo     %ClientList%
echo.

call :LOG "Client list checked/reloaded."

set "LastAction=Reloaded client list."

call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem OPEN ADMIN CONSOLE
rem ============================================================

:ADMIN_FOLDER
cls

echo ============================================================
echo                    ADMIN CONSOLE
echo ============================================================
echo.

if not exist "%AdminConsole%\" (
    echo [ERROR] AdminConsole directory does not exist.
    echo.
    echo     %AdminConsole%
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

echo Opening:
echo     %AdminConsole%
echo.

explorer.exe "%AdminConsole%"

set "LastAction=Opened AdminConsole."

echo [OK] Explorer request sent.
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

echo Computer:
echo     %COMPUTERNAME%
echo.

echo User:
echo     %USERNAME%
echo.

echo Administrator:
echo     %AdminStatus%
echo.

echo ============================================================
echo IP CONFIGURATION
echo ============================================================
echo.

ipconfig

echo.
echo ============================================================
echo NETWORK ADAPTERS
echo ============================================================
echo.

powershell.exe -NoProfile -Command ^
"Get-NetAdapter | Select-Object Name,Status,LinkSpeed,MacAddress | Format-Table -AutoSize"

echo.
echo ============================================================
echo COMPUTER INFORMATION
echo ============================================================
echo.

powershell.exe -NoProfile -Command ^
"Get-CimInstance Win32_ComputerSystem | Select-Object Name,Domain,PartOfDomain | Format-List"

echo.
echo ============================================================
echo LAN SCAN CONFIGURATION
echo ============================================================
echo.

echo Subnet:
echo     %ScanSubnet%0/24
echo.

echo Scan Range:
echo     %ScanSubnet%%ScanStart% - %ScanSubnet%%ScanEnd%
echo.

echo Ping Timeout:
echo     %PingTimeout% ms
echo.

echo ============================================================
echo SMB SHARE
echo ============================================================
echo.

echo Administration Server:
echo     %ServerName%
echo.

echo Network Share:
echo     \\%ServerName%\%ShareName%
echo.

set "LastAction=Displayed network information."

call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem CHECK SMB SHARE
rem ============================================================

:CHECK_SHARE
cls

echo ============================================================
echo                    SMB SHARE STATUS
echo ============================================================
echo.

echo Administration Server:
echo     %ServerName%
echo.

echo Share Name:
echo     %ShareName%
echo.

echo Expected Local Path:
echo     %SharePath%
echo.

echo Network Share:
echo     \\%ServerName%\%ShareName%
echo.

echo ============================================================
echo SERVER TCP 445 TEST
echo ============================================================
echo.

set "TARGET_PC=%ServerName%"

powershell.exe -NoProfile -Command ^
"$t=$env:TARGET_PC; ^
$r=Test-NetConnection -ComputerName $t -Port 445 -WarningAction SilentlyContinue; ^
if ($r.TcpTestSucceeded) { Write-Host '[OK] TCP 445 is reachable.' } else { Write-Host '[WARNING] TCP 445 is NOT reachable.'; exit 1 }"

if errorlevel 1 (
    echo.
    echo [WARNING] SMB TCP connectivity to %ServerName% failed.
) else (
    echo.
    echo [OK] SMB TCP connectivity is available.
)

set "TARGET_PC="

echo.
echo ============================================================
echo SERVER SHARE ENUMERATION
echo ============================================================
echo.

net view "\\%ServerName%" /all

if errorlevel 1 (
    echo.
    echo [WARNING] Windows could not enumerate shares on %ServerName%.
    echo.
    echo Direct share access will be tested below.
) else (
    echo.
    echo [OK] Server share enumeration completed.
)

echo.
echo ============================================================
echo DIRECT SHARE TEST
echo ============================================================
echo.

echo Testing:
echo     \\%ServerName%\%ShareName%
echo.
echo This is a read-only directory access test.
echo.

dir "\\%ServerName%\%ShareName%" >nul 2>&1

if errorlevel 1 (
    set "ShareStatus=ACCESS FAILED"

    echo [WARNING] Direct SMB share access failed.
    echo.
    echo Possible causes include:
    echo     - Credentials
    echo     - SMB firewall
    echo     - Share permissions
    echo     - NTFS permissions
    echo     - Name resolution
    echo     - Server availability

    call :LOG "Direct SMB share access failed for \\%ServerName%\%ShareName%."

) else (
    set "ShareStatus=ACCESS OK"

    echo [OK] Direct SMB share access succeeded.

    call :LOG "Direct SMB share access succeeded for \\%ServerName%\%ShareName%."
)

echo.
echo ============================================================
echo SMB CLIENT CONNECTIONS
echo ============================================================
echo.

net use

echo.

set "LastAction=Checked SMB share."

call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem VIEW ADMINISTRATION LOG
rem ============================================================

:VIEW_LOG
cls

echo ============================================================
echo                 ADMINISTRATION LOG
echo ============================================================
echo.

if not exist "%AdminLog%" (
    echo [INFO] Administration log does not exist.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

echo Log:
echo     %AdminLog%
echo.

echo ============================================================
echo.

type "%AdminLog%"

echo.
echo.
echo ============================================================
echo.

set "LastAction=Viewed administration log."

call :WAIT_FOR_USER
goto MENU


rem ============================================================
rem SCAN LAN AND ADD DEVICES
rem ============================================================

:SCAN_LAN
cls

echo ============================================================
echo              SCAN LAN AND ADD DEVICES
echo ============================================================
echo.

echo This function scans:
echo.
echo     %ScanSubnet%%ScanStart%
echo     through
echo     %ScanSubnet%%ScanEnd%
echo.
echo Discovery methods:
echo.
echo     1. ICMP Ping
echo     2. NBTSTAT
echo     3. NetBIOS computer name
echo     4. Existing client registry check
echo     5. Optional client registration
echo     6. WinRM connectivity test
echo.
echo Existing client entries are preserved.
echo.
echo No remote configuration is performed by the scan.
echo.
echo ============================================================
echo IMPORTANT
echo ============================================================
echo.
echo NBTSTAT does not identify every device.
echo.
echo Devices may respond to Ping but have:
echo.
echo     - NetBIOS disabled
echo     - Firewall restrictions
echo     - No NetBIOS name
echo     - No WinRM
echo     - Non-Windows operating system
echo.
echo Such devices will NOT be automatically registered by name.
echo.

choice /C YN /N /M "Start LAN scan? [Y/N]: "

if errorlevel 2 (
    echo.
    echo [CANCELLED] LAN scan was not started.
    echo.
    call :WAIT_FOR_USER
    goto MENU
)

echo.
echo ============================================================
echo                    LAN SCAN STARTED
echo ============================================================
echo.

set /a ScanTotal=0
set /a PingOnline=0
set /a NamedDevices=0
set /a ExistingDevices=0
set /a AddedDevices=0
set /a NoNameDevices=0
set /a WinRMReachable=0
set /a WinRMUnavailable=0

for /L %%I in (%ScanStart%,1,%ScanEnd%) do (

    set /a ScanTotal+=1

    set "CurrentIP=%ScanSubnet%%%I"
    set "DeviceName="

    echo ------------------------------------------------------------
    echo Scanning:
    echo     !CurrentIP!
    echo ------------------------------------------------------------

    ping -n 1 -w %PingTimeout% "!CurrentIP!" >nul 2>&1

    if errorlevel 1 (

        echo [OFFLINE] !CurrentIP!

    ) else (

        set /a PingOnline+=1

        echo [ONLINE]  !CurrentIP!

        rem --------------------------------------------------------
        rem NBTSTAT DISCOVERY
        rem --------------------------------------------------------

        for /f "tokens=1,2,3" %%A in ('
            nbtstat -A "!CurrentIP!" 2^>nul ^|
            findstr /I /R "<00>.*UNIQUE"
        ') do (

            if /I "%%B"=="<00>" if /I "%%C"=="UNIQUE" (
                if not defined DeviceName (
                    set "DeviceName=%%A"
                )
            )
        )

        rem --------------------------------------------------------
        rem NAME FOUND
        rem --------------------------------------------------------

        if defined DeviceName (

            set /a NamedDevices+=1

            echo [NAME]    !DeviceName!

            rem ----------------------------------------------------
            rem CHECK REGISTRY
            rem ----------------------------------------------------

            findstr /I /X /C:"!DeviceName!" "%ClientList%" >nul 2>&1

            if not errorlevel 1 (

                set /a ExistingDevices+=1

                echo [EXISTS]  !DeviceName!

            ) else (

                echo.
                echo New Windows device discovered:
                echo.
                echo     Name: !DeviceName!
                echo     IP:   !CurrentIP!
                echo.

                choice /C YN /N /M "Add this PC to Clients.txt? [Y/N]: "

                if errorlevel 2 (

                    echo [SKIP]    !DeviceName!

                ) else (

                    >>"%ClientList%" echo !DeviceName!

                    if errorlevel 1 (

                        echo [ERROR]   Could not add !DeviceName!
                        call :LOG "Failed to add discovered PC: !DeviceName! (!CurrentIP!)."

                    ) else (

                        set /a AddedDevices+=1

                        echo [ADDED]   !DeviceName!

                        call :LOG "LAN scan added PC: !DeviceName! (!CurrentIP!)."
                    )
                )
            )

            rem ----------------------------------------------------
            rem WINRM TEST
            rem ----------------------------------------------------

            set "TARGET_PC=!DeviceName!"

            echo [WINRM]   Testing !DeviceName!...

            powershell.exe -NoProfile -Command ^
                "$t=$env:TARGET_PC; Test-WSMan -ComputerName $t -ErrorAction Stop" ^
                >nul 2>&1

            if errorlevel 1 (

                set /a WinRMUnavailable+=1

                echo [WINRM]   Not reachable

            ) else (

                set /a WinRMReachable+=1

                echo [WINRM]   Reachable
            )

            set "TARGET_PC="

        ) else (

            set /a NoNameDevices+=1

            echo [NAME]    No NetBIOS computer name detected.
            echo [INFO]    Device was not automatically registered.
        )
    )

    echo.
)


echo ============================================================
echo                     SCAN COMPLETE
echo ============================================================
echo.

echo IP Addresses Scanned:
echo     %ScanTotal%
echo.

echo Ping Responsive:
echo     %PingOnline%
echo.

echo Named Windows Devices:
echo     %NamedDevices%
echo.

echo Already Registered:
echo     %ExistingDevices%
echo.

echo Newly Added:
echo     %AddedDevices%
echo.

echo Online Devices Without NetBIOS Name:
echo     %NoNameDevices%
echo.

echo WinRM Reachable:
echo     %WinRMReachable%
echo.

echo WinRM Not Reachable:
echo     %WinRMUnavailable%
echo.

echo Client Registry:
echo     %ClientList%
echo.

echo ============================================================
echo PRESERVATION STATUS
echo ============================================================
echo.

echo Existing client entries:
echo     PRESERVED
echo.

echo Existing D:\Share contents:
echo     PRESERVED
echo.

echo D:\Share\Client:
echo     NOT CREATED / NOT USED
echo.

echo D:\IT-Admin:
echo     NOT MODIFIED
echo.

echo ============================================================
echo.

call :LOG "LAN scan completed. Scanned=%ScanTotal%, Online=%PingOnline%, Named=%NamedDevices%, Existing=%ExistingDevices%, Added=%AddedDevices%, NoName=%NoNameDevices%, WinRM_OK=%WinRMReachable%, WinRM_Failed=%WinRMUnavailable%."

set "LastAction=Completed LAN scan."

call :WAIT_FOR_USER
goto MENU


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

if errorlevel 1 (
    echo [WARNING] Unable to create:
    echo           %~1
    exit /b 1
)

echo [OK]     Created:
echo          %~1

exit /b 0


rem ============================================================
rem NORMALIZE TARGET
rem ============================================================

:NORMALIZE_TARGET

set "NormalizeValue=!%~1!"

if not defined NormalizeValue (
    set "%~1="
    exit /b 0
)

for /f "tokens=* delims= " %%A in ("!NormalizeValue!") do (
    set "NormalizeValue=%%A"
)

for /f "tokens=* delims= " %%A in ("!NormalizeValue!") do (
    set "NormalizeValue=%%A"
)

set "%~1=!NormalizeValue!"

exit /b 0


rem ============================================================
rem LOG
rem ============================================================

:LOG

if not exist "%Logs%\" (
    mkdir "%Logs%" >nul 2>&1
)

if not exist "%AdminLog%" (

    >"%AdminLog%" echo ============================================================
    >>"%AdminLog%" echo Network Administration Console Log
    >>"%AdminLog%" echo Administration Server: %ServerName%
    >>"%AdminLog%" echo Computer: %COMPUTERNAME%
    >>"%AdminLog%" echo ============================================================

)

>>"%AdminLog%" echo [%DATE% %TIME%] %~1

exit /b 0


rem ============================================================
rem WAIT FOR USER
rem ============================================================

:WAIT_FOR_USER

echo.
echo ============================================================
echo Press any key to return to the main menu...
echo ============================================================
pause >nul

exit /b 0


rem ============================================================
rem EXIT CONFIRMATION
rem ============================================================

:EXIT_CONFIRMATION
cls

echo ============================================================
echo              EXIT ADMINISTRATION CONSOLE
echo ============================================================
echo.

echo Administration Server:
echo     %ServerName%
echo.

echo Current Computer:
echo     %COMPUTERNAME%
echo.

echo User:
echo     %USERNAME%
echo.

echo Admin Console:
echo     %AdminConsole%
echo.

echo Shared Data:
echo     %SharePath%
echo.

echo Client Registry:
echo     %ClientList%
echo.

echo Last Action:
echo     %LastAction%
echo.

echo ============================================================
echo.
echo Exiting this console does NOT:
echo.
echo     - Delete client entries
echo     - Delete D:\Share files
echo     - Delete D:\Share folders
echo     - Modify D:\IT-Admin
echo     - Modify D:\Share
echo     - Modify existing SMB shares
echo     - Modify remote PCs
echo.
echo ============================================================
echo.

choice /C YN /N /M "Exit Administration Console? [Y/N]: "

if errorlevel 2 (
    echo.
    echo [INFO] Exit cancelled.
    echo.
    set "LastAction=Exit cancelled."
    call :WAIT_FOR_USER
    goto MENU
)

goto CLOSE_CONSOLE


rem ============================================================
rem CLOSE CONSOLE
rem ============================================================
rem
rem IMPORTANT:
rem
rem This is the ONLY location in the entire script that may
rem terminate the batch process.
rem
rem Normal operations NEVER reach this label.
rem Only:
rem
rem     Q -> Exit
rem     Y -> Confirm Exit
rem
rem reaches this label.
rem

:CLOSE_CONSOLE

call :LOG "Administration Console closed by user confirmation."

cls

echo ============================================================
echo        NETWORK ADMINISTRATION CONSOLE CLOSED
echo ============================================================
echo.

echo Administration Server:
echo     %ServerName%
echo.

echo Current Computer:
echo     %COMPUTERNAME%
echo.

echo User:
echo     %USERNAME%
echo.

echo Admin Console:
echo     %AdminConsole%
echo.

echo Shared Data:
echo     %SharePath%
echo.

echo Client Registry:
echo     %ClientList%
echo.

echo.
echo Existing files and folders were preserved.
echo.
echo D:\IT-Admin was not modified by exiting.
echo.
echo D:\Share was not modified by exiting.
echo.
echo D:\Share\Client was not created or modified.
echo.
echo No passwords were stored.
echo.
echo ============================================================
echo.
echo The console will close because Exit was explicitly confirmed.
echo.
echo ============================================================
echo.

pause

endlocal
exit /b


rem ============================================================
rem SAFETY END GUARD
rem ============================================================
rem
rem If execution somehow reaches the physical end of this BAT
rem without going through CLOSE_CONSOLE, keep the console alive
rem by returning to the menu instead of allowing an unexpected
rem termination.
rem
rem ============================================================

:END_GUARD

goto MENU