﻿function ConvertTo-MCASJsonFilterString {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        $FilterSet
        )

    $Temp = @()

    ForEach ($Filter in $FilterSet) {
        $Temp += ((($Filter | ConvertTo-Json -Depth 2 -Compress).TrimEnd('}')).TrimStart('{'))
        }
    $RawJsonFilter = ('{'+($Temp -join '},')+'}}')
    Write-Verbose "JSON filter string is $RawJsonFilter"

    $RawJsonFilter
}
