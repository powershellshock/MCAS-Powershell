function Test-MCASResultCount {
    if (($response.data).count -lt $response.total) {

        Write-Verbose ('{0} of {1} total records were retrieved. Use the -InformationVariable parameter to get the total record count into a variable.' -f ($response.data.count), ($response.total))

        Write-Information $response.total
    }
}