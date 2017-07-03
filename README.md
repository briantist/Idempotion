[![Build status](https://ci.appveyor.com/api/projects/status/krw5r7k42j5v2wxq?svg=true)](https://ci.appveyor.com/project/briantist/idempotion)
# Idempotion

Idempotion is a PowerShell module designed to allow use of DSC resources as imperative commands.

The idempotent nature of DSC resources is sometimes desirable in a scenario where generating static configurations tied to a specific node doesn't make sense.

Idempotion allows you to use existing, well-tested logic as part of scripts so you don't have to reinvent the wheel.

## Quick Example

Need to check whether a system has a pending reboot? [There's a DSC Module for that (xPendingReboot)](https://www.powershellgallery.com/packages/xPendingReboot/) that checks 5 different locations in the system where a pending reboot might be set. But what if you need that functionality in a script?

```PowerShell
Import-Module -Name Idempotion

Get-DscResource -Name xPendingReboot | Convert-DscResourceToCommand -ExcludeVerb Set,Update -Verbose -Import

# This resource takes a -Name parameter that is useless outside of DSC
$PSDefaultParameterValues = @{ '*-xPendingReboot:Name' = 'Unused' }

# All the checks
Get-xPendingReboot

# Testing

if (Test-xPendingReboot) {
  throw 'Your computer requires a reboot.'
}

# Here we don't care about a pending file rename

if (Test-xPendingReboot -SkipPendingFileRename $true) {
  # etc.
}
```

The parameters come directly from the properties of the DSC resource. Try it with `-Verbose` to see the full DSC-style output; saving you from writing additional logging code.

_More documentation coming soon._

# Installation

Please install directly from [PowerShell Gallery](https://www.powershellgallery.com/packages/Idempotion/):

```PowerShell
Install-Module -Name Idempotion
```
