<#
Definitions

## Variables
[String] $Resource
[String] $Verb
[String] $ParamBlock
[String] $ModuleName
[String] $HardPrefix
[bool]   $ShouldProcess

#>

@{
    Verbs = @{
        Set = @'
function ${Verb}-${HardPrefix}${Resource} {
[CmdletBinding(SupportsShouldProcess = `$${ShouldProcess})]
[OutputType([bool])]
param(
    ${ParamBlock}
)
    ${Snippet_Parameterizerator}
    
    if (`$PSCmdlet.ShouldProcess('${Resource} DSC Resource', '${Verb}')) {

        `$oldVerbosePreference = `$VerbosePreference
        `$VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

        Invoke-DscResource -Name '${Resource}' -ModuleName '${ModuleName}' -Method '${Verb}' -Property `$params -Verbose:`$oldVerbosePreference

        `$VerbosePreference = `$oldVerbosePreference
    }
}
'@
        Test = @'
function ${Verb}-${HardPrefix}${Resource} {
[CmdletBinding()]
[OutputType([bool])]
param(
    ${ParamBlock}
)
    ${Snippet_Parameterizerator}
    
    `$oldVerbosePreference = `$VerbosePreference
    `$VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

    Invoke-DscResource -Name '${Resource}' -ModuleName '${ModuleName}' -Method '${Verb}' -Property `$params -Verbose:`$oldVerbosePreference

    `$VerbosePreference = `$oldVerbosePreference
}
'@

    Get = @'
function ${Verb}-${HardPrefix}${Resource} {
[CmdletBinding()]
[OutputType([HashTable])]
param(
    ${ParamBlock}
)
    ${Snippet_Parameterizerator}
    
    `$oldVerbosePreference = `$VerbosePreference
    `$VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

    Invoke-DscResource -Name '${Resource}' -ModuleName '${ModuleName}' -Method '${Verb}' -Property `$params -Verbose:`$oldVerbosePreference

    `$VerbosePreference = `$oldVerbosePreference
}
'@

    Update = @'
function ${Verb}-${HardPrefix}${Resource} {
[CmdletBinding(SupportsShouldProcess = `$${ShouldProcess})]
[OutputType([bool])]
param(
    ${ParamBlock}
)
    ${Snippet_Parameterizerator}

    if (-not (`$returnValue = Test-${HardPrefix}${Resource} @params)) {
        `$returnValue = Set-${HardPrefix}${Resource} @params
    }

    `$returnValue
}
'@
    } #Verbs

    Snippets = @{
        Parameterizerator = @'
# Originally from: https://www.briantist.com/how-to/splatting-psboundparameters-default-values-optional-parameters/
# Modified in issues #22 and #23: 
# - https://github.com/briantist/Idempotion/issues/22
# - https://github.com/briantist/Idempotion/issues/23
function Get-AllParameters {
[CmdletBinding()]
[OutputType([System.Collections.Hashtable])]
param(
    [Parameter(
        Mandatory
    )]
    [System.Collections.Generic.Dictionary[System.String,System.Object]]
    $BoundParameters ,

    [Parameter(
        Mandatory
    )]
    [System.Management.Automation.InvocationInfo]
    $Context ,

    [Parameter()]
    [Alias('Exclude')]
    [AllowEmptyCollection()]
    [ValidateNotNull()]
    [String[]]
    $ExcludeParameter ,

    [Parameter()]
    [Alias('ExcludeCommon')]
    [Alias('NoCommon')]
    [Switch]
    $ExcludeCommonParameters ,

    [Parameter()]
    [Alias('ExcludeOptionalCommon')]
    [Alias('NoOptionalCommon')]
    [Switch]
    $ExcludeOptionalCommonParameters
)
    $allParams = [System.Collections.Hashtable]::new($BoundParameters)
    foreach ($param in $Context.MyCommand.Parameters.GetEnumerator()) {
        if (-not $allParams.ContainsKey($param.Key) -and ($value = Get-Variable -Name $param.Key -ValueOnly -ErrorAction Ignore)) {
            $allParams.Add($param.Key, $value)
        }
    }
    if ($ExcludeCommonParameters) {
        [System.Management.Automation.PSCmdlet]::CommonParameters.ForEach({ $allParams.Remove($_) })
    }
    if ($ExcludeOptionalCommonParameters) {
        [System.Management.Automation.PSCmdlet]::OptionalCommonParameters.ForEach({ $allParams.Remove($_) })
    }
    if ($ExcludeParameter) {
        $ExcludeParameter.ForEach({ $allParams.Remove($_) })
    }

    $allParams
}
$params = Get-AllParameters -BoundParameters $PSBoundParameters -Context $MyInvocation -ExcludeCommonParameters -ExcludeOptionalCommonParameters
'@
    } # Snippets
}