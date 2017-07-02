param(
    [System.Management.Automation.PSModuleInfo]
    $Module = (Import-Module -Name ($PSScriptRoot | Split-Path -Parent) -Force -PassThru -ErrorAction Stop)
)

InModuleScope $Module.Name {
    Describe "Convert-DscResourceToCommand (Module parameter set)"  {
        $resource = Get-DscResource -Name File

        $params = @{
            Resource = $resource
        }

        $defaults = @{}
        $HelpInfo = Get-Help -Name Convert-DscResourceToCommand -Full
        $HelpInfo.parameters.parameter.Where({$_.Type.Name -ne 'SwitchParameter' -and $_.DefaultValue}).ForEach({$defaults[$_.Name] = $_.DefaultValue})

        $commons = [System.Management.Automation.Cmdlet]::CommonParameters + [System.Management.Automation.Cmdlet]::OptionalCommonParameters

        Context 'Defaults' {
            $result = Convert-DscResourceToCommand @params

            It "returns a module" {
                $result -is [System.Management.Automation.PSModuleInfo] | Should Be $true
            }

            It "imports correctly" {
                { $result | Import-Module -ErrorAction Stop -PassThru | Remove-Module -ErrorAction Ignore } | Should Not Throw
            }

            It "contains included verbs" {
                {
                    $result.ExportedCommands.GetEnumerator().ForEach({
                        # throw if a verb matches any of the included verb patterns
                        foreach ($pattern in $defaults['IncludeVerb']) {
                            if ($_.Value.Verb -like $pattern) {
                                throw
                            }
                        }
                    })
                } | Should Throw
            }

            It "doesn't contain excluded verbs" {
                {
                    $result.ExportedCommands.GetEnumerator().ForEach({
                        # throw if a verb matches any of the excluded verb patterns
                        foreach ($pattern in $defaults['ExcludeVerb']) {
                            if ($_.Value.Verb -like $pattern) {
                                throw
                            }
                        }
                    })
                } | Should Not Throw
            }

            It "doesn't include excluded properties" {
                {
                    [ResourcePropertyPattern[]]$patterns = foreach ($ExPropPat in $defaults['ExcludeProperty']) {
                        [ResourcePropertyPattern]::new($ExPropPat)
                    }

                    $result.ExportedCommands.GetEnumerator().ForEach({
                        $res = $_.Value.Noun
                        $_.Value.Parameters.GetEnumerator().Where({
                            $_.Key -notin $commons -and
                            (
                                $_.Value.Attributes.TypeId.Name -notcontains 'ParameterAttribute' -or
                                $_.Value.Attributes.Where({
                                    $_.TypeId.Name -eq 'ParameterAttribute' -and
                                    -not $_.Mandatory 
                                    # ExcludeMandatory is not included in the default parameter set 
                                    # so this whole thing is to not check any mandatory params 
                                    # against the exclusion patterns

                                })
                            )
                        }).ForEach({
                            foreach ($pat in $patterns) {
                                if ($pat.Match($res, $_.Key)) {
                                    throw
                                }
                            }
                        })
                    })
                } | Should Not Throw
            }
        }

        Context 'Not Complete' {
            It 'is not done yet' -Pending {
                $true | Should Be $false
            }
        }
    }
}