﻿<#
.Synopsis
   Gets user activity information from your Cloud App Security tenant.
.DESCRIPTION
   Gets user activity information from your Cloud App Security tenant and requires a credential be provided.

   Without parameters, Get-MCASActivity gets 100 activity records and associated properties. You can specify a particular activity GUID to fetch a single activity's information or you can pull a list of activities based on the provided filters.

   Get-MCASActivity returns a single custom PS Object or multiple PS Objects with all of the activity properties. Methods available are only those available to custom objects by default.
.EXAMPLE
   Get-MCASActivity -ResultSetSize 1

    This pulls back a single activity record and is part of the 'List' parameter set.

.EXAMPLE
   Get-MCASActivity -Identity 572caf4588011e452ec18ef0

    This pulls back a single activity record using the GUID and is part of the 'Fetch' parameter set.

.EXAMPLE
   (Get-MCASActivity -AppName Box).rawJson | ?{$_.event_type -match "upload"} | select ip_address -Unique

    ip_address
    ----------
    69.4.151.176
    98.29.2.44

    This grabs the last 100 Box activities, searches for an event type called "upload" in the rawJson table, and returns a list of unique IP addresses.

.FUNCTIONALITY
   Get-MCASActivity is intended to function as a query mechanism for obtaining activity information from Cloud App Security.
