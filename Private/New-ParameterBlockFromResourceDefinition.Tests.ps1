param(
    [System.Management.Automation.PSModuleInfo]
    $Module = (Import-Module -Name ($PSScriptRoot | Split-Path -Parent) -Force -PassThru -ErrorAction Stop)
)

InModuleScope $Module.Name {
    Describe "New-ParameterBlockFromResourceDefinition" {
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
    }
}