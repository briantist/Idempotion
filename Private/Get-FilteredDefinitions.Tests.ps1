param(
    [System.Management.Automation.PSModuleInfo]
    $Module = (Import-Module -Name ($PSScriptRoot | Split-Path -Parent) -Force -PassThru -ErrorAction Stop)
)

InModuleScope $Module.Name {
    Describe "Get-FilteredDefinitions" {
        $hashMatch = {param([HashTable]$cur, [HashTable]$orig)
            $curKeys = $cur.Keys | Sort-Object
            $origKeys = $orig.Keys | Sort-Object

            $keysMatch = $valuesMatch = -not (Compare-Object -ReferenceObject $origKeys -DifferenceObject $curKeys)
            if ($keysMatch) {
                foreach ($kvp in $cur.GetEnumerator()) {
                    if ($kvp.Value -ne $orig[$kvp.Key]) {
                        $valuesMatch = $false
                        break
                    }
                }
            }

            $valuesMatch
        }

        $originalSnip = @{
            Snip = '6'
            Snap = '7'
            Get = '8'
        }

        $defs = @{
            Verbs = @{
                Get = '1'
                Set = '2'
                Test = '3'
                Update = '4'
                Snax = '5'
            }

            Snippets = $originalSnip.Clone()
        }

        Context 'No filters' {
            $result = Get-FilteredDefinitions -CommandDefinition $defs

            It 'should return no definitions' {
                $result.Verbs.Count | Should Be 0
            }

            It 'should not touch snippets' {
                & $hashMatch $result.Snippets $originalSnip | Should Be $true
            }

            It 'should not change the original object' {
                $result.Verbs.Count | Should Not Be $defs.Verbs.Count
            }
        }

        Context 'Include All' {
            $result = Get-FilteredDefinitions -CommandDefinition $defs -IncludeVerb '*'

            It 'should not touch snippets' {
                & $hashMatch $result.Snippets $originalSnip | Should Be $true
            }

            It 'should return all definitions' {
                & $hashMatch $result.Verbs $defs.Verbs | Should Be $true
            }
        }

        Context 'Include and Exclude' {
            $matchSet = @{
                Set = $defs.Verbs.Set
                Test = $defs.Verbs.Test
            }

            $result = Get-FilteredDefinitions -CommandDefinition $defs -IncludeVerb '*t' -ExcludeVerb 'Get'

            It 'should not touch snippets' {
                & $hashMatch $result.Snippets $originalSnip | Should Be $true
            }

            It 'should only include Set and Test' {
                & $hashMatch $result.Verbs $matchSet | Should Be $true
            }
        }

        Context 'Include runs first; exclude overrides, not vice-versa' {
            $result = Get-FilteredDefinitions -CommandDefinition $defs -ExcludeVerb '*t' -IncludeVerb 'Set'

            It 'should not touch snippets' {
                & $hashMatch $result.Snippets $originalSnip | Should Be $true
            }

            It 'should return no definitions' {
                $result.Verbs.Count | Should Be 0
            }
        }

        Context 'Multiple includes and excludes' {
            $matchSet = @{
                Set = $defs.Verbs.Set
                Snax = $defs.Verbs.Snax
            }

            $result = Get-FilteredDefinitions -CommandDefinition $defs -IncludeVerb '*t','Snax' -ExcludeVerb '*es*','Get'

            It 'should not touch snippets' {
                & $hashMatch $result.Snippets $originalSnip | Should Be $true
            }

            It 'should only include Set and Snax' {
                & $hashMatch $result.Verbs $matchSet | Should Be $true
            }
        }
    }
}