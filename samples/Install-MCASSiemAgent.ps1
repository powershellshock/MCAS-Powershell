[CmdletBinding()]
param
(
    # Token to be used by this SIEM agent to communicate with MCAS (provided during SIEM Agent creation in the MCAS console)
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({$_ -match '^[0-9a-zA-Z=]{64,192}$'})]
    [string]$Token,

    # Proxy address to be used for this SIEM agent for outbound communication to the MCAS service in the cloud
    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string]$ProxyHost,

    # Proxy port number to be used for this SIEM agent to egress to MCAS cloud service (only applies if -ProxyHost is also used, default = 8080)
    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [ValidateRange(1,65535)]
    [int]$ProxyPort = 8080,

    # Target folder for installation of the SIEM Agent (default = "C:\MCAS-SIEM-Agent")
    [ValidateNotNullOrEmpty()]
    [string]$TargetFolder = 'C:\MCAS-SIEM-Agent',

    # Specifies whether to install Java interactively, if/when it is automatically installed. If this is not used, Java setup will be run silently
    [switch]$UseInteractiveJavaSetup,

    # Specifies whether to auto-download and silently install Java, if Java is not found on the machine
    [switch]$Force,

    # Specifies whether to start the SIEM Agent after installation
    [switch]$StartNow
)



function Get-JavaExePath
{   
    [CmdletBinding()]
    param()

    try {
        Write-Verbose 'Checking installed programs list for an existing Java installation on this host.'    
        $javaProductGuid = (Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -match '^Java (?:8|9) Update \d{1,3}.*$'} | Sort-Object -Property Name -Descending | Select-Object -First 1).IdentifyingNumber
        
        if ($javaProductGuid) {
            Write-Verbose "Java is installed. Getting the installation location from HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$javaProductGuid"         
            $javaInstallationPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$javaProductGuid" -Name 'InstallLocation').InstallLocation.TrimEnd('\')
            Write-Verbose "Java installation path detected is $javaInstallationPath"

            Write-Verbose "Checking $javaInstallationPath for \bin\java.exe"
            if (Test-Path "$javaInstallationPath\bin\java.exe") {
                Write-Verbose "Found $javaInstallationPath\bin\java.exe"
                "$javaInstallationPath\bin\java.exe"
            }
            else {
                Write-Verbose "Could not find /bin/java.exe in $javaInstallationPath"
            }
        }
        else {
            Write-Verbose "Java was not found in the installed programs list"
        }
    }
    catch {
        Write-Warning 'Something went wrong attempting to detect the Java installation or its installation path. The error was $_'
    }
}

function Get-JavaInstallationPackage 
{
    [CmdletBinding()]
    param()
    
    try {
        Write-Verbose 'Getting download URL for the Java installation package.'
        $javaDownloadUrl = ((Invoke-WebRequest -Uri 'https://www.java.com/en/download/manual.jsp' -UseBasicParsing).links | Where-Object {$_.title -eq 'Download Java software for Windows (64-bit)'} | Select-Object -Last 1).href
        Write-Verbose "Download URL for the Java installation package is $javaDownloadUrl"

        if (Test-Path "$pwd\JavaSetup.tmp") {
            Write-Verbose "Cleaning up the existing download file at $pwd\JavaSetup.tmp before downloading"
            Remove-Item "$pwd\JavaSetup.tmp" -Force
        }
        
        Write-Verbose "Downloading the Java installation package to $pwd\JavaSetup.tmp"
        $javaDownloadResult = Invoke-WebRequest -Uri $javaDownloadUrl -UseBasicParsing -OutFile "$pwd\JavaSetup.tmp"
        
        Write-Verbose "Getting the Java installation package original filename"
        $javaSetupFileName = (Get-Item "$pwd\JavaSetup.tmp").VersionInfo.OriginalFilename
        Write-Verbose "The Java installation package original filename is $javaSetupFileName"

        if (Test-Path "$pwd\$javaSetupFileName") {
            Write-Verbose "Deleting the existing file $javaSetupFileName before renaming the downloaded package"
            Remove-Item "$pwd\$javaSetupFileName" -Force
        }
        
        Rename-Item -Path "$pwd\JavaSetup.tmp" -NewName "$pwd\$javaSetupFileName" -Force
    }
    catch {
        throw "Something went wrong getting the Java installation package. The error was $_"
    }

    "$pwd\$javaSetupFileName"
}

