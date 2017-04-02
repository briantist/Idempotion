function New-FunctionFromDefinition {
[CmdletBinding()]
[OutputType([String])]
param(
    [Parameter(
        Mandatory,
        ValueFromPipelineByPropertyName
    )]
    [ValidateNotNullOrEmpty()]
    [Alias('Method')]
    [String]
    $Verb ,

    [Parameter(
        Mandatory,
        ValueFromPipelineByPropertyName
    )]
    [ValidateNotNullOrEmpty()]
    [String]
    $CommandDefinition ,
    
    [Parameter(
        Mandatory,
        ValueFromPipelineByPropertyName
    )]
    [ValidateNotNullOrEmpty()]
    [Alias('ResourceName')]
    [String]
    $Resource ,

    [Parameter(
        Mandatory,
        ValueFromPipelineByPropertyName
    )]
    [ValidateNotNullOrEmpty()]
    [Alias('Properties')]
    [Alias('Property')]
    [String]
    $ParamBlock ,

    [Parameter(
        Mandatory,
        ValueFromPipelineByPropertyName
    )]
    [ValidateNotNullOrEmpty()]
    [Alias('DscModule')]
    [String]
    $ModuleName ,

    [Parameter(
        ValueFromPipelineByPropertyName
    )]
    [AllowEmptyString()]
    [String]
    $HardPrefix ,

    [Parameter(
        ValueFromPipelineByPropertyName
    )]
    [bool]
    $ShouldProcess = $false ,

    [Parameter(
        ValueFromPipelineByPropertyName
    )]
    [ValidateNotNullOrEmpty()]
    [HashTable]
    $Snippets
)

    Process {
        if ($Snippets) {
            foreach ($snippet in $Snippets.GetEnumerator()) {
                Set-Variable -Name "Snippet_$($snippet.Key)" -Value $snippet.Value -Force
            }
        }
        $ExecutionContext.InvokeCommand.ExpandString($CommandDefinition)
    }
}
