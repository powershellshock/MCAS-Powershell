function ConvertFrom-MCASTimestamp {
    [CmdletBinding()]
    [OutputType([datetime])]
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        $Timestamp
        )

        (([datetime]'1/1/1970').AddSeconds($Timestamp/1000)).ToLocalTime()
}