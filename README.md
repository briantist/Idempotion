[![Build status](https://ci.appveyor.com/api/projects/status/krw5r7k42j5v2wxq?svg=true)](https://ci.appveyor.com/project/briantist/idempotion)

# Installation

Please install directly from [PowerShell Gallery](https://www.powershellgallery.com/packages/Idempotion/):

```PowerShell
Install-Module -Name Idempotion
```

# About Idempotion

Idempotion is a PowerShell module designed to allow use of DSC resources as imperative commands.

The idempotent nature of DSC resources is sometimes desirable in a scenario where generating static configurations tied to a specific node doesn't make sense.

Idempotion allows you to use existing, well-tested logic as part of scripts so you don't have to reinvent the wheel.

Essentially it turns this:

```PowerShell
Invoke-DscResource -Name File -ModuleName PSDesiredStateConfiguration -Method Set -Property @{ DestinationPath = 'C:\Folder\File.txt' ; Contents = 'Hello' }
```

into this:

```PowerShell
Set-File -DestinationPath 'C:\Folder\File.txt -Contents 'Hello'
```

---

Or even better, it turns this:

```PowerShell
$params = @{
	DestinationPath = 'C:\Folder\File.txt'
	Contents = 'Hello'
}

if (-not (Invoke-DscResource -Name File -ModuleName PSDesiredStateConfiguration -Method Test -Property $params)) {
	Invoke-DscResource -Name File -ModuleName PSDesiredStateConfiguration -Method Set -Property $params
}
```

Into this:

```PowerShell
Update-File -DestinationPath 'C:\Folder\File.txt -Contents 'Hello'
```

### More Features:

* Mock `-WhatIf` support (`Invoke-DscResource` cannot use `-WhatIf`)
* All commands returned in a module for ease of use and namespace issues (`-Prefix`)
* Overridable template for generated functions
* Control which verb(s) you want generated, and which properties of the resource become parameters
* Generate functions as a string for injection into remote sessions or saving to a file

## Quick Sample

Need to check whether a system has a pending reboot? [There's a DSC Module for that (xPendingReboot)](https://www.powershellgallery.com/packages/xPendingReboot/) that checks 5 different locations in the system where a pending reboot might be set. But what if you need that functionality in a script?

```PowerShell
Import-Module -Name Idempotion

Get-DscResource -Name xPendingReboot | Convert-DscResourceToCommand -ExcludeVerb Set,Update -Verbose -Import

# This resource takes a -Name parameter that is useless outside of DSC
$PSDefaultParameterValues = @{ '*-xPendingReboot:Name' = 'Unused' }

# All the checks
Get-xPendingReboot

# Testing

if (-not (Test-xPendingReboot)) {
  throw 'Your computer requires a reboot.'
}

# Here we don't care about a pending file rename

if (-not (Test-xPendingReboot -SkipPendingFileRename $true)) {
  # etc.
}
```

The parameters come directly from the properties of the DSC resource. Try it with `-Verbose` to see the full DSC-style output; saving you from writing additional logging code.

_More documentation coming soon._
