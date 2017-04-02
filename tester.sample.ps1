[CmdletBinding()]
param(
    [bool]
    $ExportAll = $true
)

$thisModule = [System.IO.Path]::GetFileName($PSScriptRoot)

Set-Variable -Name "__${thisModule}_Export_All" -Value $ExportAll -Force

$mod = Import-Module $PSScriptRoot -Force -Verbose -PassThru