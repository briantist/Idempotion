$modulePath = $PSScriptRoot | Split-Path -Parent
$moduleName = $modulePath | Split-Path -Leaf

Import-Module -Name $modulePath -Force

Describe "New-FunctionFromDefinition" {
    It "does something useful" -Pending {
        $true | Should Be $false
    }
}
