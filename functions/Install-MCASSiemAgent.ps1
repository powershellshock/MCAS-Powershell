<#
.Synopsis
    Install-MCASSiemAgent downloads and installs Java, downloads and unzips the MCAS SIEM Agent JAR file, and creates a scheduled task to auto-start the agent on startup. (This works on 64-bit Windows hosts only.)
.DESCRIPTION
    Auto-deploy the MCAS SIEM Agent.
.EXAMPLE
    Install-MCASSiemAgent -InteractiveJavaSetup

    This example will auto-deploy the MCAS SIEM Agent with the user experiencing an interactive Java installation process

.EXAMPLE
    Install-MCASSiemAgent -Force

    This example will auto-deploy the MCAS SIEM Agent with no user interaction.

#>
function Install-MCASSiemAgent {
    [CmdletBinding()]
    param
    (
        # Specifies whether to install Java interactively, if/when it is automatically installed. If this is not used, Java setup will be run silently
        [switch]$InteractiveJavaSetup,

        # Specifies whether to auto-download and silently install Java, if Java is not found on the machine
        [switch]$Force
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
    Write-Verbose 'This host does appear to be running 64-bit Windows. Proceeding'


    # Download and extract the latest MCAS SIEM Agent JAR file
    $jarFile = Get-MCASSiemAgentJarFile


    # Get the installation location of the latest Java engine that is installed, if there is one installed
    $javaInstallationPath = Get-JavaInstallationPath


    if (-not $javaInstallationPath) {
        if (-not $Force) {
            # Prompt user for confirmation before proceeding with automatic Java download and installation
            if ((Read-Host "CONFIRM: No Java installation was detected. Java will now be automatically downloaded and installed Java. Do you wish to continue?`n[Y] Yes or [N] No").ToLower() -ne 'y') {
                Write-Verbose "User chose not to proceed with automatic Java download and installation. Exiting"
                return
            }
            Write-Verbose "User chose to proceed with automatic Java download and installation. Continuing"
        }
        
        # Download Java
        $javaSetupFileName = Get-JavaInstallationPackage

        # Install Java
        try {
            if ($InteractiveJavaSetup) {
                Write-Verbose "Starting interactive Java setup"
                Start-Process "$pwd\$javaSetupFileName" -Wait
            }
            else {
                Write-Verbose "Starting silent Java setup"
                Start-Process "$pwd\$javaSetupFileName" -ArgumentList '/s' -Wait
            }
        }
        catch {
            throw "Something went wrong attempting to run the Java setup package. The error was $_"
        }
        Write-Verbose "Java setup seems to have finished"
        
        
        # Clean up Java setup file
        Write-Verbose "Cleaning up the Java setup package"
        try {
            Remove-Item "$pwd\$javaSetupFileName" -Force
        }
        catch {
            Write-Warning ('Failed to clean up the Java setup exe file ({0})' -f "$pwd\$javaSetupFileName")
        }


        # Get the installation location of the newly installed Java engine
        $javaInstallationPath = Get-JavaInstallationPath
    }


    if (-not $javaInstallationPath) {
        throw "There seems to still be a problem with the Java installation"
    }



    

    # Get the SIEM Agent's token





    Write-Verbose 'Creating an auto-starting scheduled task for the MCAS SIEM Agent on this host.'
    try {

    }
    catch {
        
    }






}