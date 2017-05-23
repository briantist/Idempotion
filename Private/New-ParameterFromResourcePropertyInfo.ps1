function New-ParameterFromResourcePropertyInfo {
[CmdletBinding()]
[OutputType([String])]
param(
    [Parameter(
        Mandatory,
        ValueFromPipelineByPropertyName
    )]
    [ValidateNotNullOrEmpty()]
    [String]
    $Name ,

    [Parameter(
        Mandatory,
        ValueFromPipelineByPropertyName
    )]
    [ValidateNotNullOrEmpty()]
    [String]
    $PropertyType ,

    [Parameter(
        Mandatory,
        ValueFromPipelineByPropertyName
    )]
    [bool]
    $IsMandatory ,

    [Parameter(
        Mandatory,
        ValueFromPipelineByPropertyName
    )]
    [String[]]
    [AllowEmptyCollection()]
    $Values ,

    [Parameter()]
    [AllowEmptyString()]
    [String]
    $Delimiter = "`n" ,

    [Parameter()]
    [Switch]
    $NoValidateSet
)

    Process {
        $valset = if (-not $NoValidateSet -and $Values.Count) {
            $set = $Values.ForEach( {
                $escaped = $_.Replace("'" , "''")
                "'$escaped'"
            } ) -join ','
            "[ValidateSet($set)]"
        }
        @(
             "[Parameter(Mandatory = `$$IsMandatory)]"
            ,$valset
            ,$PropertyType
            ,"`$$Name"
        ).Where({$_}) -join $Delimiter
    }
}
