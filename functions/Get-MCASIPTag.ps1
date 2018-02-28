function Get-MCASIPTag
{
    [CmdletBinding()]
    Param
    (
        # Specifies the CAS credential object containing the 64-character hexadecimal OAuth token used for authentication and authorization to the CAS tenant.
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]$Credential = $CASCredential,



        # Specifies the maximum number of results to retrieve when listing items matching the specified filter criteria.
        [Parameter(Mandatory=$false)]
        [ValidateRange(1,100)]
        [int]$ResultSetSize = 100,

        # Specifies the number of records, from the beginning of the result set, to skip.
        [Parameter(Mandatory=$false)]
        [ValidateScript({$_ -ge 0})]
        [int]$Skip = 0
    )
    Process {

        # Get the matching alerts and handle errors
        try {
            $response = Invoke-MCASRestMethod -Credential $Credential -Path "/cas/api/tags/?enabledOnly=true&sort=name&sortDirectory=asc&target=ip" -Method Get # IP tag
            #$response = Invoke-MCASRestMethod -Credential $Credential -Path "/cas/api/tags/?enabledOnly=true&sort=name&sortDirectory=asc&target=user" -Method Get # group
            #$response = Invoke-MCASRestMethod -Credential $Credential -Path "/cas/api/tags/?enabledOnly=true&sort=name&sortDirectory=asc&target=device" -Method Get # device tag
            #$response = Invoke-MCASRestMethod -Credential $Credential -Path "/cas/api/tags/?enabledOnly=true&sort=name&sortDirectory=asc&target=userAgent" -Method Get # useragent tag
            
        }
            catch {
                throw "Error calling MCAS API. The exception was: $_"
            }

        Write-Verbose "Getting just the response property named 'data'"
        $response = $response.data

        #Write-Verbose "Adding the friendly name of the application to the response as a property named 'app'"
        #$Response = $Response | Add-Member -NotePropertyName 'app' -NotePropertyValue ($AppId -as [mcas_app]) -PassThru

        #Write-Verbose "Selecting properties to be returned"
        #$Response = $Response | Select-Object -Property name,app,types,id

        $response
    }
}
