<#
.Synopsis
    Auto-detects MCAS integer timestamps, in epoch milliseconds (13-digit integers) or epoch seconds (10-digit integers), and converts to a native date/time value of type [datetime] in local time.
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
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        $Timestamp
    )
    process {
        Write-Verbose $Timestamp.ToString().length
        if ($Timestamp.ToString().length -eq 13) {
            (([datetime]'1/1/1970').AddSeconds($Timestamp/1000)).ToLocalTime()
        }
        elseif ($Timestamp.ToString().length -eq 10) {
            (([datetime]'1/1/1970').AddSeconds($Timestamp)).ToLocalTime()
        }
        else {
            throw 'Unexpected value provided for -Timestamp parameter. A 13-digit or 10-digit timestamp was expected.'
        }
    }   
}