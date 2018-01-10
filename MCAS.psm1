<#

GENERAL CODING STANDARDS TO BE FOLLOWED IN THIS MODULE:

    https://github.com/PoshCode/PowerShellPracticeAndStyle

    and

    https://msdn.microsoft.com/en-us/library/dd878270%28v=vs.85%29.aspx?f=255&MSPPError=-2147217396 

#>

#----------------------------Enum Types----------------------------
enum mcas_app {
    Amazon_Web_Services = 11599
    Box = 10489
    Dropbox = 11627
    Google_Apps = 11770
    Microsoft_OneDrive_for_Business = 15600
    Microsoft_Cloud_App_Security = 20595
    Microsoft_Sharepoint_Online = 20892
    Microsoft_Skype_for_Business = 25275
    Microsoft_Exchange_Online = 20893
    Microsoft_Teams = 28375
    Microsoft_Yammer = 11522
    Microsoft_Power_BI = 26324
    Office_365 = 11161
    Okta = 10980
    Salesforce = 11114
    ServiceNow = 14509
}

enum device_type {
    BARRACUDA = 101
    BLUECOAT = 102
    CHECKPOINT = 103
    CISCO_ASA = 104
    CISCO_ASA_FIREPOWER = 177
    CISCO_IRONPORT_PROXY = 106
    CISCO_FWSM = 157
    CISCO_SCAN_SAFE = 124
    CLAVISTER = 164
    FORTIGATE = 108
    JUNIPER_SRX = 129
    JUNIPER_SRX_SD = 172
    JUNIPER_SRX_WELF = 174
    JUNIPER_SSG = 168
    MACHINE_ZONE_MERAKI = 153
    MCAFEE_SWG = 121
    MICROSOFT_ISA_W3C = 159
    PALO_ALTO = 112  #PALO_ALTO_SYSLOG not available here
    SONICWALL_SYSLOG = 160
    SOPHOS_CYBEROAM = 162
    SOPHOS_SG = 130
    SQUID = 114
    SQUID_NATIVE = 155
    WEBSENSE_SIEM_CEF = 138
    WEBSENSE_V7_5 = 135
    ZSCALER = 120
    ZSCALER_QRADAR = 170
}

enum ip_category {
    None = 0
    Internal = 1
    Administrative = 2
    Risky = 3
    VPN = 4
    Cloud_Provider = 5
}

enum severity_level {
    High = 2
    Medium = 1
    Low = 0
}

enum resolution_status {
    Resolved = 2
    Dismissed = 1
    Open = 0
}

enum file_type {
    Other = 0
    Document = 1
    Spreadsheet = 2
    Presentation = 3
    Text = 4
    Image = 5
    Folder = 6
}

enum file_access_level {
    Private = 0
    Internal = 1
    External = 2
    Public = 3
    PublicInternet = 4
}

enum subnet_category {
    Corporate = 1
    Administrative = 2
    Risky = 3
    VPN = 4
    CloudProvider = 5
    Other = 6
}

enum app_category {
    ACCOUNTING_AND_FINANCE
    ADVERTISING
    BUSINESS_MANAGEMENT
    CLOUD_STORAGE
    CODE_HOSTING
    COLLABORATION
    COMMUNICATIONS
    CONTENT_MANAGEMENT
    CONTENT_SHARING
    CRM
    CUSTOMER_SUPPORT
    DATA_ANALYTICS
    DEVELOPMENT_TOOLS
    ECOMMERCE
    EDUCATION
    FORUMS
    HEALTH
    HOSTING_SERVICES
    HUMAN_RESOURCE_MANAGEMENT
    IT_SERVICES
    MARKETING
    MEDIA
    NEWS_AND_ENTERTAINMENT
    ONLINE_MEETINGS
    OPERATIONS_MANAGEMENT
    PRODUCT_DESIGN
    PRODUCTIVITY
    PROJECT_MANAGEMENT
    PROPERTY_MANAGEMENT
    SALES
    SECURITY
    SOCIAL_NETWORK
    SUPLLY_CHAIN_AND_LOGISTICS
    TRANSPORTATION_AND_TRAVEL
    VENDOR_MANAGEMENT_SYSTEM
    WEB_ANALYTICS
    WEBMAIL
    WEBSITE_MONITORING
}

