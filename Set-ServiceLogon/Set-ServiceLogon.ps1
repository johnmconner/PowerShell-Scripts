function Set-TMServiceLogon {
    [cmdletbinding()]
    param (
        [string]$ServiceName,
        [string[]]$ComputerName,
        [String]$NewPassword,
        [string]$NewUser,
        [string]$ErrorLogPath
    )

    if ($PSBoundParameters.ContainsKey('NewUser')) {
        $unpw = @{'StartName'=$NewUser;'StartPassword'=$NewPassword}
    } Else {
        $unpw = @{'StartPassword'=$NewPassword}
    }

    foreach ($Computer in $ComputerName) {
        #Set connection options (Defaulting to WSMAN)
        $options = New-CimSessionOption -Protocol Wsman
            
        #Establish CIM Session
        $session = New-CimSession -ComputerName $computer -SessionOption $options

        #Invoke the CIM method
        Invoke-CimMethod -Query "SELECT * from Win32_Service where name=$servicename" -MethodName Change  -Arguments $unpw -CimSession $session
    }
}