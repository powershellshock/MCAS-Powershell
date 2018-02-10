function Get-MCASAdminAccess
{
    [CmdletBinding()]
    Param
    (
        # Specifies the credential object containing tenant as username (e.g. 'contoso.us.portal.cloudappsecurity.com') and the 64-character hexadecimal Oauth token as the password.
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]$Credential = $CASCredential
    )

    try {
        $response = Invoke-MCASRestMethod -Credential $Credential -Path '/cas/api/v1/manage_admin_access/' -Method Get
    }
    catch {
        throw "Error calling MCAS API. The exception was: $_"
    }

    $response = $response.data 
    
    $response
}