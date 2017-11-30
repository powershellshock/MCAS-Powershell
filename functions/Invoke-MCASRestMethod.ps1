﻿function Invoke-MCASRestMethod {
    [CmdletBinding()]
    Param (
        # Specifies the credential object containing tenant as username (e.g. 'contoso.us.portal.cloudappsecurity.com') and the 64-character hexadecimal Oauth token as the password.
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]$Credential,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory=$true)]
        [ValidateSet('Get','Post','Put','Delete')]
        [string]$Method,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        $Body,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$ContentType = 'application/json',

        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        $FilterSet,

        # Specifies the retry interval, in seconds, if a call to the MCAS web API is throttled. Default = 5
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        $RetryInterval = 5,

        [switch]$Raw
    )

    if ($Raw) {
        $cmd = 'Invoke-WebRequest'
        Write-Verbose "-Raw parameter was specified"
    }
    else {
        $cmd = 'Invoke-RestMethod'
        Write-Verbose "-Raw parameter was not specified"
    }
    Write-Verbose "$cmd will be used"

    $tenant = ($Credential.GetNetworkCredential().username)
    Write-Verbose "Tenant name is $tenant"

    Write-Verbose "Relative path is $Path"

    Write-Verbose "Method is $Method"

    $token = $Credential.GetNetworkCredential().Password.ToLower()
    Write-Verbose "Token is $token"

    $headers = 'Authorization = "Token {0}"' -f $token | ForEach-Object {"@{$_}"}
    Write-Verbose "Request headers are $headers"

    # Construct base MCAS call before processing -Body and -FilterSet
    $mcasCall = '{0} -Uri ''https://{1}{2}'' -Method {3} -Headers {4} -ContentType {5}' -f $cmd, $tenant, $Path, $Method, $headers, $ContentType

    if ($Method -eq 'Get') {
        Write-Verbose "The http method 'Get' does not allow a message body to be sent."
    }
    else {
        $jsonBody = $Body | ConvertTo-Json -Compress -Depth 2
        Write-Verbose "Base request body is $jsonBody"

        if ($FilterSet) {
            Write-Verbose "Request body before query filters is $jsonBody"
            $jsonBody = $jsonBody.TrimEnd('}') + ',' + '"filters":{' + ((ConvertTo-MCASJsonFilterString $FilterSet).TrimStart('{')) + '}'
            Write-Verbose "Request body after query filters is $jsonBody"
        }
        else {
            Write-Verbose "No filters were added to the request body"
        }
        Write-Verbose "Final request body is $jsonBody"

        # Add -Body to the constructed MCAS call, when the http method is not 'Get'
        $mcasCall = '{0} -Body ''{1}''' -f $mcasCall, $jsonBody
    }

    Write-Verbose "Constructed call to MCAS is '$mcasCall'"

    Write-Verbose "Retry interval if MCAS call is throttled is $RetryInterval seconds"

    # This loop is the actual call to MCAS. It includes automatic retry if the API call is throttled
    do {
        $retryCall = $false

        try {
            Write-Verbose "Attempting call to MCAS..."
            $response = Invoke-Expression -Command $mcasCall
        }
            catch {
                if ($_ -like 'The remote server returned an error: (429) TOO MANY REQUESTS.') {
                    $retryCall = $true

                    Write-Warning "429 - Too many requests. The MCAS API throttling limit has been hit, the call will be retried in $RetryInterval second(s)..."

                    Write-Verbose "Sleeping for $RetryInterval seconds"
                    Start-Sleep -Seconds $RetryInterval
                }
                else {
                    throw $_
                }
            }
    }
    while ($retryCall)

    if ($null -ne $response.total) {
        Write-Verbose ('The total number of matching records was {0}' -f ($response.total))
        Write-Information $response.total
    }

    $response
}