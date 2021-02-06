<#
.Synopsis
   Short description
    This script will be used for validating the OS architecture (64 or 32-bit) in the target system.
.DESCRIPTION
   Long description
    2021-02-06 Sukri Created.
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