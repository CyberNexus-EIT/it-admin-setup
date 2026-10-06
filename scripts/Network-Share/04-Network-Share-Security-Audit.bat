@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Network Share Security Audit - IT-SERVER

set "ServerName=IT-SERVER"
set "ServerIP=192.168.1.100"
set "ShareName=Share"
set "SharePath=D:\Share"
set "ShareUser=ShareUser"

set "AuditRoot=D:\AdminConsole\Reports"
set "AuditFile=%AuditRoot%\Network-Share-Security-Audit.txt"

:MENU
cls
echo ============================================================
echo       NETWORK SHARE SECURITY AUDIT
echo ============================================================
echo.
echo Server        : %ServerName%
echo Server IP     : %ServerIP%
echo Share         : \\%ServerName%\%ShareName%
echo Share Path    : %SharePath%
echo Share Account : %ShareUser%
echo.
echo [1] Run Full Security Audit
echo [2] Network Profile
echo [3] Windows Firewall
echo [4] SMB Security
echo [5] SMB1 Status
echo [6] Guest / Insecure SMB Access
echo [7] WinRM Security
echo [8] Share Permissions
echo [9] NTFS Permissions
echo [A] ShareUser Account
echo [B] TCP 445
echo [C] Save Audit Report
echo [D] Open Audit Report Folder
echo [Q] Exit
echo.
choice /C 123456789ABCDQ /N /M "Select an option: "

if errorlevel 14 goto EXIT
if errorlevel 13 goto OPEN_REPORT_FOLDER
if errorlevel 12 goto SAVE_AUDIT
if errorlevel 11 goto TEST_445
if errorlevel 10 goto CHECK_SHAREUSER
if errorlevel 9 goto CHECK_NTFS
if errorlevel 8 goto CHECK_SHARE
if errorlevel 7 goto CHECK_WINRM
if errorlevel 6 goto CHECK_GUEST
if errorlevel 5 goto CHECK_SMB1
if errorlevel 4 goto CHECK_SMB
if errorlevel 3 goto CHECK_FIREWALL
if errorlevel 2 goto CHECK_NETWORK
if errorlevel 1 goto FULL_AUDIT

goto MENU


:FULL_AUDIT
cls
echo ============================================================
echo              FULL SECURITY AUDIT
echo ============================================================
echo.
echo This audit is READ-ONLY.
echo No configuration will be changed.
echo.

call :CHECK_NETWORK
call :CHECK_FIREWALL
call :CHECK_SMB
call :CHECK_SMB1
call :CHECK_GUEST
call :CHECK_WINRM
call :CHECK_SHARE
call :CHECK_NTFS
call :CHECK_SHAREUSER
call :TEST_445

echo.
echo ============================================================
echo              AUDIT COMPLETE
echo ============================================================
echo.
echo Review all WARNING and FAIL results.
echo.
pause
goto MENU


:CHECK_NETWORK
echo.
echo ============================================================
echo NETWORK PROFILE
echo ============================================================
echo.

powershell -NoProfile -Command "Get-NetConnectionProfile | Select-Object Name,InterfaceAlias,InterfaceIndex,NetworkCategory,IPv4Connectivity,IPv6Connectivity | Format-List"

echo.
echo Interpretation:
echo Private network  = normally appropriate for trusted LAN.
echo Public network   = WARNING for a server providing SMB services.
echo.
pause
goto :eof


:CHECK_FIREWALL
echo.
echo ============================================================
echo WINDOWS FIREWALL PROFILES
echo ============================================================
echo.

powershell -NoProfile -Command "Get-NetFirewallProfile | Select-Object Name,Enabled,DefaultInboundAction,DefaultOutboundAction,AllowInboundRules,AllowLocalFirewallRules,AllowLocalIPsecRules | Format-Table -AutoSize"

echo.
echo Checking common SMB and WinRM firewall rules...
echo.

powershell -NoProfile -Command "Get-NetFirewallRule -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -match 'File and Printer Sharing|Windows Management Instrumentation|Windows Remote Management' } | Select-Object DisplayName,Enabled,Profile,Direction,Action | Format-Table -AutoSize"

echo.
echo NOTE:
echo This audit does not enable, disable, create, or remove firewall rules.
echo.
pause
goto :eof


:CHECK_SMB
echo.
echo ============================================================
echo SMB SERVER SECURITY
echo ============================================================
echo.

echo --- SMB Server Configuration ---
powershell -NoProfile -Command "Get-SmbServerConfiguration | Select-Object EnableSMB1Protocol,EnableSMB2Protocol,EnableSecuritySignature,RequireSecuritySignature,EncryptData,RejectUnencryptedAccess,EnableAuthenticateUserSharing,EnableStrictNameChecking,EnableLeasing,EnableMultiChannel | Format-List"

echo.
echo --- SMB Server Shares ---
powershell -NoProfile -Command "Get-SmbShare -ErrorAction SilentlyContinue | Select-Object Name,Path,Description,EncryptData,FolderEnumerationMode,ConcurrentUserLimit | Format-Table -AutoSize"

