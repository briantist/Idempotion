Class ResourcePropertyPattern
{
    [String]$ResourcePattern
    [String]$PropertyPattern

    ResourcePropertyPattern([String]$ResourcePattern, [String]$PropertyPattern)
    {
        $this.ResourcePattern = $ResourcePattern
        $this.PropertyPattern = $PropertyPattern
    }

    ResourcePropertyPattern([String]$Pattern)
    {
        if ($Pattern -cmatch '^[^:]+:[^:]+$') {
            $this.ResourcePattern,$this.PropertyPattern = $Pattern.Split(':')
        } else {
            throw [System.FormatException]"Incorrect format. Should be '<ResourceName>:<PropertyName>' (wildcards supported)"
        }
    }

    [String] ToString()
    {
        return '{0}:{1}' -f $this.ResourcePattern , $this.PropertyPattern
    }

    [bool] MatchResource([String]$ResourceName)
    {
        return $ResourceName -ilike $this.ResourcePattern
    }

    [bool] MatchResource([Microsoft.PowerShell.DesiredStateConfiguration.DscResourceInfo]$Resource)
    {
        return $this.MatchResource($Resource.Name)
    }

    [bool] MatchProperty([String]$PropertyName)
    {
        return $PropertyName -ilike $this.PropertyPattern
    }

    [bool] MatchProperty([Microsoft.PowerShell.DesiredStateConfiguration.DscResourcePropertyInfo]$Property)
    {
        return $this.MatchProperty($Property.Name)
    }

    [bool] Match([String]$ResourceName, [String]$PropertyName)
    {
        return $this.MatchResource($ResourceName) -and $this.MatchProperty($PropertyName)
    }

    [bool] Match([String]$ResourceName, [Microsoft.PowerShell.DesiredStateConfiguration.DscResourcePropertyInfo]$Property)
    {
        return $this.MatchResource($ResourceName) -and $this.MatchProperty($Property)
    }

    [bool] Match([Microsoft.PowerShell.DesiredStateConfiguration.DscResourceInfo]$Resource, [String]$PropertyName)
    {
        return $this.MatchResource($Resource) -and $this.MatchProperty($PropertyName)
    }

    [bool] Match([Microsoft.PowerShell.DesiredStateConfiguration.DscResourceInfo]$Resource, [Microsoft.PowerShell.DesiredStateConfiguration.DscResourcePropertyInfo]$Property)
    {
        return $this.MatchResource($Resource) -and $this.MatchProperty($Property)
    }
}