#>
function Get-MCASActivity
{
    [CmdletBinding()]
    Param
    (
        # Fetches an activity object by its unique identifier.
        [Parameter(ParameterSetName='Fetch', Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        #[ValidatePattern("[A-Fa-f0-9_\-]{51}|[A-Za-z0-9_\-]{20}")]
        [alias("_id")]
        [string]$Identity,

        # Specifies the credential object containing tenant as username (e.g. 'contoso.us.portal.cloudappsecurity.com') and the 64-character hexadecimal Oauth token as the password.
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]$Credential = $CASCredential,

        # Specifies the property by which to sort the results. Possible Values: 'Date','Created'.
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [ValidateSet('Date','Created')]
        [string]$SortBy,

        # Specifies the direction in which to sort the results. Possible Values: 'Ascending','Descending'.
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [ValidateSet('Ascending','Descending')]
        [string]$SortDirection,

        # Specifies the maximum number of results to retrieve when listing items matching the specified filter criteria.
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [ValidateRange(1,100)]
        [int]$ResultSetSize = 100,

        # Specifies the number of records, from the beginning of the result set, to skip.
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [ValidateScript({$_ -gt -1})]
        [int]$Skip = 0,



        ##### FILTER PARAMS #####

        # -User limits the results to items related to the specified user/users, for example 'alice@contoso.com','bob@contoso.com'.
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [Alias("User")]
        [string[]]$UserName,

        # Limits the results to items related to the specified service IDs, such as 11161,11770 (for Office 365 and Google Apps, respectively).
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [Alias("Service","Services")]
        [int[]]$AppId,

        # Limits the results to items related to the specified service names, such as 'Office_365' and 'Google_Apps'.
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [Alias("ServiceName","ServiceNames")]
        [mcas_app[]]$AppName,

        # Limits the results to items not related to the specified service ids, such as 11161,11770 (for Office 365 and Google Apps, respectively).
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [Alias("ServiceNot","ServicesNot")]
        [int[]]$AppIdNot,

        # Limits the results to items not related to the specified service names, such as 'Office_365' and 'Google_Apps'.
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [Alias("ServiceNameNot","ServiceNamesNot")]
        [mcas_app[]]$AppNameNot,

        # Limits the results to items of specified event type name, such as EVENT_CATEGORY_LOGIN,EVENT_CATEGORY_DOWNLOAD_FILE.
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$EventTypeName,

        # Limits the results to items not of specified event type name, such as EVENT_CATEGORY_LOGIN,EVENT_CATEGORY_DOWNLOAD_FILE.
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$EventTypeNameNot,

        # Limits the results by ip category. Possible Values: 'None','Internal','Administrative','Risky','VPN','Cloud_Provider'.
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [ip_category[]]$IpCategory,

        # Limits the results to items with the specified IP leading digits, such as 10.0.
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [ValidateLength(1,45)]
        [string[]]$IpStartsWith,

        # Limits the results to items without the specified IP leading digits, such as 10.0.
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [ValidateLength(1,45)]
        [string]$IpDoesNotStartWith,

        # Limits the results to items found before specified date. Use Get-Date.
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [datetime]$DateBefore,

        # Limits the results to items found after specified date. Use Get-Date.
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [datetime]$DateAfter,

        # Limits the results by device type. Possible Values: 'Desktop','Mobile','Tablet','Other'.
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [ValidateSet('Desktop','Mobile','Tablet','Other')]
        [string[]]$DeviceType,

        # Limits the results by performing a free text search
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({$_.Length -ge 5})]
        [string]$Text,

        # Limits the results to events listed for the specified File ID.
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        #[ValidatePattern("\b[A-Za-z0-9]{24}\b")]
        [string]$FileID,

        # Limits the results to events listed for the specified AIP classification labels. Use ^ when denoting (external) labels. Example: @("^Private")
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [array]$FileLabel,

        # Limits the results to events excluded by the specified AIP classification labels. Use ^ when denoting (external) labels. Example: @("^Private")
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [array]$FileLabelNot,

        # Limits the results to events listed for the specified IP Tags.
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [validateset("Anonymous_Proxy","Botnet","Darknet_Scanning_IP","Exchange_Online","Exchang_Online_Protection","Malware_CnC_Server","Microsoft_Cloud","Microsoft_Authentication_and_Identity","Office_365","Office_365_Planner","Office_365_ProPlus","Office_Online","Office_Sway","Office_Web_Access_Companion","OneNote","Remote_Connectivity_Analyzer","Satellite_Provider","SharePoint_Online","Skype_for_Business_Online","Smart_Proxy_and_Access_Proxy_Network","Tor","Yammer","Zscaler")]
        [string[]]$IPTag,

        # Limits the results to events that include a country code value.
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [switch]$CountryCodePresent,
        
        # Limits the results to events listed for the specified IP Tags.
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        #[ValidatePattern("[A-Fa-f0-9]{24}")]
        [string]$PolicyId,

        # Limits the results to items occuring in the last x number of days.
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [ValidateRange(1,180)]
        [int]$DaysAgo,

        # Limits the results to admin events if specified.
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [switch]$AdminEvents,

        # Limits the results to non-admin events if specified.
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [switch]$NonAdminEvents,

        # Limits the results to impersonated events if specified.
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [switch]$Impersonated,

        # Limits the results to non-impersonated events if specified.
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [switch]$ImpersonatedNot,

        # Limits the results to those with user agent strings containing the specified substring.
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$UserAgentContains,

        # Limits the results to those with user agent strings not containing the specified substring..
        [Parameter(ParameterSetName='List', Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$UserAgentNotContains
    )
    begin {
    }
    process
    {
        # Fetch mode should happen once for each item from the pipeline, so it goes in the 'Process' block
        If ($PSCmdlet.ParameterSetName -eq 'Fetch')
        {
            try {
                # Fetch the item by its id
                $response = Invoke-MCASRestMethod -Credential $Credential -Path "/api/v1/activities/$Identity/" -Method Get
            }
            catch {
                throw $_  #Exception handling is in Invoke-MCASRestMethod, so here we just want to throw it back up the call stack, with no additional logic
            }

            try {
                Write-Verbose "Adding alias property to results, if appropriate"
                $Response = $Response | Add-Member -MemberType AliasProperty -Name Identity -Value '_id' -PassThru
            }
            catch {}
            
            $response
        }
    }
    end
    {
        If ($PSCmdlet.ParameterSetName -eq  'List') # Only run remainder of this end block if not in fetch mode
        {
            # List mode logic only needs to happen once, so it goes in the 'End' block for efficiency

            $body = @{'skip'=$Skip;'limit'=$ResultSetSize} # Base request body

            #region ----------------------------SORTING----------------------------

            If ($SortBy -xor $SortDirection) {Throw 'Error: When specifying either the -SortBy or the -SortDirection parameters, you must specify both parameters.'}

            # Add sort direction to request body, if specified
            If ($SortDirection) {$Body.Add('sortDirection',$SortDirection.TrimEnd('ending').ToLower())}

            # Add sort field to request body, if specified
            If ($SortBy)
            {
                $body.Add('sortField',$SortBy.ToLower())
            }
            #endregion ----------------------------SORTING----------------------------

            #region ----------------------------FILTERING----------------------------
            $filterSet = @() # Filter set array

            # Additional function for date conversion to unix format.
            If ($DateBefore) {$DateBefore2 = ([int](Get-Date -Date $DateBefore -UFormat %s)*1000)}
            If ($DateAfter) {$DateAfter2 = ([int](Get-Date -Date $DateAfter -UFormat %s)*1000)}

            # Additional parameter validations and mutual exclusions
            If ($AppName    -and ($AppId   -or $AppNameNot -or $AppIdNot)) {Throw 'Cannot reconcile app parameters. Only use one of them at a time.'}
            If ($AppId      -and ($AppName -or $AppNameNot -or $AppIdNot)) {Throw 'Cannot reconcile app parameters. Only use one of them at a time.'}
            If ($AppNameNot -and ($AppId   -or $AppName    -or $AppIdNot)) {Throw 'Cannot reconcile app parameters. Only use one of them at a time.'}
            If ($AppIdNot   -and ($AppId   -or $AppNameNot -or $AppName))  {Throw 'Cannot reconcile app parameters. Only use one of them at a time.'}
            If (($DateBefore -and $DateAfter) -or ($DateBefore -and $DaysAgo) -or ($DateAfter -and $DaysAgo)){Throw 'Cannot reconcile app parameters. Only use one date parameter.'}
            If ($Impersonated -and $ImpersonatedNot){Throw 'Cannot reconcile app parameters. Do not combine Impersonated and ImpersonatedNot parameters.'}

            # Value-mapped filters
            If ($IpCategory) {$filterSet += @{'ip.category'=@{'eq'=([int[]]($IpCategory | ForEach-Object {$_ -as [int]}))}}}
            If ($AppName)    {$filterSet += @{'service'=@{'eq'=([int[]]($AppName | ForEach-Object {$_ -as [int]}))}}}
            If ($AppNameNot) {$filterSet += @{'service'=@{'neq'=([int[]]($AppNameNot | ForEach-Object {$_ -as [int]}))}}}
            If ($IPTag)      {$filterSet += @{'ip.tags'=    @{'eq'=($IPTag.GetEnumerator() | ForEach-Object {$IPTagsList.$_ -join ','})}}}

            # Simple filters
            If ($UserName)             {$filterSet += @{'user.username'=          @{'eq'=$UserName}}}
            If ($AppId)                {$filterSet += @{'service'=                @{'eq'=$AppId}}}
            If ($AppIdNot)             {$filterSet += @{'service'=                @{'neq'=$AppIdNot}}}
            If ($EventTypeName)        {$filterSet += @{'activity.actionType'=    @{'eq'=$EventTypeName}}}
            If ($EventTypeNameNot)     {$filterSet += @{'activity.actionType'=    @{'neq'=$EventTypeNameNot}}}
            If ($CountryCodePresent)   {$filterSet += @{'location.country'=       @{'isset'=$true}}}
            If ($DeviceType)           {$filterSet += @{'device.type'=            @{'eq'=$DeviceType.ToUpper()}}} # CAS API expects upper case here
            If ($UserAgentContains)    {$filterSet += @{'userAgent.userAgent'=    @{'contains'=$UserAgentContains}}}
            If ($UserAgentNotContains) {$filterSet += @{'userAgent.userAgent'=    @{'ncontains'=$UserAgentNotContains}}}
            If ($IpStartsWith)         {$filterSet += @{'ip.address'=             @{'startswith'=$IpStartsWith}}}
            If ($IpDoesNotStartWith)   {$filterSet += @{'ip.address'=             @{'doesnotstartwith'=$IpStartsWith}}}
            If ($Text)                 {$filterSet += @{'text'=                   @{'text'=$Text}}}
            If ($DaysAgo)              {$filterSet += @{'date'=                   @{'gte_ndays'=$DaysAgo}}}
            If ($Impersonated)         {$filterSet += @{'activity.impersonated' = @{'eq'=$true}}}
            If ($ImpersonatedNot)      {$filterSet += @{'activity.impersonated' = @{'eq'=$false}}}
            If ($FileID)               {$filterSet += @{'fileSelector'=           @{'eq'=$FileID}}}
            If ($FileLabel)            {$filterSet += @{'fileLabels'=             @{'eq'=$FileLabel}}}
            If ($PolicyId)             {$filterSet += @{'policy'=                 @{'eq'=$PolicyId}}}
            If ($DateBefore -and (-not $DateAfter)) {$filterSet += @{'date'= @{'lte'=$DateBefore2}}}
            If ($DateAfter -and (-not $DateBefore)) {$filterSet += @{'date'= @{'gte'=$DateAfter2}}}

            # boolean filters
            If ($AdminEvents)    {$filterSet += @{'activity.type'= @{'eq'=$true}}}
            If ($NonAdminEvents) {$filterSet += @{'activity.type'= @{'eq'=$false}}}

            #endregion ----------------------------FILTERING----------------------------

            # Get the matching items and handle errors
            try {
                #$Response = Invoke-MCASRestMethod2 -Uri "https://$TenantUri/api/v1/activities/" -Body $body -Method Post -Token $Token -FilterSet $FilterSet
                $response = Invoke-MCASRestMethod -Credential $Credential -Path "/api/v1/activities/" -Body $body -Method Post -FilterSet $filterSet
            }
            catch {
                throw $_  #Exception handling is in Invoke-MCASRestMethod, so here we just want to throw it back up the call stack, with no additional logic
            }

            $response = $response.data 
            
            try {
                Write-Verbose "Adding alias property to results, if appropriate"
                $response = $response | Add-Member -MemberType AliasProperty -Name Identity -Value '_id' -PassThru
            }
            catch {}
            
            $response
        }
    }
}