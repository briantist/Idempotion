param(
    [System.Management.Automation.PSModuleInfo]
    $Module = (Import-Module -Name ($PSScriptRoot | Split-Path -Parent) -Force -PassThru -ErrorAction Stop)
)

InModuleScope $Module.Name {
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

        Context 'With ValidateSet values supplied and -NoValidateSet not specified' {
            $result = $testValidateSet | New-ParameterFromResourcePropertyInfo
        
            It 'generates a [ValidateSet()] attribute when values are supplied' {
                $result | Should Match '\[ValidateSet\(.+?\)\]'
            }

            It 'generates a semantically valid parameter' {
                { [ScriptBlock]::Create("[CmdletBinding()]param($result)") } | Should Not Throw
            }
        }

        Context 'With ValidateSet values supplied and -NoValidateSet specified' {
            $result = $testValidateSet | New-ParameterFromResourcePropertyInfo -NoValidateSet
        
            It 'does not generate a [ValidateSet()] attribute when values are supplied' {
                $result | Should Not Match '\[ValidateSet\(.+?\)\]'
            }

            It 'generates a semantically valid parameter' {
                { [ScriptBlock]::Create("[CmdletBinding()]param($result)") } | Should Not Throw
            }
        }

        Context 'Without ValidateSet values and without suppressing ValidateSet' {
            $result = $testNoSet | New-ParameterFromResourcePropertyInfo
        
            It 'leaves out the [ValidateSet()] attribute when Values is empty' {

                $result | Should Not Match '\[ValidateSet\(.*?\)\]'
            }

            It 'generates a semantically valid parameter' {
                { [ScriptBlock]::Create("[CmdletBinding()]param($result)") } | Should Not Throw
            }
        }

        Context 'Without ValidateSet values and suppressing ValidateSet' {
            $result = $testNoSet | New-ParameterFromResourcePropertyInfo -NoValidateSet
            $resultNoSuppress = $testNoSet | New-ParameterFromResourcePropertyInfo
        
            It 'leaves out the [ValidateSet()] attribute when Values is empty' {

                $result | Should Not Match '\[ValidateSet\(.*?\)\]'
            }

            It 'has the same output as if it were called without -NoValidateSet' {
                $result | Should BeExactly $resultNoSuppress
            }

            It 'generates a semantically valid parameter' {
                { [ScriptBlock]::Create("[CmdletBinding()]param($result)") } | Should Not Throw
            }
        }
    }
}