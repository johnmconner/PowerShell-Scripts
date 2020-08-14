function Get-MachineInfo {
    <#
    .SYNOPSIS
    Retrieves specific information about one or more computers, using CIM over WSMAN.
    
    .DESCRIPTION
    This command uses CIM to retrieve specific information about one or more computers.
    You must run this command as a user who has permission to remotely query CIM on the machines involved.
    
    .PARAMETER Log
    Logs the computer name to a log when a connection to the computer fails
    
    .NOTES
    Version:        1.0
    Author:         John Conner
    Creation Date:  8/07/2020
      
    .EXAMPLE
    Get-MachineInfo -ComputerName ONE,TWO,THREE
    This example will query three machines.
    
    .EXAMPLE
    Get-ADComputer -filter * | Select -Expand Name | Get-MachineInfo
    This example will attempt to query all machines in AD.
    #>
    [cmdletbinding()]
    Param(
        [parameter(ValueFromPipeline = $True, Mandatory = $True)]
        [string[]]$ComputerName,
        [switch]$Log
    )
    
    BEGIN { $ProblemPC = @() }
    
    PROCESS {
            
        foreach ($computer in $computername) {
    
            #Establish sessions protocol
                
            $option = New-CimSessionOption -Protocol Wsman
    
            #Create session
            write-verbose "Connecting to $computer"
            Try {
                $session = New-CimSession -ComputerName $computer -SessionOption $option -ErrorAction Stop
    
                #Grab all system information
                $osinfo = Get-CimInstance -ClassName Win32_OperatingSystem -Property Caption, BuildNumber, CSName -CimSession $session
                $systeminfo = Get-CimInstance -ClassName Win32_ComputerSystem -Property SystemSKUNumber, model, totalphysicalmemory -CimSession $session
                $serialnumber = Get-CimInstance -ClassName Win32_BIOS -Property SerialNumber -CimSession $session
                $processor = Get-CimInstance -ClassName Win32_Processor -Property Name -CimSession $session
                $productkey = Get-CimInstance -Query "SELECT OA3xOriginalProductKey FROM softwarelicensingservice" -CimSession $session
    
                #Close session
                $session | Remove-CimSession
                    
                #Create output object
                $props = @{'ModelSKU' = $systeminfo.SystemSKUNumber
                    'Model'           = $systeminfo.Model
                    'OS'              = $osinfo.Caption
                    'OSVersion'       = $osinfo.BuildNumber
                    'ComputerName'    = $osinfo.CSName
                    'SerialNumber'    = $serialnumber.SerialNumber
                    'ProductKey'      = $productkey.OA3xOriginalProductKey
                    'Processor'       = $processor.Name
                    'TotalMemory'     = $systeminfo.TotalPhysicalMemory
                }
                New-Object -TypeName psobject -Property $props
 
            }    
            #add failures to array
            Catch {
                Write-Warning "FAILURE on $computer"
                $ProblemPC += $computer
            }
        }
        #log any failures
        $logpath = "$env:systemdrive\logging\"
        $logname = $logpath + 'log.txt'
        if ($Log) {
            if (-not(test-path $logpath)) {
                New-Item -Path $logpath -ItemType Directory | Out-Null
                $ProblemPC | out-file -filepath $logname 
            }
            Else {
                $ProblemPC | out-file -filepath $logname 
            }
        }
            
    }
}

    