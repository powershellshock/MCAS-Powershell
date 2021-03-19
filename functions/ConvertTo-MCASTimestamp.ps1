<#
.Synopsis
    Converts a [datetime] to epoch milliseconds for MCAS.
.DESCRIPTION
    ConvertTo-MCASTimestamp returns an [int] value representing the milliseconds since 1970-01-01, 
    the expected timestamp format for MCAS requests, such as in URI-based query filters.

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
function ConvertTo-MCASTimestamp {
    [CmdletBinding()]
    [OutputType([int])]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [datetime]$Timestamp
    )
    (New-TimeSpan -Start (Get-Date "01/01/1970") -End (Get-Date $Timestamp)).TotalMilliseconds  
}