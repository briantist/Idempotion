function Convert-DscResourceToCommand {
[CmdletBinding()]
[OutputType([System.Management.Automation.PSModuleInfo], ParameterSetName = 'Module-Import-PassThru')]
[OutputType([System.Management.Automation.PSObject], ParameterSetName = 'Module-AsCustomObject')]
[OutputType([String], ParameterSetName = 'AsString')]
[OutputType([void], ParameterSetName = 'Module-Import')]
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
    $CommandDefinition = (Get-DefaultDefinitions) ,

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
    [Alias('SupportsShouldProcess')]
    [Alias('ShouldProcess')]
    [Alias('SupportsWhatIf')]
    [Switch]
    $MockWhatIf ,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [String]
    $HardPrefix ,

    [Parameter()]
    [Alias('DefaultModule')]
    [AllowNull()]
    [AllowEmptyString()]
    [String]
    $DefaultResourceModuleName = 'PSDesiredStateConfiguration' ,

    [Parameter(
        ParameterSetName = 'Module-Import'
    )]
    [Parameter(
        ParameterSetName = 'Module-Import-PassThru'
    )]
    [Parameter(
        ParameterSetName = 'Module-AsCustomObject'
    )]
    [AllowNull()]
    [AllowEmptyString()]
    [String]
    $ModuleName = 'Idempotion.Tincture' ,

    [Parameter(
        ParameterSetName = 'Module-Import'
    )]
    [Parameter(
        ParameterSetName = 'Module-Import-PassThru'
    )]
    [Alias('SoftPrefix')]
    [ValidateNotNullOrEmpty()]
    [String]
    $Prefix ,

    [Parameter(
        ParameterSetName = 'Module-Import'
    )]
    [Parameter(
        ParameterSetName = 'Module-Import-PassThru'
    )]
    [Switch]
    $NoClobber ,

    [Parameter(
        ParameterSetName = 'Module-Import'
    )]
    [Parameter(
        ParameterSetName = 'Module-Import-PassThru'
    )]
    [Switch]
    $DisableNameChecking ,

    [Parameter(
        ParameterSetName = 'Module-Import-PassThru' ,
        Mandatory
    )]
    [Switch]
    $PassThru ,

    [Parameter(
        ParameterSetName = 'Module-Import-PassThru'
    )]
    [Switch]
    $NoImport ,

    [Parameter(
        ParameterSetName = 'Module-AsCustomObject' ,
        Mandatory
    )]
    [Switch]
    $AsCustomObject ,

    [Parameter(
        ParameterSetName = 'Module-Import'
    )]
    [Parameter(
        ParameterSetName = 'Module-Import-PassThru'
    )]
    [Parameter(
        ParameterSetName = 'Module-AsCustomObject'
    )]
    [Switch]
    $Force ,

    [Parameter(
        ParameterSetName = 'AsString'
    )]
    [Switch]
    $AsString
)

    Begin {
        try {
            if ($DefaultResourceModuleName) {
                $DefaultModule = Get-Module -Name $DefaultModuleName
            }

            $Definitions = Get-FilteredDefinitions -CommandDefinition $CommandDefinition -IncludeVerb $IncludeVerb -ExcludeVerb $ExcludeVerb

            $Functions = @()
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }

    Process {
        try {
            foreach ($ResourceDefinition in $Resource) {
                if (-not $ResourceDefinition.ModuleName -and $DefaultModule) {
                    $ResourceDefinition.Module = $DefaultModule
                }

                $ParamBlock = New-ParameterBlockFromResourceDefinition -Resource $ResourceDefinition

                $DscModule = $ResourceDefinition.ModuleName

                $GeneratedFunctions = $Definitions.Verbs.GetEnumerator() | ForEach-Object -Process {
                    New-Object -TypeName PSObject -Property @{
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

                if ($AsString) {
                    $GeneratedFunctions
                } else {
                    $Functions += $GeneratedFunctions
                }
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }

    End {
        try {
            if (-not $AsString) {
                throw [System.NotImplementedException]'Not done yet..'

                $modCommonParams = @{}
            
                if ($AsCustomObject) {
                    $modCommonParams.AsCustomObject = $true
                }

                if ($ModuleName) {
                    $modCommonParams.Name = $ModuleName
                }

                $nmoParams = $modCommonParams.Clone()
                $nmoParams.ScriptBlock = $Functions -join "`n"

                $ipmoParams = $modCommonParams.Clone()
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
}
