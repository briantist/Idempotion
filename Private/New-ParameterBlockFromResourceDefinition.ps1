function New-ParameterBlockFromResourceDefinition {
[CmdletBinding(DefaultParameterSetName = 'AsString')]
[OutputType([String], ParameterSetName = 'AsString')]
[OutputType([String[]], ParameterSetName = 'AsArray')]
param(
    [Parameter(
        Mandatory,
        ValueFromPipeline
    )]
    [Microsoft.PowerShell.DesiredStateConfiguration.DscResourceInfo]
    $Resource ,

    [Parameter(
        ParameterSetName = 'AsString'
    )]
    [ValidateNotNull()]
    [AllowEmptyString()]
    $Delimiter = " ,`n`n" ,

    [Parameter(
        Mandatory,
        ParameterSetName = 'AsArray'
    )]
    [Switch]
    $AsArray ,

    [Parameter()]
    [Switch]
    $NoValidateSet ,

    [Parameter()]
    [AllowEmptyCollection()]
    [SupportsWildcards()]
    [ResourcePropertyPattern[]]
    $ExcludeProperty ,

    [Parameter()]
    [Switch]
    $ExcludeMandatory
)

    Process {
        $params = $Resource.Properties |
            Where-Object -FilterScript {
                $thisProp = $_
                -not (
                    $ExcludeProperty.Where({
                        $thisExclusion = $_
                        $thisExclusion.Match($Resource, $thisProp) -and (
                            $ExcludeMandatory -or
                            -not $thisProp.IsMandatory
                        )                 
                    },[System.Management.Automation.WhereOperatorSelectionMode]::First)
                )
            } |
            New-ParameterFromResourcePropertyInfo -NoValidateSet:$NoValidateSet

        if ($AsArray.IsPresent) {
            $params
        } else {
            $params -join $Delimiter
        }
    }
}
