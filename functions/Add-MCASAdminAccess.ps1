function Add-MCASAdminAccess
{
    [CmdletBinding()]
    param
    (
        # Specifies the credential object containing tenant as username (e.g. 'contoso.us.portal.cloudappsecurity.com') and the 64-character hexadecimal Oauth token as the password.
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]$Credential = $CASCredential,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$Username,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=1)]
        [ValidateNotNullOrEmpty()]
        [permission_type]$PermissionType
    )
    begin {
        $ReadOnlyAdded = $false
    }
    process {
        if ((Get-MCASAdminAccess -Credential $Credential).username -contains $Username) {
            Write-Warning "Add-MCASAdminAccess: $Username is already listed as an administrator of Cloud App Security. No changes were made."
            }
        else {
            $body = [ordered]@{'username'=$Username;'permissionType'=($PermissionType -as [string])}

            try {
                #$Response = Invoke-MCASRestMethod2 -Uri "https://$TenantUri/cas/api/v1/manage_admin_access/" -Token $Token -Method Post -Body $Body
                $response = Invoke-MCASRestMethod -Credential $Credential -Path '/cas/api/v1/manage_admin_access/' -Method Post -Body $body
            }
                catch {
                    throw "Error calling MCAS API. The exception was: $_"
                }
                      
            if ($Response.StatusCode -eq '200') {
                Write-Verbose "$Username was added to MCAS admin list with $PermissionType permission"
                if ($PermissionType -eq 'READ_ONLY') {
                    $ReadOnlyAdded = $true
                }
            }
            else {
                Write-Error "Something went wrong when attempting to add $Username to MCAS admin list with $PermissionType permission"
            }
        }
    }
    end {
        if ($ReadOnlyAdded) {
            Write-Warning "Add-MCASAdminAccess: READ_ONLY acces includes the ability to manage alerts."
        }
    }
}
