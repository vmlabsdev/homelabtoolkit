function Get-PVEVM {
    <#
    .SYNOPSIS
        Gets Proxmox VMs.
    .DESCRIPTION
        Gets Proxmox VMs using Proxmox REST API. Returns data about the VM and Qemu agent (if present).
    .NOTES
        It requires an API token.
    .LINK
        Read more about this function in: [Work In Prorgress]
    .PARAMETER Token
        Must provide an API token, example: root@pam!token=abcdefg-1234-1234-ab12-abcdefghijkl
    .PARAMETER PVEUri
        Must provide the PVE Uri, for example: https://pve.vmlabs.es:8006
    .EXAMPLE
        Get-PVEVMs -Token "root@pam!token=abcdefg-1234-1234-ab12-abcdefghijkl" -PVEUri "https://pve.vmlabs.es:8006" | Format-Table
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Token, 
        [Parameter(Mandatory)]
        [string]
        $PVEUri
    )
    begin {
        $Headers = @{
            "Authorization" = "PVEAPIToken=$Token"
        }
        $Report = @()
    }
    process {
        $Nodes = ((Invoke-WebRequest -Headers $Headers -Uri "$PVEUri/api2/json/nodes").Content | ConvertFrom-Json).Data

        $Nodes | ForEach-Object {
            $Node = $PSItem
            $VMs = ((Invoke-WebRequest -Headers $Headers -Uri "$PVEUri/api2/json/nodes/$(($Node.Node).ToLower())/qemu").Content | ConvertFrom-Json).Data
            $VMs | ForEach-Object {
                $VM = $PSItem
                $AgentData = ((Invoke-WebRequest -Headers $Headers -Uri "$PVEUri/api2/json/nodes/$(($Node.Node).ToLower())/qemu/$($VM.vmid)/agent").Content | ConvertFrom-Json).Data
                $NetworkAdapters = @()
                $NetworkAdapters = ((Invoke-WebRequest -Headers $Headers -Uri "$PVEUri/api2/json/nodes/$(($Node.Node).ToLower())/qemu/$($VM.vmid)/agent/network-get-interfaces").Content | ConvertFrom-Json).Data.Result | Select-Object *, @{l = "MAC"; e = { $_.'hardware-address' } } | Where-Object { ($_.MAC -clike "bc:24*") }
                $IPs = "NO"
                $IPs = $NetworkAdapters.'ip-addresses' | Where-Object { ($_.'ip-address-type' -eq "ipv4") -and ($_.'prefix' -ne 8) }
                if ($IPs -eq "NO") {
                    $IPAddress = "No guest agent"
                }
                else {
                    $IPAddress = $($IPs.'ip-address' -join ",")
                }
        
                $SecondsUptime = $VM.uptime
                $TimeSpan = [timespan]::FromSeconds($SecondsUptime) 
                $Report += [PSCustomObject]@{
                    Node = $Node.Node
                    VMName       = $VM.Name
                    State        = $VM.Status
                    Uptime       = $("{0:dd}d:{0:hh}h:{0:mm}m:{0:ss}s" -f $TimeSpan)
                    IPAddress    = $IPAddress
                }
            }
        }
    }
    end {
        return $Report
    }
}
