Function Get-NetboxVM {
    <#
    .SYNOPSIS
        Gets VMs from Netbox
    .DESCRIPTION
        Gets VMs from Netbox and all provided data by the API.
    .NOTES
        Must provide an API token and the URL with https://
    .LINK
        Read more about this function in: [Work In Prorgress]
    .PARAMETER Token
        Must provide a Netbox API token
    .PARAMETER NetboxUri
        Must provide the Netbox instance URL with https://
    .PARAMETER VMName
        Provide a VMName if you want to get data from only one VM
    .EXAMPLE
        $Token = "API Token"
        Get-NetboxVM -Token $Token -NetboxUri "https://netbox.vmlabs.es"
    #>
    
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Token, 
        [Parameter(Mandatory)]
        [string]
        $NetboxURI,
        [Parameter()]
        [string]
        $VMName
    )
    
    $Headers = @{
        "Authorization" = "Token $Token"
    }
    $VMs = ((Invoke-WebRequest -Headers $Headers -Uri "$NetboxURI/api/virtualization/virtual-machines/").Content | ConvertFrom-Json).Results

    if ($VMName) {
        $VMs = $VMs | Where-Object { $_.Name -eq $VMName }
    }

    return $VMs
}

