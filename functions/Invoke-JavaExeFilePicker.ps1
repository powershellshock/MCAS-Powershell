function Invoke-JavaExeFilePicker
{   
    param
    (
        # Specifies the directory in which the picker will begin
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$InitialDirectory = 'C:\Program Files'
    )
    $InitialDirectory = 
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $filePicker = New-Object System.Windows.Forms.OpenFileDialog
    
    $filePicker.initialDirectory = $InitialDirectory
    $filePicker.filter = "Java|java.exe"
    $filePicker.ShowDialog() | Out-Null
    
    $filePicker.filename
}
