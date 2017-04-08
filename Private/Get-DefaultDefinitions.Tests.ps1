param(
    [System.Management.Automation.PSModuleInfo]
    $Module = (Import-Module -Name ($PSScriptRoot | Split-Path -Parent) -Force -PassThru -ErrorAction Stop)
)

InModuleScope $Module.Name {
    Describe "Get-DefaultDefinitions" {
        $result = Get-DefaultDefinitions

        It 'returns a hashtable' {
            $result -is [hashtable] | Should Be $true
        }

        It 'contains a Verbs key that is also a hashtable' {
            $result.Verbs -is [hashtable] | Should Be $true
        }

        It 'contains a Snippets key that is also a hashtable' {
            $result.Snippets -is [hashtable] | Should Be $true
        }
    }
}