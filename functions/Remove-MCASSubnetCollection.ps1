function Remove-MCASSubnetCollection
{
    [CmdletBinding()]
    Param
    (
        # Specifies the credential object containing tenant as username (e.g. 'contoso.us.portal.cloudappsecurity.com') and the 64-character hexadecimal Oauth token as the password.
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]$Credential = $CASCredential,

        [Parameter(ParameterSetName='ById',Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern("[a-z0-9]{24}")]
        [alias("_id")]
        [string]$Identity,

        [Parameter(ParameterSetName='ByName',Mandatory=$true,ValueFromPipeline=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory=$false)]
        [Switch]$Quiet
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            Write-Verbose "Parameter set 'ByName' detected"

            Get-MCASSubnetCollection -Credential $Credential | ForEach-Object {
                if ($_.Name -eq $Name) {
                    $SubnetId = $_.Identity
                    $NameOrIdTargeted = $Name
                }
            }
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'ById') {
            Write-Verbose "Parameter set 'ById' detected"
            $SubnetId = $Identity
            $NameOrIdTargeted = $SubnetId
        }
        else {
            Write-Verbose "Parameter set not detected"
            Write-Error "Could not determine identity of subnet to be deleted"
        }

        try {
            #$response = Invoke-MCASRestMethod2 -Uri "https://$TenantUri/api/v1/subnet/$SubnetId/" -Token $Token -Method Delete 
            $response = Invoke-MCASRestMethod -Credential $Credential -Path "/api/v1/subnet/$SubnetId/" -Method Delete 
        }
        catch {
            throw "Error calling MCAS API. The exception was: $_"
        }
        
        Write-Verbose "Checking response for success" 
        if ($response.StatusCode -eq '200') {
            $Success = $true
            Write-Verbose "Successfully deleted subnet $Name" 
        }
        else {
            $Success = $false
            Write-Verbose "Something went wrong attempting to delete subnet $Name" 
            Write-Error "Something went wrong attempting to delete subnet $Name"
        }

        if (!$Quiet) {
            $Success
        }      
    }
}
