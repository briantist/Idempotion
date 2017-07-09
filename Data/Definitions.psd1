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
        Invoke-DscResource -Name '${Resource}' -ModuleName '${ModuleName}' -Method '${Verb}' -Property `$params -Verbose:`$VerbosePreference
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
    
    Invoke-DscResource -Name '${Resource}' -ModuleName '${ModuleName}' -Method '${Verb}' -Property `$params -Verbose:`$VerbosePreference
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
    
    Invoke-DscResource -Name '${Resource}' -ModuleName '${ModuleName}' -Method '${Verb}' -Property `$params -Verbose:`$VerbosePreference
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
# From: https://www.briantist.com/how-to/splatting-psboundparameters-default-values-optional-parameters/
$params = @{}
foreach($h in $MyInvocation.MyCommand.Parameters.GetEnumerator()) {
    try {
        $key = $h.Key
        $val = Get-Variable -Name $key -ErrorAction Stop | Select-Object -ExpandProperty Value -ErrorAction Stop
        if (([String]::IsNullOrEmpty($val) -and (!$PSBoundParameters.ContainsKey($key)))) {
            throw "A blank value that wasn't supplied by the user."
        }
        $params[$key] = $val
    } catch {}
}
'@
    } # Snippets
}