function Get-SiemAgentJarFile
{
    [CmdletBinding()]
    param()

    Write-Verbose 'Attempting to download the MCAS SIEM Agent zip file from Microsoft Download Center...'
    try {
        $siemAgentDownloadUrl = ((Invoke-WebRequest -Uri 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=54537' -UseBasicParsing).Links | Where-Object {$_.'data-bi-cN' -eq 'click here to download manually'} | Select-Object -First 1).href
        $siemAgentZipFileName = $siemAgentDownloadUrl.Split('/') | Select-Object -Last 1
        $siemAgentDownloadResult = Invoke-WebRequest -Uri $siemAgentDownloadUrl -UseBasicParsing -OutFile "$pwd\$siemAgentZipFileName"
        Write-Verbose "$siemAgentDownloadResult"

        Write-Verbose 'Attempting to extract the MCAS SIEM Agent jar file from the downloaded zip file.'
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory("$pwd\$siemAgentZipFileName", $pwd)
        $jarFile = $siemAgentZipFileName.TrimEnd('.zip') + '.jar'
        Write-Verbose "The extracted MCAS SIEM Agent JAR file is $pwd\$jarFile"
    }
    catch {
        throw "Something went wrong when attempting to download or extract the MCAS SIEM Agent zip file. The error was: $_"
    }
    
    Write-Verbose 'Attempting to cleanup the MCAS SIEM Agent zip file.'
    try {
        Remove-Item "$pwd\$siemAgentZipFileName" -Force
    }
    catch {
        Write-Warning "Something went wrong when attempting to cleanup the MCAS SIEM Agent zip file. The error was: $_"
    } 
    
    "$pwd\$jarFile"
}



# Check system requirements
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
Write-Verbose 'This host does appear to meet system requirements. Proceeding...'


# Check for the SIEM agent folder and .jar file
Write-Verbose "Checking for an existing SIEM Agent JAR file in $TargetFolder"
if (-not (Test-Path "$TargetFolder\mcas-siemagent-*-signed.jar")) {
    Write-Verbose "A JAR file for the MCAS SIEM Agent was not found in $TargetFolder"
        
    @($TargetFolder, "$TargetFolder\Logs") | ForEach-Object {
        Write-Verbose "Checking for $_"
        if (-not (Test-Path $_)) {
            Write-Verbose "$_ was not found, creating it"
            try {
                $dir = $_
                New-Item -ItemType Directory -Path $dir -Force | Out-Null
            }
            catch {
                throw "An error occurred creating $dir. The error was $_"
            }
        }
    }
        
    Write-Verbose "Downloading and extracting the latest MCAS SIEM Agent JAR file to $pwd"
    $jarFile = Get-SiemAgentJarFile

    Write-Verbose "Moving the MCAS SIEM Agent JAR file to $TargetFolder"
    $jarFinalPath = (Move-Item -Path "$jarFile" -Destination $TargetFolder -Force -PassThru).FullName
    Write-Verbose "Final jar file path is $jarFinalPath"
}


# Get the installation location of the latest Java engine that is installed, if there is one installed
$javaExePath = Get-JavaExePath


# If Java is not found, download and install it
if (-not $javaExePath) {
    if (-not $Force) {
        # Prompt user for confirmation before proceeding with automatic Java download and installation
        if ((Read-Host 'CONFIRM: No Java installation was detected. Java will now be automatically downloaded and installed Java. Do you wish to continue?`n[Y] Yes or [N] No (default is "No"').ToLower() -ne 'y') {
            Write-Verbose "User chose not to proceed with automatic Java download and installation. Exiting"
            return
        }
        Write-Verbose "User chose to proceed with automatic Java download and installation. Continuing"
    }
        
    # Download Java
    $javaSetupFileName = Get-JavaInstallationPackage

    # Install Java
    try {
        if ($UseInteractiveJavaSetup) {
            Write-Verbose "Starting interactive Java setup"
            Start-Process  "$javaSetupFileName" -Wait
        }
        else {
            Write-Verbose "Starting silent Java setup"
            Start-Process "$javaSetupFileName" -ArgumentList '/s' -Wait
        }
    }
    catch {
        throw "Something went wrong attempting to run the Java setup package. The error was $_"
    }
    Write-Verbose "Java setup seems to have finished"      
        
    Write-Verbose "Cleaning up the Java setup package"
    try {
        Remove-Item "$javaSetupFileName" -Force
    }
    catch {
        Write-Warning ('Failed to clean up the Java setup exe file ({0})' -f "$javaSetupFileName")
    }

    # Get the installation location of the newly installed Java engine
    $javaExePath = Get-JavaExePath
}


# Check again for Java, which should be there now
Write-Verbose "Checking again for Java, which should be there now"
if (-not $javaExePath) {
    throw "There seems to still be a problem with the Java installation, it could not be found"
}

# Assemble the Java arguments
if ($ProxyHost) {
    $javaArgs = '-jar {0} --logsDirectory {1} --token {2} --proxy {3}:{4} ' -f $jarFinalPath,"$TargetFolder\Logs",$Token,$ProxyHost,$ProxyPort
}
else {
    $javaArgs = '-jar {0} --logsDirectory {1} --token {2}' -f $jarFinalPath,"$TargetFolder\Logs",$Token
}
Write-Verbose "Arguments to be used for Java will be $javaArgs"


# Create a scheduled task to auto-run the MCAS SIEM Agent
Write-Verbose 'Creating an MCAS SIEM Agent scheduled task that will automatically run as SYSTEM upon startup on this host'
try {               
    # Assemble the components of the scheduled task
    $taskName = 'MCAS SIEM Agent'     
    $taskAction = New-ScheduledTaskAction -Execute $javaExePath -WorkingDirectory $TargetFolder -Argument $javaArgs
    $taskPrincipal = New-ScheduledTaskPrincipal -Id Author -LogonType S4U -ProcessTokenSidType Default -UserId SYSTEM
    $taskTrigger = New-ScheduledTaskTrigger -AtStartup
    $taskSettings = New-ScheduledTaskSettingsSet -DontStopIfGoingOnBatteries -DontStopOnIdleEnd -AllowStartIfOnBatteries -ExecutionTimeLimit 0
        
    # Create the scheduled task in the root folder of the tasks library
    $task = Register-ScheduledTask -TaskName $taskName -Action $taskAction -Principal $taskPrincipal -Description $taskName -Trigger $taskTrigger -Settings $taskSettings
}
catch {
    throw ('Something went wrong when creating the scheduled task named {0}' -f $taskName)
}

# Start the scheduled task
if ($StartNow -and $task) {
    Write-Verbose 'Starting the MCAS SIEM Agent scheduled task'
    try {
        Start-ScheduledTask $taskName
    }
    catch {
        throw ('Something went wrong when starting the scheduled task named {0}' -f $taskName)
    }    
}