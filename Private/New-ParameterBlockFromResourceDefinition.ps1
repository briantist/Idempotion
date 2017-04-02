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
    $AsArray
)

    Process {
        $params = $Resource.Properties |
            New-ParameterFromResourcePropertyInfo

        if ($AsArray.IsPresent) {
            $params
        } else {
            $params -join $Delimiter
        }
    }
}
