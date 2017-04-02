function Get-FilteredResourceProperties {
[CmdletBinding()]
[OutputType([System.Management.Automation.DscResourcePropertyInfo[]])]
param(
    [Parameter(
        Mandatory,
        ValueFromPipeline
    )]
    [Microsoft.PowerShell.DesiredStateConfiguration.DscResourceInfo]
    $Resource ,

    [Parameter(
        Mandatory
    )]
    [AllowEmptyCollection()]
    [SupportsWildcards()]
    [ResourcePropertyPattern[]]
    $ExcludeProperty ,

    [Parameter()]
    [Switch]
    $ExcludeMandatory
)

    Process {
        $Resource.Properties.Where( {
            $include = $true

            foreach ($exclusion in $ExcludeProperty) {
                if ($exclusion.Match($Resource, $_)) {
                    if (-not $_.IsMandatory -or $ExcludeMandatory.IsPresent) {
                        $include = $false
                        break
                    }
                }
            }
            $include
        })
    }
}
