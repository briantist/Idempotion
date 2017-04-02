$modulePath = $PSScriptRoot
$moduleName = $modulePath | Split-Path -Leaf

Describe 'Idempotion Module' {
    It 'loads successfully' {
        { Import-Module -Name $modulePath -Force -ErrorAction Stop } | Should Not Throw
    }
}
