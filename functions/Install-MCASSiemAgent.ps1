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
        [string]$InstallJavaSilent = 'Off',
        
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$JavaExePath = 'C:\Program Files\Java\jre1.8.0_171\bin\java.exe'
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

    $javaInstallationPath = Get-JavaInstallationPath


    if ($javaInstallationPath)


<#

    Write-Verbose 'Attempting to detect an existing Java installation on this host.'
    # Check for Java
    $javaProduct = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -match '^Java (?:8|9) Update \d{1,3}.*$'}
    if ($javaProduct) {

        Write-Verbose 'Java appears to be installed, based on the Add/Remove Programs list'
        
        
        (Get-ItemProperty -Path ('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{0}' -f $javaProduct.IdentifyingNumber) -Name 'InstallLocation').InstallLocation



        


        # 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{26A24AE4-039D-4CA4-87B4-2F64180171F0}\InstallLocation = C:\Program Files\Java\jre1.8.0_171\'
        # (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{26A24AE4-039D-4CA4-87B4-2F64180171F0}' -Name 'InstallLocation').InstallLocation








        Write-Verbose 'Attempting to detect an existing Java installation on this host.'

        Write-Verbose 'Checking for Java in its default location (C:\Program Files\Java\jre*\bin\java.exe).'
        $progFilesJava = "$env:ProgramFiles\Java"       
        $javaExeFiles = (Get-ChildItem -Path $env:ProgramFiles -Recurse 'java.exe' -ErrorAction SilentlyContinue).FullName
        $javaExePathMatchPattern = '^C:\\Program Files\\Java\\jre(?:\d|\.|_)+\\bin\\java.exe$'

        if ($javaExeFiles.Count -eq 1 -and $javaExeFiles -match $javaExePathMatchPattern) {
            Write-Verbose "One Java installation detected in Program Files"

        }
        elseif ($javaExeFiles.Count -gt 1) {
            Write-Verbose "More than one Java installation detected in Program Files, so prompting the user to select one"
            Invoke-FilePickerDialog -InitialDirectory 'C:\Program Files\Java' -Filter 'Java Runtime Engine|java.exe' -Title 'Select Java engine (java.exe) to be used by the MCAS SIEM Agent'
        }
        else {
            Write-Verbose "No Java installation detected in Program Files, so prompting the user for the path to java.exe"
            Invoke-FilePickerDialog -InitialDirectory 'C:\' -Filter 'Java Runtime Engine|java.exe' -Title 'Select Java engine (java.exe) to be used by the MCAS SIEM Agent'
        }


        # check if java is in the PATH
        try {     
            #$JavaExePath = (Get-Item ($JavaExePath = '{0}\java.exe' -f (($env:PATH).split(';') | Where-Object {$_ -match '^.*Java\\.*\\bin$'} | Select -First 1))).FullName
        }
        catch {

        }
        
    }
    else {
        Write-Verbose 'Java does NOT appear to be installed, based on the Add/Remove Programs list'
        

        # Ask if Java has already been downloaded
        $downloadJava = $false

        if ($downloadJava) {
            Write-Verbose 'Attempting to download the Java installation package.'
            try {
                $javaDownloadUrl = ((Invoke-WebRequest -Uri 'https://www.java.com/en/download/manual.jsp' -UseBasicParsing).links | Where-Object {$_.title -eq 'Download Java software for Windows (64-bit)'} | select -Last 1).href
                
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
                throw "Something went wrong downloading the Java installation package. The error was $_"
            }
        }
        else {
            # Prompt for path to Java setup package
            Invoke-FilePickerDialog -InitialDirectory "$env:userprofile\Downloads" -Filter 'EXE files|*.exe' -Title 'Select Java setup package to be installed for the MCAS SIEM Agent'
        }

        
        # Ask if Java setup should be interactive or silent

        # Install Java


    }
    #>


    #$javaPath = 'C:\Program Files\Java\jre1.8.0_171\bin\java.exe'

    #Get-ChildItem
    
    Invoke-FilePickerDialog -InitialDirectory 'C:\Program Files\Java' -Filter 'Java Runtime Engine|java.exe' -Verbose










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