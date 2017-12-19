$ModuleManifestName = 'MCAS.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\$ModuleManifestName"

Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $ModuleManifestPath | Should Not BeNullOrEmpty
        $? | Should Be $true
    }
}


# Tenant specific tests and test values
$RunTenantSpecificTests = $true

$TenantSpecificTestParams = @{
    'ExampleKey' = 'ExampleValue'
}


# Host specific tests and test values
$RunHostSpecificTests = $true

$HostSpecificTestParams = @{
    'ExampleKey' = 'ExampleValue'
}




#$TenantSpecificTestParams.ExampleKey



# Get-Credential tests
<#
[void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
[Microsoft.VisualBasic.Interaction]::AppActivate("Test.ps1 - Notepad")

[void] [System.Reflection.Assembly]::LoadWithPartialName("'System.Windows.Forms")
[System.Windows.Forms.SendKeys]::SendWait("ABCDEFGHIJKLM")
#>


# Commands which support the -Credential parameter
Get-Command -Module MCAS | ForEach-Object { if (($_.parameters.GetEnumerator() | Where-Object {$_.Key -eq 'Credential'}).Count -eq 1) {$_.Name}} | ForEach-Object {

}


<#
Describe 'Validating -Credential parameter' {

        Mock -ModuleName MCAS Get-Date { return (New-Object datetime(2000,1,1)) }

        Context $cmd {
            It "Should not accept a credential with an invalid MCAS tenant as the user name" {
                {Get-MCASUserGroup -Credential (Import-Clixml "badtenanturi.credential")} | Should Throw 'Cannot validate argument on parameter'
            }     

            It "Should not accept a credential with a 63 char hex token as the password" {
                {&($cmdExpression) -Credential (Import-Clixml "63charhex.credential")} | Should Throw 'Cannot validate argument on parameter'
            }  

            It "Should not accept a credential with a 65 char hex token as the password" {
                {&($cmdExpression) -Credential (Import-Clixml "65charhex.credential")} | Should Throw 'Cannot validate argument on parameter'
            } 
            
            It "Should not accept a credential with an 64 char non-hex as the password" {
                {&($cmdExpression) -Credential (Import-Clixml "64charnonhex.credential")} | Should Throw 'Cannot validate argument on parameter'
            }
        }
    }
}
#>

<#
# get the path of this test script
$mypath = (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)

# find and load all the ps1 files in the Functions subfolder
Resolve-Path -Path $mypath\Functions\Test-*.ps1 | ForEach-Object -Process {
    . $_.ProviderPath
}
#>
