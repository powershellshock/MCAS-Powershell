<#
.Synopsis
   Uploads a proxy/firewall log file to a Cloud App Security tenant for discovery.
.DESCRIPTION
   Send-MCASDiscoveryLog uploads an edge device log file to be analyzed for SaaS discovery by Cloud App Security.

   When using Send-MCASDiscoveryLog, you must provide a log file by name/path and a log file type, which represents the source firewall or proxy device type. Also required is the name of the discovery data source with which the uploaded log should be associated; this can be created in the console.

   Send-MCASDiscoveryLog does not return any value

.EXAMPLE
   Send-MCASDiscoveryLog -LogFile C:\Users\Alice\MyFirewallLog.log -LogType CISCO_IRONPORT_PROXY -DiscoveryDataSource 'My CAS Discovery Data Source'

   This uploads the MyFirewallLog.log file to CAS for discovery, indicating that it is of the CISCO_IRONPORT_PROXY log format, and associates it with the data source name called 'My CAS Discovery Data Source'

.FUNCTIONALITY
   Uploads a proxy/firewall log file to a Cloud App Security tenant for discovery.
#>
function Send-MCASDiscoveryLog
{
    [CmdletBinding()]
    param
    (
        # Specifies the credential object containing tenant as username (e.g. 'contoso.us.portal.cloudappsecurity.com') and the 64-character hexadecimal Oauth token as the password.
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]$Credential = $CASCredential,
                
        # The full path of the Log File to be uploaded, such as 'C:\mylogfile.log'.
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        [Validatescript({Test-Path $_})]
        [Validatescript({(Get-Item $_).Length -le 5GB})]
        [alias("FullName")]
        [string]$LogFile,

        # Specifies the source device type of the log file.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [device_type]$LogType,

        # Specifies the discovery data source name as reflected in your CAS console, such as 'US West Microsoft ASA'.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]$DiscoveryDataSource,

        # Specifies that the uploaded log file should be deleted after the upload operation completes.
        [alias("dts")]
        [switch]$Delete
    )
    begin {}
    process
    {
        # Get just the file name, for when full path is specified
        try {
            $fileName = (Get-Item $LogFile).Name
        }
        catch {
            throw "Could not get $LogFile : $_"
        }

        #region GET UPLOAD URL
        try {
            # Get an upload URL for the file
            #$getUploadUrlResponse = Invoke-RestMethod -Uri "https://$TenantUri/api/v1/discovery/upload_url/?filename=$fileName&source=$LogType" -Headers @{Authorization = "Token $Token"} -Method Get -UseBasicParsing
            $getUploadUrlResponse = Invoke-MCASRestMethod -Credential $Credential -Path "/api/v1/discovery/upload_url/?filename=$fileName&source=$LogType" -Method Get

            $uploadUrl = $getUploadUrlResponse.url
        }
        catch {
            throw "Error calling MCAS API. The exception was: $_"
        }
        
        #endregion GET UPLOAD URL

        #region UPLOAD LOG FILE

        # Set appropriate transfer encoding header info based on log file size
        if (($getUploadUrlResponse.provider -eq 'azure') -and ($LogFileBlob.Length -le 64mb)) {
            $fileUploadHeader = @{'x-ms-blob-type'='BlockBlob'}
        }
        elseif (($getUploadUrlResponse.provider -eq 'azure') -and ($LogFileBlob.Length -gt 64mb)) {
            $fileUploadHeader = @{'Transfer-Encoding'='chunked'}
        }

        try
        {
            # Upload the log file to the target URL obtained earlier, using appropriate headers
            if ($fileUploadHeader) {
                if (Test-Path $LogFile) {
                    Invoke-RestMethod -Uri $uploadUrl -InFile $LogFile -Headers $fileUploadHeader -Method Put -UseBasicParsing -ErrorAction Stop
                }
            }
            else {
                if (Test-Path $LogFile) {
                    Invoke-RestMethod -Uri $uploadUrl -InFile $LogFile -Method Put -UseBasicParsing -ErrorAction Stop
                }
            }
        }
        catch {
            throw "File upload failed. The exception was: $_"
        }
        #endregion UPLOAD LOG FILE

        #region FINALIZE UPLOAD
        try {
            # Finalize the upload
            #$finalizeUploadResponse = Invoke-RestMethod -Uri "https://$TenantUri/api/v1/discovery/done_upload/" -Headers @{Authorization = "Token $Token"} -Body @{'uploadUrl'=$UploadUrl;'inputStreamName'=$DiscoveryDataSource} -Method Post -UseBasicParsing -ErrorAction Stop
            $finalizeUploadResponse = Invoke-MCASRestMethod -Credential $Credential -Path "/api/v1/discovery/done_upload/" -Body @{'uploadUrl'=$uploadUrl;'inputStreamName'=$DiscoveryDataSource} -Method Post
        }
        catch {
            throw "Error calling MCAS API. The exception was: $_"
        }
        #endregion FINALIZE UPLOAD

        try {
            # Delete the file
            if ($Delete) {
                Remove-Item $LogFile -Force
            }
        }
        catch {
            throw "Could not delete $LogFile : $_"
        }
    }
    end {}
}