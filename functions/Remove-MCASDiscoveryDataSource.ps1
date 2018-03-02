function Remove-MCASDiscoveryDataSource {
    [CmdletBinding()]
    param
    (
        # Specifies the credential object containing tenant as username (e.g. 'contoso.us.portal.cloudappsecurity.com') and the 64-character hexadecimal Oauth token as the password.
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]$Credential = $CASCredential,

        # Specifies the name of the data source object to create
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [alias("_id")]
        [string]$Identity
    )
    process {
        try {
            $response = Invoke-MCASRestMethod -Credential $Credential -Path "/cas/api/v1/discovery/data_sources/$Identity/" -Method Delete
        }
        catch {
            throw "Error calling MCAS API. The exception was: $_"
        }
    }
}