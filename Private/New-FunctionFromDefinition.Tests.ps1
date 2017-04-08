param(
    [System.Management.Automation.PSModuleInfo]
    $Module = (Import-Module -Name ($PSScriptRoot | Split-Path -Parent) -Force -PassThru -ErrorAction Stop)
)

InModuleScope $Module.Name {
    Describe "New-FunctionFromDefinition" {

        $defs = Get-DefaultDefinitions
        $dscModule = 'PSDesiredStateConfiguration'
        $resource = Get-DscResource -Module $dscModule | Select-Object -First 1

        $defs.Verbs.GetEnumerator() | ForEach-Object -Process {
            $propBase = @{
                Verb = $_.Key
                CommandDefinition = $_.Value
                ResourceName = $resource.Name
                ParamBlock = '[Parameter()]$Fake'
                DscModule = $dscModule
                Snippets = $defs.Snippets
            }

            $props = @(
                 ($propBase.Clone() + @{ ShouldProcess = $true  ; HardPrefix = '' })
                ,($propBase.Clone() + @{ ShouldProcess = $false ; HardPrefix = '' })
                ,($propBase.Clone() + @{ ShouldProcess = $true  ; HardPrefix = 'MohsPrefix' })
                ,($propBase.Clone() + @{ ShouldProcess = $false ; HardPrefix = 'MohsPrefix' })
            )

            foreach ($propSet in $props) {
                Context "For verb '$($_.Key)' with ShouldProcess '$($propSet.ShouldProcess)' and HardPrefix '$($propSet.HardPrefix)'" {

                    $result = New-Object PSObject -Property $propSet | 
                        New-FunctionFromDefinition

                    It 'returns a string' {
                        $result -is [String] | Should Be $true
                    }

                    It 'generates a semantically valid function' {
                        { [ScriptBlock]::Create($result) } | Should Not Throw
                    }
                }
            }
        }
    }
}