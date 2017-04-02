$modulePath = $PSScriptRoot | Split-Path -Parent
$moduleName = $modulePath | Split-Path -Leaf

Import-Module -Name $modulePath -Force

InModuleScope $moduleName {
    Describe "New-ParameterFromResourcePropertyInfo" {
        $testValidateSet = [PSCustomObject]@{
            Name = 'Ensure'
            PropertyType = '[string]'
            IsMandatory = $true
            Values = @(
                 'Present'
                ,'Absent'
                ,"Single ' Quote"
            )
        }
        $testNoSet = [PSCustomObject]@{
            Name = 'DesiredCount'
            PropertyType = '[int]'
            IsMandatory = $false
            Values = @()
        }

        Context 'With ValidateSet' {
            $result = $testValidateSet | New-ParameterFromResourcePropertyInfo
        
            It 'generates a [ValidateSet()] attribute when values are supplied' {
                $result | Should Match '\[ValidateSet\(.+?\)\]'
            }

            It 'generates a semantically valid parameter' {
                { [ScriptBlock]::Create("[CmdletBinding()]param($result)") } | Should Not Throw
            }
        }

        Context 'Without ValidateSet' {
            $result = $testNoSet | New-ParameterFromResourcePropertyInfo
        
            It 'leaves out the [ValidateSet()] attribute when Values is empty' {

                $result | Should Not Match '\[ValidateSet\(.*?\)\]'
            }

            It 'generates a semantically valid parameter' {
                { [ScriptBlock]::Create("[CmdletBinding()]param($result)") } | Should Not Throw
            }
        }
    }
}