<#
.Synopsis
   Short description
    This script will be used for installing silently Notepad++ installer with getting latest version from web.
.DESCRIPTION
   Long description
    2020-11-16 Sukri Created.
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

$IsAdministrator = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($IsAdministrator -ne $true)
{
    Write-Warning -Message "Please run script with administrator right." -WarningAction Stop
    Exit-PSSession
}

function Get-OSArchitecture
{
    Param
    (
    #parameter for query statement for OS Architecture.
        [ValidateNotNullOrEmpty()]
        [String]
        $QueryOSArchitecture = "Select OSArchitecture from Win32_OperatingSystem"
    )

    Begin
    {
        #get OS Architecture.
        $OSArchitecture = (Get-WmiObject -Query "Select OSArchitecture from Win32_OperatingSystem").OSArchitecture
    }
    Process
    {
        #identify which OS Architecture.
        if ($OSArchitecture)
        {
            #for 64-bit OS Architecture.
            if ($OSArchitecture -eq "64-bit")
            {
                $OSArchitectureBit = $OSArchitecture
            }

            #for 32-bit OS Architecture.
            if ($OSArchitecture -ne "64-bit")
            {
                $OSArchitectureBit = $OSArchitecture
            }
        }

        #return null if OS Architecture is empty.
        if (!$OSArchitecture)
        {
            $OSArchitectureBit = $null
        }
    }
    End
    {
        #return true if values available.
        if ($OSArchitectureBit)
        {
            return $true, $OSArchitectureBit
        }

        #return true if values available.
        if ($OSArchitectureBit)
        {
            return $false
        }
    }
}

function Get-Notepadpp
{
    Param
    (
    #Parameter for registry path for installed software..
        [ValidateNotNullOrEmpty()]
        [Array]
        $UninstallRegistries = @("HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall")
    )

    Begin
    {
        #throw exception if registry path is not available.
        foreach ($UninstallRegistry in $UninstallRegistries)
        {
            #write warning if only not exist.
            if (!$( Test-Path -Path $UninstallRegistry -PathType Any ))
            {
                Write-Warning -Message "[$UninstallRegistry] does not exist." -WarningAction Continue
            }

        }
    }
    Process
    {
        #recusively search Notepad++ through registry key.
        foreach ($UninstallRegistry in $UninstallRegistries)
        {
            #get Notepad++ registry properties.
            $RegistryProperties = Get-ItemProperty -Path "$UninstallRegistry\*"

            foreach ($RegistryProperty in $RegistryProperties)
            {
                if ($( $RegistryProperty.DisplayName ) -like "*Notepad++*")
                {
                    $ApplicationName = $( $RegistryProperty.DisplayName )
                }
            }

        }
    }
    End
    {
        #return true if Notepad++ installed in target system.
        if ($ApplicationName)
        {
            return $true, $ApplicationName
        }

        #return false if no Notepad++ installed in target system.
        if (!$ApplicationName)
        {
            return $false
        }
    }
}


function Get-NotepadppBinary
{
    Param
    (
    #parameter for Notepad++ installer source url.
        [ValidateNotNullOrEmpty()]
        [String]
        $InstallerSourceUrl
    )

    Begin
    {
        #create the request.
        $HttpRequest = [System.Net.WebRequest]::Create($InstallerSourceUrl)

        #get a response from the site.
        $HttpResponse = $HttpRequest.GetResponse()

        #get the HTTP code as an integer.
        $HttpStatusCode = [int]$HttpResponse.StatusCode

        #throw exception if status code is not 200 (OK).
        if ($HttpStatusCode -ne 200)
        {
            Write-Error -Message "[$InstallerSourceUrl] unable to reach out with status code [$HttpStatusCode]." -ErrorAction Stop
        }

        #get OS architecture - 32 or 64-bit?.
        $OSArchitecture = Get-OSArchitecture

    }
    Process
    {
        #get site contents.
        $SiteContents = Invoke-WebRequest -Uri $InstallerSourceUrl -UseBasicParsing

        #get href link.
        $SiteHrefs = $SiteContents.Links

        #dynamic array for storing Notepad++ version extracted from site.
        $ApplicationVersion = [system.Collections.ArrayList]@()

        #filter only uri contains the Notepad++ versions.
        foreach ($SiteHref in $SiteHrefs)
        {
            if ($SiteHref.href -match "https://notepad-plus-plus.org/downloads/v\d.*/$")
            {
                $UrlVersion = $SiteHref.href -replace "https://notepad-plus-plus.org/downloads/", ""
                $VersionNumber = $UrlVersion -replace "/", ""
                $ApplicationVersion.Add($VersionNumber) | Out-Null
            }
        }

        #get latest Notepad++ installer version.
        $LatestApplicationVersion = $ApplicationVersion[0]

        #remove space from installer version.
        $VersionNumber = $( $LatestApplicationVersion -replace "v", "" )

        #get OS architecture for Notepad++ binary file name.
        if ($OSArchitecture[0] -eq $true)
        {
            #for 32-bit
            if ($OSArchitecture[1] -eq "32-bit")
            {
                #get latest Notepad++ binary file name.
                $BinaryFileName = "npp.$VersionNumber.Installer.exe"
            }

            #for 64-bit
            if ($OSArchitecture[1] -eq "64-bit")
            {
                #get latest Notepad++ binary file name.
                $BinaryFileName = "npp.$VersionNumber.Installer.x64.exe"
            }
        }

        #if no available for OS Architecture, then use 32-bit Notepad++ binary file name.
        if ($OSArchitecture[0] -eq $false)
        {
            #get latest Notepad++ binary file name.
            $BinaryFileName = "npp.$VersionNumber.Installer.exe"
        }

        #get full path of Notepad++ binary source url.
        $BinarySourceUrl = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/$LatestApplicationVersion/$BinaryFileName"

        #get Notepad++ download destination directory for specific user.
        $InstallerDownloadDirectory = "$( $env:USERPROFILE )\Downloads\$BinaryFileName"

        #download latest Notepad++ binary file from site.
        Invoke-WebRequest -Uri $BinarySourceUrl -OutFile $InstallerDownloadDirectory -Verbose -TimeoutSec 60

        #throw exception if no available for Notepad++ installer.
        if (!$( Test-Path -Path $InstallerDownloadDirectory -PathType Leaf ))
        {
            Write-Error -Message "[$InstallerDownloadDirectory] does not exist." -Category ObjectNotFound -ErrorAction Stop
        }
    }
    End
    {
        if (!$( Test-Path -Path $InstallerDownloadDirectory -PathType Leaf ))
        {
            Write-Error -Message "[$InstallerDownloadDirectory] does not exist." -Category ObjectNotFound -ErrorAction Stop
        }

        #return full path for Notepad++ installer binary file.
        return $InstallerDownloadDirectory
    }
}



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

Install-Notepadpp