function Convert-DscResourceToCommand {
[CmdletBinding(DefaultParameterSetName = 'Module')]
[OutputType([System.Management.Automation.PSModuleInfo], ParameterSetName = 'Module')]
[OutputType([System.Management.Automation.PSModuleInfo], ParameterSetName = 'Module-Import')]
[OutputType([System.Management.Automation.PSObject], ParameterSetName = 'Module-AsCustomObject')]
[OutputType([String], ParameterSetName = 'AsString')]
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
        throw [System.NotImplementedException]'This parameter is not implemented yet.'
    } )]
    [String[]]
    $ExcludeProperty = '*:DependsOn' ,

    [Parameter()]
    [ValidateScript( {
        throw [System.NotImplementedException]'This parameter is not implemented yet.'
    } )]
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
        ParameterSetName = 'Module'
    )]
    [Parameter(
        ParameterSetName = 'Module-Import'
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
    [Alias('SoftPrefix')]
    [ValidateNotNullOrEmpty()]
    [String]
    $Prefix ,

    [Parameter(
        ParameterSetName = 'Module-Import'
    )]
    [Switch]
    $NoClobber ,

    [Parameter(
        ParameterSetName = 'Module-Import'
    )]
    [Switch]
    $DisableNameChecking ,

    [Parameter(
        ParameterSetName = 'Module'
    )]
    [Parameter(
        ParameterSetName = 'Module-Import'
    )]
    [PSDefaultValue(Help = 'Always active when creating a module without importing it')]
    [Switch]
    $PassThru ,

    [Parameter(
        ParameterSetName = 'Module-Import' ,
        Mandatory
    )]
    [Switch]
    $Import ,

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
        ParameterSetName = 'Module-AsCustomObject'
    )]
    [Switch]
    $Force ,

    [Parameter(
        ParameterSetName = 'AsString' ,
        Mandatory
    )]
    [Switch]
    $AsString
)

    Begin {
        try {
            $boundKeys = $PSBoundParameters.Keys.GetEnumerator().ForEach({$_})

            if ($DefaultResourceModuleName) {
                $DefaultModule = Get-Module -Name $DefaultResourceModuleName
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
                $nmoParams = @{
                    ScriptBlock = [ScriptBlock]::Create($Functions -join "`n")
                }
            
                if ($AsCustomObject) {
                    $nmoParams.AsCustomObject = $true
                }

                if ($ModuleName) {
                    $nmoParams.Name = $ModuleName
                }

                $ipmoParams = @{}

                $ipmoApplicableParamNames = @(
                     'DisableNameChecking'
                    ,'Force'
                    ,'PassThru'
                    ,'Prefix'
                    ,'NoClobber'
                    ,'AsCustomObject'
                )

                Compare-Object -ReferenceObject $boundKeys -DifferenceObject $ipmoApplicableParamNames -ExcludeDifferent -IncludeEqual |
                    ForEach-Object -Process {
                        $paramName = $_.InputObject
                        $ipmoParams[$paramName] = $PSBoundParameters[$paramName]
                    }

                $newMod = New-Module @nmoParams -Verbose:$VerbosePreference

                if ($AsCustomObject) {
                    $newMod
                } else {
                    $newMod | Remove-Module -Force -Verbose:$VerbosePreference

                    if ($Import) { # PassThru will be in $ipmoParams so the module will be returned if needed
                        $newMod | Import-Module @ipmoParams -Global -Verbose:$VerbosePreference
                    } else {
                        $newMod  # module is always returned if it's not imported
                    }
                }
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
}
