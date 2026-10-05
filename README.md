IT Admin Setup

A simple Windows batch utility for setting up a local IT administrator account and enabling Windows remote administration on authorized PCs within a small office network.

Features

- Creates a dedicated "ITAdmin" local account
- Prompts for the account password interactively
- Adds "ITAdmin" to the local "Administrators" group
- Enables Windows PowerShell Remoting
- Enables the required Windows Remote Management firewall rules
- Displays basic computer and network information
- Verifies the administrator account and WinRM configuration
- Does not store the administrator password in the script

Requirements

- Windows 10 or Windows 11
- Administrator privileges
- Authorized access to the Windows PC
- Network connection for remote administration
- PowerShell Remoting / WinRM support

Usage

1. Download "IT-Admin-Setup.bat".
2. Right-click the file.
3. Select Run as administrator.
4. Follow the instructions shown in Command Prompt.
5. Enter the password when prompted.
6. Wait for the configuration and verification steps to finish.

Account

The script creates:

Username: ITAdmin
Account type: Local Administrator

The password is entered interactively during setup and is not stored in the script.

Intended Use

This utility is intended for authorized IT administration of computers owned or managed by the user or organization.

Use it only on PCs where you have permission to create administrator accounts and configure remote administration.

Security Notice

Adding a local account to the Windows "Administrators" group gives that account extensive control over the PC.

PowerShell Remoting and WinRM also provide remote administration capabilities.

Before using this utility in a production environment, review the Windows firewall, WinRM configuration, network scope, account permissions, and organizational security policies.

For better security, use the principle of least privilege and restrict remote administration to trusted networks and authorized administrators.

License

This project is licensed under the MIT License.

See the ""LICENSE"" (LICENSE) file for the complete license text.

Author

Mark C. Pangilinan / CyberNexus PH
