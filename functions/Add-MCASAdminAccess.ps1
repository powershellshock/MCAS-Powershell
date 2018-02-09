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
        $readOnlyAdded = $false

        $preExistingAdmins = Get-MCASAdminAccess -Credential $Credential
    }
    process {
        $success = $false

        if ($preExistingAdmins.username -contains $Username) {
            Write-Warning "Add-MCASAdminAccess: $Username is already listed as an administrator of Cloud App Security."
            }
        else {
            $body = [ordered]@{'username'=$Username;'permissionType'=($PermissionType -as [string])}

            try {
                $response = Invoke-MCASRestMethod -Credential $Credential -Path '/cas/api/v1/manage_admin_access/' -Method Post -Body $body
            }
                catch {
                    throw "Error calling MCAS API. The exception was: $_"
                }
            
            Write-Verbose "Checking admin list for $Username"
            if ((Get-MCASAdminAccess -Credential $Credential).username -contains $Username) {
                if ($PermissionType -eq 'READ_ONLY') {
                    $readOnlyAdded = $true
                }
            }
            else {
                Write-Error "Something went wrong adding $Username. The user was not added."
            }
        }
    }
    end {
        if ($readOnlyAdded) {
            Write-Warning "Add-MCASAdminAccess: READ_ONLY acces includes the ability to manage alerts."
        }
    }
}
