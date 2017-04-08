param(
    [System.Management.Automation.PSModuleInfo]
    $Module = (Import-Module -Name ($PSScriptRoot | Split-Path -Parent) -Force -PassThru -ErrorAction Stop)
)

InModuleScope $Module.Name {
    Describe "Get-FilteredResourceProperties" {
        $resource = Get-DscResource -Name File
        $exclusions = @(
             '*:DependsOn'
            ,'F*:Type'
            ,'File:C*'
            ,'Other:Ensure'
            ,'File:DestinationPath'
        )

        Context 'File resource - Keep Mandatory' {

            $result = $resource | Get-FilteredResourceProperties -ExcludeProperty $exclusions -ExcludeMandatory:$false

            It 'should include DestinationPath' {
                $result.Name -contains 'DestinationPath' | Should Be $true
            }

            It 'should include Ensure' {
                $result.Name -contains 'Ensure' | Should Be $true
            }

            It 'should not include DependsOn' {
                $result.Name -contains 'DependsOn' | Should Be $false
            }

            It 'should not include Type' {
                $result.Name -contains 'Type' | Should Be $false
            }

            It 'should not include Checksum' {
                $result.Name -contains 'Checksum' | Should Be $false
            }

            It 'should not include Contents' {
                $result.Name -contains 'Contents' | Should Be $false
            }

            It 'should not include Credential' {
                $result.Name -contains 'Credential' | Should Be $false
            }
        }

        Context 'File resource - Exclude Mandatory' {

            $result = $resource | Get-FilteredResourceProperties -ExcludeProperty $exclusions -ExcludeMandatory

            It 'should not include DestinationPath' {
                $result.Name -contains 'DestinationPath' | Should Be $false
            }

            It 'should include Ensure' {
                $result.Name -contains 'Ensure' | Should Be $true
            }

            It 'should not include DependsOn' {
                $result.Name -contains 'DependsOn' | Should Be $false
            }

            It 'should not include Type' {
                $result.Name -contains 'Type' | Should Be $false
            }

            It 'should not include Checksum' {
                $result.Name -contains 'Checksum' | Should Be $false
            }

            It 'should not include Contents' {
                $result.Name -contains 'Contents' | Should Be $false
            }

            It 'should not include Credential' {
                $result.Name -contains 'Credential' | Should Be $false
            }
        }
    }
}