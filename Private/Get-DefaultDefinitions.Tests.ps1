$modulePath = $PSScriptRoot | Split-Path -Parent
$moduleName = $modulePath | Split-Path -Leaf

Import-Module -Name $modulePath -Force

InModuleScope $moduleName {
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