echo.
echo --- SMB Server Sessions ---
powershell -NoProfile -Command "Get-SmbSession -ErrorAction SilentlyContinue | Select-Object ClientComputerName,ClientUserName,NumOpens,Dialect,SecondsIdle,SecondsExists | Format-Table -AutoSize"

echo.
echo Security notes:
echo RequireSecuritySignature = True is preferred where compatible.
echo EnableSMB2Protocol = True is expected.
echo EnableSMB1Protocol = False is preferred.
echo EncryptData = True may provide stronger protection but compatibility must be considered.
echo.
pause
goto :eof


:CHECK_SMB1
echo.
echo ============================================================
echo SMB1 STATUS
echo ============================================================
echo.

echo --- SMB Server Configuration ---
powershell -NoProfile -Command "Get-SmbServerConfiguration | Select-Object EnableSMB1Protocol | Format-List"

echo.
echo --- Windows Optional Feature ---
dism /online /Get-FeatureInfo /FeatureName:SMB1Protocol

echo.
echo SMB1 is an obsolete protocol and should normally be disabled.
echo This audit does NOT disable SMB1.
echo.
pause
goto :eof


:CHECK_GUEST
echo.
echo ============================================================
echo GUEST / INSECURE SMB ACCESS
echo ============================================================
echo.

echo --- SMB Client Configuration ---
powershell -NoProfile -Command "Get-SmbClientConfiguration | Select-Object EnableInsecureGuestLogons,RequireSecuritySignature,EnableSecuritySignature,EnableSecuritySignature | Format-List"

echo.
echo --- Local Security Policy: Guest Account ---
net user Guest

echo.
echo --- Local Security Policy: Anonymous / Guest Related Registry Values ---
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RestrictAnonymous 2>nul
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RestrictAnonymousSAM 2>nul
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v EveryoneIncludesAnonymous 2>nul

echo.
echo WARNING:
echo Do not enable insecure guest access merely to solve authentication problems.
echo.
pause
goto :eof


:CHECK_WINRM
echo.
echo ============================================================
echo WINRM SECURITY
echo ============================================================
echo.

echo --- WinRM Service ---
sc query WinRM

echo.
echo --- WinRM Startup Configuration ---
sc qc WinRM

echo.
echo --- WinRM Listeners ---
winrm enumerate winrm/config/listener

echo.
echo --- WinRM Configuration ---
winrm get winrm/config

echo.
echo --- TrustedHosts ---
powershell -NoProfile -Command "Get-Item WSMan:\localhost\Client\TrustedHosts -ErrorAction SilentlyContinue | Select-Object Name,Value | Format-List"

echo.
echo --- Local Test-WSMan ---
powershell -NoProfile -Command "Test-WSMan -ComputerName localhost"

echo.
echo Security notes:
echo TrustedHosts wildcard (*) should generally be avoided.
echo WinRM should not be exposed broadly to untrusted networks.
echo This audit does not change WinRM configuration.
echo.
pause
goto :eof


:CHECK_SHARE
echo.
echo ============================================================
echo SMB SHARE PERMISSIONS
echo ============================================================
echo.

echo --- net share ---
net share %ShareName%

echo.
echo --- SMB Share Access Rules ---
powershell -NoProfile -Command "Get-SmbShareAccess -Name '%ShareName%' -ErrorAction SilentlyContinue | Format-Table -AutoSize"

echo.
echo --- SMB Share Details ---
powershell -NoProfile -Command "Get-SmbShare -Name '%ShareName%' -ErrorAction SilentlyContinue | Select-Object Name,Path,Description,EncryptData,FolderEnumerationMode | Format-List"

echo.
echo IMPORTANT:
echo Share permissions and NTFS permissions work together.
echo The most restrictive effective permission applies.
echo.
pause
goto :eof


:CHECK_NTFS
echo.
echo ============================================================
echo NTFS PERMISSIONS
echo ============================================================
echo.

if not exist "%SharePath%\" (
    echo FAIL: %SharePath% does not exist.
    pause
    goto :eof
)

echo --- Root NTFS ACL ---
icacls "%SharePath%"

echo.
echo --- NTFS ACL Summary ---
powershell -NoProfile -Command "Get-Acl -LiteralPath '%SharePath%' | Select-Object Owner,Access | Format-List"

echo.
echo --- ShareUser NTFS Entries ---
icacls "%SharePath%" | findstr /I "%ShareUser%"

echo.
echo NOTE:
echo This audit does not modify D:\Share permissions.
echo Existing files and folders are preserved.
echo.
pause
goto :eof


:CHECK_SHAREUSER
echo.
echo ============================================================
echo SHAREUSER ACCOUNT AUDIT
echo ============================================================
echo.

echo --- Account Information ---
net user %ShareUser%

echo.
echo --- Local Group Membership ---
net user %ShareUser% | findstr /I "Local Group Memberships"

echo.
echo --- Administrators Group ---
net localgroup Administrators

echo.
echo --- Users Group ---
net localgroup Users

echo.
echo Security notes:
echo ShareUser should normally be a standard account, not an Administrator.
echo Password should not be stored in BAT files.
echo Password should not be embedded in configuration files.
echo.
pause
goto :eof


