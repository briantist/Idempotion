function Convert-DscResourceToCommand {
[CmdletBinding()]
[OutputType([System.Management.Automation.PSModuleInfo])]
param(
    [Parameter(
        Mandatory,
        ValueFromPipeline
    )]
    [Microsoft.PowerShell.DesiredStateConfiguration.DscResourceInfo[]]
    $Resource ,

    [Parameter()]
    [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformation()]
    [PSDefaultValue(Help = 'Module Defaults')]
    [HashTable]
    $CommandDefinition = (Import-PowerShellDataFile -LiteralPath ($MyInvocation.MyCommand.Module.ModuleBase | Join-Path -ChildPath $MyInvocation.MyCommand.Module.PrivateData.IdempotionConfig.CommandDefinitions)) ,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [String]
    $ModuleName = 'Idempotion.Tincture' ,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [String]
    $Prefix ,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [SupportsWildcards()]
    [String[]]
    $IncludeVerb = '*' ,

    [Parameter()]
    [AllowEmptyCollection()]
    [AllowEmptyString()]
    [SupportsWildcards()]
    [String[]]
    $ExcludeVerb = 'Get' ,

    [Parameter()]
    [AllowEmptyCollection()]
    [AllowEmptyString()]
    [SupportsWildcards()]
    [ValidateScript( {
        [ResourcePropertyPattern]::new($_) -as [bool]
    } )]
    [String[]]
    $ExcludeProperty = '*:DependsOn' ,

    [Parameter()]
    [Switch]
    $ExcludeMandatory ,

    [Parameter()]
    [Switch]
    $NoClobber ,

    [Parameter()]
    [Switch]
    $PassThru ,

    [Parameter()]
    [Switch]
    $NoImport ,

    [Parameter()]
    [Switch]
    $AsCustomObject ,

    [Parameter()]
    [Alias('SupportsShouldProcess')]
    [Alias('ShouldProcess')]
    [Alias('SupportsWhatIf')]
    [Switch]
    $MockWhatIf ,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [String]
    $HardPrefix
)

    Begin {
        $Definitions = Get-FilteredDefinitions -CommandDefinition $CommandDefinition -IncludeVerb $IncludeVerb -ExcludeVerb $ExcludeVerb
    }

    Process {
        foreach ($ResourceDefinition in $Resource) {
            $ParamBlock = New-ParameterBlockFromResourceDefinition -Resource $ResourceDefinition

            $DscModule = if ($ResourceDefinition.ModuleName) {
                $ResourceDefinition.ModuleName
            } else {
                'PSDesiredStateConfiguration'
            }

            $Definitions.Verbs.GetEnumerator() | ForEach-Object -Process {
                New-Object PSObject -Property @{
                    Verb = $_.Key
                    CommandDefinition = $_.Value
                    ResourceName = $ResourceDefinition.Name
                    ParamBlock = $ParamBlock
                    DscModule = $DscModule
                    HardPrefix = $HardPrefix
                    ShouldProcess = $MockWhatIf
                    Snippets = $Definitions.Snippets
                }
            } | New-FunctionFromDefinition
        }
    }
}
