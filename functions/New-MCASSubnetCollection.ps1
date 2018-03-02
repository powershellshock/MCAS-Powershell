function New-MCASSubnetCollection
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
        [string]$Name,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=1)]
        [ValidateNotNullOrEmpty()]
        [ip_category]$Category,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=2)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}\/\d{1,2}$|^[a-zA-Z0-9:]{3,39}\/\d{1,3}$')]
        [string[]]$Subnets,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true,Position=3)]
        [ValidateNotNullOrEmpty()]
        [string]$Organization,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true,Position=4)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tags,

        [Parameter(Mandatory=$false)]
        [Switch]$Quiet
    )
    process {
        $body = [ordered]@{'name'=$Name;'category'=($Category -as [int]);'subnets'=$Subnets}

        if ($Tags) {
            $body.Add('tags',$Tags)
        }
        
        if ($Organization) {
            $body.Add('organization',$Organization)
        }

        try {
            $response = Invoke-MCASRestMethod -Credential $Credential -Path "/cas/api/v1/subnet/create_rule/" -Method Post -Body $body
        }
        catch {
            throw "Error calling MCAS API. The exception was: $_"
        }

        if (!$Quiet) {
            $response
        }
    }
}