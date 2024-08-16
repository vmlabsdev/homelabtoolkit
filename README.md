
# VMLABS HomeLab Powershell Toolkit

This repo contains various functions useful to manage your HomeLab.

Please, see the FUNCTIONS.md file for reference.

## Usage

To import this module, run:

```powershell
Import-Module .\VMLabsHLToolkit\VMLabsHLToolkit.psd1 -Verbose -Force
```

## Functions
|Description|Name|Parameters|
|:--|:--|:--|
|Gets IdRac 7 Memory information, returning the used slots information using Redfish API.|Get-IdRac7MemoryInformation|IdracUrl,Credentials|
|Gets VMs from Netbox and all provided data by the API.|Get-NetboxVM|Token,NetboxURI,VMName|

