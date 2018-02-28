function Get-MCASIPRange
{
    [CmdletBinding()]
    Param
    (
        # Specifies the CAS credential object containing the 64-character hexadecimal OAuth token used for authentication and authorization to the CAS tenant.
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]$Credential = $CASCredential,

        # Specifies the maximum number of results to retrieve when listing items matching the specified filter criteria.
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [ValidateRange(1,100)]
        [int]$ResultSetSize = 100,

        # Specifies the number of records, from the beginning of the result set, to skip.
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [ValidateScript({$_ -gt -1})]
        [int]$Skip = 0
        
    )
    
    $body = @{'skip'=$Skip;'limit'=$ResultSetSize} # Base request body

    try {
        $response = Invoke-MCASRestMethod -Credential $Credential -Path "/cas/api/v1/subnet/" -Method Post -Body $body
    }
    catch {
        throw $_  #Exception handling is in Invoke-MCASRestMethod, so here we just want to throw it back up the call stack, with no additional logic
    }

    $response = $response.data 
    
    try {
        Write-Verbose "Adding alias property to results, if appropriate"
        $response = $response | Add-Member -MemberType AliasProperty -Name Identity -Value '_id' -PassThru
    }
    catch {}
    
    $response
}
