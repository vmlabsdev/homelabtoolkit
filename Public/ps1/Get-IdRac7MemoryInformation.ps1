function Get-IdRac7MemoryInformation {
    <#
    .SYNOPSIS
        Gets IdRac 7 Memory information.
    .DESCRIPTION
        Gets IdRac 7 Memory information, returning the used slots information using Redfish API.
    .NOTES
        It requires Redfish API to be activated, it may be not enabled by default.
    .LINK
        Read more about this function in: [Work In Prorgress]
    .PARAMETER IdracUrl
        Must provide a FQDN, for example: https://idrac.vmlabs.es
    .PARAMETER Credentials
        Must provide idrac credentials with Get-Credential, if credentials are not provided function will ask for credentials.
    .EXAMPLE
        Get-IdRac7MemoryInformation -IdracUrl "https://idrac.vmlabs.es" | Ft
    #>
    [CmdletBinding()]
    param (
        $IdracUrl, $Credentials = $(Get-Credential)
    )
    $BaseUri = $IdracUrl
    Write-Verbose "[$($MyInvocation.MyCommand)]"
    $Slots = (Invoke-WebRequest -Uri "$BaseUri/redfish/v1/Systems/System.Embedded.1/Memory" -Credential $Credentials).Content | ConvertFrom-Json

    $Report = @()

    $Slots.Members.'@odata.id' | ForEach-Object {
        $Uri = "$($BaseUri)$($PSItem)"
        $Slot = (Invoke-WebRequest -Uri $URI -Credential $Credentials).Content | ConvertFrom-Json
        $Report += [PSCustomObject]@{
            Slot            = $Slot.Name
            Manufacturer    = $Slot.Manufacturer
            CapacityMiB     = $Slot.CapacityMiB
            OperatingSpeed  = $Slot.OperatingSpeedMhz
            ErrorCorrection = $Slot.ErrorCorrection
            PartNumber      = $Slot.PartNumber
            SerialNumber    = $Slot.SerialNumber
            HealthStatus    = $Slot.Status.Health
            State           = $Slot.Status.State
        }
    }

    return $Report
}