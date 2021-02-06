<#
.Synopsis
   Short description
    This script will be used for installing silently Notepad++ installer with getting latest version from web.
.DESCRIPTION
   Long description
    2020-11-16 Sukri Created.
    2021-02-06 Sukri Imported some external modules.
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
    Author : Sukri Kadir
    Email  : msmak1990@gmail.com
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>

#import the external functions from the external script files.
. "$PSScriptRoot\Get-AdministrationRight"
. "$PSScriptRoot\Get-OSArchitecture"
. "$PSScriptRoot\Get-Notepadpp"
. "$PSScriptRoot\Get-NotepadppBinary"

#throw exception if no administration right.
$IsAdministrator = Get-AdministrationRight

if ($IsAdministrator -ne $true)
{
    Write-Warning -Message "You are currently running this script WITHOUT the administration right. Please run with administration right. Exit." -WarningAction Stop
}

#function to install the Notepad++ application.
function Install-Notepadpp
{
    Param
    (

    #Parameter for Notepad++ installer file name.
        [ValidateNotNullOrEmpty()]
        [String]
        $BinaryFileName = "npp.7.9.1.Installer.exe",

    #Parameter for Notepad++ installer source path or uri.
        [ValidateNotNullOrEmpty()]
        [String]
        $InstallerSourceDirectory = "https://notepad-plus-plus.org/downloads"
    )

    Begin
    {
        #validate if Notepad++ installed or not from target system.
        $ApplicationInstallationStatus = Get-Notepadpp

        if ($ApplicationInstallationStatus[0] -eq $true)
        {
            Write-Warning -Message "[$( $ApplicationInstallationStatus[1] )] already installed." -WarningAction Continue
        }

        #validate if Notepad++ is not installed from target system.
        if ($ApplicationInstallationStatus[0] -eq $false)
        {
            #if Notepad++ installer source directory is local directory.
            if ($( Test-Path -Path $InstallerSourceDirectory -PathType Any ))
            {
                Write-Warning -Message "[$InstallerSourceDirectory] is local directory."

                #get full path of Notepad++ binary file.
                $BinaryFile = "$InstallerSourceDirectory\$BinaryFileName"
            }

            #if Notepad++ installer source directory is url.
            if (!$( Test-Path -Path $InstallerSourceDirectory -PathType Any ))
            {
                Write-Warning -Message "[$InstallerSourceDirectory] is url link." -WarningAction Continue

                #get full path of Notepad++ binary file.
                $BinaryFile = Get-NotepadppBinary -InstallerSourceUrl $InstallerSourceDirectory
            }
        }

    }
    Process
    {

        #if Notepad++ is not installed from target system.
        if ($ApplicationInstallationStatus[0] -eq $false)
        {
            #install Notepad++ binary.
            Start-Process -FilePath $BinaryFile -ArgumentList "/S" -Wait -NoNewWindow -Verbose -ErrorAction Stop
        }

    }
    End
    {
        Write-Host "Done."
    }
}

#log the logging into log file.
Start-Transcript -Path "$PSScriptRoot\$( $MyInvocation.ScriptName )"

#execute the function.
Install-Notepadpp

#stop to log the logging.
Stop-Transcript