param(
    [System.Management.Automation.PSModuleInfo]
    $Module = (Import-Module -Name ($PSScriptRoot | Split-Path -Parent) -Force -PassThru -ErrorAction Stop)
)

InModuleScope $Module.Name {
    Describe "Convert-DscResourceToCommand (Module parameter set)"  {
        $resource = Get-DscResource -Name File

        $params = @{
            Resource = $resource
        }

        Context 'Defaults' {
            $result = Convert-DscResourceToCommand @params

            It "returns a module" {
                $result -is [System.Management.Automation.PSModuleInfo] | Should Be $true
            }

            It "imports correctly" {
                { $result | Import-Module -ErrorAction Stop -PassThru | Remove-Module -ErrorAction Ignore } | Should Not Throw
            }

            It "contains included verbs" {
                {
                    $result.ExportedCommands.GetEnumerator().ForEach({
                        # throw if a verb doesn't match the included verbs
                        # Verbs: $mod.ExportedCommands.GetEnumerator()|% Value | % ResolvedCommand|% Verb

                    })
                }
            }
        }

        Context 'Not Complete' {
            It 'is not done yet' {
                $true | Should Be $false
            }
        }
    }
}