:TEST_445
echo.
echo ============================================================
echo TCP 445 SMB CONNECTIVITY
echo ============================================================
echo.

echo Testing local SMB listener...
powershell -NoProfile -Command "Test-NetConnection -ComputerName '%ServerIP%' -Port 445 | Select-Object ComputerName,RemotePort,TcpTestSucceeded"

echo.
echo Testing server hostname...
powershell -NoProfile -Command "Test-NetConnection -ComputerName '%ServerName%' -Port 445 | Select-Object ComputerName,RemotePort,TcpTestSucceeded"

echo.
echo --- Local Listening Port ---
netstat -ano | findstr ":445"

echo.
echo NOTE:
echo TCP 445 should be reachable only from networks that require SMB.
echo This audit does not change firewall rules.
echo.
pause
goto :eof


:SAVE_AUDIT
cls
echo ============================================================
echo SAVE SECURITY AUDIT REPORT
echo ============================================================
echo.

if not exist "%AuditRoot%\" mkdir "%AuditRoot%"

echo Running full audit and saving report...
echo.

(
echo ============================================================
echo NETWORK SHARE SECURITY AUDIT
echo ============================================================
echo Date:
date /t
echo Time:
time /t
echo.
echo Server        : %ServerName%
echo Server IP     : %ServerIP%
echo Share         : \\%ServerName%\%ShareName%
echo Share Path    : %SharePath%
echo Share Account : %ShareUser%
echo ============================================================
echo.
echo NETWORK PROFILE
echo ============================================================
powershell -NoProfile -Command "Get-NetConnectionProfile | Select-Object Name,InterfaceAlias,InterfaceIndex,NetworkCategory,IPv4Connectivity,IPv6Connectivity | Format-List"

echo.
echo FIREWALL PROFILES
echo ============================================================
powershell -NoProfile -Command "Get-NetFirewallProfile | Select-Object Name,Enabled,DefaultInboundAction,DefaultOutboundAction,AllowInboundRules,AllowLocalFirewallRules | Format-Table -AutoSize"

echo.
echo SMB SERVER CONFIGURATION
echo ============================================================
powershell -NoProfile -Command "Get-SmbServerConfiguration | Select-Object EnableSMB1Protocol,EnableSMB2Protocol,EnableSecuritySignature,RequireSecuritySignature,EncryptData,RejectUnencryptedAccess,EnableAuthenticateUserSharing,EnableStrictNameChecking | Format-List"

echo.
echo SMB SHARES
echo ============================================================
powershell -NoProfile -Command "Get-SmbShare -ErrorAction SilentlyContinue | Select-Object Name,Path,Description,EncryptData,FolderEnumerationMode | Format-Table -AutoSize"

echo.
echo SMB SHARE ACCESS
echo ============================================================
powershell -NoProfile -Command "Get-SmbShareAccess -Name '%ShareName%' -ErrorAction SilentlyContinue | Format-Table -AutoSize"

echo.
echo SMB1 FEATURE
echo ============================================================
dism /online /Get-FeatureInfo /FeatureName:SMB1Protocol

echo.
echo GUEST / INSECURE SMB
echo ============================================================
powershell -NoProfile -Command "Get-SmbClientConfiguration | Select-Object EnableInsecureGuestLogons,RequireSecuritySignature,EnableSecuritySignature | Format-List"
net user Guest

echo.
echo WINRM SERVICE
echo ============================================================
sc query WinRM
sc qc WinRM

echo.
echo WINRM LISTENERS
echo ============================================================
winrm enumerate winrm/config/listener

echo.
echo WINRM CONFIGURATION
echo ============================================================
winrm get winrm/config

echo.
echo TRUSTEDHOSTS
echo ============================================================
powershell -NoProfile -Command "Get-Item WSMan:\localhost\Client\TrustedHosts -ErrorAction SilentlyContinue | Select-Object Name,Value | Format-List"

echo.
echo SHAREUSER
echo ============================================================
net user %ShareUser%

echo.
echo NTFS PERMISSIONS
echo ============================================================
icacls "%SharePath%"

echo.
echo TCP 445
echo ============================================================
powershell -NoProfile -Command "Test-NetConnection -ComputerName '%ServerIP%' -Port 445 | Select-Object ComputerName,RemotePort,TcpTestSucceeded"
netstat -ano | findstr ":445"

echo.
echo ============================================================
echo END OF SECURITY AUDIT
echo ============================================================
) > "%AuditFile%" 2>&1

echo.
echo Audit saved:
echo %AuditFile%
echo.
pause
goto MENU


:OPEN_REPORT_FOLDER
if not exist "%AuditRoot%\" mkdir "%AuditRoot%"
start "" "%AuditRoot%"
goto MENU


:EXIT
cls
echo ============================================================
echo EXIT
echo ============================================================
echo.
choice /C YN /N /M "Exit Security Audit? [Y/N]: "

if errorlevel 2 goto MENU
if errorlevel 1 (
    endlocal
    exit
)

goto MENU