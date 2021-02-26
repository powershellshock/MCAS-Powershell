function Invoke-MCASRequest {
    [CmdletBinding()]
    param (
        # Specifies the credential object containing tenant as username (e.g. 'contoso.us.portal.cloudappsecurity.com') and the 64-character hexadecimal Oauth token as the password.
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({
            ($_.GetNetworkCredential().username).EndsWith('.portal.cloudappsecurity.com')
        })]
        [ValidateScript({
            $_.GetNetworkCredential().Password -match ($MCAS_TOKEN_VALIDATION_PATTERN)
        })]
        [System.Management.Automation.PSCredential]$Credential = $CASCredential,

        # Specifies the relative path of the uri being invoked (e.g. - '/api/v1/alerts/' or '/api/v1/alerts/<alertId>/')
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        # Specifies the HTTP method to be used for the request
        [Parameter(Mandatory=$true)]
        [ValidateSet('Get','Post','Put','Delete')]
        [string]$Method,

        # Specifies the body of the request, not including MCAS query filters, which should be specified separately in the -Path
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        $Body,

        # Specifies the content type to be used for the request. Default = 'application/json'
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$ContentType = 'application/json',

        # Specifies the retry interval, in seconds, if a call to the MCAS web API is throttled. Default = 3 (seconds)
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [int]$RetryInterval = 3
    )
    
    Write-Verbose ('$Path={0}' -f $Path)
    $pathElements = $Path.Split('/')
    $baseUri = '/{0}/{1}/{2}/' -f $pathElements[1],$pathElements[2],$pathElements[3]  
    Write-Verbose ('$baseUri={0}' -f $baseUri)

    if ($MCAS_ALLOWED_VERBS.$baseUri -notcontains $Method) {
        throw "That URI or URI/method combination is not supported. The supported URIs with supported methods for each are:`n{0}" -f ($MCAS_ALLOWED_VERBS | ConvertTo-Json)
    }

    $tenant = ($Credential.GetNetworkCredential().username)
    Write-Verbose ('$tenant={0}' -f $tenant)
    
    $token = $Credential.GetNetworkCredential().Password
    Write-Verbose "Authorization token length is {0} chars" -f $token.Length

    #$headers = 'Authorization = "Token {0}"' -f $token | ForEach-Object {"@{$_}"}    
    $headers = @{Authorization="Token $token"} # need to test if this will work instead of above
    
    # Params for Invoke-WebRequest
    $requestParams = @{
        Uri = 'https://{0}{1}' -f $tenant,$Path
        Method = $Method
        Headers = $headers
        ContentType = $ContentType
        UseBasicParsing = $true
    }

    if ($Method -eq 'Get') {
        Write-Verbose "A request using the Get HTTP method cannot have a message body."
    }
    else {
        $jsonBody = $Body | ConvertTo-Json -Compress -Depth 2
        Write-Verbose ('$jsonBody={0}' -f $jsonBody)
    }

    Write-Verbose ('$RetryInterval={0}' -f $RetryInterval)

    # This loop is the actual call to MCAS. It includes automatic retry if the API call is throttled
    do {
        $retryCall = $false

        try {
            Write-Verbose "Attempting call to MCAS..."
            $response = Invoke-WebRequest @requestParams
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

        # Uncomment following two lines if you want to see raw responses in -Verbose output
        #Write-Verbose 'Raw MCAS response to follow:'
        #Write-Verbose $response
    }
    while ($retryCall)

    $response
}