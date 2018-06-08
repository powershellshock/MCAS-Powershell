function Get-JavaInstallationPackage {
    [CmdletBinding()]
    
    Write-Verbose 'Attempting to download the Java installation package.'
    try {
        $javaDownloadUrl = ((Invoke-WebRequest -Uri 'https://www.java.com/en/download/manual.jsp' -UseBasicParsing).links | Where-Object {$_.title -eq 'Download Java software for Windows (64-bit)'} | Select-Object -Last 1).href
        
        if (Test-Path "$pwd\JavaSetup.tmp") {
            Remove-Item "$pwd\JavaSetup.tmp" -Force
        }
        
        $javaDownloadResult = Invoke-WebRequest -Uri $javaDownloadUrl -UseBasicParsing -OutFile "$pwd\JavaSetup.tmp"
        
        $javaSetupFileName = (Get-Item "$pwd\JavaSetup.tmp").VersionInfo.OriginalFilename
        
        if (Test-Path "$pwd\$javaSetupFileName") {
            Remove-Item "$pwd\$javaSetupFileName" -Force
        }
        
        Rename-Item "$pwd\$javaSetupFileName" -Force
    }
    catch {
        throw "Something went wrong getting the Java installation package. The error was $_"
    }

    "$pwd\$javaSetupFileName"
}