function Get-MCASReport {
    [CmdletBinding()]
    param
    (
        # Specifies the credential object containing tenant as username (e.g. 'contoso.us.portal.cloudappsecurity.com') and the 64-character hexadecimal Oauth token as the password.
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]$Credential = $CASCredential
    )

    # Get the matching items and handle errors
    try {
        #$response = Invoke-MCASRestMethod2 -Uri "https://$TenantUri/api/reports/" -Method Post -Token $Token
        $response = Invoke-MCASRestMethod -Credential $Credential -Path "/api/reports/" -Method Post
    }
    catch {
        throw "Error calling MCAS API. The exception was: $_"
    }

    $response = $response.data

    # Add 'Identity' alias property and 'FriendlyName' note property
    #$response = $response | Add-Member -MemberType AliasProperty -Name Identity -Value _id -PassThru | ForEach-Object {Add-Member -InputObject $_ -MemberType NoteProperty -Name FriendlyName -Value $ReportsListReverse.Get_Item($_.report_name) -PassThru}

    <#
    try {
        Write-Verbose "Adding alias property to results, if appropriate"
        $response = $response | Add-Member -MemberType AliasProperty -Name Identity -Value '_id' -PassThru
    }
    catch {} #>

    $response    
}