enum permission_type {
    READ_ONLY
    FULL_ACCESS
}


#----------------------------Hash Tables---------------------------
$IPTagsList = @{
    Anonymous_Proxy = '000000030000000000000000'
    Botnet = '0000000c0000000000000000'
    Darknet_Scanning_IP = '0000001f0000000000000000'
    Exchange_Online = '0000000e0000000000000000'
    Exchange_Online_Protection = '000000150000000000000000'
    Malware_CnC_Server = '0000000d0000000000000000'
    Microsoft_Cloud = '0000001e0000000000000000'
    Microsoft_Authentication_and_Identity = '000000100000000000000000'
    Office_365 = '000000170000000000000000'
    Office_365_Planner = '000000190000000000000000'
    Office_365_ProPlus = '000000120000000000000000'
    Office_Online = '000000140000000000000000'
    Office_Sway = '0000001d0000000000000000'
    Office_Web_Access_Companion = '0000001a0000000000000000'
    OneNote = '000000130000000000000000'
    Remote_Connectivity_Analyzer = '0000001c0000000000000000'
    Satellite_Provider = '000000040000000000000000'
    SharePoint_Online = '0000000f0000000000000000'
    Skype_for_Business_Online = '000000180000000000000000'
    Smart_Proxy_and_Access_Proxy_Network = '000000050000000000000000'
    Tor = '2dfa95cd7922d979d66fcff5'
    Yammer = '0000001b0000000000000000'
    Zscaler = '000000160000000000000000'
}

$ReportsList = @{
	'Activity by Location' = 'geolocation_summary'
	'Browser Use' = 'browser_usage'
	'IP Addresses' = 'ip_usage'
	'IP Addresses for Admins' = 'ip_admin_usage'
	'OS Use' = 'os_usage'
	'Strictly Remote Users' = 'standalone_users'
	'Cloud App Overview' = 'app_summary'
	'Inactive Accounts' = 'zombie_users'
	'Privileged Users' = 'admins'
	'Salesforce Special Privileged Accounts' = 'sf_permissions'
	'User Logon' = 'logins_rate'
	'Data Sharing Overview' = 'files_summary'
	'File Extensions' = 'file_extensions'
	'Orphan Files' = 'orphan_files'
	'Outbound Sharing by Domain' = 'external_domains'
	'Owners of Shared Files' = 'shared_files_owners'
	'Personal User Accounts' = 'personal_users'
	'Sensitive File Names' = 'file_name_dlp'
}

# Create reversed copy of the reports list hash table (keys become values and values become keys)
$ReportsListReverse = @{}
$ReportsList.GetEnumerator() | ForEach-Object {
    $ReportsListReverse.Add($_.Value,$_.Key)
}

$GovernanceStatus = @{
    'Failed' = $false
    'Pending' = $null
    'Successful' = $true
}


#----------------------------Include functions---------------------------
# KUDOS to the chocolatey project for the basis of this code

# get the path of where the module is saved (if module is at c:\myscripts\module.psm1, then c:\myscripts\)
$mypath = (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)

# find and load all the ps1 files in the Functions subfolder
Resolve-Path -Path $mypath\Functions\*.ps1 | ForEach-Object -Process {
    . $_.ProviderPath
}


#----------------------------Exports---------------------------
# Cmdlets to export (must be exported as functions, not cmdlets) - This array format can be copied directly to the manifest as the 'FunctionsToExport' value
$ExportedCommands = @('Export-MCASPortalSettings','Get-MCASConfiguration','Get-MCASCredential','Get-MCASActivityType','Get-MCASAppId','Get-MCASDiscoverySampleLog','Get-MCASUserGroup')
$ExportedCommands | ForEach-Object {
    Export-ModuleMember -Function $_
}

#Export-ModuleMember -Function Invoke-MCASRestMethod2

# Vars to export (must be exported here, even if also included in the module manifest in 'VariablesToExport'
Export-ModuleMember -Variable CASCredential

# Aliases to export
Export-ModuleMember -Alias *



<#
# Implement your module commands in this script.


# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function Get-MCASUserGroup


#>