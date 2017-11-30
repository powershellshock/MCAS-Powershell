$ModuleManifestName = 'MCAS.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\$ModuleManifestName"

Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $ModuleManifestPath | Should Not BeNullOrEmpty
        $? | Should Be $true
    }
}

$cmdsUsingCredParam = Get-Command -Module MCAS | ForEach-Object { if (($_.parameters.GetEnumerator() | Where-Object {$_.Key -eq 'Credential'}).Count -eq 1) {$_.Name}}


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
