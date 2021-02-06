# auto-install-notepadpp
Date | Modified by | Remarks
:----: | :----: | :----
2020-11-16 | Sukri | Created.
2020-11-16 | Sukri | Added on what script does.
2020-11-16 | Sukri | Added on how to run the script.
2020-11-16 | Sukri | Added its function descriptions.
2021-02-06 | Sukri | Imported the external modules into the main script.
---

## Description:
> * This is the PowerShell script to install **silently** the Notepad++ installer by getting the latest version from its official site. 
> * All done by automated way!.

Windows Version | OS Architecture | PowerShell Version | Result
:----: | :----: | :----: | :----
Windows 10 | 64-bit and 32-bit | 5.1.x | Tested. `OK`

---

### Below are steps on what script does:

No. | Steps
:----: | :----
0 | Pre-validate to check the administration right when executing the script.
1 | Identify the Windows Operating System (OS) architecture in the target system (i.e. 32-bit or 64-bit).
2 | Pre-validate the Notepad++ application in the target system (either installed or not).
3 | Throw the warning message if the target system already installed with the Notepad++ application and show its current version as well.
4 | Download the latest Notepad++ installer from its official site and temporarily save to `C:\Users\<userprofile>\Downloads`.
5 | Install **silently** the Notepad++ installer in the target system.
6 | Post-validate the Notepad++ application in the target system to check the installation was successfully installed.

---  

### How to run this script.

1. Go to the cloned directory which contains both the `Install-Notepadpp.cmd` and `Install-Notepadpp.ps1` files.
2. Right-click on `Install-Notepadpp.cmd` file and run it as administrator.

**_Note: both of files need to locate the same directory or folder._**

---

### There are some functions involved:

No. | Function Name | Description
:----: | :----: | :----
1 | `Get-OSArchitecture` | This function used for identifying the Windows OS architecture for the target system ( i.e. 32-bit or 64-bit ).
2 | `Get-Notepadpp` | This function used for validating the existing of installed Notepad++ from target system.
3 | `Get-NotepadppBinary` | This function used for downloading the latest version of Notepad++ from its official site.
4 | `Install-Notepadpp` | This function used for installing *silently* the Notepad++ application from temporary download directory. i.e.: `C:\Users\<UserProfile>\Downloads`.
