function Get-FilteredDefinitions {
[CmdletBinding()]
[OutputType([HashTable])]
param(
    [Parameter(
        Mandatory
    )]
    [HashTable]
    $CommandDefinition ,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [SupportsWildcards()]
    [String[]]
    $IncludeVerb ,

    [Parameter()]
    [AllowEmptyCollection()]
    [AllowEmptyString()]
    [SupportsWildcards()]
    [String[]]
    $ExcludeVerb 
)
    $Definitions = $CommandDefinition.Clone()
    $Definitions.Verbs = $CommandDefinition.Verbs.Clone()

    $Definitions.Verbs.Keys.Where( {
        $verb = $_
        $remove = $true

        foreach ($inclusion in $IncludeVerb) {
            if ($verb -ilike $inclusion) {
                $remove = $false
                break
            }
        }

        foreach ($exclusion in $ExcludeVerb) {
            if ($verb -ilike $exclusion) {
                $remove = $true
                break
            }
        }

        $remove
    } ).ForEach( {
        $Definitions.Verbs.Remove($_)
    } )

    $Definitions
}
