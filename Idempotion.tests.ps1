$modulePath = $PSScriptRoot
$moduleName = $modulePath | Split-Path -Leaf

Describe 'Idempotion Module' -Tags Root {
    Context "Manifest Destinies" {

        $Script:manifest = $null

        It 'has a valid manifest' {
            { 
                $Script:manifest = Test-ModuleManifest -Path "$modulePath\$moduleName.psd1" -ErrorAction Stop 
            } | Should Not Throw
        }

        It 'has the right name' {
            $Script:manifest.Name | Should Be $moduleName
        }

        It 'has a valid version' {
            $Script:manifest.Version -as [version] | Should Not BeNullOrEmpty
        }
    }

    Context "Loading $moduleName" {
        $Error.Clear()
        $module = Import-Module -Name $modulePath -Force -PassThru -ErrorAction SilentlyContinue
        $errorAfter = $Error.Clone()

        It 'loaded successfully' {
            $module | Should Not BeNullOrEmpty
        }

        It 'raised no non-terminating errors' {
            $errorAfter.Count | Should Be 0
        }
    }
}
