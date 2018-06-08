function Get-JavaInstallationPath
{   
    [CmdletBinding()]
    param()

    try {
        Write-Verbose 'Checking installed programs list for an existing Java installation on this host.'    
        $javaProductGuid = (Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -match '^Java (?:8|9) Update \d{1,3}.*$'} | Sort-Object -Property Name -Descending | select -First 1).IdentifyingNumber
        
        if ($javaProductGuid) {
            Write-Verbose "Java is installed. Getting the installation location from HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$javaProductGuid"         
            $javaInstallationPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$javaProductGuid" -Name 'InstallLocation').InstallLocation
            Write-Verbose "Java installation path detected is $javaInstallationPath"
            $javaInstallationPath
        }
        else {
            Write-Verbose "Java was not found in the installed programs list"
        }
    }
    catch {
        Write-Warning 'Something went wrong attempting to detect the Java installation or its installation path. The error was $_'
    }
}