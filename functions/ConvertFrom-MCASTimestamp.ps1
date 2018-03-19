<#
.Synopsis
    Converts an MCAS timestamp (13-digit integer) to a native date/time value of type [datetime].
.DESCRIPTION
    ConvertFrom-MCASTimestamp returns a System.DateTime value representing the time (localized to the Powershell session's timezone) for a timestamp value from MCAS.

.EXAMPLE
    PS C:\> ConvertFrom-MCASTimestamp 1520272590839
    Monday, March 5, 2018 12:56:30 PM

.EXAMPLE
    PS C:\> Get-MCASActivity -ResultSetSize 5 | ForEach-Object {ConvertFrom-MCASTimestamp $_.timestamp}
    Monday, March 5, 2018 12:56:30 PM
    Monday, March 5, 2018 12:50:28 PM
    Monday, March 5, 2018 12:49:34 PM
    Monday, March 5, 2018 12:45:36 PM
    Monday, March 5, 2018 12:45:23 PM

.FUNCTIONALITY
    ConvertFrom-MCASTimestamp is intended to return the Powershell datetime of a timestamp value from MCAS.
#>
function ConvertFrom-MCASTimestamp {
    [CmdletBinding()]
    [OutputType([datetime])]
    param (
        [Parameter(Mandatory=$true,Position=0)]
        [ValidatePattern({^\d{13}$})]
        $Timestamp
    )
    (([datetime]'1/1/1970').AddSeconds($Timestamp/1000)).ToLocalTime()
}