$modulePath = $PSScriptRoot | Split-Path -Parent
$moduleName = $modulePath | Split-Path -Leaf

Import-Module -Name $modulePath -Force

InModuleScope $moduleName {
    Describe "New-ParameterBlockFromResourceDefinition" {
        $resource = Get-DscResource -Name File

        Context 'As String' {
            $result = $resource | New-ParameterBlockFromResourceDefinition

            It 'returns a string' {
                $result -is [String] | Should Be $true
            }

            It 'generates a semantically valid parameter block' {
                { [ScriptBlock]::Create("[CmdletBinding()]param($result)") } | Should Not Throw
            }
        }

        Context 'As Array' {
            $result = $resource | New-ParameterBlockFromResourceDefinition -AsArray

            It 'returns an array' {
                $result -is [Array] | Should Be $true
            }

            It 'generates semantically valid parameters' {
                { [ScriptBlock]::Create("[CmdletBinding()]param($($result -join ','))") } | Should Not Throw
            }
        }
    }
}