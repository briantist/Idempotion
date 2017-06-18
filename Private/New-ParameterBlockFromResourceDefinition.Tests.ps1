param(
    [System.Management.Automation.PSModuleInfo]
    $Module = (Import-Module -Name ($PSScriptRoot | Split-Path -Parent) -Force -PassThru -ErrorAction Stop)
)

InModuleScope $Module.Name {
    Describe "New-ParameterBlockFromResourceDefinition" {
        $ParamExclusions = '*:DependsOn','Gorgon:Ensure','*ile:*Path'| ForEach-Object -Process { $_ -as [ResourcePropertyPattern]}
        $resource = Get-DscResource -Name File

        Context 'As String' {
            $result = $resource | New-ParameterBlockFromResourceDefinition

            It 'returns a string' {
                $result -is [String] | Should Be $true
            }

            It 'contains [ValidateSet()]' {
                $result | Should Match '\[ValidateSet\(.+?\)\]'
            }

            It 'generates a semantically valid parameter block' {
                { [ScriptBlock]::Create("[CmdletBinding()]param($result)") } | Should Not Throw
            }
        }

        Context 'As String (suppressing ValidateSet)' {
            $result = $resource | New-ParameterBlockFromResourceDefinition -NoValidateSet

            It 'returns a string' {
                $result -is [String] | Should Be $true
            }

            It 'does not contain [ValidateSet()]' {
                $result | Should Not Match '\[ValidateSet\(.+?\)\]'
            }

            It 'generates a semantically valid parameter block' {
                { [ScriptBlock]::Create("[CmdletBinding()]param($result)") } | Should Not Throw
            }
        }

        Context 'As String (excluding properties)' {
            $result = $resource | New-ParameterBlockFromResourceDefinition -ExcludeProperty $ParamExclusions

            It 'returns a string' {
                $result -is [String] | Should Be $true
            }

            It 'contains [ValidateSet()]' {
                $result | Should Match '\[ValidateSet\(.+?\)\]'
            }

            It 'generates a semantically valid parameter block' {
                { [ScriptBlock]::Create("[CmdletBinding()]param($result)") } | Should Not Throw
            }

            It 'does not contain a DependsOn parameter' {
                $result -match '\$DependsOn' | Should Be $false
            }

            It 'does not contain a SourcePath parameter' {
                $result -match '\$SourcePath' | Should Be $false
            }

            It 'does contain a DestinationPath parameter' {
                $result -match '\$DestinationPath' | Should Be $true
            }

            It 'does contain an Ensure parameter' {
                $result -match '\$Ensure' | Should Be $true
            }
        }

        Context 'As String (suppressing ValidateSet, excluding properties)' {
            $result = $resource | New-ParameterBlockFromResourceDefinition -NoValidateSet -ExcludeProperty $ParamExclusions

            It 'returns a string' {
                $result -is [String] | Should Be $true
            }

            It 'does not contain [ValidateSet()]' {
                $result | Should Not Match '\[ValidateSet\(.+?\)\]'
            }

            It 'generates a semantically valid parameter block' {
                { [ScriptBlock]::Create("[CmdletBinding()]param($result)") } | Should Not Throw
            }
 
            It 'does not contain a DependsOn parameter' {
                $result -match '\$DependsOn' | Should Be $false
            }

            It 'does not contain a SourcePath parameter' {
                $result -match '\$SourcePath' | Should Be $false
            }

            It 'does contain a DestinationPath parameter' {
                $result -match '\$DestinationPath' | Should Be $true
            }

            It 'does contain an Ensure parameter' {
                $result -match '\$Ensure' | Should Be $true
            }
        }

        Context 'As String (excluding mandatory properties)' {
            $result = $resource | New-ParameterBlockFromResourceDefinition -ExcludeProperty $ParamExclusions -ExcludeMandatory

            It 'returns a string' {
                $result -is [String] | Should Be $true
            }

            It 'contains [ValidateSet()]' {
                $result | Should Match '\[ValidateSet\(.+?\)\]'
            }

            It 'generates a semantically valid parameter block' {
                { [ScriptBlock]::Create("[CmdletBinding()]param($result)") } | Should Not Throw
            }

            It 'does not contain a DependsOn parameter' {
                $result -match '\$DependsOn' | Should Be $false
            }

            It 'does not contain a SourcePath parameter' {
                $result -match '\$SourcePath' | Should Be $false
            }

            It 'does not contain a DestinationPath parameter' {
                $result -match '\$DestinationPath' | Should Be $false
            }

            It 'does contain an Ensure parameter' {
                $result -match '\$Ensure' | Should Be $true
            }
        }

        Context 'As String (suppressing ValidateSet, excluding mandatory properties)' {
            $result = $resource | New-ParameterBlockFromResourceDefinition -NoValidateSet -ExcludeProperty $ParamExclusions -ExcludeMandatory

            It 'returns a string' {
                $result -is [String] | Should Be $true
            }

            It 'does not contain [ValidateSet()]' {
                $result | Should Not Match '\[ValidateSet\(.+?\)\]'
            }

            It 'generates a semantically valid parameter block' {
                { [ScriptBlock]::Create("[CmdletBinding()]param($result)") } | Should Not Throw
            }

            It 'does not contain a DependsOn parameter' {
                $result -match '\$DependsOn' | Should Be $false
            }

            It 'does not contain a SourcePath parameter' {
                $result -match '\$SourcePath' | Should Be $false
            }

            It 'does not contain a DestinationPath parameter' {
                $result -match '\$DestinationPath' | Should Be $false
            }

            It 'does contain an Ensure parameter' {
                $result -match '\$Ensure' | Should Be $true
            }
        }



        Context 'As Array' {
            $result = $resource | New-ParameterBlockFromResourceDefinition -AsArray

            It 'returns an array' {
                $result -is [Array] | Should Be $true
            }

            It 'should include [ValidateSet()] attributes' {
                $result -join ',' | Should Match '\[ValidateSet\(.+?\)\]'
            }

            It 'generates semantically valid parameters' {
                { [ScriptBlock]::Create("[CmdletBinding()]param($($result -join ','))") } | Should Not Throw
            }
        }

        Context 'As Array (suppressing ValidateSet)' {
            $result = $resource | New-ParameterBlockFromResourceDefinition -AsArray -NoValidateSet

            It 'returns an array' {
                $result -is [Array] | Should Be $true
            }

            It 'should not include [ValidateSet()] attributes' {
                $result -join ',' | Should Not Match '\[ValidateSet\(.+?\)\]'
            }

            It 'generates semantically valid parameters' {
                { [ScriptBlock]::Create("[CmdletBinding()]param($($result -join ','))") } | Should Not Throw
            }
        }

        Context 'As Array (excluding properties)' {
            $result = $resource | New-ParameterBlockFromResourceDefinition -AsArray -ExcludeProperty $ParamExclusions

            It 'returns an array' {
                $result -is [Array] | Should Be $true
            }

            It 'should include [ValidateSet()] attributes' {
                $result -join ',' | Should Match '\[ValidateSet\(.+?\)\]'
            }

            It 'generates semantically valid parameters' {
                { [ScriptBlock]::Create("[CmdletBinding()]param($($result -join ','))") } | Should Not Throw
            }

            It 'does not contain a DependsOn parameter' {
                $result.Where({
                    $_ -match '\$DependsOn'
                }, [System.Management.Automation.WhereOperatorSelectionMode]::First) -as [bool] | Should Be $false
            }

            It 'does not contain a SourcePath parameter' {
                $result.Where({
                    $_ -match '\$SourcePath'
                }, [System.Management.Automation.WhereOperatorSelectionMode]::First) -as [bool] | Should Be $false
            }

            It 'does contain a DestinationPath parameter' {
                $result.Where({
                    $_ -match '\$DestinationPath'
                }, [System.Management.Automation.WhereOperatorSelectionMode]::First) -as [bool] | Should Be $true
            }

            It 'does contain an Ensure parameter' {
                $result.Where({
                    $_ -match '\$Ensure'
                }, [System.Management.Automation.WhereOperatorSelectionMode]::First) -as [bool] | Should Be $true
            }
        }

        Context 'As Array (suppressing ValidateSet, excluding properties)' {
            $result = $resource | New-ParameterBlockFromResourceDefinition -AsArray -NoValidateSet -ExcludeProperty $ParamExclusions

            It 'returns an array' {
                $result -is [Array] | Should Be $true
            }

            It 'should not include [ValidateSet()] attributes' {
                $result -join ',' | Should Not Match '\[ValidateSet\(.+?\)\]'
            }

            It 'generates semantically valid parameters' {
                { [ScriptBlock]::Create("[CmdletBinding()]param($($result -join ','))") } | Should Not Throw
            }

            It 'does not contain a DependsOn parameter' {
                $result.Where({
                    $_ -match '\$DependsOn'
                }, [System.Management.Automation.WhereOperatorSelectionMode]::First) -as [bool] | Should Be $false
            }

            It 'does not contain a SourcePath parameter' {
                $result.Where({
                    $_ -match '\$SourcePath'
                }, [System.Management.Automation.WhereOperatorSelectionMode]::First) -as [bool] | Should Be $false
            }

            It 'does contain a DestinationPath parameter' {
                $result.Where({
                    $_ -match '\$DestinationPath'
                }, [System.Management.Automation.WhereOperatorSelectionMode]::First) -as [bool] | Should Be $true
            }

            It 'does contain an Ensure parameter' {
                $result.Where({
                    $_ -match '\$Ensure'
                }, [System.Management.Automation.WhereOperatorSelectionMode]::First) -as [bool] | Should Be $true
            }
        }

        Context 'As Array (excluding mandatory properties)' {
            $result = $resource | New-ParameterBlockFromResourceDefinition -AsArray -ExcludeProperty $ParamExclusions -ExcludeMandatory

            It 'returns an array' {
                $result -is [Array] | Should Be $true
            }

            It 'should include [ValidateSet()] attributes' {
                $result -join ',' | Should Match '\[ValidateSet\(.+?\)\]'
            }

            It 'generates semantically valid parameters' {
                { [ScriptBlock]::Create("[CmdletBinding()]param($($result -join ','))") } | Should Not Throw
            }

            It 'does not contain a DependsOn parameter' {
                $result.Where({
                    $_ -match '\$DependsOn'
                }, [System.Management.Automation.WhereOperatorSelectionMode]::First) -as [bool] | Should Be $false
            }

            It 'does not contain a SourcePath parameter' {
                $result.Where({
                    $_ -match '\$SourcePath'
                }, [System.Management.Automation.WhereOperatorSelectionMode]::First) -as [bool] | Should Be $false
            }

            It 'does not contain a DestinationPath parameter' {
                $result.Where({
                    $_ -match '\$DestinationPath'
                }, [System.Management.Automation.WhereOperatorSelectionMode]::First) -as [bool] | Should Be $false
            }

            It 'does contain an Ensure parameter' {
                $result.Where({
                    $_ -match '\$Ensure'
                }, [System.Management.Automation.WhereOperatorSelectionMode]::First) -as [bool] | Should Be $true
            }
        }

        Context 'As Array (suppressing ValidateSet, excluding mandatory properties)' {
            $result = $resource | New-ParameterBlockFromResourceDefinition -AsArray -NoValidateSet -ExcludeProperty $ParamExclusions -ExcludeMandatory

            It 'returns an array' {
                $result -is [Array] | Should Be $true
            }

            It 'should not include [ValidateSet()] attributes' {
                $result -join ',' | Should Not Match '\[ValidateSet\(.+?\)\]'
            }

            It 'generates semantically valid parameters' {
                { [ScriptBlock]::Create("[CmdletBinding()]param($($result -join ','))") } | Should Not Throw
            }

            It 'does not contain a DependsOn parameter' {
                $result.Where({
                    $_ -match '\$DependsOn'
                }, [System.Management.Automation.WhereOperatorSelectionMode]::First) -as [bool] | Should Be $false
            }

            It 'does not contain a SourcePath parameter' {
                $result.Where({
                    $_ -match '\$SourcePath'
                }, [System.Management.Automation.WhereOperatorSelectionMode]::First) -as [bool] | Should Be $false
            }

            It 'does not contain a DestinationPath parameter' {
                $result.Where({
                    $_ -match '\$DestinationPath'
                }, [System.Management.Automation.WhereOperatorSelectionMode]::First) -as [bool] | Should Be $false
            }

            It 'does contain an Ensure parameter' {
                $result.Where({
                    $_ -match '\$Ensure'
                }, [System.Management.Automation.WhereOperatorSelectionMode]::First) -as [bool] | Should Be $true
            }
        }
    }
}