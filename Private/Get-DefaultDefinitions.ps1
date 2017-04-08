function Get-DefaultDefinitions {
[CmdletBinding()]
[OutputType([HashTable])]
param()
    
    $definitionPath = $MyInvocation.MyCommand.Module.ModuleBase | Join-Path -ChildPath $MyInvocation.MyCommand.Module.PrivateData.IdempotionConfig.CommandDefinitions
    Import-PowerShellDataFile -LiteralPath $definitionPath
}
