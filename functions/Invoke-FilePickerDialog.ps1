function Invoke-FilePickerDialog
{   
    param
    (
        # Specifies the directory in which the picker will begin
        [string]$InitialDirectory = "C:\Program Files",

        # Specifies the directory in which the picker will begin
        [string]$Filter = 'All files|*.*'    
        )
    $InitialDirectory = 
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $filePicker = New-Object System.Windows.Forms.OpenFileDialog
    
    $filePicker.initialDirectory = $InitialDirectory
    $filePicker.filter = $Filter
    $filePicker.ShowDialog() | Out-Null
    
    $filePicker.filename
}