#
# Module manifest for module 'MCAS'
#
# Generated by: Microsoft (Jared Poeppelman, Mike Kassis)
#
# Generated on: 11/30/2017
#

@{

# Script module or binary module file associated with this manifest.
# RootModule = ''

# Version number of this module.
ModuleVersion = '3.0.0'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = '12f3a402-48e8-4a58-926f-061ca000d627'

# Author of this module
Author = 'Microsoft Corporation'

# Company or vendor of this module
CompanyName = 'Microsoft'

# Copyright statement for this module
Copyright = '(c) 2017 jpoeppel. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Powershell module for Microsoft Cloud App Security (MCAS)'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '3.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @(
    'Add-MCASAdminAccess',
    'ConvertFrom-MCASTimestamp',
    'Get-MCASActivity',
    'Get-MCASActivityType',
    'Get-MCASAdminAccess',
    'Get-MCASAlert',
    'Get-MCASAppId',
    'Get-MCASAppPermission',
    'Get-MCASBlockScriptContent',
    'Get-MCASConfiguration',
    'Get-MCASCredential',
    'Get-MCASDiscoverySampleLog',
    'Get-MCASPolicy',
    'Get-MCASPortalSettings',
    'Get-MCASTag',
    'Get-MCASUserGroup',
    'Remove-MCASAdminAccess'
    )

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = '*'

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
<#
FileList = @(
    'MCAS.psd1'
    'MCAS.psm1'
    'LICENSE.txt'
    'README.md'
    'functions\Add-MCASAdminAccess.ps1'
    'functions\ConvertTo-MCASJsonFilterString.ps1'
    'functions\Edit-MCASPropertyName.ps1'
    'functions\Export-MCASBlockScript.ps1'
    'functions\Get-MCASAccount.ps1'
    'functions\Get-MCASActivity.ps1'
    'functions\Get-MCASActivityType.ps1'
    'functions\Get-MCASAdminAccess.ps1'
    'functions\Get-MCASAlert.ps1'
    'functions\Get-MCASAppInfo.ps1'
    'functions\Get-MCASCredential.ps1'
    'functions\Get-MCASDiscoveredApp.ps1'
    'functions\Get-MCASFile.ps1'
    'functions\Get-MCASGovernanceAction.ps1'
    'functions\Get-MCASPolicy.ps1'
    'functions\Get-MCASReport.ps1'
    'functions\Get-MCASReportData.ps1'
    'functions\Get-MCASStream.ps1'
    'functions\Get-MCASSubnet.ps1'
    'functions\Invoke-MCASResponseHandling.ps1'  #### ???? ####
    'functions\Invoke-MCASRestMethod.ps1'
    'functions\New-MCASSubnet.ps1'
    'functions\Remove-MCASAdminAccess.ps1'
    'functions\Remove-MCASSubnet.ps1'
    'functions\Send-MCASDiscoveryLog.ps1'
    'functions\Set-MCASAlert.ps1'
    'test\Cloud-App-Security.Tests.ps1'
    'test\Test-Add-MCASAdminAccess.ps1'
    'test\Test-Get-MCASCredential.ps1'
    'test\Test-Remove-MCASAdminAccess.ps1'
    'diagrams\Dependencies.vsdx'
)
#>

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        # Tags = @()

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/powershellshock/MCAS-Powershell/blob/master/LICENSE.txt'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/powershellshock/MCAS-Powershell'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

