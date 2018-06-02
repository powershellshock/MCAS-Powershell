<#
.Synopsis
    Install-MCASSiemAgent downloads and installs Java, downloads and unzips the MCAS SIEM Agent JAR file, and creates a scheduled task to auto-start the agent on startup. (This works on 64-bit Windows hosts only.)
.DESCRIPTION
    Auto-deploy the MCAS SIEM Agent.
.EXAMPLE

#>
function Install-MCASSiemAgent {
    [CmdletBinding()]
    param
    (
        # Specifies whether to auto-download and install Java, if Java is not found on the machine
        [Parameter(Mandatory=$false)]
        [ValidateSet('On','Off')]
        [string]$JavaAutoInstall = 'Off',

        # Specifies whether to install Java silently, when it is automatically installed. If set to 'Off' the user will get an interactive Java setup. Does not applie if -JavaAutoInstall 'Off' is used or if a Java installation is detected.
        [Parameter(Mandatory=$false)]
        [ValidateSet('On','Off')]
        [string]$InstallJavaSilent = 'Off'

    )
    
    Write-Verbose 'Checking for 64-bit Windows host'
    try {
        $sysInfo = Get-CimInstance Win32_OperatingSystem | Select-Object  Caption,OSArchitecture
        $isWindows = $sysInfo.Caption -cmatch 'Windows'
        $is64Bit = $sysInfo.OSArchitecture -cmatch '64-bit'
        }
    catch {
        throw 'Error detecting host information. This command only works on 64-bit Windows hosts.'
    }
    if (-not ($isWindows -and $is64Bit)) {
        throw 'This does not appear to be a 64-bit Windows host. This command only works on 64-bit Windows hosts.'
    }
    Write-Verbose 'This host does appear to be running 64-bit Windows. Proceeding...'


    Write-Verbose 'Attempting to download the MCAS SIEM Agent zip file from Microsoft Download Center...'
    try {
        $siemAgentDownloadUrl = ((Invoke-WebRequest -Uri 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=54537' -UseBasicParsing).Links | Where-Object {$_.'data-bi-cN' -eq 'click here to download manually'} | select -First 1).href
        $siemAgentZipFileName = $siemAgentDownloadUrl.Split('/') | select -Last 1
        $siemAgentDownloadResult = Invoke-WebRequest -Uri $siemAgentDownloadUrl -UseBasicParsing -OutFile "$pwd\$siemAgentZipFileName"
    }
    catch {
        throw "Something went wrong when attempting to download the MCAS SIEM Agent zip file. The error was: $_"
    }


    Write-Verbose 'Attempting to extract the MCAS SIEM Agent jar file from the downloaded zip file.'
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory("$pwd\$siemAgentZipFileName", $pwd)
        $jarFile = $siemAgentZipFileName.TrimEnd('.zip')
    }
    catch {
        throw "Something went wrong when attempting to extract the MCAS SIEM Agent jar file from the downloaded zip file. The error was: $_"
    }


    Write-Verbose 'Attempting to cleanup the MCAS SIEM Agent zip file.'
    try {
        Remove-Item "$pwd\$siemAgentZipFileName" -Force
    }
    catch {
        Write-Warning "Something went wrong when attempting to cleanup the MCAS SIEM Agent zip file. The error was: $_"
    } 

    Write-Verbose 'Attempting to detect an existing Java installation on this host.'
    # Check for java.exe in the path

    $javaPath = 'C:\Program Files\Java\jre1.8.0_171\bin\java.exe'
    
    try {

    }
    catch {

    }





    Write-Verbose 'Attempting to download the Java installation package.'
    try {
        $javaDownloadUrl = ((Invoke-WebRequest -Uri 'https://www.java.com/en/download/manual.jsp' -UseBasicParsing).links | Where-Object {$_.title -eq 'Download Java software for Windows (64-bit)'} | select -Last 1).href
        $javaDownloadResult = Invoke-WebRequest -Uri $javaDownloadUrl -UseBasicParsing -OutFile "$pwd\JavaSetup.tmp"
        $javaSetupFileName = (Get-Item "$pwd\JavaSetup.tmp").VersionInfo.OriginalFilename
        Rename-Item "$pwd\JavaSetup.tmp" $javaSetupFileName -Force
    }
    catch {
        
    }


    Write-Verbose 'Attempting to install Java on this host.'
    if ($InstallJavaSilent -eq 'On') {
        Start-Process "$pwd\$javaSetupFileName" -ArgumentList '/s' -Wait
    }
    else {
        Start-Process "$pwd\$javaSetupFileName" -Wait
    }
    
    try {
        #Start-Process "$pwd\$javaSetupFileName" -ArgumentList '/s' -Wait
        Remove-Item "$pwd\$javaSetupFileName" -Force
    }
    catch {
        
    }
    


    Write-Verbose 'Attempting to create an auto-starting scheduled task for the MCAS SIEM Agent on this host.'
    try {

    }
    catch {
        
    }


}