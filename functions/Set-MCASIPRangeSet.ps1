function Set-MCASIPRangeSet
{
    [CmdletBinding()]
    Param
    (    
        # Specifies the URL of your CAS tenant, for example 'contoso.portal.cloudappsecurity.com'.
        [Parameter(Mandatory=$false)]
        [ValidateScript({($_.EndsWith('.portal.cloudappsecurity.com') -or $_.EndsWith('.adallom.com'))})]
        [string]$TenantUri,

        # Specifies the CAS credential object containing the 64-character hexadecimal OAuth token used for authentication and authorization to the CAS tenant.
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]$Credential,

        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern("[a-z0-9]{24}")]
        [alias("_id")]
        [string]$Identity,
    
        [Parameter(Mandatory=$false,ValueFromPipeline=$true,Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true,Position=2)]
        [ValidateNotNullOrEmpty()]
        [subnet_category]$Category,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true,Position=3)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Subnets,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true,Position=4)]
        [ValidateNotNullOrEmpty()]
        [string]$Organization,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true,Position=5)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tags,

        [Parameter(Mandatory=$false)]
        [Switch]$Quiet
    )
    Begin {
        Try {$TenantUri = Select-MCASTenantUri}
            Catch {Throw $_}

        Try {$Token = Select-MCASToken}
            Catch {Throw $_}
    }
    Process {
        # Get the object by its id
        $item = Get-MCASSubnet -TenantUri $TenantUri | Where-Object {$_._id -eq $Identity}



        
        
        Write-Host -ForegroundColor Cyan "Before:"
        $item
        
        



        # Modify the object properties based on params provided
        If ($Name){
            $item.name = $Name
        }
        
        If ($Category) {
            $item.category = $Category
        }

        If ($Subnets){
            $item.subnets = $Subnets
        }

        If ($Tags) {
            $item.tags = $Tags
        }

        If ($Organization) {
            $item.organization = $Organization
        }

        # Fixup any properties that need fixing
        If ($item.tags -eq (@{})) {
            $item.tags = $null
        }
        #$item.tags = $null





        Write-Host -ForegroundColor Cyan "After:"
        $item

        
        
        
        
        # Convert the object into a hashtable, then a JSON document
        $Body = @{}
        $item.psobject.properties | ForEach-Object {$Body.Add($_.Name,$_.Value) }
        $Body = $Body | ConvertTo-Json -Compress -Depth 3


        

        Write-Host -ForegroundColor Cyan "Body:"
        $Body







        Try {
            $Response = Invoke-MCASRestMethod2 -Uri "https://$TenantUri/cas/api/v1/subnet/$Identity/update_rule/" -Token $Token -Method Post -Body $Body
        }
            Catch {
                Throw $_  #Exception handling is in Invoke-MCASRestMethod, so here we just want to throw it back up the call stack, with no additional logic
            }
        
        Write-Verbose "Checking response for success" 
        If ($Response.StatusCode -eq '200') {
            Write-Verbose "Successfully modified subnet $NameOrIdTargeted" 
        }
        Else {
            Write-Verbose "Something went wrong attempting to modify subnet $NameOrIdTargeted" 
            Write-Error "Something went wrong attempting to modify subnet $NameOrIdTargeted"
        }  

        $Response = $Response.content | ConvertFrom-Json

        If (!$Quiet) {
            $Response
        }
    }
    End {
    }
}
