param(
    [System.Management.Automation.PSModuleInfo]
    $Module = (Import-Module -Name ($PSScriptRoot | Split-Path -Parent) -Force -PassThru -ErrorAction Stop)
)

Describe "Convert-DscResourceToCommand"  {
    It "does something useful" -Pending {
        $true | Should Be $false
    }
}
